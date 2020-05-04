import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_feed.dart';
import 'package:newspector_flutter/pages/sign_page.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/widgets/home_page/news_group_container.dart';
import 'package:newspector_flutter/services/sign_in_service.dart'
    as sign_in_service;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NewsFeed _newsFeed;
  var pageSize = app_const.homePagePageSize;
  var newsGroupPageSize = app_const.newsGroupPageSize;
  var loadMoreVisible = true;

  @override
  Widget build(BuildContext context) {
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
        onRefresh: getRefreshedFeed,
        onBottomReached: fetchAdditionalNewsGroups,
        loadMoreVisible: loadMoreVisible,
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
  Future<void> getFeed() async {
    _newsFeed = await NewsFeedService.getOrFetchNewsFeed();
    loadMoreVisible = _newsFeed.getItemCount() >= pageSize;
  }

  /// Forces a fresh fetch of the feed from the database.
  Future<void> getRefreshedFeed() async {
    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      newsGroupPageSize: newsGroupPageSize,
    );
    loadMoreVisible = _newsFeed.getItemCount() >= pageSize;
    if (mounted) setState(() {});
  }

  /// Fetches the wanted documents after the specified document.
  Future<void> fetchAdditionalNewsGroups() async {
    var lastDocumentId = _newsFeed.getLastItem();

    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
      newsGroupPageSize: newsGroupPageSize,
    );

    loadMoreVisible = lastDocumentId != _newsFeed.getLastItem();
    if (mounted) setState(() {});
  }
}
