import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/pages/signin_page.dart';


import '../model/users_model.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/prefs_service.dart';
import '../services/utils_service.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  static const String id = 'signup_page';

  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // values
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cPasswordController = TextEditingController();
  var isLoading = false;

  _doSignUp() {
    // values
    String name = _fullNameController.text.toString().trim();
    String email = _emailController.text.toString().trim();
    String password = _passwordController.text.toString().trim();
    String cPassword = _cPasswordController.text.toString().trim();

    // validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) return;
    if (password != cPassword) {
      Utils.fireToast('Password and confirm password does not match!');
      return;
    }
    //if (!(Utils.emailAndPasswordValidation(email, password))) return;

    setState(() {
      isLoading = true;
    });

    AuthService.signUpUser(context,email, password).then((map) => {
      _getFirebaseUser(
          Users(fullName: name, email: email, password: password), map),
    });
  }

  _getFirebaseUser(Users users, Map<String, User?> map) async {
    setState(() {
      isLoading = false;
    });

    // validation
    if (!map.containsKey('SUCCESS')) {
      if (map.containsKey('ERROR_EMAIL_ALREADY_IN_USE')) {
        Utils.fireToast('Email already in use');
      } else {
        Utils.fireToast('Try again later');
      }
      return;
    }

    User? firebaseUser = map['SUCCESS'];
    if (firebaseUser == null) return;

    await Prefs.saveUserId(firebaseUser.uid);

    users.uid = firebaseUser.uid;

    DataService.storeUser(users).then((value) => {
      Navigator.pushNamedAndRemoveUntil(
          context, HomePage.id, (route) => false),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
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
              child: Column(
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

                          // TextField : Full name
                          Container(
                            height: 50,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: Colors.white54.withOpacity(0.2),
                            ),
                            child: TextField(
                              controller: _fullNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Full name',
                                hintStyle:
                                TextStyle(color: Colors.white54, fontSize: 16),
                                border: InputBorder.none,
                              ),
                            ),
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
                              decoration:const  InputDecoration(
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
                              controller: _passwordController,
                              obscureText: true,
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

                          // TextField : Confirm password
                          Container(
                            height: 50,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: Colors.white54.withOpacity(0.2),
                            ),
                            child: TextField(
                              controller: _cPasswordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Confirm password',
                                hintStyle:
                                TextStyle(color: Colors.white54, fontSize: 16),
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // Button : Sign Up
                          GestureDetector(
                            onTap: _doSignUp,
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
                                  'Sign Up',
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
                        "Already have an account? ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, SignInPage.id);
                          },
                          child: const Text(
                            "Sign in",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            isLoading
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: const Center(
                      child: CircularProgressIndicator(),
              ),
            )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}