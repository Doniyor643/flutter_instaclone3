import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/model/users_model.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';

import '../model/users_model.dart';

class DataService {
  static final _firestore = FirebaseFirestore.instance;

  static String folder_users = "users";
  static String folder_posts = "posts";
  static String folder_feeds = "feeds";
  static String folder_following = "following";
  static String folder_followers = "followers";

  // User Related

  static Future storeUser(Users users) async {
    users.uid = (await Prefs.loadUserId())!;
    Map<String, String> params = await Utils.deviceParams();
    print(params.toString());

    users.device_id = params["device_id"].toString();
    users.device_type = params["device_type"].toString();
    users.device_token = params["device_token"].toString();

    return _firestore.collection('users').doc(users.uid).set(users.toJson());
  }

  static Future<Users> loadUser() async {
    String? uid = await Prefs.loadUserId();
    var value = await _firestore.collection("users").doc(uid).get();
    Users user = Users.fromJson(value.data());

    var querySnapshot1 = await _firestore.collection(folder_users).doc(uid).collection(folder_followers).get();
    user.followers_count = querySnapshot1.docs.length;

    var querySnapshot2 = await _firestore.collection(folder_users).doc(uid).collection(folder_following).get();
    user.following_count = querySnapshot2.docs.length;

    return user;
  }

  static Future updateUser(Users user) async {
    String? uid = await Prefs.loadUserId();
    return _firestore.collection(folder_users).doc(uid).update(user.toJson());
  }

  static Future<List<Users>> searchUsers(String keyword) async {
    List<Users> users = [];
    String? uid = await Prefs.loadUserId();

    var querySnapshot = await _firestore.collection(folder_users).orderBy("email").startAt([keyword]).get();
    print(querySnapshot.docs.length);

    for (var result in querySnapshot.docs) {
      Users newUser = Users.fromJson(result.data());
      if(newUser.uid != uid){
        users.add(newUser);
      }
    }

    List<Users> following = [];

    var querySnapshot2 = await _firestore.collection(folder_users).doc(uid).collection(folder_following).get();
    for (var result in querySnapshot2.docs) {
      following.add(Users.fromJson(result.data()));
    }

    for(Users user in users){
      if(following.contains(user)){
        user.followed = true;
      }else{
        user.followed = false;
      }
    }

    return users;
  }

// Post Related

  static Future<Post> storePost(Post post) async {
    Users me = await loadUser();
    post.uid = me.uid;
    post.fullname = me.fullname;
    post.img_user = me.img_url;
    post.date = Utils.currentDate();

    String postId = _firestore.collection(folder_users).doc(me.uid).collection(folder_posts).doc().id;  //.documentsId
    post.id = postId;

    await _firestore.collection(folder_users).doc(me.uid).collection(folder_posts).doc(postId).set(post.toJson());
    return post;
  }

  static Future<Post> storeFeed(Post post) async {
    String? uid = await Prefs.loadUserId();

    await _firestore.collection(folder_users).doc(uid).collection(folder_feeds).doc(post.id).set(post.toJson());
    return post;
  }

  static Future<List<Post>> loadFeeds() async {
    List<Post> posts = [];
    String? uid = await Prefs.loadUserId();
    var querySnapshot = await _firestore.collection(folder_users).doc(uid).collection(folder_feeds).get();

    for (var result in querySnapshot.docs) {
      Post post = Post.fromJson(result.data());
      if(post.uid == uid) post.mine = true;
      posts.add(post);
    }
    return posts;
  }

  static Future<List<Post>> loadPosts() async {
    List<Post> posts = [];
    String? uid = await Prefs.loadUserId();

    var querySnapshot = await _firestore.collection(folder_users).doc(uid).collection(folder_posts).get();

    for (var result in querySnapshot.docs) {
      posts.add(Post.fromJson(result.data()));
    }
    return posts;
  }


  static Future<Post?> likePost(Post post, bool liked) async {
    String? uid = await Prefs.loadUserId();
    post.liked = liked;

    await _firestore.collection(folder_users).doc(uid).collection(folder_feeds).doc(post.id).set(post.toJson());

    if(uid == post.uid){
      await _firestore.collection(folder_users).doc(uid).collection(folder_posts).doc(post.id).set(post.toJson());
    }
    return null;
  }

  static Future<List<Post>> loadLikes() async {
    String? uid = await Prefs.loadUserId();
    List<Post> posts = [];

    var querySnapshot = await _firestore.collection(folder_users).doc(uid).collection(folder_feeds).where("liked", isEqualTo: true).get();

    for (var result in querySnapshot.docs) {
      Post post = Post.fromJson(result.data());
      if(post.uid == uid) post.mine = true;
      posts.add(post);
    }
    return posts;

  }

  // Follower and Following Related

  static Future<Users> followUser(Users someone) async {
    Users me = await loadUser();

    // I followed to someone
    await _firestore.collection(folder_users).doc(me.uid).collection(folder_following).doc(someone.uid).set(someone.toJson());

    // I am in someone`s followers
    await _firestore.collection(folder_users).doc(someone.uid).collection(folder_followers).doc(me.uid).set(me.toJson());

    return someone;
  }

  static Future<Users> unfollowUser(Users someone) async {
    Users me = await loadUser();

    // I un followed to someone
    await _firestore.collection(folder_users).doc(me.uid).collection(folder_following).doc(someone.uid).delete();

    // I am not in someone`s followers
    await _firestore.collection(folder_users).doc(someone.uid).collection(folder_followers).doc(me.uid).delete();

    return someone;
  }

  static Future storePostsToMyFeed(Users someone) async{
    // Store someone`s posts to my feed

    List<Post> posts = [];
    var querySnapshot = await _firestore.collection(folder_users).doc(someone.uid).collection(folder_posts).get();
    for (var result in querySnapshot.docs) {
      var post = Post.fromJson(result.data());
      post.liked = false;
      posts.add(post);
    }

    for(Post post in posts){
      storeFeed(post);
    }
  }

  static Future removePostsFromMyFeed(Users someone) async{
    // Remove someone`s posts from my feed

    List<Post> posts = [];
    var querySnapshot = await _firestore.collection(folder_users).doc(someone.uid).collection(folder_posts).get();
    for (var result in querySnapshot.docs) {
      posts.add(Post.fromJson(result.data()));
    }

    for(Post post in posts){
      removeFeed(post);
    }
  }

  static Future removeFeed(Post post) async{
    String? uid = await Prefs.loadUserId();

    return await _firestore.collection(folder_users).doc(uid).collection(folder_feeds).doc(post.id).delete();
  }

  static Future removePost(Post post) async{
    String? uid = await Prefs.loadUserId();
    await removeFeed(post);
    return await _firestore.collection(folder_users).doc(uid)
        .collection(folder_posts).doc(post.id).delete();
  }

}