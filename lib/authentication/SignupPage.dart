import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constant/constant.dart';
import '../widgets/Osm_dailoge.dart';
import '../widgets/login_signup_btn.dart';
import '../widgets/textfield.dart';
import 'LoginScreen.dart';
class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({Key? key, this.onTap}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();



  void signUp() async{
    if (passwordTextController.text != confirmPasswordTextController.text) {
      OsmDailogue(context).showDialog("Error", "Password are not same", DialogType.error, const Duration(seconds: 5));

      return;
    }
    try {
      UserCredential userCredential=await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text);
      makeUserDocument(userCredential);
      OsmDailogue(context).showDialog("Success", "Registered successfully", DialogType.success, const Duration(seconds: 1));

    }

    on FirebaseException catch (e)
    {
      OsmDailogue(context).showDialog("Error", e.code, DialogType.error, const Duration(seconds: 5));

    }
  }
  Future<void> makeUserDocument( UserCredential? userCredential)async {
    if(userCredential!=null && userCredential.user!=null){
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.email).set({
        "name":nameTextController.text,
        "userEmail":userCredential.user!.email,
        "password":passwordTextController.text,
        "uid":userCredential.user!.uid,
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 65,),
            Container(
              height: MediaQuery.of(context).size.height/ 6.5,
              width: MediaQuery.of(context).size.width / 2.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/homeicon.jpg"),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              " Sign up to your account ",
              style: TextStyle(
                  color: Colors.teal, fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10),
              child: SingleChildScrollView(
                  child: MyTextField(
                    controller: nameTextController,
                    hintText: 'Name',
                    icon:  Icon(Icons.mail,color: btnColor),
                  )),
            ),
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10),
              child: SingleChildScrollView(
                  child: MyTextField(
                    controller: emailTextController,
                    hintText: 'Email', icon:  Icon(Icons.mail,color: btnColor),
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10),
              child: SingleChildScrollView(
                  child: MyTextField(
                    controller: passwordTextController,
                    obscureText: true,
                    hintText: 'Password', icon:  Icon(Icons.password,color: btnColor),
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10),
              child: SingleChildScrollView(
                  child: MyTextField(
                    obscureText: true,
                    controller: confirmPasswordTextController,
                    hintText: ' Confirm Password',
                    icon: Icon( Icons.password,color: btnColor),
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10),
              child:
              MyButton(onPressed: (){signUp();}, text: 'Signup',),
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 33,
                ),
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  },
                  child:   Text(
                    'Login Now',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.teal.shade300,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}