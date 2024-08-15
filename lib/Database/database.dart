import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataBaseStorage {
  //adding item to Firebase
  User? user = FirebaseAuth.instance.currentUser;

  //adding data into  home currentuser
  Future<void> add_data_to_home(Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.email).collection("propertyDetails").doc("home").collection("_").add(profileData);
      print(user.toString());
      print("Data added to Firestore successfully! ");
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }
  Future<void> add_data_to_apartment(Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.email).collection("propertyDetails").doc("apartment")..collection("_").add(profileData);
      print(user.toString());
      print("Data added to Firestore successfully! ");
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }
  Future<void> add_data_to_hotel(Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.email).collection("propertyDetails").doc("hotel").collection("_").add(profileData);
      print(user.toString());
      print("Data added to Firestore successfully! ");
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }
  Future<void> add_data_to_villa(Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.email).collection("propertyDetails").doc("villa").collection("_").add(profileData);
      print(user.toString());
      print("Data added to Firestore successfully! ");
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }
  //fav
  Future<List<Map<String, dynamic>>> getFav() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.email)
          .collection("propertyDetails").doc("favourite").collection("_")
          .get();

      List<Map<String, dynamic>> dataList = [];

      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
          Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
          dataList.add(data);
        }

        return dataList;
      } else {
        print('No documents found in the collection');
        return [];
      }
    } catch (e) {
      print('Error retrieving data from Firestore: $e');
      return [];
    }
  }






  Stream<List<Map<String, dynamic>>> retrieveDataFromHome() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserEmail = user.email!;

    var userSnapshot = await FirebaseFirestore.instance.collection("users").get();
    var filteredUsers = userSnapshot.docs.where((doc) => doc.id != currentUserEmail);

    List<Map<String, dynamic>> combinedData = [];

    for (var userDoc in filteredUsers) {
      var propertySnapshot = await userDoc.reference
          .collection("propertyDetails")
          .doc("home")
          .collection("_")
          .get();

      for (var propertyDoc in propertySnapshot.docs) {
        combinedData.add(propertyDoc.data());
      }
    }

    yield combinedData;
  }
  Stream<List<Map<String, dynamic>>> retrieveDataFromApartment() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserEmail = user.email!;

    // Fetch all users except the current user
    var userSnapshot = await FirebaseFirestore.instance.collection("users").get();
    var filteredUsers = userSnapshot.docs.where((doc) => doc.id != currentUserEmail);

    List<Map<String, dynamic>> combinedData = [];

    // For each filtered user, fetch their home property details
    for (var userDoc in filteredUsers) {
      var propertySnapshot = await userDoc.reference
          .collection("propertyDetails")
          .doc("apartment")
          .collection("_")
          .get();

      for (var propertyDoc in propertySnapshot.docs) {
        combinedData.add(propertyDoc.data() as Map<String, dynamic>);
      }
    }

    yield combinedData;
  }
  Stream<List<Map<String, dynamic>>> retrieveDataFromHotel() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserEmail = user.email!;

    // Fetch all users except the current user
    var userSnapshot = await FirebaseFirestore.instance.collection("users").get();
    var filteredUsers = userSnapshot.docs.where((doc) => doc.id != currentUserEmail);

    List<Map<String, dynamic>> combinedData = [];

    // For each filtered user, fetch their home property details
    for (var userDoc in filteredUsers) {
      var propertySnapshot = await userDoc.reference
          .collection("propertyDetails")
          .doc("hotel")
          .collection("_")
          .get();

      for (var propertyDoc in propertySnapshot.docs) {
        combinedData.add(propertyDoc.data() as Map<String, dynamic>);
      }
    }

    yield combinedData;
  }
  Stream<List<Map<String, dynamic>>> retrieveDataFromVilla() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserEmail = user.email!;

    // Fetch all users except the current user
    var userSnapshot = await FirebaseFirestore.instance.collection("users").get();
    var filteredUsers = userSnapshot.docs.where((doc) => doc.id != currentUserEmail);

    List<Map<String, dynamic>> combinedData = [];

    // For each filtered user, fetch their home property details
    for (var userDoc in filteredUsers) {
      var propertySnapshot = await userDoc.reference
          .collection("propertyDetails")
          .doc("villa")
          .collection("_")
          .get();

      for (var propertyDoc in propertySnapshot.docs) {
        combinedData.add(propertyDoc.data() as Map<String, dynamic>);
      }
    }

    yield combinedData;
  }




  // Helper function to merge streams
  Stream<List<Map<String, dynamic>>> combineStreams(List<Stream<List<Map<String, dynamic>>>> streams) {
    return StreamZip(streams).map((listOfLists) {
      List<Map<String, dynamic>> combinedData = [];
      for (var list in listOfLists) {
        combinedData.addAll(list);
      }
      return combinedData;
    });
  }

// Function to get all property data
  Stream<List<Map<String, dynamic>>> retrieveAllData() {
    // Define the list of streams
    List<Stream<List<Map<String, dynamic>>>> streams = [
      retrieveDataFromHome(),
      retrieveDataFromApartment(),
      retrieveDataFromHotel(),
      retrieveDataFromVilla(),
    ];

    // Combine the streams into a single stream
    return combineStreams(streams);
  }























  //fetching data from name_or_age of currentuser
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getData_home() async {
    if (user == null || user?.email == null) {
      print('User information is missing.');
      return null; // Return null if user information is missing
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("users")
        .doc(user?.email).collection('propertyDetails').doc("home").collection("_").get();


    if (snapshot.docChanges.isNotEmpty) {
      return snapshot.docs; // Extract data from DocumentSnapshot
    } else {
      print('Document does not exist for the current user.');
      return null; // Return null if document does not exist
    }
  }

  Future<void> addData_interest(List<String> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection("usersProfile")
          .doc("interest")
          .update({'interests': profileData});

      print('Data added to Firestore successfully!');
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsersData() async {
    try {
      // Fetch all users except the current user
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection("users").get();

      // Filter out the current user's data
      List<Map<String, dynamic>> allUsersData = querySnapshot.docs
          .where((doc) =>
              doc.id !=
              user?.email) // Assuming email is used as a unique identifier
          .map((doc) => doc.data())
          .toList();

      return allUsersData;
    } catch (e) {
      print('Error retrieving data from Firestore: $e');
      return [];
    }
  }




  void deleteFav(Map<String, dynamic> temp) {
    try {
      String documentId = temp['documentId']; // Change this to your actual key
      FirebaseFirestore.instance
          .collection("users")
          .doc(user?.email)
          .collection("profileData")
          .doc()
          .delete();
      print("Data removed from Firestore successfully! ");
    } catch (e) {
      print('Error removing data from Firestore: $e');
    }
  }

  void signout() {
    FirebaseAuth.instance.signOut();
  }

  Future<List<String>> getUsersWithMessages(String currentUserUid) async {
    List<String> usersWithMessages = [];

    // Query messages where the current user is either the sender or receiver
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc()
        .collection("messages")
        .where('senderid', isEqualTo: currentUserUid)
        .get();

    // Add receiver IDs to the list
    querySnapshot.docs.forEach((doc) {
      String receiverId = doc['receiverid'];
      if (!usersWithMessages.contains(receiverId)) {
        usersWithMessages.add(receiverId);
      }
    });

    // Query messages where the current user is the receiver
    querySnapshot = await FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc()
        .collection('messages')
        .where('receiverid', isEqualTo: currentUserUid)
        .get();

    // Add sender IDs to the list
    querySnapshot.docs.forEach((doc) {
      String senderId = doc['senderid'];
      if (!usersWithMessages.contains(senderId)) {
        usersWithMessages.add(senderId);
      }
    });

    return usersWithMessages;
  }
}
