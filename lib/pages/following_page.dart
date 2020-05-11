import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/user.dart';
import 'package:newspector_flutter/services/user_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';
import 'package:newspector_flutter/widgets/news_group_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

class FollowingPage extends StatefulWidget {
  final ScrollController scrollController;

  FollowingPage({
    Key key,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> with FeedContainer {
  User _user;
  int pageSize = app_const.followingPagePageSize;
  int newsGroupPageSize = app_const.newsGroupPageSize;
  ScrollController _scrollController;
  var loadMoreVisible = true;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    // if there is an existing feed show that
    if (UserService.hasUserWithFeed()) {
      _user = UserService.getUser();
      loadMoreVisible = _user.followingFeed.getItemCount() < pageSize
          ? false
          : loadMoreVisible;

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
            return loadingScaffold('Following');
        }
      },
    );
  }

  // shown when there is a user
  Widget homeScaffold() {
    return Scaffold(
      backgroundColor: app_const.backgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          return onScrollNotification(
            loadMoreVisible,
            isLoading,
            scrollInfo,
            fetchAdditionalItems,
            (loading) => isLoading = loading,
          );
        },
        child: CupertinoScrollbar(
          child: CustomScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics()
                .applyTo(AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              sliverAppBar("Following"),
              refreshControl(getFeed),
              itemList(),
              loadMoreContainer(loadMoreVisible),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemList() {
    if (_user.followingFeed.getItemCount() == 0)
      return emptyList("You are not following any news groups yet.");

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            child: NewsGroupContainer(
              newsGroupId: _user.followingFeed.getItem(index),
            ),
          );
        },
        childCount: _user.followingFeed.getItemCount(),
      ),
    );
  }

  ///
  Future<User> getFeed() async {
    _user = await UserService.updateAndGetUserWithFeed(
      pageSize: pageSize,
      newsGroupPageSize: newsGroupPageSize,
    );
    loadMoreVisible = _user.followingFeed.getItemCount() >= pageSize;
    if (mounted) setState(() {});
    return _user;
  }

  /// this fetches additional items
  /// called when user reached the bottom of the page
  Future<void> fetchAdditionalItems() async {
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
