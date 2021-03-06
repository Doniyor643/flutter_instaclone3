import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/users_model.dart';
import 'package:flutter_instaclone/pages/signin_page.dart';
import 'package:flutter_instaclone/services/auth_service.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';

import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  static const String id = "signup_page";

  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var isLoading = false;

  var fullnameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var cpasswordController = TextEditingController();

  _doSignUp() {
    String name = fullnameController.text.toString().trim();
    String email = emailController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    String cpassword = cpasswordController.text.toString().trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) return;
    if (cpassword != password) {
      Utils.fireToast("Password and confirm password does not match");
      return;
    }

    setState(() {
      isLoading = true;
    });
    Users users = Users(fullname: name, email: email, password: password);
    AuthService.signUpUser(context, name, email, password).then((
        value) =>
    {
      _getFirebaseUser(users, value),
    });
  }

  _getFirebaseUser(Users users, Map<String, User?> map) async {
    setState(() {
      isLoading = false;
    });
    if (map.containsKey("SUCCESS")) {
      if (map.containsKey("ERROR_EMAIL_ALREADY_IN_USE")) {
        Utils.fireToast("Email already in use");
      }
      if (map.containsKey("ERROR")) {
        print(map.containsKey("ERROR"));
        Utils.fireToast("Try again later");
      }
      return;
    }
    User? firebaseUser = map["SUCCESS"];
    if (firebaseUser == null) return;

    await Prefs.saveUserId(firebaseUser.uid);
    DataService.storeUser(users);
    Navigator.pushReplacementNamed(context, HomePage.id);
  }

  _callSignInPage() {
    Navigator.pushReplacementNamed(context, SignInPage.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery
                .of(context)
                .size
                .height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(193, 53, 132, 1),
                    Color.fromRGBO(131, 58, 180, 1),
                  ]
              ),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          const Text(
                            "Instagram",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 45,
                                fontFamily: 'Billabong'),
                          ),
                          const SizedBox(
                            height: 20,
                          ),

                          //#fullname
                          Container(
                            height: 50,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white54.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              controller: fullnameController,
                              decoration: const InputDecoration(
                                hintText: "Fullname",
                                border: InputBorder.none,
                                hintStyle:
                                TextStyle(
                                    fontSize: 17.0, color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          //#email
                          Container(
                            height: 50,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white54.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              controller: emailController,
                              decoration: const InputDecoration(
                                hintText: "Email",
                                border: InputBorder.none,
                                hintStyle:
                                TextStyle(
                                    fontSize: 17.0, color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          //#password
                          Container(
                            height: 50,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white54.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                              controller: passwordController,
                              decoration: const InputDecoration(
                                hintText: "Password",
                                border: InputBorder.none,
                                hintStyle:
                                TextStyle(
                                    fontSize: 17.0, color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          //#cpassword
                          Container(
                            height: 50,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white54.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                              controller: cpasswordController,
                              decoration: const InputDecoration(
                                hintText: "Confirm Password",
                                border: InputBorder.none,
                                hintStyle:
                                TextStyle(
                                    fontSize: 17.0, color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          //#signup
                          GestureDetector(
                            onTap: () {
                              _doSignUp();
                            },
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white54.withOpacity(0.2),
                                    width: 2),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Center(
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: _callSignInPage,
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),

                isLoading ?
                const Center(
                  child: CircularProgressIndicator(),
                ) : const SizedBox.shrink(),
              ],
            )
        ),
      ),
    );
  }
}