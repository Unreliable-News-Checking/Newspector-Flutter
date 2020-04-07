import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/services/news_article_service.dart';

class NewsArticleContainer extends StatefulWidget {
  final String newsArticleID;

  NewsArticleContainer({Key key, @required this.newsArticleID})
      : super(key: key);

  @override
  _NewsArticleContainerState createState() => _NewsArticleContainerState();
}

class _NewsArticleContainerState extends State<NewsArticleContainer> {
  NewsArticle _newsArticle;

  @override
  Widget build(BuildContext context) {
    _newsArticle = NewsArticleService.getNewsArticle(widget.newsArticleID);

    return Center(
      child: Column(
        children: <Widget>[
          Text(_newsArticle.headline),
        ],
      ),
    );
  }
}
