import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/post_model.dart';
import '../services/data_service.dart';
import '../services/file_service.dart';

class MyUploadPage extends StatefulWidget {
  static const String id = 'my_upload_page';

  PageController pageController;
  MyUploadPage(this.pageController, {Key? key}) : super(key: key);

  @override
  _MyUploadPageState createState() => _MyUploadPageState();
}

class _MyUploadPageState extends State<MyUploadPage> {
  // values
  final _captionController = TextEditingController();
  XFile? _image;
  bool isLoading = false;
  ImagePicker imagePicker = ImagePicker();

  // Image Picker
  // ===========================================================================
  _imgFromCamera() async {
    XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image!;
    });
  }

  _imgFromGallery() async {
    XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image!;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Pick Photo'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take Photo'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }
  // ===========================================================================

  _uploadNewPost() {
    String _caption = _captionController.text.toString();
    if (_caption.isEmpty || _image == null) return;

    // Send post to server
    _apiPostImage();
  }

  _apiPostImage() {
    setState(() {
      isLoading = true;
    });

    FileService.uploadPostImage(_image!).then((downloadUrl) => {
      _resPostImage(downloadUrl!),
    });
  }

  _resPostImage(String downloadUrl) {
    String caption = _captionController.text.toString().trim();
    Post post = Post(postImage: downloadUrl, caption: caption);
    _apiStorePost(post);
  }

  _apiStorePost(Post post) async {
    // Post to posts
    Post posted = await DataService.storePost(post);

    // Post to feeds
    DataService.storeFeed(post).then((value) => {_moveToFeed()});
  }

  _moveToFeed() {
    _image;
    _captionController.text = '';

    setState(() {
      isLoading = false;
    });

    widget.pageController.animateToPage(0,
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Upload',
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontFamily: 'Billabong'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(
                Icons.drive_folder_upload,
                color: Color(0xffFCAF45),
                size: 25,
              ),
              onPressed: _uploadNewPost)
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(children: [
                // Button : add a photo
                GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width,
                    color: Colors.grey.withOpacity(0.4),
                    child: _image == null
                        ? const Icon(
                      Icons.add_a_photo,
                      color: Colors.grey,
                      size: 60,
                    )
                        : Stack(
                      children: [
                        // Added photo
                        SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child: Image.file(
                            File(_image!.path),
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Button : x => remove added photo
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black12.withOpacity(0.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                  icon: const Icon(
                                    Icons.highlight_remove,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _image;
                                    });
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // TextField : Caption
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: _captionController,
                    decoration: const InputDecoration(
                      hintText: 'Caption',
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 17),
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
              ]),
            ),
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(),
            )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}