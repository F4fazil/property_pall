import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shimmer_loading/shimmer_loading.dart';

import '../Database/Fav.dart';
import '../Database/database.dart';
import '../constant/constant.dart';
import '../demo_data/Data.dart';
import '../filter_class/price_range_class.dart';
import '../widgets/animated_searchbox.dart';
import '../widgets/curvecut_conatiner.dart';
import 'detailPage_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FavoriteManager _favoriteManager = FavoriteManager();
  late List<Map<String, dynamic>> temp;

  Map<int, bool> favoriteStatus = {};
  TextEditingController _searchController = TextEditingController();
  PriceRange? _selectedPriceRange;
  int _selectedIndex = -1;
  final Color selectedColor = Color(0xFF234F68);
  final Color unselectedColor = Colors.blueGrey.shade50;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  DataBaseStorage _dataBaseStorage = DataBaseStorage();
  bool isFav = false;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
    _firebaseMessaging.requestPermission();

    // Get the token for this device
    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      print("Firebase Messaging Token: $token");
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final circularContainerHeight = screenHeight * 0.65;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height:  circularContainerHeight,// 35% of screen height
                width: MediaQuery.of(context).size.width, // Make it circular
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: CustomPaint(
                  painter: CurvedSplitPainter(),
                ),
              ),
            ),

            Positioned(top: circularContainerHeight * 0.1, child: searchField(context)),
            Positioned(
                top: circularContainerHeight * 0.2,
                left: 19,
                child: Text(
                  "Find Your\nDream Home",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                )),
            Positioned(
              top: circularContainerHeight * 0.4,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child:  Column(
                  children: [
                    SizedBox(height: 20,),

                    propertyType(),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (_selectedIndex == -1) {
                            // Show default data when no index is selected
                            return Expanded(
                              child: StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _dataBaseStorage.retrieveAllData(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return buildShimmerLoading();
                                  }

                                  if (snapshot.hasError) {
                                    return Center(
                                        child: Text('Error: ${snapshot.error}'));
                                  }

                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text('No data available'));
                                  }

                                  List<Map<String, dynamic>> homeData = snapshot.data!;
                                  List<Map<String, dynamic>> filteredData = homeData;
                                  List<String> priceRange = homeData
                                      .map((item) => item['price'].toString())
                                      .toList();
                                  return _buildList(context, homeData);
                                },
                              ),
                            );
                          } else {
                            // Show data based on the selected index
                            return
                              Flexible(
                              child: IndexedStack(
                                index: _selectedIndex,
                                children: [
                                  StreamBuilder<List<Map<String, dynamic>>>(
                                    stream: _dataBaseStorage.retrieveDataFromHome(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return buildShimmerLoading();
                                      }

                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text('Error: ${snapshot.error}'));
                                      }

                                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return const Center(
                                            child: Text('No data available'));
                                      }

                                      List<Map<String, dynamic>> homeData =
                                      snapshot.data!;

                                      return _buildList(context, homeData);
                                    },
                                  ),
                                  StreamBuilder<List<Map<String, dynamic>>>(
                                    stream:
                                    _dataBaseStorage.retrieveDataFromApartment(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return buildShimmerLoading();
                                      }

                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text('Error: ${snapshot.error}'));
                                      }

                                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return const Center(
                                            child: Text('No data available'));
                                      }

                                      List<Map<String, dynamic>> homeData =
                                      snapshot.data!;

                                      return _buildList(context, homeData);
                                    },
                                  ),
                                  StreamBuilder<List<Map<String, dynamic>>>(
                                    stream: _dataBaseStorage.retrieveDataFromHotel(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return buildShimmerLoading();
                                      }

                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text('Error: ${snapshot.error}'));
                                      }

                                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return const Center(
                                            child: Text('No data available'));
                                      }

                                      List<Map<String, dynamic>> homeData =
                                      snapshot.data!;

                                      return _buildList(context, homeData);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),



            // propertyType(),

          ],
        ));
  }

  //shimmer loading for fethching data
  Widget buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(15.0),
        itemCount: 2, // Number of placeholder items
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: Container(
              height: 200.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 120.0,
                    height: 150.0,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 20.0,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            height: 15.0,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 100.0,
                            height: 15.0,
                            color: Colors.grey,
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
    );
  }

  Widget searchField(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildFilterSheet(context),
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                );
              },
              child: Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 35,
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 300),
          child: GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 33,
              )),
        ),
      ],
    );
  }

  propertyType() {
    List<String> propertyType = ["Home", "Apartment", "Hotel"];
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.050,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: propertyType.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal:15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isSelected ? selectedColor : unselectedColor,
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),

              ],
            ),
            width: MediaQuery.of(context).size.width / 4,
            height: 50,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = _selectedIndex == index ? -1 : index;
                });
              },
              child: Center(
                child: Text(
                  propertyType[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
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
      duration: Duration(milliseconds: 300),
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

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> homeData) {
    String searchText = _searchController.text.toLowerCase();

    List<Map<String, dynamic>> filteredData = homeData.where((item) {
      final lowerCaseName = item['name'].toString().toLowerCase();
      final lowerCaseLocation =
          item['location']?.toString().toLowerCase() ?? '';
      final lowerCaseDescription =
          item['description']?.toString().toLowerCase() ?? '';

      return lowerCaseName.contains(searchText) ||
          lowerCaseLocation.contains(searchText) ||
          lowerCaseDescription.contains(searchText);
    }).toList();

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

    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Featured Properties",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5, // Adjust container height
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          homeData: filteredData[index],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    margin: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Ensure text starts from the left
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15), // Padding around the image
                          child: Stack(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * 0.4 * 0.6, // Adjust image height
                                width: MediaQuery.of(context).size.width * 0.9, // 90% of container width
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color(0xFFF5F4F9),
                                  image: DecorationImage(
                                    image: NetworkImage(filteredData[index]['images'][0]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Consumer<FavoriteManager>(
                                    builder: (BuildContext context, favourite, Widget? child) {
                                      String propertyId = favourite.generatePropertyId(filteredData[index]);
                                      bool isFavorite = favourite.isFavorite(propertyId);
                                      return IconButton(
                                        icon: Icon(
                                          Icons.favorite,
                                          size: 30,
                                          color: isFavorite ? Colors.red : Colors.white,
                                        ),
                                        onPressed: () async {
                                          await Provider.of<FavoriteManager>(context, listen: false)
                                              .toggleFavorite(filteredData[index]);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 65,
                                  height: 30,
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'For Sale',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0), // Adjust padding for text
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${filteredData[index]['name'] ?? 'House'}",
                                    style: GoogleFonts.openSans(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.bedroom_parent,
                                    size: 20,
                                    color: Colors.teal,
                                  ),
                                  const Icon(
                                    Icons.wash_rounded,
                                    size: 20,
                                    color: Colors.teal,
                                  ),
                                  const Icon(
                                    Icons.money,
                                    size: 20,
                                    color: Colors.teal,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7), // Add some spacing between the rows
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "📍${filteredData[index]['location'] ?? 'No location'}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '5',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '  3',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '\$${filteredData[index]['price'] ?? ''}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
