import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/pages/news_article_page.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/news_group_page/news_article_container.dart'
    as nac;

class NewsGroupPage extends StatefulWidget {
  final String newsGroupId;

  NewsGroupPage({Key key, @required this.newsGroupId}) : super(key: key);

  @override
  _NewsGroupPageState createState() => _NewsGroupPageState();
}

class _NewsGroupPageState extends State<NewsGroupPage> {
  NewsGroup _newsGroup;
  var pageSize = 6;
  var loadMoreVisible = true;

  @override
  Widget build(BuildContext context) {
    print(
        "has newsgroup: ${NewsGroupService.hasNewsGroup(widget.newsGroupId)}");
    print(
        "newsgroup has feed: : ${NewsGroupService.getNewsGroup(widget.newsGroupId).newsArticleFeed}");

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
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      title: Text("News Group Page"),
    );
  }

  Future<NewsGroup> getInitialFeed() async {
    _newsGroup = await NewsGroupService.updateAndGetNewsGroup(
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
    _newsGroup = await NewsGroupService.updateAndGetNewsGroup(
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

    _newsGroup = await NewsGroupService.updateAndGetNewsGroup(
      newsGroupId: widget.newsGroupId,
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
    );

    if (_newsGroup.newsArticleFeed.getItemCount() < pageSize) {
      loadMoreVisible = false;
    } else {
      loadMoreVisible = true;
    }

    if (mounted) setState(() {});
  }
}

class NewsGroupFeedContainer extends StatefulWidget {
  final NewsGroup newsGroup;

  NewsGroupFeedContainer({Key key, @required this.newsGroup}) : super(key: key);

  @override
  _NewsGroupFeedContainerState createState() => _NewsGroupFeedContainerState();
}

class _NewsGroupFeedContainerState extends State<NewsGroupFeedContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemBuilder: _buildNewsGroupFeedItem2,
        itemCount: widget.newsGroup.getArticleCount(),
      ),
    );
  }

  Widget _buildNewsGroupFeedItem2(BuildContext context, int index) {
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
                  Expanded(
                    child: line(),
                  ),
                  ball(),
                  Expanded(
                    child: line(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Card(
                margin: EdgeInsets.all(10),
                child: nac.NewsArticleContainer(
                  newsArticleId: widget.newsGroup.getNewsArticleId(index),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return NewsArticlePage(
                        newsArticleId: widget.newsGroup.getNewsArticleId(index),
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
    return Container(
      width: width,
      color: Colors.grey,
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
