// import 'dart:async';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:newspector_flutter/models/feed.dart';
// import 'package:newspector_flutter/services/news_feed_service.dart';
// import 'package:newspector_flutter/widgets/feed_container.dart';
// import 'package:newspector_flutter/widgets/news_group_container.dart';
// import 'package:newspector_flutter/application_constants.dart' as app_const;

// class FollowingPage extends StatefulWidget {
//   final ScrollController scrollController;

//   FollowingPage({
//     Key key,
//     @required this.scrollController,
//   }) : super(key: key);

//   @override
//   _FollowingPageState createState() => _FollowingPageState();
// }

// class _FollowingPageState extends State<FollowingPage>
//     with FeedContainer<FollowingPage, Feed<String>> {
//   Feed<String> _followingFeed;
//   ScrollController _scrollController;
//   int pageSize = app_const.followingPagePageSize;
//   int newsGroupPageSize = app_const.newsGroupPageSize;
//   var loadMoreVisible = true;
//   var isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = widget.scrollController ?? ScrollController();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // if there is an existing feed show that
//     if (NewsFeedService.hasFeed(FeedType.Following)) {
//       _followingFeed = NewsFeedService.getFeed(FeedType.Following);
//       loadMoreVisible =
//           _followingFeed.getItemCount() < pageSize ? false : loadMoreVisible;

//       return homeScaffold();
//     }

//     // if there is no existing feed,
//     // get the latest feed and display it
//     return FutureBuilder(
//       future: getFeed(),
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.done:
//             return homeScaffold();
//             break;
//           default:
//             return loadingScaffold('Following');
//         }
//       },
//     );
//   }

//   // shown when there is a user
//   Widget homeScaffold() {
//     return Scaffold(
//       backgroundColor: app_const.backgroundColor,
//       body: NotificationListener<ScrollNotification>(
//         onNotification: (scrollInfo) {
//           return onScrollNotification(
//             loadMoreVisible,
//             isLoading,
//             scrollInfo,
//             fetchAdditionalItems,
//             (loading) => isLoading = loading,
//           );
//         },
//         child: CupertinoScrollbar(
//           child: CustomScrollView(
//             controller: _scrollController,
//             physics: BouncingScrollPhysics()
//                 .applyTo(AlwaysScrollableScrollPhysics()),
//             slivers: <Widget>[
//               sliverAppBar("Following"),
//               refreshControl(getFeed),
//               itemList(),
//               loadMoreContainer(loadMoreVisible),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget itemList() {
//     if (NewsFeedService.getFeed(FeedType.Following).getItemCount() == 0)
//       return emptyList("You are not following any news groups yet.");

//     return SliverList(
//       delegate: SliverChildBuilderDelegate(
//         (context, index) {
//           return Container(
//             child: NewsGroupContainer(
//               newsGroupId: _followingFeed.getItem(index),
//             ),
//           );
//         },
//         childCount: _followingFeed.getItemCount(),
//       ),
//     );
//   }

//   ///
//   @override
//   Future<Feed<String>> getFeed() async {
//     _followingFeed = await NewsFeedService.updateAndGetNewsFeed(
//       pageSize: pageSize,
//       newsGroupPageSize: newsGroupPageSize,
//       feedType: FeedType.Following,
//     );
//     loadMoreVisible = _followingFeed.getItemCount() >= pageSize;

//     if (mounted) setState(() {});
//     return _followingFeed;
//   }

//   /// this fetches additional items
//   /// called when user reached the bottom of the page
//   Future<void> fetchAdditionalItems() async {
//     var lastDocumentId = _followingFeed.getLastItem();

//     _followingFeed = await NewsFeedService.updateAndGetNewsFeed(
//       pageSize: pageSize,
//       lastDocumentId: lastDocumentId,
//       newsGroupPageSize: newsGroupPageSize,
//       feedType: FeedType.Following,
//     );

//     loadMoreVisible = lastDocumentId != _followingFeed.getLastItem();
//   }
// }
