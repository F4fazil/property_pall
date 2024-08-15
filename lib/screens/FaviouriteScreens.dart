import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Database/Fav.dart';// Assuming FavoriteManager is in this path
import 'detailPage_screen.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  FavoriteManager _manager=FavoriteManager();
  @override
  void initState() {
    super.initState();
    // Fetch favorite properties when the page is initialized
    Provider.of<FavoriteManager>(context, listen: false).fetchFavoriteProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          title: Text('Favorites'),
         actions: [
           IconButton(
             onPressed: () async {
               await Provider.of<FavoriteManager>(context, listen: false).deleteAllFavorites();
               setState(() {});
             },
             icon: Icon(Icons.delete, size: 33),
           )
         ],
      ),
      body: Consumer<FavoriteManager>(
        builder: (context, favoriteManager, child) {
          if (favoriteManager.favoriteProperties.isEmpty) {
            return Center(child: Text('No favorites available'));
          }

          final favoriteProperties = favoriteManager.favoriteProperties;

          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: favoriteProperties.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> propertyData = favoriteProperties[index]['propertyData'];

              // Safely cast the dynamic list to List<String>?
              List<String>? images = (propertyData['images'] as List<dynamic>?)
                  ?.map((item) => item as String)
                  .toList();
              String imageUrl = (images != null && images.isNotEmpty)
                  ? images[0]
                  : 'https://via.placeholder.com/150'; // Placeholder image URL

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        homeData: propertyData,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.4,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54.withOpacity(0.1),
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
                                image: NetworkImage(imageUrl),
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
                                icon: Icon(Icons.favorite, color: Colors.red),
                                onPressed: () async {
                                  await favoriteManager.toggleFavorite(propertyData);
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
                                '\$${propertyData['price'] ?? ''}',
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
                                    child: Text(
                                      propertyData['name'] != null
                                          ? "🏠︎${propertyData['name']}"
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
                                propertyData['description'] ?? 'No description',
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
          );
        },
      ),
    );
  }
}
