import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/pages/someone_profile_page.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';
import 'package:share/share.dart';

class MyFeedPage extends StatefulWidget {
  static const String id = 'my_feed_page';

  PageController pageController;
  MyFeedPage(this.pageController, {Key? key}) : super(key: key);

  @override
  _MyFeedPageState createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {
  // values
  List<Post> items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _apiLoadFeeds();
  }

  _apiLoadFeeds() {
    setState(() {
      isLoading = true;
    });

    DataService.loadFeeds().then((posts) => {_resLoadFeeds(posts)});
  }

  _resLoadFeeds(List<Post> posts) {
    setState(() {
      items = posts;
      isLoading = false;
    });
  }

  // Like || Unlike actions
  // ===========================================================================
  _apiPostLike(Post post) async {
    setState(() {
      isLoading = true;
    });

    await DataService.likePost(post, true);

    setState(() {
      isLoading = false;
      post.liked = true;
    });
  }

  _apiPostUnlike(Post post) async {
    setState(() {
      isLoading = true;
    });

    await DataService.likePost(post, false);

    setState(() {
      isLoading = false;
      post.liked = true;
    });
  }
  // ===========================================================================

  _actionRemovePost(Post post) async {
    if (await Utils.commonDialog(context, 'Logout?', 'Do you want to logout?', false)) {
      setState(() {
        isLoading = true;
      });

      DataService.removePost(post).then((value) => {
        _apiLoadFeeds(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Instagram',
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontFamily: 'Billabong'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              widget.pageController.animateToPage(2,
                  duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
            },
            icon: const Icon(
              Icons.camera_alt,
              color: Color(0xffFCAF45),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          items.isNotEmpty ?
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              return _postOfItems(items[index]);
            },
          ) : const Center(child: Text('No posts'),),

          isLoading ? const Center(child: CircularProgressIndicator(),) : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _postOfItems(Post post) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(),

          // Profile information
          GestureDetector(
            onTap: () {
              if (post.mine == false) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SomeoneProfilePage(uid: post.uid,),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile information
                  Row(
                    children: [
                      // Profile image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22.5),
                        child: post.imgUser == null || post.imgUser.isEmpty
                            ? const Image(
                          image: AssetImage("assets/images/ic_profile.png"),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                            : Image.network(
                          post.imgUser,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      // Username || Data
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.fullName,
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(
                            post.date,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Button : More (Options)
                  post.mine ?
                  IconButton(
                    onPressed: () {
                      _actionRemovePost(post);
                    },
                    icon: const Icon(SimpleLineIcons.options),
                  ) : const SizedBox.shrink(),
                ],
              ),
            ),
          ),

          // Post image
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            imageUrl: post.postImage,
            placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          // Buttons : Like || Share
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (!post.liked) {
                    _apiPostLike(post);
                  } else {
                    _apiPostUnlike(post);
                  }
                },
                icon: !post.liked ? const Icon(FontAwesome.heart_o) : const Icon(FontAwesome.heart, color: Colors.red,),
              ),

              // Button : Share
              IconButton(
                onPressed: () {
                  Share.share('Image: ${post.postImage} \n Caption: ${post.caption}');
                },
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),

          // Caption
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(children: [
                TextSpan(
                  text: " " + post.caption,
                  style: const TextStyle(color: Colors.black),
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }
}