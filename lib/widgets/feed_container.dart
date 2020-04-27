import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';

class FeedContainer<E> extends StatefulWidget {
  final SliverAppBar sliverAppBar;
  final Feed<E> feed;
  final Function onRefresh;
  final Function onBottomReached;
  final bool loadMoreVisible;
  final Function buildContainer;
  final String emptyListMessage;

  FeedContainer({
    Key key,
    @required this.feed,
    @required this.onRefresh,
    @required this.onBottomReached,
    @required this.loadMoreVisible,
    @required this.buildContainer,
    @required this.emptyListMessage,
    @required this.sliverAppBar,
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
            widget.sliverAppBar,
            refreshControl(),
            itemList(),
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

  Widget itemList() {
    if (widget.feed.getItemCount() == 0) return emptyItemList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            child: widget.buildContainer(widget.feed.getItem(index)),
          );
        },
        childCount: widget.feed.getItemCount(),
      ),
    );
  }

  // shown when the page is loading the new feed
  Widget emptyItemList() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(top: 50),
        child: Center(
          child: Text(widget.emptyListMessage),
        ),
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