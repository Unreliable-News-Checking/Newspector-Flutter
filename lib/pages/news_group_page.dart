import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/news_group_page/news_group_feed_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

class NewsGroupPage extends StatefulWidget {
  final String newsGroupId;

  NewsGroupPage({Key key, @required this.newsGroupId}) : super(key: key);

  @override
  _NewsGroupPageState createState() => _NewsGroupPageState();
}

class _NewsGroupPageState extends State<NewsGroupPage> {
  NewsGroup _newsGroup;
  var pageSize = app_const.newsGroupPageSize;
  var loadMoreVisible = true;

  @override
  Widget build(BuildContext context) {
    print("news group id: ${widget.newsGroupId}");
    if (NewsGroupService.hasNewsGroup(widget.newsGroupId)) {
      _newsGroup = NewsGroupService.getNewsGroup(widget.newsGroupId);
      if (_newsGroup.newsArticleFeed.getItemCount() < pageSize) {
        loadMoreVisible = false;
      }
      return homeScaffold();
    }

    // if there is no existing feed,
    // get the latest feed and display it
    return FutureBuilder(
      future: getInitialFeed(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            _newsGroup.newsArticleFeed = snapshot.data;
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
      appBar: appBar(),
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  // shown when there is a feed with news groups
  Widget homeScaffold() {
    return Scaffold(
      appBar: appBar(),
      body: NewsGroupFeedContainer(
        newsGroup: _newsGroup,
        loadMoreVisible: loadMoreVisible,
        onBottomReached: fetchAdditionalNewsGroups,
        onRefresh: getRefreshedFeed,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      title: Text("News Group Page"),
    );
  }

  Future<NewsGroup> getInitialFeed() async {
    _newsGroup = await NewsGroupService.updateAndGetNewsGroupFeed(
      newsGroupId: widget.newsGroupId,
      pageSize: pageSize,
    );

    if (_newsGroup.newsArticleFeed.getItemCount() < pageSize) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    return _newsGroup;
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> getRefreshedFeed() async {
    _newsGroup = await NewsGroupService.updateAndGetNewsGroupFeed(
      newsGroupId: widget.newsGroupId,
      pageSize: pageSize,
    );

    if (_newsGroup.newsArticleFeed.getItemCount() < pageSize) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    if (mounted) setState(() {});
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> fetchAdditionalNewsGroups() async {
    var lastDocumentId = _newsGroup.newsArticleFeed.getLastItem();

    _newsGroup = await NewsGroupService.updateAndGetNewsGroupFeed(
      newsGroupId: widget.newsGroupId,
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
    );

    if (lastDocumentId == _newsGroup.newsArticleFeed.getLastItem()) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    if (mounted) setState(() {});
  }
}
