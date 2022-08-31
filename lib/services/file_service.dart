import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:image_picker/image_picker.dart';


class FileService {
  static final _storage = FirebaseStorage.instance.ref();
  static final folder_post = 'post_images';
  static final folder_user = 'user_images';

  static Future<String?> uploadUserImage(XFile _image) async {
    String? uid = await Prefs.loadUserId();

    String? imgName = uid;

    Reference firebaseStorageRef =
    _storage.child(folder_user).child(imgName!);

    UploadTask uploadTask = firebaseStorageRef.putFile(File(_image.path));

    TaskSnapshot taskSnapshot = await uploadTask.snapshot;

    if (taskSnapshot != null) {
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    }
    return null;
  }

  static Future<String?> uploadPostImage(XFile _image) async {
    String? uid = await Prefs.loadUserId();

    String imgName = uid! + "_" + DateTime.now().toString();

    Reference firebaseStorageRef =
    _storage.child(folder_post).child(imgName);

    UploadTask uploadTask = firebaseStorageRef.putFile(File(_image.path));

    TaskSnapshot taskSnapshot = await uploadTask.snapshot;

    if (taskSnapshot != null) {
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    }
    return null;
  }
}