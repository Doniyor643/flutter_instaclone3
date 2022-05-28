import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/file_service.dart';
import 'package:image_picker/image_picker.dart';

class MyUploadPage extends StatefulWidget {
  final PageController pageController;

  const MyUploadPage({Key? key, required this.pageController}) : super(key: key);

  @override
  _MyUploadPageState createState() => _MyUploadPageState();
}

class _MyUploadPageState extends State<MyUploadPage> {
  bool isLoading = false;
  var captionController = TextEditingController();
  XFile? _image;
  ImagePicker imagePicker = ImagePicker();

  _imgFromGallery() async {
    XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image!;
    });
  }

  _imgFromCamera() async {
    XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

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
        }
    );
  }

  _uploadNewPost() {
    String caption = captionController.text.toString().trim();
    if (caption.isEmpty) return;
    if (_image == null) return;
    _apiPostImage();
  }

  void  _apiPostImage(){
    setState(() {
      isLoading = true;
    });
    FileService.uploadPostImage(File(_image!.path)).then((downloadUrl) => {
      _resPostImage(downloadUrl!),
    });
  }

  void _resPostImage(String downloadUrl){
    String caption = captionController.text.toString().trim();
    Post post = Post(caption: caption,img_post: downloadUrl);
    _apiStorePost(post);
  }

  void _apiStorePost(Post post) async{
    // Post to posts
    Post posted = await DataService.storePost(post);
    // Post to feeds
    DataService.storeFeed(posted).then((value) => {
      _moveToFeed(),
    });
  }

  void _moveToFeed(){
    setState(() {
      isLoading = false;
    });
    captionController.text = "";
    //_image = null;
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
          "Upload",
          style: TextStyle(
              color: Colors.black, fontFamily: 'Billabong', fontSize: 25),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _uploadNewPost();
            },
            icon: const Icon(
              Icons.drive_folder_upload,
              color: Color.fromRGBO(193, 53, 132, 1),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [

          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width,
                      color: Colors.grey.withOpacity(0.4),
                      child: (_image == null)
                          ? const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 60,
                          color: Colors.grey,
                        ),
                      )
                          : Stack(
                        children: [
                          Image.file(
                            File(_image!.path),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            width: double.infinity,
                            color: Colors.black12,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: (){
                                    setState(() {
                                      _image = null;
                                    });
                                  },
                                  icon: const Icon(Icons.highlight_remove),
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: TextField(
                      controller: captionController,
                      style: const TextStyle(color: Colors.black),
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      //Normal textInputField will be displayed
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: "Caption",
                        hintStyle: TextStyle(fontSize: 17.0, color: Colors.black38),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}