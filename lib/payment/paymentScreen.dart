// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_credit_card/flutter_credit_card.dart';
// import 'package:flutter_stripe/flutter_stripe.dart'; // Import Stripe library
//
// class MySample extends StatefulWidget {
//   const MySample({super.key});
//
//   @override
//   State<StatefulWidget> createState() => MySampleState();
// }
//
// class MySampleState extends State<MySample> {
//   bool isLightTheme = false;
//   String cardNumber = '';
//   String expiryDate = '';
//   String cardHolderName = '';
//   String cvvCode = '';
//   bool isCvvFocused = false;
//   bool useGlassMorphism = false;
//   bool useBackgroundImage = false;
//   bool useFloatingAnimation = true;
//   final OutlineInputBorder border = OutlineInputBorder(
//     borderSide: BorderSide(
//       color: Colors.grey.withOpacity(0.7),
//       width: 2.0,
//     ),
//   );
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   // Add your Stripe publishable key (replace with yours)
//   final String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       isLightTheme ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
//     );
//     return MaterialApp(
//       title: 'Credit Card View',
//       debugShowCheckedModeBanner: false,
//       themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
//       theme: ThemeData(
//         textTheme: const TextTheme(
//           // Text style for text fields' input.
//           titleMedium: TextStyle(color: Colors.black, fontSize: 18),
//         ),
//         colorScheme: ColorScheme.fromSeed(
//           brightness: Brightness.light,
//           seedColor: Colors.white,
//           background: Colors.black,
//           // Defines colors like cursor color of the text fields.
//           primary: Colors.black,
//         ),
//         // Decoration theme for the text fields.
//         inputDecorationTheme: InputDecorationTheme(
//           hintStyle: const TextStyle(color: Colors.black),
//           labelStyle: const TextStyle(color: Colors.black),
//           focusedBorder: border,
//           enabledBorder: border,
//         ),
//       ),
//       darkTheme: ThemeData(
//         textTheme: const TextTheme(
//           // Text style for text fields' input.
//           titleMedium: TextStyle(color: Colors.white, fontSize: 18),
//         ),
//         colorScheme: ColorScheme.fromSeed(
//           brightness: Brightness.dark,
//           seedColor: Colors.black,
//           background: Colors.white,
//           // Defines colors like cursor color of the text fields.
//           primary: Colors.white,
//         ),
//         // Decoration theme for the text fields.
//         inputDecorationTheme: InputDecorationTheme(
//           hintStyle: const TextStyle(color: Colors.white),
//           labelStyle: const TextStyle(color: Colors.white),
//           focusedBorder: border,
//           enabledBorder: border,
//         ),
//       ),
//       home: Scaffold(
//         resizeToAvoidBottomInset: false,
//         body: Builder(
//           builder: (BuildContext context) {
//             return Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: ExactAssetImage(
//                     isLightTheme ? '' : '',
//                   ),
//                   fit: BoxFit.fill,
//                 ),
//               ),
//               child: SafeArea(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: <Widget>[
//                     IconButton(
//                       onPressed: () => setState(() {
//                         isLightTheme = !isLightTheme;
//                       }),
//                       icon: Icon(
//                         isLightTheme ? Icons.light_mode : Icons.dark_mode,
//                       ),
//                     ),
//                     CreditCardWidget(
//                       enableFloatingCard: useFloatingAnimation,
//                       glassmorphismConfig: _getGlassmorphismConfig(),
//                       cardNumber: cardNumber,
//                       expiryDate: expiryDate,
//                       cardHolderName: cardHolderName,
//                       cvvCode: cvvCode,
//                       bankName: 'Bank',
//                       frontCardBorder: useGlassMorphism
//                           ? null
//                           : Border.all(color: Colors.grey),
//                       backCardBorder: useGlassMorphism
//                           ? null
//                           : Border.all(color: Colors.grey),
//                       showBackView: isCvvFocused,
//                       obscureCardNumber: true,
//                       obscureCardCvv: true,
//                       isHolderNameVisible: true,
//                       cardBgColor: isLightTheme
//                           ? Colors.blue.shade200
//                           : Colors.teal,
//                       backgroundImage:
//                       useBackgroundImage ? 'assets/bg_light.png' : null,
//                       isSwipeGestureEnabled: true,
//                       onCreditCardWidgetChange:
//                           (CreditCardBrand creditCardBrand) {},
//                       customCardTypeIcons: <CustomCardTypeIcon>[
//                         CustomCardTypeIcon(
//                           cardType: CardType.visa,
//                           cardImage: Image.asset(
//                             'assets/icons/my_chip.png',
//                             height: 48,
//                             width: 48,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Column(
//                           children: <Widget>[
//                             CreditCardForm(
//                               formKey: formKey,
//                               obscureCvv: true,
//                               obscureNumber: true,
//                               cardNumber: cardNumber,
//                               cvvCode: cvvCode,
//                               isHolderNameVisible: true,
//                               isCardNumberVisible: true,
//                               isExpiryDateVisible: true,
//                               cardHolderName: cardHolderName,
//                               expiryDate: expiryDate,
//                               inputConfiguration: const InputConfiguration(
//                                 cardNumberDecoration: InputDecoration(
//                                   labelText: 'Number',
//                                   hintText: 'XXXX XXXX XXXX XXXX',
//                                 ),
//                                 expiryDateDecoration: InputDecoration(
//                                   labelText: 'Expired Date',
//                                   hintText: 'XX/XX',
//                                 ),
//                                 cvvCodeDecoration: InputDecoration(
//                                   labelText: 'CVV',
//                                   hintText: 'XXX',
//                                 ),
//                                 cardHolderDecoration: InputDecoration(
//                                   labelText: 'Card Holder',
//                                 ),
//                               ),
//                               onCreditCardModelChange: onCreditCardModelChange,
//                             ),
//                             const SizedBox(height: 20),
//                             GestureDetector(
//                               onTap: _onValidate,
//                               child: Container(
//                                 margin: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 8,
//                                 ),
//                                 decoration: const BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: <Color>[
//                                       Color(0XFFB58D67),
//                                       Color(0XFFB58D67),
//                                       Color(0XFFF9EED2),
//                                       Color(0XFFEFEFED),
//                                       Color(0XFFF9EED2),
//                                       Color(0XFFB58D67),
//                                     ],
//                                     begin: Alignment(-1, -4),
//                                     end: Alignment(1, 4),
//                                   ),
//                                   borderRadius: BorderRadius.all(
//                                     Radius.circular(8),
//                                   ),
//                                 ),
//                                 padding:
//                                 const EdgeInsets.symmetric(vertical: 15),
//                                 alignment: Alignment.center,
//                                 child: const Text(
//                                   'Validate',
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontFamily: 'halter',
//                                     fontSize: 14,
//                                     package: 'flutter_credit_card',
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   void _onValidate() async {
//     if (formKey.currentState?.validate() ?? false) {
//       try {
//         // Initialize Stripe with your publishable key
//         Stripe.publishableKey = stripePublishableKey;
//
//         // Create a payment method using Stripe
//         final paymentMethod = await Stripe.instance.createPaymentMethod(
//           params: PaymentMethodParams.card(
//            paymentMethodData:  PaymentMethodData(
//              mandateData: MandateData()
//             ),
//           ),
//         );
//
//         // Prepare data with the payment method ID
//         final cardDetails = {
//           'paymentMethodId': paymentMethod.id,
//           'cardHolderName': cardHolderName,
//           'createdAt': FieldValue.serverTimestamp(),
//         };
//
//         // Store the payment method ID in Firebase Firestore
//         User? _user = FirebaseAuth.instance.currentUser;
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(_user!.email.toString())
//             .collection("card_details")
//             .add(cardDetails);
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Card details stored successfully!')),
//         );
//
//         // You can perform any additional payment actions here, like initiating a payment
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error storing card details: $e')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invalid input!')),
//       );
//     }
//   }
//
//   void onCreditCardModelChange(CreditCardModel creditCardModel) {
//     setState(() {
//       cardNumber = creditCardModel.cardNumber;
//       expiryDate = creditCardModel.expiryDate;
//       cardHolderName = creditCardModel.cardHolderName;
//       cvvCode = creditCardModel.cvvCode;
//       isCvvFocused = creditCardModel.isCvvFocused;
//     });
//   }
//
//   Glassmorphism? _getGlassmorphismConfig() {
//     if (!useGlassMorphism) {
//       return null;
//     }
//
//     final LinearGradient gradient = LinearGradient(
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//       colors: <Color>[Colors.grey.withAlpha(50), Colors.grey.withAlpha(50)],
//       stops: const <double>[0.3, 0],
//     );
//
//     return isLightTheme
//         ? Glassmorphism(blurX: 8.0, blurY: 16.0, gradient: gradient)
//         : Glassmorphism.defaultConfig();
//   }
// }
