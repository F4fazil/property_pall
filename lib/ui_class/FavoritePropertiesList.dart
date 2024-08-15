import 'package:flutter/material.dart';

import '../screens/detailPage_screen.dart';

class FavoritePropertiesList extends StatelessWidget {
  final List<Map<String, dynamic>> filteredData;
  final Function(String) onFavoriteToggle;
  final Future<bool> Function(String) isFavoriteAsync;

  FavoritePropertiesList({
    required this.filteredData,
    required this.onFavoriteToggle,
    required this.isFavoriteAsync,
  });

  @override
  Widget build(BuildContext context) {
    return
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
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            String propertyId = filteredData[index]['propertyId']; // Adjust as needed
            return FutureBuilder<bool>(
              future: isFavoriteAsync(propertyId),
              builder: (context, snapshot) {
                bool isFavorite = snapshot.data ?? false;
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
                                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red,),
                                  onPressed: () {
                                    onFavoriteToggle(propertyId);
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
                                      child: Text(
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
            );
          },
        ),
      ),
    );
  }
}
