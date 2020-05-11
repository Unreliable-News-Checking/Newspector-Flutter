// import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/widgets/sliver_app_bar.dart';

// import 'package:newspector_flutter/models/feed.dart';

// class FeedContainer<E> extends StatefulWidget {
//   final SliverAppBar sliverAppBar;
//   final Feed<E> feed;
//   final Function onRefresh;
//   final Function onBottomReached;
//   final Function buildContainer;
//   final String emptyListMessage;
//   final Stream loadMoreStream;
//   final bool initialLoadMoreVisible;
//   final ScrollController scrollController;

//   FeedContainer({
//     Key key,
//     @required this.feed,
//     @required this.onRefresh,
//     @required this.onBottomReached,
//     @required this.buildContainer,
//     @required this.emptyListMessage,
//     @required this.sliverAppBar,
//     @required this.loadMoreStream,
//     @required this.initialLoadMoreVisible,
//     this.scrollController,
//   }) : super(key: key);

//   @override
//   _FeedContainerState createState() => _FeedContainerState();
// }

// class _FeedContainerState extends State<FeedContainer> {
//   ScrollController _scrollController;
//   bool isLoading = false;
//   bool loadMoreVisible = true;
//   StreamSubscription<dynamic> loadMoreSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = widget.scrollController ?? ScrollController();
//     loadMoreSubscription = widget.loadMoreStream.listen((event) {
//       loadMoreVisible = event;

//       // print('received event $event');
//       if (mounted) setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     loadMoreSubscription.cancel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return NotificationListener<ScrollNotification>(
//       onNotification: onScrollNotification,
//       child: CupertinoScrollbar(
//         child: CustomScrollView(
//           controller: _scrollController,
//           physics:
//               BouncingScrollPhysics().applyTo(AlwaysScrollableScrollPhysics()),
//           slivers: <Widget>[
//             widget.sliverAppBar,
//             refreshControl(),
//             itemList(),
//             SliverToBoxAdapter(
//               child: loadMoreContainer(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget refreshControl() {
//     return CupertinoSliverRefreshControl(
//       onRefresh: widget.onRefresh,
//     );
//   }

//   Widget itemList() {
//     if (widget.feed.getItemCount() == 0) return emptyItemList();

//     return SliverList(
//       delegate: SliverChildBuilderDelegate(
//         (context, index) {
//           return Container(
//             child: widget.buildContainer(widget.feed.getItem(index)),
//           );
//         },
//         childCount: widget.feed.getItemCount(),
//       ),
//     );
//   }

//   // shown when the page is loading the new feed
//   Widget emptyItemList() {
//     return SliverToBoxAdapter(
//       child: Container(
//         margin: EdgeInsets.only(top: 50),
//         child: Center(
//           child: Text(widget.emptyListMessage),
//         ),
//       ),
//     );
//   }

//   Widget loadMoreContainer() {
//     if (!loadMoreVisible) return Container();

//     return Container(
//       height: 50,
//       color: Colors.transparent,
//       child: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }

//   bool onScrollNotification(ScrollNotification scrollInfo) {
//     if (!loadMoreVisible) return true;
//     if (isLoading) return true;

//     var reachedBottom =
//         scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.5;

//     if (!reachedBottom) return true;

//     onBottomReached();

//     return true;
//   }

//   void onBottomReached() async {
//     if (!loadMoreVisible) return;
//     if (isLoading) return;

//     setState(() {
//       isLoading = true;
//     });

//     await widget.onBottomReached();

//     setState(() {
//       isLoading = false;
//     });
//   }
// }

mixin FeedContainerTest<T extends StatefulWidget> on State<T> {
  // shown when the page is loading the new feed
  Widget loadingScaffold(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: app_const.backgroundColor,
      ),
      backgroundColor: app_const.backgroundColor,
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget sliverAppBar(String title, {List<Widget> actions}) {
    return defaultSliverAppBar(titleText: title, actions: actions);
  }

  Widget refreshControl(Function onRefresh) {
    return CupertinoSliverRefreshControl(
      onRefresh: onRefresh,
    );
  }

  // shown when the page is loading the new feed
  Widget emptyList(String message) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(top: 50),
        child: Center(
          child: Text(message),
        ),
      ),
    );
  }

  Widget loadMoreContainer(bool loadMoreVisible) {
    if (!loadMoreVisible) {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        color: Colors.transparent,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  bool onScrollNotification(
    bool loadMoreVisible,
    bool isLoading,
    ScrollNotification scrollInfo,
    Function fetchAdditionalItems,
    Function(bool) setLoading,
  ) {
    if (!loadMoreVisible) return true;
    if (isLoading) return true;

    var reachedBottom =
        scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.5;

    if (!reachedBottom) return true;

    onBottomReached(
      loadMoreVisible,
      isLoading,
      fetchAdditionalItems,
      setLoading,
    );

    return true;
  }

  void onBottomReached(
    bool loadMoreVisible,
    bool isLoading,
    Function fetchAdditionalItems,
    Function(bool) setLoading,
  ) async {
    if (!loadMoreVisible) return;
    if (isLoading) return;

    setState(() {
      setLoading(true);
    });

    await fetchAdditionalItems();

    setState(() {
      setLoading(false);
    });
  }
}
