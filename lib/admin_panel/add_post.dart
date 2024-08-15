import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

import '../Database/database.dart';
import '../constant/constant.dart';
import '../widgets/ExploreTextField.dart';
import '../widgets/Osm_dailoge.dart';
import '../widgets/login_signup_btn.dart';
import '../widgets/textfield.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  final Owner_name = TextEditingController();
  final property_type = TextEditingController();
  final price = TextEditingController();
  final description = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<String> _type = ["Home", "Villa", "Hotel", "Apartment"];
  List<File> _imageFiles = [];
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'What Do you want to Sale?',
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: buildui(),
    );
  }

  Widget buildui() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Center(
                child: Stack(children: [
                  GestureDetector(
                    onTap: () {
                      if (_controller != null) {
                        _controller!.forward().then((value) => _controller!.reverse());
                      }
                      _pickImages();
                    },
                    child: Center(
                      child: ScaleTransition(
                        scale: _controller != null
                            ? Tween(begin: 1.0, end: 1.2).animate(
                          CurvedAnimation(
                            parent: _controller!,
                            curve: Curves.easeInOut,
                          ),
                        )
                            : AlwaysStoppedAnimation(1.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 6,
                          width: MediaQuery.of(context).size.width / 2.5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child:  Icon(
                            Icons.add_a_photo_outlined,
                            size: 50,
                            color: Colors.indigo.shade100
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 50),
              _buildImageGrid(),
              const SizedBox(height: 50),
              const Row(
                children: [
                  SizedBox(width: 20),
                  Text("Property Type"),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: ExploreTextField(
                  controller: property_type,
                  suggestions: _type,
                  hinttext: "Select Property type",
                  svgIconPath: 'assets/1.jpg',
                ),
              ),
              const Row(
                children: [
                  SizedBox(width: 20),
                  Text("Property Details"),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyTextField(
                  controller: Owner_name,
                  icon: const Icon(Icons.location_on_rounded),
                  hintText: 'Location',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyTextField(
                  controller: price,
                  icon: const Icon(Icons.person),
                  hintText: 'Price e.g 100000',
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                child: TextField(
                  controller: description,
                  maxLines: null,
                  minLines: 5,
                  decoration: InputDecoration(
                      iconColor: textfield_border_color,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        BorderSide(color: Colors.indigo.shade50, width: 0.7),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.indigo.shade100, width: 1),
                      ),
                      fillColor: Colors.white.withOpacity(0.7),
                      filled: true,
                      hintText: "Mention Details"),
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 30),
                child: MyButton(
                  onPressed: () async {
                    if (user != null) {
                      uploadImages(user!.uid.toString());
                      OsmDailogue(context).showDialog("Success", "Posted", DialogType.success, const Duration(seconds: 1));
                      print("upload from here.");
                    } else {
                      print("User is not logged in.");
                    }
                  },
                  text: 'Proceed',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageGrid() {
    return _imageFiles.isNotEmpty
        ? GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _imageFiles.length,
      itemBuilder: (context, index) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onLongPress: () {
              setState(() {
                _imageFiles.removeAt(index);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: FileImage(_imageFiles[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    )
        : Container();
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _imageFiles.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  void uploadImages(String userid) async {
    List<String> downloadUrls = [];
    for (File image in _imageFiles) {
      var id = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
      FirebaseStorage.instance.ref().child("pic").child(id);
      UploadTask upload = firebaseStorageRef.putFile(image);
      var downloadurl = await (await upload).ref.getDownloadURL();
      downloadUrls.add(downloadurl);
    }
    if (downloadUrls.isNotEmpty &&
        Owner_name.text.isNotEmpty &&
        price.text.isNotEmpty &&
        description.text.isNotEmpty) {
      Map<String, dynamic> addItem = {
        "images": downloadUrls,
        "location": Owner_name.text,
        "price": price.text,
        "description": description.text,
        "uid": userid,
      };

      if (property_type.text == "Home") {
        await DataBaseStorage().add_data_to_home(addItem);
      } else if (property_type.text == "Apartment") {
        print("Saved to apartment");
        await DataBaseStorage().add_data_to_apartment(addItem);
      } else if (property_type.text == "Hotel") {
        print("Saved to hotel");
        await DataBaseStorage().add_data_to_hotel(addItem);
      } else if (property_type.text == "Villa") {
        print("Saved to villa");
        await DataBaseStorage().add_data_to_villa(addItem);
      }
    }
  }
}
