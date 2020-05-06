import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/widgets/news_sources_page/news_source_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

class NewsSourcesPage extends StatefulWidget {
  @override
  _NewsSourcesPageState createState() => _NewsSourcesPageState();
}

class _NewsSourcesPageState extends State<NewsSourcesPage> {
  Feed<String> _newsSourceFeed;
  int pageSize = 11;
  bool loadMoreVisible = true;

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
    if (NewsSourceService.hasFeed()) {
      _newsSourceFeed = NewsSourceService.getNewsSourceFeed();
      loadMoreVisible =
          _newsSourceFeed.getItemCount() < pageSize ? false : loadMoreVisible;
      _loadMoreController.add(loadMoreVisible);

      return homeScaffold();
    }

    // if there is no existing feed,
    // get the latest feed and display it
    return FutureBuilder(
      future: getFeed(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            _newsSourceFeed = snapshot.data;
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
      backgroundColor: app_const.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Sources",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: app_const.backgroundColor,
      ),
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
      body: FeedContainer(
        sliverAppBar: sliverAppBar(),
        feed: _newsSourceFeed,
        loadMoreStream: loadMoreStream,
        onBottomReached: fetchAdditionalNewsGroups,
        onRefresh: getFeed,
        emptyListMessage: "There are no news sources yet.",
        buildContainer: (String newsSourceId) {
          return NewsSourceContainer(
            newsSourceId: newsSourceId,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return NewsSourcePage(
                  newsSourceId: newsSourceId,
                );
              }));
            },
          );
        },
      ),
    );
  }

  Widget sliverAppBar() {
    return SliverAppBar(
      title: Text(
        "Sources",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      floating: true,
      pinned: false,
      snap: false,
      backgroundColor: app_const.backgroundColor,
    );
  }

  Future<Feed<String>> getFeed() async {
    _newsSourceFeed = await NewsSourceService.updateAndGetNewsSourceFeed(
      pageSize: pageSize,
    );

    loadMoreVisible = _newsSourceFeed.getItemCount() >= pageSize;
    _loadMoreController.add(loadMoreVisible);
    return _newsSourceFeed;
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> fetchAdditionalNewsGroups() async {
    var lastDocumentId = _newsSourceFeed.getLastItem();

    _newsSourceFeed = await NewsSourceService.updateAndGetNewsSourceFeed(
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
    );

    loadMoreVisible = lastDocumentId != _newsSourceFeed.getLastItem();
    _loadMoreController.add(loadMoreVisible);
  }
}
