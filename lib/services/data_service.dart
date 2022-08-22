import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';

import '../model/post_model.dart';
import '../model/users_model.dart';


class DataService {
  static final _firestore = FirebaseFirestore.instance;

  static String folderUsers = "users";
  static String folderPosts = "posts";
  static String folderFeeds = "feeds";
  static String folderFollowing = "following";
  static String folderFollowers = "followers";

  // User Related
  static Future storeUser(Users users) async {
    users.uid = (await Prefs.loadUserId())!;

    Map<String, String?> params = await Utils.deviceParams();

    print(params.toString());

    users.deviceId = params['device_id']!;
    users.deviceType = params['device_type']!;
    users.deviceToken = params['device_token']!;

    final instance = FirebaseFirestore.instance;
    return instance
        .collection('users')
        .doc(users.uid)
        .set(users.toJson());
  }

  static Future<Users> loadUser({required String? id}) async {
    String? uid = await Prefs.loadUserId();

    if (id != null) uid = id;

    final instance = FirebaseFirestore.instance;

    var value = await _firestore.collection(folderUsers).doc(uid).get();

    Users users = Users.fromJson(value.data());

    var querySnapshot1 = await _firestore.collection(folderUsers).doc(uid).collection(folderFollowers).get();
    users.followersCount = querySnapshot1.docs.length;

    var querySnapshot2 = await _firestore.collection(folderUsers).doc(uid).collection(folderFollowing).get();
    users.followingCount = querySnapshot2.docs.length;

    return users;
  }

  static Future updateUser(Users users) async {
    String? uid = await Prefs.loadUserId();
    final instance = FirebaseFirestore.instance;
    return instance.collection(folderUsers).doc(uid).update(users.toJson());
  }

  static Future<List<Users>> searchUsers(String keyword) async {
    List<Users> users = [];
    String? uid = await Prefs.loadUserId();

    final instance = FirebaseFirestore.instance;

    var querySnapshot = await _firestore
        .collection(folderUsers)
        .orderBy('email')
        .startAt([keyword]).get();

    for (var users in querySnapshot.docs) {
      Users respUser = Users.fromJson(users.data());

      //if (respUser.uid != uid) users.add(respUser);
    }

    List<Users> following = [];

    var querySnapshot2 = await _firestore.collection(folderUsers).doc(uid).collection(folderFollowing).get();

    for (var element in querySnapshot2.docs) {
      following.add(Users.fromJson(element.data()));
    }

    for (Users users in users) {
      if (following.contains(users)) {
        users.followed = true;
      } else {
        users.followed = false;
      }
    }

    return users;
  }

  // Post Related
  static Future<Post> storePost(Post post) async {
    Users me = await loadUser(id: '');

    post.uid = me.uid;
    post.fullName = me.fullName;
    post.imgUser = me.imgUrl;
    post.date = Utils.currentDate();

    String postId = _firestore
        .collection(folderUsers)
        .doc(me.uid)
        .collection(folderPosts)
        .doc().id;

    post.id = postId;

    await _firestore
        .collection(folderUsers)
        .doc(me.uid)
        .collection(folderPosts)
        .doc(postId)
        .set(post.toJson());

    return post;
  }

  static Future<Post> storeFeed(Post post) async {
    String? uid = await Prefs.loadUserId();

    await _firestore
        .collection(folderUsers)
        .doc(uid)
        .collection(folderFeeds)
        .doc(post.id)
        .set(post.toJson());

    return post;
  }

  static Future<List<Post>> loadFeeds() async {
    List<Post> posts = [];
    String? uid = await Prefs.loadUserId();
    var querySnapshot = await _firestore
        .collection(folderUsers)
        .doc(uid)
        .collection(folderFeeds)
        .get();

    for (var element in querySnapshot.docs) {
      Post post = Post.fromJson(element.data());
      if (post.uid == uid) post.mine = true;
      posts.add(post);
    }
    return posts;
  }

  static Future<List<Post>> loadPosts({String? id}) async {
    List<Post> posts = [];
    String? uid = await Prefs.loadUserId();

    if (id != null) uid = id;

    var querySnapshot = await _firestore
        .collection(folderUsers)
        .doc(uid)
        .collection(folderPosts)
        .get();

    for (var element in querySnapshot.docs) {
      Post post = Post.fromJson(element.data());
      posts.add(post);
    }
    return posts;
  }


  // Like || Unlike
  static Future<Post?> likePost(Post post, bool liked) async {
    String? uid = await Prefs.loadUserId();
    post.liked = liked;

    await _firestore.collection(folderUsers).doc(uid).collection(folderFeeds).doc(post.id).set(post.toJson());

    if (uid == post.uid) {
      await _firestore.collection(folderUsers).doc(uid).collection(folderPosts).doc(post.id).set(post.toJson());
    }
    return null;
  }

  static Future<List<Post>> loadLikes() async {
    String? uid = await Prefs.loadUserId();
    List<Post> posts = [];

    var querySnapshot = await _firestore.collection(folderUsers).doc(uid).collection(folderFeeds).where('liked', isEqualTo: true).get();

    for (var result in querySnapshot.docs) {
      Post post = Post.fromJson(result.data());

      if (post.uid == uid) post.mine = true;

      posts.add(post);
    }

    return posts;
  }


  // Follow actions
  static Future<Users> followUser(Users someone) async {
    Users me = await loadUser(id: '');

    // I followed to someone
    await _firestore.collection(folderUsers).doc(me.uid).collection(folderFollowing).doc(someone.uid).set(someone.toJson());

    // I am in someone's followers
    await _firestore.collection(folderUsers).doc(someone.uid).collection(folderFollowers).doc(me.uid).set(me.toJson());

    return someone;
  }

  static Future<Users> unfollowUser(Users someone) async {
    Users me = await loadUser(id: '');

    // I unfollowed to someone
    await _firestore.collection(folderUsers).doc(me.uid).collection(folderFollowing).doc(someone.uid).delete();

    // I am not in someone's followers
    await _firestore.collection(folderUsers).doc(someone.uid).collection(folderFollowers).doc(me.uid).delete();

    return someone;
  }

  static Future storePostsToMyFeed(Users someone) async {
    // Store someone posts to my feed

    List<Post> posts = [];

    var querySnapshot = await _firestore.collection(folderUsers).doc(someone.uid).collection(folderPosts).get();

    for (var element in querySnapshot.docs) {
      var post = Post.fromJson(element.data());

      post.liked = false;
      posts.add(post);
    }

    for (Post post in posts) {
      storeFeed(post);
    }
  }

  static Future removePostsFromMyFeed(Users someone) async {
    // Remove someone's posts from my feed

    List<Post> posts = [];

    var querySnapshot = await _firestore.collection(folderUsers).doc(someone.uid).collection(folderPosts).get();

    for (var element in querySnapshot.docs) {
      var post = Post.fromJson(element.data());

      posts.add(post);
    }

    for (Post post in posts) {
      removeFeed(post);
    }
  }

  static Future removeFeed(Post post) async {
    String? uid = await Prefs.loadUserId();

    return await _firestore.collection(folderUsers).doc(uid).collection(folderFeeds).doc(post.id).delete();
  }

  static Future removePost(Post post) async {
    String? uid = await Prefs.loadUserId();

    await removeFeed(post);

    return await _firestore.collection(folderUsers).doc(uid).collection(folderPosts).doc(post.uid).delete();
  }
}