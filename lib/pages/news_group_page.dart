import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/pages/feed_page.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/news_group_page/ngp_feed_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

class NewsGroupPage extends StatefulWidget {
  final String newsGroupId;

  NewsGroupPage({Key key, @required this.newsGroupId}) : super(key: key);

  @override
  _NewsGroupPageState createState() => _NewsGroupPageState();
}

class _NewsGroupPageState extends State<NewsGroupPage> implements FeedPage {
  NewsGroup _newsGroup;
  var pageSize = app_const.newsGroupPageSize;
  var loadMoreVisible = true;

  StreamController _loadMoreController;
  Stream loadMoreStream;

  @override
  void initState() {
    super.initState();
    _loadMoreController = StreamController.broadcast();
    loadMoreStream = _loadMoreController.stream;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.newsGroupId);
    if (NewsGroupService.hasNewsGroup(widget.newsGroupId)) {
      _newsGroup = NewsGroupService.getNewsGroup(widget.newsGroupId);
      loadMoreVisible = _newsGroup.newsArticleFeed.getItemCount() < pageSize
          ? false
          : loadMoreVisible;
      _loadMoreController.add(loadMoreVisible);
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
            return loadingScaffold();
        }
      },
    );
  }

  // shown when the page is loading the new feed
  Widget loadingScaffold() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  // shown when there is a feed with news groups
  Widget homeScaffold() {
    return Scaffold(
      backgroundColor: app_const.backgroundColor,
      body: NewsGroupFeedContainer(
        sliverAppBar: sliverAppBar(),
        newsGroup: _newsGroup,
        onBottomReached: fetchAdditionalItems,
        onRefresh: getFeed,
        loadMoreStream: loadMoreStream,
      ),
    );
  }

  Widget sliverAppBar() {
    return defaultSliverAppBar(titleText: 'News Group Page');
  }

  Future<NewsGroup> getFeed() async {
    _newsGroup = await NewsGroupService.updateAndGetNewsGroupFeed(
      newsGroupId: widget.newsGroupId,
      pageSize: pageSize,
    );

    loadMoreVisible = _newsGroup.newsArticleFeed.getItemCount() >= pageSize;
    _loadMoreController.add(loadMoreVisible);
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
    _loadMoreController.add(loadMoreVisible);
  }
}
