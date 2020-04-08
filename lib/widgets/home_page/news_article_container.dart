import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/services/news_article_service.dart';

class NewsArticleContainer extends StatefulWidget {
  final String newsArticleID;
  final Function onTap;

  NewsArticleContainer({Key key, @required this.newsArticleID, @required this.onTap})
      : super(key: key);

  @override
  _NewsArticleContainerState createState() => _NewsArticleContainerState();
}

class _NewsArticleContainerState extends State<NewsArticleContainer> {
  NewsArticle _newsArticle;

  @override
  Widget build(BuildContext context) {
    _newsArticle = NewsArticleService.getNewsArticle(widget.newsArticleID);

    return GestureDetector(
      onTap: () {
        print("tapped on news article with index ${widget.newsArticleID}");
        widget.onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Center(
          child: Column(
            children: <Widget>[
              Text(_newsArticle.headline),
            ],
          ),
        ),
      ),
    );
  }
}
