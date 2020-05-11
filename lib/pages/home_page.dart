import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/pages/sign_page.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';
import 'package:newspector_flutter/widgets/news_group_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/services/sign_in_service.dart'
    as sign_in_service;

class HomePage extends StatefulWidget {
  final ScrollController scrollController;

  HomePage({
    Key key,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with FeedContainer {
  Feed<String> _newsFeed;
  ScrollController _scrollController;
  var pageSize = app_const.homePagePageSize;
  var newsGroupPageSize = app_const.newsGroupPageSize;
  var loadMoreVisible = true;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    if (NewsFeedService.hasFeed()) {
      _newsFeed = NewsFeedService.getFeed();
      loadMoreVisible =
          _newsFeed.getItemCount() < pageSize ? false : loadMoreVisible;

      return homeScaffold();
    }

    return FutureBuilder(
      future: getFeed(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return homeScaffold();
            break;
          default:
            return loadingScaffold("Newspector");
        }
      },
    );
  }

  // shown when there is a feed with news groups
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
              sliverAppBar(
                "Newspector",
                actions: <Widget>[
                  CloseButton(
                    onPressed: () {
                      sign_in_service.signOutGoogle();
                      Navigator.of(context, rootNavigator: true)
                          .pushReplacement(
                              MaterialPageRoute(builder: (context) {
                        return SignPage();
                      }));
                    },
                  ),
                ],
              ),
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
    if (_newsFeed.getItemCount() == 0)
      return emptyList("You are not following any news groups yet.");

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            child: NewsGroupContainer(
              newsGroupId: _newsFeed.getItem(index),
            ),
          );
        },
        childCount: _newsFeed.getItemCount(),
      ),
    );
  }

  /// If there is an existing feed returns it,
  /// if not fetches the feed from the database and returns it.
  Future<Feed<String>> getFeed() async {
    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      newsGroupPageSize: newsGroupPageSize,
    );

    loadMoreVisible = _newsFeed.getItemCount() >= pageSize;
    if (mounted) setState(() {});
    return _newsFeed;
  }

  /// Fetches the wanted documents after the specified document.
  Future<void> fetchAdditionalItems() async {
    var lastDocumentId = _newsFeed.getLastItem();

    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
      newsGroupPageSize: newsGroupPageSize,
    );

    loadMoreVisible = lastDocumentId != _newsFeed.getLastItem();
  }
}
