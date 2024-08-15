import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavoriteManager extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get user => _auth.currentUser;

  // Local cache of favorite IDs
  Set<String> _favorites = {};

  // List to store all favorite properties
  List<Map<String, dynamic>> _favoriteProperties = [];

  // Getter for favorite properties
  List<Map<String, dynamic>> get favoriteProperties => _favoriteProperties;

  FavoriteManager() {
    _initializeFavorites();
  }

  Future<void> _initializeFavorites() async {
    if (user == null) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.email)
          .collection("propertyDetails")
          .doc("favourite")
          .collection("_")
          .get();

      _favorites = querySnapshot.docs.map((doc) => doc.id).toSet();
      _favoriteProperties = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error initializing favorites: $e');
      // Handle error, e.g., show a user-friendly message
    }
  }

  bool isFavorite(String propertyId) {
    return _favorites.contains(propertyId);
  }
  Future<void> deleteAllFavorites() async {
    if (user == null) throw Exception('User not logged in');

    try {
      final collectionRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user!.email)
          .collection("propertyDetails")
          .doc("favourite")
          .collection("_");

      // Get all documents in the collection and delete them
      QuerySnapshot querySnapshot = await collectionRef.get();
      for (DocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Clear local cache
      _favorites.clear();
      _favoriteProperties.clear();

      notifyListeners();
    } catch (e) {
      print('Error deleting all favorites: $e');
      // Handle error, e.g., show a user-friendly message
    }
  }

  Future<void> toggleFavorite(Map<String, dynamic> propertyData) async {
    if (user == null) throw Exception('User not logged in');

    String propertyId = generatePropertyId(propertyData);

    try {
      if (_favorites.contains(propertyId)) {
        _favorites.remove(propertyId);
        _favoriteProperties.removeWhere((prop) => generatePropertyId(prop['propertyData']) == propertyId);
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.email)
            .collection("propertyDetails")
            .doc("favourite")
            .collection("_")
            .doc(propertyId)
            .delete();
      } else {
        _favorites.add(propertyId);
        _favoriteProperties.add({'propertyData': propertyData});
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.email)
            .collection("propertyDetails")
            .doc("favourite")
            .collection("_")
            .doc(propertyId)
            .set({'propertyData': propertyData});
      }
      notifyListeners();
    } catch (e) {
      print('Error toggling favorite: $e');
      // Handle error, e.g., show a user-friendly message
    }
  }

  Future<void> removeFavorite(String propertyId) async {
    if (user == null) throw Exception('User not logged in');

    try {
      if (_favorites.contains(propertyId)) {
        _favorites.remove(propertyId);
        _favoriteProperties.removeWhere((prop) => generatePropertyId(prop['propertyData']) == propertyId);
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.email)
            .collection("propertyDetails")
            .doc("favourite")
            .collection("_")
            .doc(propertyId)
            .delete();
        notifyListeners();
      }
    } catch (e) {
      print('Error removing favorite: $e');
      // Handle error, e.g., show a user-friendly message
    }
  }

  String generatePropertyId(Map<String, dynamic> propertyData) {
    // Consider using a more robust ID generation mechanism, e.g., UUID or Firebase's generateId
    return propertyData['id'] ?? propertyData.toString().hashCode.toString();
  }

  Future<void> fetchFavoriteProperties() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.email)
          .collection("propertyDetails")
          .doc("favourite")
          .collection("_")
          .get();

      _favoriteProperties = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Update the _favorites set with the new IDs
      _favorites = _favoriteProperties
          .map((prop) => generatePropertyId(prop['propertyData']))
          .toSet();
      notifyListeners();
    } catch (e) {
      print('Error fetching favorite properties: $e');
      // Handle error, e.g., show a user-friendly message
    }
  }
}
