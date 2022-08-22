import 'package:flutter/material.dart';

import '../model/users_model.dart';
import '../services/data_service.dart';
import '../services/http_service.dart';


class MySearchPage extends StatefulWidget {
  static const String id = 'my_search_page';

  const MySearchPage({Key? key}) : super(key: key);

  @override
  _MySearchPageState createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {
  // values
  final _searchController = TextEditingController();
  List<Users> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _apiSearchUsers("");
  }

  _apiSearchUsers(String keyword) {
    setState(() {
      isLoading = true;
    });

    DataService.searchUsers(keyword).then((respUsers) => {
      _respSearchUsers(respUsers),
    });
  }

  _respSearchUsers(List<Users> respUsers) {

      users = respUsers;
      isLoading = false;

  }

  // Follow action
  _apiFollowUser(Users someone) async {
    isLoading = true;

    await DataService.followUser(someone);

      someone.followed = true;
      isLoading = false;


    DataService.storePostsToMyFeed(someone);

    // Notification
    String username = '';
    DataService.loadUser(id: '').then((userMe) {
      username = userMe.fullName;
    });

    Map<String, dynamic> params = HttpService.paramCreate(username, someone.deviceToken);
    HttpService.POST(params);
  }

  _apiUnfollowUser(Users someone) async {
    setState(() {
      isLoading = true;
    });

    await DataService.unfollowUser(someone);

    setState(() {
      someone.followed = false;
      isLoading = false;
    });

    DataService.removePostsFromMyFeed(someone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Search',
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontFamily: 'Billabong'),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                // TextField : Search
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.grey.withOpacity(0.4),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black87),
                    onChanged: (input) {
                      _apiSearchUsers(input);
                    },
                    decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                        icon: Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                // Users
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (ctx, i) {
                      return _itemsOfList(users[i]);
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
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget _itemsOfList(Users user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          // Profile Image
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              border: Border.all(
                color: const Color(0xffFCAF45),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.5),
              child: user.imgUrl == null || user.imgUrl.isEmpty
                  ? const Image(
                image: AssetImage("assets/images/ic_profile.png"),
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              )
                  : Image.network(
                user.imgUrl,
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(
            width: 5,
          ),

          // FullName || Email
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FullName
              Text(
                user.fullName,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),

              const SizedBox(
                height: 5,
              ),

              // Email
              Text(
                user.email,
                style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                    fontSize: 14),
              ),
            ],
          ),

          // Button : Follow
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    if (user.followed) {
                      _apiUnfollowUser(user);
                    } else {
                      _apiFollowUser(user);
                    }
                  },
                  child: Container(
                    height: 30,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user.followed ? 'Followed' : 'Follow',
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}