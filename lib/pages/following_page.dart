import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/user.dart';
import 'package:newspector_flutter/services/user_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';
import 'package:newspector_flutter/widgets/home_page/news_group_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

class FollowingPage extends StatefulWidget {
  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  User _user;
  int pageSize = app_const.followingPagePageSize;
  int newsGroupPageSize = app_const.newsGroupPageSize;
  var loadMoreVisible = true;

  @override
  Widget build(BuildContext context) {
    // if there is an existing feed show that
    if (UserService.hasUserWithFeed()) {
      _user = UserService.getUser();
      loadMoreVisible = _user.followingFeed.getItemCount() >= pageSize;
      return homeScaffold();
    }

    // if there is no existing feed,
    // get the latest feed and display it
    return FutureBuilder(
      future: getFeed(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
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
      appBar: AppBar(
        title: Text(
          "Following",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: app_const.backgroundColor,
      ),
      backgroundColor: app_const.backgroundColor,
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  // shown when there is a user
  Widget homeScaffold() {
    return Scaffold(
      backgroundColor: app_const.backgroundColor,
      body: FeedContainer(
        sliverAppBar: sliverAppBar(),
        feed: _user.followingFeed,
        onRefresh: getRefreshedFeed,
        onBottomReached: fetchAdditionalNewsGroups,
        loadMoreVisible: loadMoreVisible,
        emptyListMessage: "You are not following any news groups yet.",
        buildContainer: (String newsGroupId) {
          return NewsGroupContainer(
            newsGroupId: newsGroupId,
          );
        },
      ),
    );
  }

  Widget sliverAppBar() {
    return SliverAppBar(
      title: Text(
        "Following",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: app_const.backgroundColor,
      floating: true,
      pinned: false,
      snap: false,
    );
  }

  Future<User> getFeed() async {
    _user = await UserService.updateAndGetUserWithFeed(
      pageSize: pageSize,
      newsGroupPageSize: newsGroupPageSize,
    );
    loadMoreVisible = _user.followingFeed.getItemCount() >= pageSize;
    return _user;
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> getRefreshedFeed() async {
    _user = await getFeed();
    if (mounted) setState(() {});
  }

  // this fetches additional items
  // called when user reached the bottom of the page
  Future<void> fetchAdditionalNewsGroups() async {
    var lastDocumentId = _user.followingFeed.getLastItem();

    _user = await UserService.updateAndGetUserWithFeed(
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
      newsGroupPageSize: newsGroupPageSize,
    );

    loadMoreVisible = lastDocumentId != _user.followingFeed.getLastItem();
    if (mounted) setState(() {});
  }
}
