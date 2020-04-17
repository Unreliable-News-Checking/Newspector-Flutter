import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_feed.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NewsFeed _newsFeed;
  var pageSize = 3;
  var loadMoreVisible = true;

  @override
  Widget build(BuildContext context) {
    // if there is an existing feed show that
    if (NewsFeedService.hasFeed()) {
      _newsFeed = NewsFeedService.getNewsFeed();
      return homeScaffold();
    }

    // if there is no existing feed,
    // get the latest feed and display it
    return FutureBuilder(
      future: NewsFeedService.updateAndGetNewsFeed(
        pageSize: pageSize,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            _newsFeed = snapshot.data;
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

  // shown when there is a feed with news groups
  Widget homeScaffold() {
    return Scaffold(
      appBar: appBar(),
      body: FeedContainer<String>(
        feed: _newsFeed,
        onRefresh: getRefreshedFeed,
        onBottomReached: fetchAdditionalNewsGroups,
        loadMoreVisible: loadMoreVisible,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      title: Text("Newspector"),
    );
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> getRefreshedFeed() async {
    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
    );
    loadMoreVisible = true;
    if (mounted) {
      setState(() {});
    }
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> fetchAdditionalNewsGroups() async {
    var lastDocumentId = _newsFeed.getLastItem();

    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
    );

    if (lastDocumentId == _newsFeed.getLastItem()) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    print(_newsFeed.getItemCount());
    if (mounted) {
      setState(() {});
    }
  }
}
