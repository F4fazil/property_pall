import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripePaymentService {
  Map<String, dynamic>? paymentIntent;

  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> _body = {
        "amount": amount,
        "currency": currency
      };
      http.Response response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: _body,
          headers: {
            "Authorization": "Bearer sk_test_51OFewFLG8GWemPagYO4htDImdZoSWM7cxzrHxfdNdiFMY4LCzJjbpBPbveFqSofKivyshM8E8DycDJKWgV8omQNK00lOdjXkSk",
            "Content-Type": "application/x-www-form-urlencoded"
          });
      return json.decode(response.body.toString());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> initPaymentSheet(Map<String, dynamic> paymentIntent, BuildContext context) async {
    try {
      var gpay = const PaymentSheetGooglePay(
        merchantCountryCode: "US",
        currencyCode: "US",
        testEnv: true,
      );
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent["client_secret"],
            style: ThemeMode.dark,
            googlePay: gpay,
            merchantDisplayName: "fazil"),
      );
      await presentPaymentSheet(context);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> presentPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      paymentIntent = null;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment successful")));
    } on StripeException catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
              content: Text("Payment Failed", style: TextStyle(fontSize: 15),)));
    }
  }

  Future<void> makePayment(BuildContext context, String amount, String currency) async {
    try {
      paymentIntent = await createPaymentIntent(amount, currency);
      if (paymentIntent != null) {
        await initPaymentSheet(paymentIntent!, context);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
