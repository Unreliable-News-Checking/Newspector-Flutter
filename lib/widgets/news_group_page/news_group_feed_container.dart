import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/pages/news_article_page.dart';
import 'package:newspector_flutter/widgets/news_group_page/news_article_container.dart'
    as nac;
import 'package:newspector_flutter/models/news_group.dart';

class NewsGroupFeedContainer extends StatefulWidget {
  final NewsGroup newsGroup;
  final Function onRefresh;
  final Function onBottomReached;
  final bool loadMoreVisible;

  NewsGroupFeedContainer(
      {Key key,
      @required this.newsGroup,
      @required this.onRefresh,
      @required this.onBottomReached,
      @required this.loadMoreVisible})
      : super(key: key);

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

  const TimelineItem({
    Key key,
    @required this.newsArticleId,
    this.dontShowTopLine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: double.infinity,
              child: Column(
                children: <Widget>[
                  dontShowTopLine ? Expanded(child: Container()) : line(),
                  ball(),
                  line(),
                ],
              ),
            ),
            Flexible(
              child: Card(
                margin: EdgeInsets.all(10),
                child: nac.NewsArticleContainer(
                  newsArticleId: newsArticleId,
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

  Widget line() {
    var width = 2.0;
    var color = Colors.grey;
    return Expanded(
      child: Container(
        width: width,
        color: color,
      ),
    );
  }

  Widget ball() {
    var radius = 20.0;
    var margin = 5.0;
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
