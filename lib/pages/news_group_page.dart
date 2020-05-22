import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/widgets/news_group_page/ngp_news_article_container.dart';

class NewsGroupPage extends StatefulWidget {
  final String newsGroupId;

  NewsGroupPage({Key key, @required this.newsGroupId}) : super(key: key);

  @override
  _NewsGroupPageState createState() => _NewsGroupPageState();
}

class _NewsGroupPageState extends State<NewsGroupPage>
    with FeedContainer<NewsGroupPage, NewsGroup> {
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
              sliverAppBar("Full Coverage"),
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
            child: TimelineItem(
              newsArticleId: _newsGroup.getNewsArticleId(index),
              dontShowTopLine: index == 0,
              dontShowBottomDivider:
                  index == _newsGroup.newsArticleFeed.getItemCount() - 1,
            ),
          );
        },
        childCount: _newsGroup.newsArticleFeed.getItemCount(),
      ),
    );
  }

  @override
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

class TimelineItem extends StatelessWidget {
  final String newsArticleId;
  final bool dontShowTopLine;
  final bool dontShowBottomDivider;

  const TimelineItem({
    Key key,
    @required this.newsArticleId,
    this.dontShowTopLine,
    @required this.dontShowBottomDivider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              height: double.infinity,
              child: Column(
                children: <Widget>[
                  dontShowTopLine ? Container(height: 10) : line(heigth: 10),
                  ball(),
                  line(),
                ],
              ),
            ),
            Flexible(
              child: Container(
                child: NewsGroupPageNewsArticleContainer(
                  dontShowDivider: dontShowBottomDivider,
                  newsArticleId: newsArticleId,
                  topMargin: 10,
                  // onTap: () {
                  //   Navigator.of(context)
                  //       .push(MaterialPageRoute(builder: (context) {
                  //     return NewsArticlePage(
                  //       newsArticleId: newsArticleId,
                  //     );
                  //   }));
                  // },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget line({double heigth}) {
    var width = 1.0;
    var color = app_const.inactiveColor;

    if (heigth != null) {
      return Container(
        height: heigth,
        width: width,
        color: color,
      );
    }

    return Expanded(
      child: Container(
        width: width,
        color: color,
      ),
    );
  }

  Widget ball() {
    var radius = 9.0;
    var margin = 3.0;
    return Container(
      margin: EdgeInsets.all(margin),
      height: radius,
      width: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: app_const.inactiveColor,
      ),
    );
  }
}
