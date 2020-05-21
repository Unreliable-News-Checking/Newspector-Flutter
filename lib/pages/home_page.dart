import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/category.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';
import 'package:newspector_flutter/widgets/news_group_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

class NewsFeedPage extends StatefulWidget {
  final ScrollController scrollController;
  final FeedType feedType;
  final NewsCategory newsCategory;
  final String title;
  final List<Widget> actions;

  NewsFeedPage({
    Key key,
    @required this.scrollController,
    @required this.feedType,
    @required this.title,
    this.newsCategory,
    this.actions,
  }) : super(key: key);

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage>
    with FeedContainer<NewsFeedPage, Feed<String>> {
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
    if (NewsFeedService.hasFeed(widget.feedType,
        newsCategory: widget.newsCategory)) {
      _newsFeed = NewsFeedService.getFeed(widget.feedType,
          newsCategory: widget.newsCategory);
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
            return loadingScaffold(widget.title);
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
                widget.title,
                actions: widget.actions,
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
      return emptyList("There are no news groups yet.");

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
  @override
  Future<Feed<String>> getFeed() async {
    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      newsGroupPageSize: newsGroupPageSize,
      feedType: widget.feedType,
      newsCategory: widget.newsCategory,
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
      feedType: widget.feedType,
      newsCategory: widget.newsCategory,
    );

    loadMoreVisible = lastDocumentId != _newsFeed.getLastItem();
  }
}
