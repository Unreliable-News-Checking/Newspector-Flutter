import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/widgets/news_group_container.dart';

class NewsGroupPage extends StatefulWidget {
  final String newsGroupId;

  NewsGroupPage({Key key, @required this.newsGroupId}) : super(key: key);

  @override
  _NewsGroupPageState createState() => _NewsGroupPageState();
}

class _NewsGroupPageState extends State<NewsGroupPage> with FeedContainerTest {
  NewsGroup _newsGroup;
  ScrollController _scrollController;
  var pageSize = app_const.newsGroupPageSize;
  var loadMoreVisible = true;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.newsGroupId);
    if (NewsGroupService.hasNewsGroup(widget.newsGroupId)) {
      _newsGroup = NewsGroupService.getNewsGroup(widget.newsGroupId);
      loadMoreVisible = _newsGroup.newsArticleFeed.getItemCount() < pageSize
          ? false
          : loadMoreVisible;
      return homeScaffold();
    }

    // if there is no existing feed,
    // get the latest feed and display it
    return FutureBuilder(
      future: getFeed(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            _newsGroup = snapshot.data;
            return homeScaffold();
            break;
          default:
            return loadingScaffold('');
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
              sliverAppBar("Following"),
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
    if (_newsGroup.newsArticleFeed.getItemCount() == 0)
      return emptyList("You are not following any news groups yet.");

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            child: NewsGroupContainer(
              newsGroupId: _newsGroup.newsArticleFeed.getItem(index),
            ),
          );
        },
        childCount: _newsGroup.newsArticleFeed.getItemCount(),
      ),
    );
  }

  Future<NewsGroup> getFeed() async {
    _newsGroup = await NewsGroupService.updateAndGetNewsGroupFeed(
      newsGroupId: widget.newsGroupId,
      pageSize: pageSize,
    );

    loadMoreVisible = _newsGroup.newsArticleFeed.getItemCount() >= pageSize;
    if (mounted) setState(() {});
    return _newsGroup;
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> fetchAdditionalItems() async {
    var lastDocumentId = _newsGroup.newsArticleFeed.getLastItem();

    _newsGroup = await NewsGroupService.updateAndGetNewsGroupFeed(
      newsGroupId: widget.newsGroupId,
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
    );

    loadMoreVisible =
        lastDocumentId != _newsGroup.newsArticleFeed.getLastItem();
  }
}
