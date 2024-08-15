import 'package:flutter/material.dart';

class SimpleSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const SimpleSearchBar({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: TextField(
        controller: controller,
        onChanged: (text) {
          (context as Element).markNeedsBuild();
        },
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search,size: 25,color: Colors.black54,),
          iconColor: Colors.indigo.shade100,
          fillColor: Colors.white,
          filled: true,
          hintText: "Search in Featured Properties",
          border: InputBorder.none,           // Hide underline
          enabledBorder: InputBorder.none,    // Hide underline when enabled
          focusedBorder: InputBorder.none,    // Hide underline when focused
        ),
      ),
    );
  }
}
