import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';

class NSPFeedContainer<E> extends StatefulWidget {
  final SliverAppBar sliverAppBar;
  final Feed<E> feed;
  final Function onRefresh;
  final Function onBottomReached;
  final Function buildContainer;
  final String emptyListMessage;
  final ScrollController scrollController;
  final Stream loadMoreStream;

  NSPFeedContainer({
    Key key,
    @required this.feed,
    @required this.onRefresh,
    @required this.onBottomReached,
    @required this.buildContainer,
    @required this.emptyListMessage,
    @required this.sliverAppBar,
    @required this.loadMoreStream,
    this.scrollController,
  }) : super(key: key);

  @override
  _NSPFeedContainerState createState() => _NSPFeedContainerState();
}

class _NSPFeedContainerState extends State<NSPFeedContainer> {
  ScrollController _scrollController;
  bool isLoading = false;
  bool loadMoreVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    widget.loadMoreStream.listen((event) {
      loadMoreVisible = event;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        var reachedBottom = scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent * 0.5;

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

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // crossAxisSpacing: 1,
        crossAxisCount: 2,
      ),
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
    if (!loadMoreVisible) return Container();

    return Container(
      height: 50,
      color: Colors.transparent,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void onBottomReached() async {
    if (!loadMoreVisible) return;
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
