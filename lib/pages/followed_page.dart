import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/user.dart';
import 'package:newspector_flutter/services/user_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';

class FollowedPage extends StatefulWidget {
  @override
  _FollowedPageState createState() => _FollowedPageState();
}

class _FollowedPageState extends State<FollowedPage> {
  User _user;
  int pageSize = 10;

  @override
  Widget build(BuildContext context) {
    // if there is an existing feed show that
    if (UserService.hasUserWithFeed()) {
      _user = UserService.getUser();
      return homeScaffold();
    }

    // if there is no existing feed,
    // get the latest feed and display it
    return FutureBuilder(
      future: UserService.updateAndGetUserFeed(pageSize: pageSize),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            _user = snapshot.data;
            return homeScaffold();
            break;
          default:
            return loadingScaffold();
        }
      },
    );
  }

  // shown when the page is loading the new feed
  Widget loadingScaffold() {
    return Scaffold(
      appBar: appBar(),
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  // shown when there is a user
  Widget homeScaffold() {
    return Scaffold(
      appBar: appBar(),
      body: FeedContainer(
        feed: _user.followingFeed,
        onRefresh: getRefreshedFeed,
        onBottomReached: null,
        loadMoreVisible: true,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      title: Text("Following"),
    );
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> getRefreshedFeed() async {
    _user = await UserService.updateAndGetUserFeed(pageSize: pageSize);

    if (mounted) {
      setState(() {});
    }
  }
}
