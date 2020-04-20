import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/services/news_article_service.dart';

class NewsArticleContainer extends StatefulWidget {
  final String newsArticleId;
  final Function onTap;

  NewsArticleContainer(
      {Key key, @required this.newsArticleId, @required this.onTap})
      : super(key: key);

  @override
  _NewsArticleContainerState createState() => _NewsArticleContainerState();
}

class _NewsArticleContainerState extends State<NewsArticleContainer> {
  NewsArticle _newsArticle;

  @override
  Widget build(BuildContext context) {
    _newsArticle = NewsArticleService.getNewsArticle(widget.newsArticleId);

    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.white,
        child: Center(
          child: Text(_newsArticle.headline),
        ),
      ),
    );
  }
}
