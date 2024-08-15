import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../chat_service/chat_screen.dart';
import '../constant/constant.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "💬Messages",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22,color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildUserList(),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading users."));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blueAccent,
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot userData = snapshot.data!.docs[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: userListItem(userData),
            );
          },
        );
      },
    );
  }

  Widget userListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String? name = data['name'] as String?;
    String? userEmail = data["userEmail"] as String?;

    if (firebaseAuth.currentUser?.email != userEmail) {
      return ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userEmail!,
                receiverId: data["uid"],
                username: name.toString(),
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Text(
          "🙋🏻‍♂️"
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 5.0, left: 10),
          child: Text(
            name ?? "Unknown",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(left: 11.0),
          child: Text(
            "Tap to view messages",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return Container();
  }
}
