import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void fireToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static bool emailAndPasswordValidation(String email, String password) {
    bool emailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    if (!emailValid) {
      Utils.fireToast('Check your email');
      return false;
    }

    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    if (!(regExp.hasMatch(password))) {
      Utils.fireToast('Check your password');
      return false;
    }

    return true;
  }

  static String currentDate() {
    DateTime now = DateTime.now();

    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString()}:${now.minute.toString()}";
    return convertedDateTime;
  }

  static Future<bool> commonDialog(BuildContext context, String title, String content, bool isSingle) async {
    return await showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          // Button : Cancel
          !isSingle ?
          FlatButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ) : const SizedBox.shrink(),

          // Button : Confirm
          FlatButton(
            child: const Text('Confirm'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    });
  }


  // Device info
  static Future<Map<String, String>> deviceParams() async {
    Map<String, String> params = {};
    var deviceInfo = DeviceInfoPlugin();
    String? fcmToken = await Prefs.loadFCM();

    if (Platform.isIOS) {
      var iOSDeviceInfo = await deviceInfo.iosInfo;
      params.addAll({
        'device_id' : iOSDeviceInfo.identifierForVendor!,
        'device_type' : 'I',
        'device_token' : fcmToken!,
      });
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      params.addAll({
        'device_id' : androidDeviceInfo.androidId!,
        'device_type' : 'A',
        'device_token' : fcmToken!,
      });
    }

    return params;
  }


  // Notification : Local
  static Future<void> showLocalNotification(Map<String, dynamic> message) async {
    String title = message['title'];
    String body = message['body'];

    if (Platform.isAndroid) {
      title = message['notification']['title'];
      body = message['notification']['body'];
    }

    var android = const AndroidNotificationDetails('channelId', 'channelName',);
    var iOS = const IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    int number = pow(2, 31).toInt();
    int id = Random().nextInt(number).toInt();
    await FlutterLocalNotificationsPlugin().show(id, title, body, platform);
  }
}