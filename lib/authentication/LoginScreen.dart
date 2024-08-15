
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constant/constant.dart';
import '../widgets/Osm_dailoge.dart';
import '../widgets/login_signup_btn.dart';
import '../widgets/textfield.dart';
import 'SignupPage.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  //signIN
  void signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text, password: password.text);
    } on FirebaseException catch (e) {
      OsmDailogue(context).showDialog("Error", e.code, DialogType.error, const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            Container(
              height: MediaQuery.of(context).size.height/ 6.5,
              width: MediaQuery.of(context).size.width / 2.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: const DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: AssetImage("assets/homeicon.jpg"),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),
            const Text(
              "Sign in to you account",
              style: TextStyle(
                  color: Colors.teal, fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: MyTextField(
                  controller: email,
                  icon:  Icon(Icons.mail_sharp,color: btnColor), hintText: 'Enter your Email',
                )
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: MyTextField(
                  obscureText: true,
                  controller: password,
                  icon:  Icon(Icons.password,color:btnColor), hintText: 'Password',
                )),
            const SizedBox(
              height: 50,
            ),
             MyButton(onPressed: ()async{
              await OsmDailogue(context).showDialog("Success", "Logging", DialogType.success, const Duration(seconds: 1));
               signIn();
               }, text: 'Login',),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 40,
                ),
                const Text(
                  'Does not have an account?',
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
                            builder: (context) => const RegisterPage()));
                  },
                  child:   Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: 17,
                        color:Colors.teal.shade300,
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
