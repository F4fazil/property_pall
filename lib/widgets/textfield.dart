import 'package:flutter/material.dart';

import '../constant/constant.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final Icon icon;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.icon,
    required this.hintText,
    this.obscureText = false,
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0,right: 8),
      child:
      TextField(
        controller: widget.controller,
        obscureText: widget.obscureText ? _isObscured : false,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: widget.icon,
          iconColor: Colors.indigo.shade100,
          suffixIcon: widget.obscureText
              ? IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility : Icons.visibility_off,
             color: Colors.teal.shade300,
            ),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
          )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade300,width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color:Colors.teal.shade300, width: 1.4),
          ),
          fillColor: Colors.white.withOpacity(0.7),
          filled: true,
          hintText: widget.hintText,
        ),
      ),
    );
  }
}
