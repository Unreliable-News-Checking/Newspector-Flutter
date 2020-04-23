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
        emptyListMessage: "There are no news available yet.",
        buildContainer: (String newsGroupId) {
          return NewsGroupContainer(
            newsGroupId: newsGroupId,
          );
        },
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      title: Text("Newspector"),
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

  Future<NewsFeed> getInitialFeed() async {
    _newsFeed = null;
    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      newsGroupPageSize: newsGroupPageSize,
    );

    if (_newsFeed.getItemCount() < pageSize) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    return _newsFeed;
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> getRefreshedFeed() async {
    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      newsGroupPageSize: newsGroupPageSize,
    );

    if (_newsFeed.getItemCount() < pageSize) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    if (mounted) setState(() {});
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> fetchAdditionalNewsGroups() async {
    var lastDocumentId = _newsFeed.getLastItem();

    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
      newsGroupPageSize: newsGroupPageSize,
    );

    if (lastDocumentId == _newsFeed.getLastItem()) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    if (mounted) setState(() {});
  }
}
