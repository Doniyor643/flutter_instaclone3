import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/pages/signup_page.dart';

import '../services/auth_service.dart';
import '../services/prefs_service.dart';
import '../services/utils_service.dart';
import 'home_page.dart';

class SignInPage extends StatefulWidget {
  static const String id = 'signin_page';

  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // values
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var isLoading = false;

  _doSignIn() {
    String email = _emailController.text.toString().trim();
    String password = _passwordController.text.toString().trim();
    if (email.isEmpty || password.isEmpty) return;

    //if (!(Utils.emailAndPasswordValidation(email, password))) return;

    setState(() {
      isLoading = true;
    });
    AuthService.signInUser(context, email, password).then((map) => {
      _getFirebaseUser(map),
    });
  }

  _getFirebaseUser(map) async {
    setState(() {
      isLoading = false;
    });

    User firebaseUser;

    if (!map.containsKey('SUCCESS')) {
      Utils.fireToast('Check email or password');
      return;
    }

    firebaseUser = map['SUCCESS'];

    if (firebaseUser == null) return;

    await Prefs.saveUserId(firebaseUser.uid).then((value) => {
      Navigator.pushReplacementNamed(context, HomePage.id),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xffFCAF45),
                  Color(0xffF56040),
                ]),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Text : Instagram
                          const Text(
                            'Instagram',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 45,
                                fontFamily: 'Billabong'),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // TextField : Email
                          Container(
                            height: 50,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: Colors.white54.withOpacity(0.2),
                            ),
                            child: TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                hintStyle:
                                TextStyle(color: Colors.white54, fontSize: 16),
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // TextField : Password
                          Container(
                            height: 50,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: Colors.white54.withOpacity(0.2),
                            ),
                            child: TextField(
                              obscureText: true,
                              controller: _passwordController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                hintStyle:
                                TextStyle(color: Colors.white54, fontSize: 16),
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // Button : Sign in
                          GestureDetector(
                            onTap: _doSignIn,
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                    color: Colors.white54.withOpacity(0.2),
                                    width: 2),
                              ),
                              child: const Center(
                                child: Text(
                                  'Sign in',
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),

                  // GestureDetector : Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, SignUpPage.id);
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                ],
              ),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
              )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}