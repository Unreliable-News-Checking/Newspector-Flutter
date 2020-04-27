import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/user.dart';
import 'package:newspector_flutter/services/user_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/widgets/home_page/news_group_container.dart';

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
      if (_user.followingFeed.getItemCount() < pageSize) {
        loadMoreVisible = false;
      }
      return homeScaffold();
    }

    // if there is no existing feed,
    // get the latest feed and display it
    return FutureBuilder(
      future: getInitialFeed(),
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
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  // shown when there is a user
  Widget homeScaffold() {
    return Scaffold(
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
      title: Text("Following"),
      backgroundColor: Theme.of(context).backgroundColor,
      floating: true,
      pinned: false,
      snap: false,
    );
  }

  Future<User> getInitialFeed() async {
    _user = await UserService.updateAndGetUserFeed(
      pageSize: pageSize,
      newsGroupPageSize: newsGroupPageSize,
    );

    if (_user.followingFeed.getItemCount() < pageSize) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    return _user;
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> getRefreshedFeed() async {
    _user = await UserService.updateAndGetUserFeed(
      pageSize: pageSize,
      newsGroupPageSize: newsGroupPageSize,
    );

    if (_user.followingFeed.getItemCount() < pageSize) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    if (mounted) {
      setState(() {});
    }
  }

  // this fetches additional items
  // called when user reached the bottom of the page
  Future<void> fetchAdditionalNewsGroups() async {
    var lastDocumentId = _user.followingFeed.getLastItem();

    _user = await UserService.updateAndGetUserFeed(
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
      newsGroupPageSize: newsGroupPageSize,
    );

    if (lastDocumentId == _user.followingFeed.getLastItem()) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    if (mounted) {
      setState(() {});
    }
  }
}