import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';

class FeedContainer<E> extends StatefulWidget {
  final Feed<E> feed;
  final Function onRefresh;
  final Function onBottomReached;
  final bool loadMoreVisible;
  final Function buildContainer;

  FeedContainer({
    Key key,
    @required this.feed,
    @required this.onRefresh,
    @required this.onBottomReached,
    @required this.loadMoreVisible,
    @required this.buildContainer,
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
            // margin: EdgeInsets.all(20),
            // alignment: Alignment.center,
            child: widget.buildContainer(widget.feed.getItem(index)),
            // NewsGroupContainer(
            // newsGroupId: widget.feed.getItem(index),
            // ),
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
