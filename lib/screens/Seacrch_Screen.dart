import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:propertypall/Database/database.dart';
import 'package:propertypall/widgets/Osm_dailoge.dart';

import '../filter_class/price_range_class.dart';
import '../widgets/animated_searchbox.dart';
import 'detailPage_screen.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  TextEditingController _searchController = TextEditingController();
  PriceRange? _selectedPriceRange;
  String stAddress = "No address found";
  bool bToggle = true;
  final Completer<GoogleMapController> _mapController = Completer();
  static const LatLng _googlePlex = LatLng(31.446, 74.2682);
  LatLng? _currentPosition;
  final List<Marker> _markers = <Marker>[];
  Timer? _debounce;

  Future<void> loadData() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      setState(() {
        stAddress = "${placemarks.first.subThoroughfare}, ${placemarks.first.subLocality}, ${placemarks.first.locality}";
      });

      _markers.clear(); // Clear previous markers
      _markers.add(
        Marker(
          markerId: MarkerId("current_location"),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: stAddress),
          icon: BitmapDescriptor.defaultMarkerWithHue(bToggle ? BitmapDescriptor.hueYellow : BitmapDescriptor.hueOrange),
        ),
      );

      GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _currentPosition!, zoom: 14)));
    } catch (e) {
      print("Error loading data: $e");
      // Handle errors appropriately here
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    loadData();
  }
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel(); // Cancel previous timer if still running

    _debounce = Timer(const Duration(seconds: 3), () {
      // Perform search after 3 seconds of inactivity
      setState(() {
        // No need to manually trigger the search; the StreamBuilder will automatically rebuild
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DataBaseStorage().retrieveAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Map<String, dynamic>> homeData = snapshot.data!;
            String searchText = _searchController.text.toLowerCase();

            List<Map<String, dynamic>> filteredData = homeData.where((item) {
              final lowerCaseName = item['name'].toString().toLowerCase() ??'';
              final lowerCaseLocation =
                  item['location']?.toString().toLowerCase() ?? '';
              final lowerCaseDescription =
                  item['description']?.toString().toLowerCase() ?? '';

              return lowerCaseName.contains(searchText) ||
                  lowerCaseLocation.contains(searchText) ||
                  lowerCaseDescription.contains(searchText);
            }).toList();
            print('Search Text: $searchText');
            print('Filtered Data: ${filteredData.length} items');


            // Apply price range filter
            if (_selectedPriceRange != null) {
              filteredData = filteredData.where((item) {
                final priceString = item['price'];
                final price = (priceString is String)
                    ? double.tryParse(priceString)
                    : (priceString is num ? priceString.toDouble() : null);

                if (price != null) {
                  return price >= _selectedPriceRange!.start &&
                      price <= _selectedPriceRange!.end;
                }
                return false;
              }).toList();
            }

            if (filteredData.isEmpty) {
              return const Center(
                  child: Text('No Property available for the selected criteria.'));
            }
            return Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) => _mapController.complete(controller),
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(target: _googlePlex, zoom: 14),
                  markers: Set<Marker>.of(_markers),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width/2,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                            "📍$stAddress",
                          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
                        ),
                      ),
                      Container(
                        width:50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => _buildFilterSheet(context),
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                ),
                              );
                            },
                            child: Image.asset(
                              'assets/icons/filter.png',
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child:
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5), // Adjust opacity as needed
                          offset: Offset(4, 4), // Horizontal and vertical offset
                          blurRadius: 8, // The blur radius
                          spreadRadius: 5, // The spread radius
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0, left: 0, right: 0),
                      child: SimpleSearchBar(controller: _searchController),
                    ),
                  )

                ),
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // Change to horizontal scroll
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  homeData: homeData[index],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.4,
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.33,
                                      height: MediaQuery.of(context).size.height * 0.15,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: NetworkImage(filteredData[index]['images'][0]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        padding: EdgeInsets.only(right: 3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.favorite_border, color: Colors.red,),
                                          onPressed: () {
                                            // Handle favorite button press
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '\$${filteredData[index]['price'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child:
                                              Text(
                                                filteredData[index]['location'] != null
                                                    ? "🏠︎${filteredData[index]['location']}"
                                                    : '🏠︎ No location',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),

                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          filteredData[index]['description'] ?? 'No description',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: 10,),

              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(color: Colors.deepOrangeAccent.shade100),
          );
        },
      ),
    );
  }
  final priceRanges = [
    PriceRange(start: 0, end: 1000),
    PriceRange(start: 1000, end: 5000),
    PriceRange(start: 5000, end: 10000),
    PriceRange(start: 10000, end: double.infinity),
  ];

  Widget _buildFilterSheet(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by Price Range',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () =>
                      Navigator.pop(context), // Close the bottom sheet
                ),
              ],
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: priceRanges.length,
              itemBuilder: (context, index) {
                final range = priceRanges[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 150),
                  curve: Curves.easeIn,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _selectedPriceRange == range
                        ? Colors.blue[50]
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0.5,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: RadioListTile<PriceRange>(
                    title: Text(
                      '${range.start.toStringAsFixed(0)} - ${range.end.toStringAsFixed(0)}',
                    ),
                    value:
                    range, // Assuming PriceRange holds start and end values
                    groupValue: _selectedPriceRange,
                    onChanged: (value) {
                      setState(() {
                        _selectedPriceRange =
                        value == _selectedPriceRange ? null : value;
                      });
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    activeColor:
                    Colors.blue, // Active color for selected option
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
