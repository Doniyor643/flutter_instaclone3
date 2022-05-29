import 'package:flutter/material.dart';

class FireStoreApp extends StatefulWidget {
  const FireStoreApp({Key? key}) : super(key: key);

  @override
  State<FireStoreApp> createState() => _FireStoreAppState();
}

class _FireStoreAppState extends State<FireStoreApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FireStore Example"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child: const Icon(Icons.add_chart),
      ),
    );
  }
}
