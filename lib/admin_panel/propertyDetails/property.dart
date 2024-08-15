import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import"package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

import '../../Database/database.dart';
import '../../widgets/textfield.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user = FirebaseAuth.instance.currentUser;
  final Owner_name = TextEditingController();
  final price = TextEditingController();
  final description = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body:
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Property  Details",
                  ),
                ],
              ),
              MyTextField(controller: Owner_name, icon: Icon(Icons.person), hintText: 'Your name',),
              MyTextField(controller: price, icon: Icon(Icons.person), hintText: 'Your Demand',),
              MyTextField(controller: description, icon: const Icon(Icons.person), hintText: 'PLots Details',),

              SizedBox(
                height: 50,
              ),
              Center(
                child: Stack(children: [
                  _imageFile == null
                      ? GestureDetector(
                    onTap: () {
                      _pickImage(ImageSource.gallery);
                    },
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height / 6,
                        width: MediaQuery.of(context).size.width / 2.5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          size: 50,
                          color: Colors.cyan,
                        ),
                      ),
                    ),
                  )
                      : Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 6,
                      width: MediaQuery.of(context).size.width / 2.5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _imageFile!,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 15,
              ),

              Padding(
                padding: EdgeInsets.only(top: 70),
                child: ElevatedButton(
                  onPressed: () {
                    uploadImage(user!.uid.toString());
                  },
                  child: Text('Continue'),
                ),
              ),
            ],
          ),
        ));
  }
  uploadImage( String userid) async {
    var id = randomAlphaNumeric(10);
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child("pic").child(id);
    UploadTask upload = firebaseStorageRef.putFile(_imageFile!);
    var downloadurl = await (await upload).ref.getDownloadURL();
    if(downloadurl.isNotEmpty && Owner_name.text.isNotEmpty && price.text.isNotEmpty &&description.text.isNotEmpty){
      Map<String, dynamic> addItem = {
        "image": downloadurl,
        "name": Owner_name.text,
        "price": price.text,
        "description": description.text,
        "uid":userid,
      };
      navigateToNeXTpAGE();
      print("Saved");
     // await DataBaseStorage().addData_name_or_age(addItem);
    }
    else{
      print("Fill the above blanks");
    }

  }
  navigateToNeXTpAGE(){
    //Navigator.push(context, MaterialPageRoute(builder: (context)=>const Gender()));
  }
}