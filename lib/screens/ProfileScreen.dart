import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../admin_panel/add_post.dart';
import '../payment/paymentScreen.dart'; // Make sure this import is correct

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late Animation<double> _avatarScaleAnimation;
  late Animation<double> _nameOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _avatarScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_headerAnimationController);
    _nameOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_headerAnimationController);

    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user?.email?.trim(); // Ensure there are no leading or trailing spaces
    String? namePart = email?.split('@')[0] ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
       // backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(namePart),
            _buildSettingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String namePart) {
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) => Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Uncomment and adjust color if needed
          // color: Colors.blue[700],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            ScaleTransition(
              scale: _avatarScaleAnimation,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black,
                backgroundImage: NetworkImage('https://example.com/profile_image.jpg'), // Replace with real URL
              ),
            ),
            SizedBox(height: 10),
            FadeTransition(
              opacity: _nameOpacityAnimation,
              child: Text(
                namePart,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            FadeTransition(
              opacity: _nameOpacityAnimation,
              child: Text(
                FirebaseAuth.instance.currentUser?.email ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    final List<Map<String, dynamic>> settingsItems = [
      {'icon': Icons.person, 'title': 'Edit Profile'},
      {'icon': Icons.monetization_on, 'title': 'Sell Your Property'},
      {'icon': Icons.payment, 'title': 'Payments'},
      {'icon': Icons.security, 'title': 'Security'},
      {'icon': Icons.help, 'title': 'Help & Support'},
      {'icon': Icons.info, 'title': 'About'},
      {'icon': Icons.exit_to_app, 'title': 'Logout'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: settingsItems.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white),
      itemBuilder: (context, index) {
        final item = settingsItems[index];
        return ListTile(
          leading: Icon(item['icon'], color: Color(0xFF234F68)),
          title: Text(item['title']),
          trailing: Icon(Icons.chevron_right, color: Color(0xFF234F68)),
          onTap: () {
            switch (index) {
              case 0:
              // Navigate to Edit Profile screen
              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditProfileScreen()));
                break;
              case 1:
              // Navigate to Sell Your Property screen
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddPost()));
                break;
              case 2:
            //    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MySample()));

                break;
              case 3:

                break;
              case 4:
              // Handle Help & Support
                break;
              case 5:
              // Handle About
                break;
              case 6:
               FirebaseAuth.instance.signOut();
                break;
              default:
                print('Tapped on ${item['title']}');
            }
          },
        );
      },
    );
  }
}
