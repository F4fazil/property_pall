import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:propertypall/payment/paymentMethod.dart';
import 'package:shimmer_loading/shimmer_loading.dart';
import '../call_services/audiopage.dart';
import '../call_services/video_call.dart';
import '../chat_service/chat_service.dart';
import '../widgets/login_signup_btn.dart'; // Import for SVG icons

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> homeData;

  DetailPage({required this.homeData});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  ChatService _chatService = ChatService(); // Update if needed
  StripePaymentService _payment = StripePaymentService();
  PageController _pageController = PageController();
  int _currentPage = 0;
  var uid;

  @override
  void initState() {
    super.initState();
    uid=widget.homeData["uid"];
    print("uid");
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  void _buyProperty(BuildContext context) async {
    // Ensure 'price' is a double by parsing the string value
    double price;
    try {
      price = double.parse(widget.homeData['price'].toString());
    } catch (e) {
      print("Price Parsing Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid price format'),
        ),
      );
      return;
    }

    // Calculate the advance amount (5% of the price)
    double advanceAmount = price * 0.05;

    try {
      // Make the payment using Stripe
      await _payment.makePayment(context, advanceAmount.toStringAsFixed(2), "USD");
    } catch (e) {
      print("Payment Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
        ),
      );
      return;
    }
  }


  void _sendMessage(BuildContext context) {
    // Ensure 'ownerId' is available in homeData

    if (uid != null) {
      _chatService.sendmessage(uid, "Hi, I'm interested in this property!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message sent to the property owner!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Owner ID not available.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Explicitly cast to List<String>
    final List<String> images = List<String>.from(widget.homeData['images']);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.homeData['name'] ?? 'Property Details'),
      ),
      body: Stack(
        children: [
          // Property details content
          Column(
            children: [
              // Image PageView
              Container(
                height: MediaQuery.of(context).size.height * 0.5, // Half height of the screen
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: 'image-${images[index]}',
                      child: Material(
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width, // Full width
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Page indicator
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    '${_currentPage + 1}/${images.length}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10.0,
                        offset: Offset(0, 5),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price: \$${widget.homeData['price']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: ${widget.homeData['location'] ?? 'No location'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.homeData['description'] ?? 'No description',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: MyButton(
                          onPressed: () {
                           _payment.makePayment(context, "10", "usd");
                          },
                          text: 'Buy this Property',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Beautiful UI for communication buttons
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AudioCallPage()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Connecting Audio call'),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/audio.svg',
                    color: Colors.white,
                    height: 32,
                  ),
                  backgroundColor: Colors.teal,
                  elevation: 8.0,
                ),
                const SizedBox(height: 10.0),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CallPage()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Video call functionality not implemented.'),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/video_call.svg',
                    color: Colors.white,
                    height: 32,
                  ),
                  backgroundColor: Colors.purple,
                  elevation: 8.0,
                ),
                const SizedBox(height: 10.0),
                FloatingActionButton(
                  onPressed: () {
                    _sendMessage(context);
                  },
                  child: SvgPicture.asset(
                    'assets/icons/chat.svg',
                    color: Colors.white,
                    height: 32,
                  ),
                  backgroundColor: Colors.blue,
                  elevation: 8.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
