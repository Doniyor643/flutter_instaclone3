// @dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/pages/home_page.dart';
import 'package:flutter_instaclone/pages/signin_page.dart';
import 'package:flutter_instaclone/pages/signup_page.dart';
import 'package:flutter_instaclone/pages/spash_page.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';

import 'model/users_model.dart';

Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp().then((value) => print('Firebase Initialization Complete !!!!!!!!!!!!!!!'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:_callStartPage(),    //_callStartPage(),
      routes: {
        SplashPage.id:(context) => const SplashPage(),
        SignInPage.id:(context) => const SignInPage(),
        SignUpPage.id:(context) => const SignUpPage(),
        HomePage.id:(context) => const HomePage(),
      },
    );
  }
}

Widget _callStartPage() {
  return StreamBuilder<User>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (BuildContext context, AsyncSnapshot  snapshot) {
      if (snapshot.hasData) {
        Prefs.saveUserId(snapshot.data.uid);
        return const SplashPage();
      } else {
        Prefs.removeUserId();
        return const SignInPage();
      }
    },
  );
}




