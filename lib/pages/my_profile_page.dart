import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/model/users_model.dart';
import 'package:flutter_instaclone/services/auth_service.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/file_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';
import 'package:image_picker/image_picker.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool isLoading = false;
  int axisCount = 1;
  List<Post> items = [];
  late File _image;
  String fullname = "", email = "", img_url = "";
  int count_posts = 0, count_followers = 0, count_following = 0;

  final ImagePicker _imagePicker = ImagePicker();

  _imgFromGallery() async {
    XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image! as File;
    });
    _apiChangePhoto();
  }

  _imgFromCamera() async {
    XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image! as File;
    });
    _apiChangePhoto();
  }

  void _apiChangePhoto() {
    if (_image == null) return;
    setState(() {
      isLoading = true;
    });

    FileService.uploadUserImage(_image).then((downloadUrl) => {
      _apiUpdateUser(downloadUrl!),
    });
  }

  void _apiUpdateUser(String downloadUrl) async {
    Users users = await DataService.loadUser();
    users.img_url = downloadUrl;
    await DataService.updateUser(users);
    _apiLoadUser();
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

  void _apiLoadUser() {
    setState(() {
      isLoading = true;
    });
    DataService.loadUser().then((value) => {
      _showUserInfo(value),
    });
  }

  void _showUserInfo(Users users) {
    setState(() {
      isLoading = false;
      fullname = users.fullname;
      email = users.email;
      img_url = users.img_url;
      count_followers = users.followers_count;
      count_following = users.following_count;
    });
  }

  void _apiLoadPosts() {
    DataService.loadPosts().then((value) => {
      _resLoadPosts(value),
    });
  }

  void _resLoadPosts(List<Post> posts) {
    setState(() {
      items = posts;
      count_posts = items.length;
    });
  }

  _actionLogout() async{

    var result = await Utils.dialogCommon(context, "Insta Clone", "Do you want to logout?", false);
    if(result != null && result){
      AuthService.signOutUser(context);
    }
  }

  _actionRemovePost(Post post) async{
    var result = await Utils.dialogCommon(context, "Insta Clone", "Do you want to remove this post?", false);
    if(result != null && result){
      setState(() {
        isLoading = true;
      });
      DataService.removePost(post).then((value) => {
        _apiLoadPosts(),
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _apiLoadUser();
    _apiLoadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.black, fontFamily: 'Billabong', fontSize: 25),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _actionLogout();
            },
            icon: const Icon(Icons.exit_to_app),
            color: const Color.fromRGBO(193, 53, 132, 1),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                //#myphoto
                GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(70),
                          border: Border.all(
                            width: 1.5,
                            color: const Color.fromRGBO(193, 53, 132, 1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: img_url == null || img_url.isEmpty
                              ? const Image(
                            image: AssetImage("assets/images/defold_photo.png"),
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            img_url,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Icon(
                              Icons.add_circle,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //#myinfos
                const SizedBox(
                  height: 10,
                ),
                Text(
                  fullname.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  email,
                  style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.normal),
                ),
                //mycounts
                SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                count_posts.toString(),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              const Text(
                                "POSTS",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                count_followers.toString(),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              const Text(
                                "FOLLOWERS",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                count_following.toString(),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              const Text(
                                "FOLLOWING",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //listgrid
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              axisCount = 1;
                            });
                          },
                          icon: const Icon(Icons.list_alt),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              axisCount = 2;
                            });
                          },
                          icon: const Icon(Icons.grid_view),
                        ),
                      ),
                    ),
                  ],
                ),
                //#myposts
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: axisCount),
                    itemCount: items.length,
                    itemBuilder: (ctx, index) {
                      return _itemOfPost(items[index]);
                    },
                  ),
                ),
              ],
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

  Widget _itemOfPost(Post post) {
    return GestureDetector(
        onLongPress: (){
          _actionRemovePost(post);
        },
        child: Container(
          margin: const EdgeInsets.all(5),
          child: Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  width: double.infinity,
                  imageUrl: post.img_post,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(),),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                post.caption,
                style: TextStyle(color: Colors.black87.withOpacity(0.7)),
                maxLines: 2,
              ),
            ],
          ),
        )
    );
  }
}