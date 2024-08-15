import 'package:flutter/material.dart';

import '../constant/constant.dart';

class MyButton extends StatefulWidget {
  String text;
  final Function()? onPressed;

   MyButton({Key? key,required this.text, required this.onPressed}) : super(key: key);

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.06,
      child: ElevatedButton(
        onPressed:widget.onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color:  Colors.indigo.shade50),
          ),
          backgroundColor: Colors.teal.shade300,
        ),
        child:  Text(
          widget.text,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
