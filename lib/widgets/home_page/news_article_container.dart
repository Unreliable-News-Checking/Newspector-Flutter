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
        print("tapped on news article with id ${widget.newsArticleId}");
        widget.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_newsArticle.headline),
              Text(_newsArticle.date.toDate().toString()),
              Text(_newsArticle.link),
              Text("is retweet: ${_newsArticle.isRetweet}"),
              Text(_newsArticle.newsSourceId),
            ],
          ),
        ),
      ),
    );
  }
}
