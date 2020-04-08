import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/services/news_article_service.dart';

class NewsArticlePage extends StatefulWidget {
  final String newsArticleID;

  NewsArticlePage({Key key, @required this.newsArticleID})
      : super(key: key);

  @override
  _NewsArticlePageState createState() => _NewsArticlePageState();
}

class _NewsArticlePageState extends State<NewsArticlePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              NewsArticleContainer(newsArticleID: widget.newsArticleID),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsArticleContainer extends StatefulWidget {
  final String newsArticleID;
  NewsArticleContainer({
    @required this.newsArticleID,
  });

  @override
  _NewsArticleContainerState createState() => _NewsArticleContainerState();
}

class _NewsArticleContainerState extends State<NewsArticleContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NewsArticle newsArticle =
        NewsArticleService.getNewsArticle(widget.newsArticleID);

    return Container(
      color: Colors.blue,
      child: Column(
        children: <Widget>[
          Text(newsArticle.headline),
          Text(newsArticle.link),
          Text(newsArticle.newsSource.name),
          Text(newsArticle.date.toString()),
          Text(newsArticle.analysisResult),
        ],
      ),
    );
  }
}
