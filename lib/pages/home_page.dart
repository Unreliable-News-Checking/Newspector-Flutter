import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_feed.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'package:newspector_flutter/widgets/news_feed_container.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NewsFeed newsFeed;
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // if there is an existing feed show that
    if (NewsFeedService.hasFeed()) {
      newsFeed = NewsFeedService.getNewsFeed();
      return homeScaffold();
    }

    // if there is no existing feed,
    // get the latest feed and display it
    return FutureBuilder(
      future: NewsFeedService.updateAndGetNewsFeed(
        pageSize: 10,
        lastTimeStamp: "",
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            newsFeed = snapshot.data;
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
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  // shown when there is no news in the feed
  Widget emptyScaffold() {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        margin: EdgeInsets.all(30),
        alignment: Alignment.center,
        child: Text("NO POSTS"),
      ),
    );
  }

  // shown when there is a feed with news groups
  Widget homeScaffold() {
    return Scaffold(
      body: CupertinoScrollbar(
        child: CustomScrollView(
          controller: _scrollController,
          physics:
              BouncingScrollPhysics().applyTo(AlwaysScrollableScrollPhysics()),
          slivers: <Widget>[
            SliverAppBar(),
            refreshControl(),
            NewsFeedContainer(newsFeed: newsFeed),
          ],
        ),
      ),
    );
  }

  Widget refreshControl() {
    return CupertinoSliverRefreshControl(
      onRefresh: () {
        return getRefreshedFeed();
      },
    );
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> getRefreshedFeed() async {
    newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: 10,
      lastTimeStamp: DateTime.now(),
    );
    if (mounted) {
      setState(() {});
    }
  }
}
