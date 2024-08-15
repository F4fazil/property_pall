import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class OsmDailogue {
  final BuildContext context;

  OsmDailogue(this.context);

   showDialog(String title, String des, DialogType temp, Duration sec) {
    AwesomeDialog(
      context: context,
      dialogType: temp,
      borderSide: const BorderSide(
        color: Colors.green,
        width: 2,
      ),
      width: MediaQuery.of(context).size.width,
      buttonsBorderRadius: const BorderRadius.all(
        Radius.circular(2),
      ),
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: false,
      onDismissCallback: (type) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating, // Makes the SnackBar float
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5), // Adds margin on left, right, and bottom
            backgroundColor: Colors.black, // Customize the background color if needed
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            content: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Text(
                des, // Your description text
                style: TextStyle(color: Colors.white), // Customize the text style if needed
              ),
            ),
          ),
        );
      },
      headerAnimationLoop: true,
      animType: AnimType.bottomSlide,
      title: title,
      desc: des,
      showCloseIcon: true,
      autoHide: sec,
      btnCancelOnPress: () {
      },
      btnOkOnPress: () {
      },
    ).show();
  }
}
