import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/widgets/home_page/news_group_container.dart';

class FeedContainer<E> extends StatefulWidget {
  final Feed<E> feed;
  final Function onRefresh;
  final Function onBottomReached;
  final bool loadMoreVisible;

  FeedContainer({
    Key key,
    @required this.feed,
    @required this.onRefresh,
    @required this.onBottomReached,
    @required this.loadMoreVisible,
  }) : super(key: key);

  @override
  _FeedContainerState createState() => _FeedContainerState();
}

class _FeedContainerState extends State<FeedContainer> {
  ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        var loadNewItems = !isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent;

        if (!loadNewItems) return true;

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
            newsGroupList(),
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

  Widget newsGroupList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            margin: EdgeInsets.all(30),
            alignment: Alignment.center,
            child: NewsGroupContainer(
              newsGroupId: widget.feed.getItem(index),
            ),
          );
        },
        childCount: widget.feed.getItemCount(),
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
    setState(() {
      isLoading = true;
    });

    await widget.onBottomReached();

    setState(() {
      isLoading = false;
    });
  }
}
