import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/pages/news_article_page.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/application_constants.dart' as app_consts;

import 'news_group_page_news_article_container.dart';

class NewsGroupFeedContainer extends StatefulWidget {
  final SliverAppBar sliverAppBar;
  final NewsGroup newsGroup;
  final Function onRefresh;
  final Function onBottomReached;
  final bool loadMoreVisible;

  NewsGroupFeedContainer({
    Key key,
    @required this.newsGroup,
    @required this.onRefresh,
    @required this.onBottomReached,
    @required this.loadMoreVisible,
    @required this.sliverAppBar,
  }) : super(key: key);

  @override
  _NewsGroupFeedContainerState createState() => _NewsGroupFeedContainerState();
}

class _NewsGroupFeedContainerState extends State<NewsGroupFeedContainer> {
  ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        var reachedBottom =
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent;

        if (!reachedBottom) return true;

        onBottomReached();

        return true;
      },
      child: CupertinoScrollbar(
        child: CustomScrollView(
          controller: _scrollController,
          physics:
              BouncingScrollPhysics().applyTo(AlwaysScrollableScrollPhysics()),
          slivers: <Widget>[
            widget.sliverAppBar,
            refreshControl(),
            newsArticleList(),
            SliverToBoxAdapter(
              child: loadMoreContainer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget refreshControl() {
    return CupertinoSliverRefreshControl(
      onRefresh: widget.onRefresh,
    );
  }

  Widget newsArticleList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            alignment: Alignment.center,
            child: TimelineItem(
              newsArticleId: widget.newsGroup.getNewsArticleId(index),
              dontShowTopLine: index == 0,
              dontShowBottomDivider:
                  index == widget.newsGroup.newsArticleFeed.getItemCount() - 1,
            ),
          );
        },
        childCount: widget.newsGroup.newsArticleFeed.getItemCount(),
      ),
    );
  }

  Widget loadMoreContainer() {
    if (!widget.loadMoreVisible) return Container();

    return Container(
      height: 50,
      color: Colors.transparent,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void onBottomReached() async {
    if (!widget.loadMoreVisible) return;
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    await widget.onBottomReached();

    setState(() {
      isLoading = false;
    });
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
                  backgroundColor: app_consts.newsArticleBackgroundColor,
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return NewsArticlePage(
                        newsArticleId: newsArticleId,
                      );
                    }));
                  },
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
    var color = Colors.grey;

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
        color: Colors.grey,
      ),
    );
  }
}
