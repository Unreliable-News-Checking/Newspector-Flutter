import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/widgets/news_sources_page/news_source_container.dart';

class NewsSourcesPage extends StatefulWidget {
  @override
  _NewsSourcesPageState createState() => _NewsSourcesPageState();
}

class _NewsSourcesPageState extends State<NewsSourcesPage> {
  Feed<String> _newsSourceFeed;
  int pageSize = 11;
  bool loadMoreVisible = true;

  @override
  Widget build(BuildContext context) {
    if (NewsSourceService.hasFeed()) {
      _newsSourceFeed = NewsSourceService.getNewsSourceFeed();
      if (_newsSourceFeed.getItemCount() < pageSize) {
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
      body: FeedContainer(
        feed: _newsSourceFeed,
        loadMoreVisible: loadMoreVisible,
        onBottomReached: fetchAdditionalNewsGroups,
        onRefresh: getRefreshedFeed,
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

  Widget appBar() {
    return AppBar(
      title: Text("Sources"),
    );
  }

  Future<Feed<String>> getInitialFeed() async {
    _newsSourceFeed = await NewsSourceService.updateAndGetNewsSourceFeed(
      pageSize: pageSize,
    );

    if (_newsSourceFeed.getItemCount() < pageSize) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    return _newsSourceFeed;
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> getRefreshedFeed() async {
    _newsSourceFeed = await NewsSourceService.updateAndGetNewsSourceFeed(
      pageSize: pageSize,
    );

    if (_newsSourceFeed.getItemCount() < pageSize) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    if (mounted) setState(() {});
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> fetchAdditionalNewsGroups() async {
    var lastDocumentId = _newsSourceFeed.getLastItem();

    _newsSourceFeed = await NewsSourceService.updateAndGetNewsSourceFeed(
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
    );

    if (lastDocumentId == _newsSourceFeed.getLastItem()) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    if (mounted) setState(() {});
  }
}
