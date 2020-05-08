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

class _HomePageState extends State<HomePage> {
  Feed<String> _newsFeed;
  var pageSize = app_const.homePagePageSize;
  var newsGroupPageSize = app_const.newsGroupPageSize;
  var loadMoreVisible = true;

  StreamController _loadMoreController;
  Stream loadMoreStream;

  @override
  void initState() {
    super.initState();
    _loadMoreController = StreamController.broadcast();
    loadMoreStream = _loadMoreController.stream;
  }

  @override
  Widget build(BuildContext context) {
    if (NewsFeedService.hasFeed()) {
      _newsFeed = NewsFeedService.getFeed();
      loadMoreVisible =
          _newsFeed.getItemCount() < pageSize ? false : loadMoreVisible;
      _loadMoreController.add(loadMoreVisible);

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
          "Newspector",
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

  // shown when there is a feed with news groups
  Widget homeScaffold() {
    return Scaffold(
      backgroundColor: app_const.backgroundColor,
      body: FeedContainer<String>(
        sliverAppBar: sliverAppBar(),
        feed: _newsFeed,
        scrollController: widget.scrollController,
        onRefresh: getFeed,
        onBottomReached: fetchAdditionalNewsGroups,
        loadMoreStream: loadMoreStream,
        emptyListMessage: "There are no news available yet.",
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
        "Newspector",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      floating: true,
      pinned: false,
      snap: false,
      elevation: 0,
      backgroundColor: app_const.backgroundColor,
      actions: <Widget>[
        CloseButton(
          onPressed: () {
            sign_in_service.signOutGoogle();
            Navigator.of(context, rootNavigator: true)
                .pushReplacement(MaterialPageRoute(builder: (context) {
              return SignPage();
            }));
          },
        ),
      ],
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
    _loadMoreController.add(loadMoreVisible);
    if (mounted) setState(() {});
    return _newsFeed;
  }

  /// Fetches the wanted documents after the specified document.
  Future<void> fetchAdditionalNewsGroups() async {
    print("in fetch additional");
    var lastDocumentId = _newsFeed.getLastItem();

    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
      newsGroupPageSize: newsGroupPageSize,
    );

    loadMoreVisible = lastDocumentId != _newsFeed.getLastItem();
    _loadMoreController.add(loadMoreVisible);
  }
}
