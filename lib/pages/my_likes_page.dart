import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';

class MyLikesPage extends StatefulWidget {
  const MyLikesPage({Key? key}) : super(key: key);

  @override
  _MyLikesPageState createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage> {
  bool isLoading = false;
  List<Post> items = [];

  void _apiLoadLikes() {
    setState(() {
      isLoading = true;
    });
    DataService.loadLikes().then((value) => {
      _resLoadLikes(value),
    });
  }

  void _resLoadLikes(List<Post> posts) {
    setState(() {
      items = posts;
      isLoading = false;
    });
  }

  void _apiPostUnLike(Post post) {
    setState(() {
      isLoading = true;
      post.liked = false;
    });
    DataService.likePost(post, false).then((value) => {
      _apiLoadLikes(),
    });
  }

  _actionRemovePost(Post post) async{
    var result = await Utils.dialogCommon(context, "Insta Clone", "Do you want to remove this post?", false);
    if(result != null && result){
      setState(() {
        isLoading = true;
      });
      DataService.removePost(post).then((value) => {
        _apiLoadLikes(),
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadLikes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Likes",
          style: TextStyle(
              color: Colors.black, fontFamily: 'Billabong', fontSize: 30),
        ),
      ),
      body: Stack(
        children: [

          items.isNotEmpty?
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, index){
              return _itemOfPost(items[index]);
            },
          ): const Center(
            child: Text("No liked posts"),
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

  Widget _itemOfPost(Post post){
    return Container(
      color: Colors.white,
      child: Column(
        children: [

          const Divider(),
          //userinfo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: (post.img_user == null || post.img_user.isEmpty)? const Image(
                        image: AssetImage("assets/images/ic_person.png"),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ):Image.network(
                        post.img_user,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.fullname,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Text(
                          post.date,
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                ),
                post.mine ?
                IconButton(
                  icon: const Icon(SimpleLineIcons.options),
                  onPressed: () {
                    _actionRemovePost(post);
                  },
                ): const SizedBox.shrink(),
              ],
            ),
          ),
          //#image
          //Image.network(post.postImage, fit: BoxFit.cover),

          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            imageUrl: post.img_post,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator(),),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),

          //#likeshare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      if (post.liked) {
                        _apiPostUnLike(post);
                      }
                    },
                    icon: post.liked
                        ? const Icon(
                      FontAwesome.heart,
                      color: Colors.red,
                    )
                        : const Icon(FontAwesome.heart_o),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined),
                  ),
                ],
              ),
            ],
          ),
          // #caption
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: " ${post.caption}",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

}