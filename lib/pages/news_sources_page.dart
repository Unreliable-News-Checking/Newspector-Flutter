import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/widgets/news_sources_page/news_source_container.dart';

class NewsSourcesPage extends StatefulWidget {
  final ScrollController scrollController;

  NewsSourcesPage({
    Key key,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _NewsSourcesPageState createState() => _NewsSourcesPageState();
}

class _NewsSourcesPageState extends State<NewsSourcesPage>
    with FeedContainer<NewsSourcesPage, Feed<String>> {
  Feed<String> _newsSourceFeed;
  ScrollController _scrollController;
  var pageSize = 11;
  var loadMoreVisible = true;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    if (NewsSourceService.hasFeed()) {
      _newsSourceFeed = NewsSourceService.getNewsSourceFeed();
      loadMoreVisible =
          _newsSourceFeed.getItemCount() < pageSize ? false : loadMoreVisible;

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
            return loadingScaffold("Sources");
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
              sliverAppBar("Sources"),
              refreshControl(getFeed),
              itemList(),
              loadMoreContainer(loadMoreVisible),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget itemList() {
    if (_newsSourceFeed.getItemCount() == 0)
      return emptyList("You are not following any news groups yet.");

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            child: NewsSourceContainer(
              newsSourceId: _newsSourceFeed.getItem(index),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return NewsSourcePage(
                    newsSourceId: _newsSourceFeed.getItem(index),
                  );
                }));
              },
            ),
          );
        },
        childCount: _newsSourceFeed.getItemCount(),
      ),
    );
  }

  @override
  Future<Feed<String>> getFeed() async {
    _newsSourceFeed = await NewsSourceService.updateAndGetNewsSourceFeed(
      pageSize: pageSize,
    );

    loadMoreVisible = _newsSourceFeed.getItemCount() >= pageSize;
    return _newsSourceFeed;
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  @override
  Future<void> fetchAdditionalItems() async {
    var lastDocumentId = _newsSourceFeed.getLastItem();

    _newsSourceFeed = await NewsSourceService.updateAndGetNewsSourceFeed(
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
    );

    loadMoreVisible = lastDocumentId != _newsSourceFeed.getLastItem();
  }
}
