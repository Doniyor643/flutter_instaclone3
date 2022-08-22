import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/services/utils_service.dart';

import 'my_feed_page.dart';
import 'my_likes_page.dart';
import 'my_profile_page.dart';
import 'my_search_page.dart';
import 'my_upload_page.dart';


class HomePage extends StatefulWidget {
  static const String id = 'home_page';

  const HomePage({required Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Notification
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // _initNotification() {
  //   _firebaseMessaging.configure(
  //       onMessage: (Map<String, dynamic> message) async {
  //         print('onMessage: $message');
  //         Utils.showLocalNotification(message);
  //       },
  //       onLaunch: (Map<String, dynamic> message) async {
  //         // print('onLaunch: $message');
  //       },
  //       onResume: (Map<String, dynamic> message) async {
  //         // print('onLaunch: $message');
  //       }
  //   );
  // }

  _initNotification2(){
    _firebaseMessaging.sendMessage();
  }

  // values
  late PageController _pageController;
  var _currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _pageController = PageController();
    //_initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              MyFeedPage(_pageController,),
              const MySearchPage(),
              MyUploadPage(_pageController),
              const MyLikesPage(),
              const MyProfilePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
          });
        },
        activeColor: const Color(0xffFCAF45),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.add_box)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded)),
        ],
      ),
    );
  }
}