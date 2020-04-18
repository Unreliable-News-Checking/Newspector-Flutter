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
    print("has feed: ${NewsFeedService.hasFeed()}");

    // if there is an existing feed show that
    if (NewsFeedService.hasFeed()) {
      _newsFeed = NewsFeedService.getNewsFeed();
      if (_newsFeed.getItemCount() < pageSize) {
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
            _newsFeed = snapshot.data;
            print("count in future builder ${_newsFeed.getItemCount()}");
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
    print("count: ${_newsFeed.getItemCount()}");

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

  Future<NewsFeed> getInitialFeed() async {
    print("get initial feed called");
    _newsFeed = null;
    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
    );

    if (_newsFeed.getItemCount() < pageSize) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    print("count in get initial feed: ${_newsFeed.getItemCount()}");

    return _newsFeed;
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> getRefreshedFeed() async {
    print("get refreshed feed called");

    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
    );

    if (_newsFeed.getItemCount() < pageSize) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    if (mounted) {
      setState(() {});
    }
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> fetchAdditionalNewsGroups() async {
    print("fetch additional items called");

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

    if (mounted) {
      setState(() {});
    }
  }
}
