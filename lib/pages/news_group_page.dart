import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/pages/news_article_page.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/news_group_page/news_article_container.dart'
    as nac;

class NewsGroupPage extends StatefulWidget {
  final String newsGroupID;

  NewsGroupPage({Key key, @required this.newsGroupID}) : super(key: key);

  @override
  _NewsGroupPageState createState() => _NewsGroupPageState();
}

class _NewsGroupPageState extends State<NewsGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: NewsGroupFeed(newsGroupID: widget.newsGroupID),
      ),
    );
  }
}

class NewsGroupFeed extends StatefulWidget {
  final String newsGroupID;

  NewsGroupFeed({Key key, @required this.newsGroupID}) : super(key: key);

  @override
  _NewsGroupFeedState createState() => _NewsGroupFeedState();
}

class _NewsGroupFeedState extends State<NewsGroupFeed> {
  NewsGroup _newsGroup;
  @override
  Widget build(BuildContext context) {
    _newsGroup = NewsGroupService.getNewsGroup(widget.newsGroupID);

    return Container(
      child: ListView.builder(
        itemCount: _newsGroup.getArticleCount(),
        itemBuilder: (context, itemIndex) {
          return _buildNewsGroupFeedItem(context, itemIndex);
        },
      ),
    );
  }

  Widget _buildNewsGroupFeedItem(BuildContext context, int index) {
    return nac.NewsArticleContainer(
      newsArticleID: _newsGroup.getNewsArticle(index).id,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return NewsArticlePage(
            newsArticleID: _newsGroup.getNewsArticle(index).id,
          );
        }));
      },
    );
  }
}
