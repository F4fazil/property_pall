
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:propertypall/screens/FaviouriteScreens.dart';
import 'package:propertypall/screens/ProfileScreen.dart';
import 'package:propertypall/screens/Seacrch_Screen.dart';
import 'package:propertypall/screens/chatScreen.dart';
import 'package:propertypall/screens/homepage.dart';
import 'package:propertypall/theme/themeProvider.dart';

import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'Database/Fav.dart';
import 'authentication/auth.dart';
import 'firebase_options.dart';
import 'constant/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 Stripe.publishableKey=publishkey;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteManager()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey = GlobalKey<SliderDrawerState>();



  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return
      MaterialApp(
        theme: themeProvider.themedata.copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        debugShowCheckedModeBanner: false,
        home: AuthPage(),
      );
  }
}
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static  List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ChatScreen(),
    GoogleMapScreen(),
    FavoritesPage(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        minHeight: 0, // Minimum height when panel is collapsed
        maxHeight: MediaQuery.of(context).size.height * 0.3, // Adjust the height as needed
        panel: Container(
          color: Colors.white,
          child: Center(child: Text('Sliding Panel Content')),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.pentagon_outlined),
            label: '▲',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.messenger),
            label: '▲',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '▲',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_sharp),
            label: '▲',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '▲',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF234F68),
        unselectedItemColor: Colors.black54,
        iconSize: 30.0,
        selectedFontSize: 14.0,
        unselectedFontSize: 16.0,
        onTap: _onItemTapped,
      ),
    );
  }
}
































//notification code implementation
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // Request permission for iOS
    _firebaseMessaging.requestPermission();

    // Get the token for this device
    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      print("Firebase Messaging Token: $token");
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Home Page'),
      ),
      body: Center(
        child: Text('Push Notifications with Firebase Messaging'),
      ),
    );
  }
}
