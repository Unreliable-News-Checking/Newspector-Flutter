import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/pages/news_group_page.dart';
import 'package:newspector_flutter/services/news_article_service.dart';

class NewsArticlePage extends StatefulWidget {
  final String newsArticleId;

  NewsArticlePage({Key key, @required this.newsArticleId}) : super(key: key);

  @override
  _NewsArticlePageState createState() => _NewsArticlePageState();
}

class _NewsArticlePageState extends State<NewsArticlePage> {
  NewsArticle _newsArticle;

  @override
  Widget build(BuildContext context) {
    _newsArticle = NewsArticleService.getNewsArticle(widget.newsArticleId);
    return Scaffold(
      appBar: appBar(),
      body: Center(
        child: Container(
          child: NewsArticleContainer(newsArticleId: widget.newsArticleId),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.fullscreen),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return NewsGroupPage(
                newsGroupId: _newsArticle.newsGroupId,
              );
            }));
          },
        )
      ],
    );
  }
}

class NewsArticleContainer extends StatefulWidget {
  final String newsArticleId;
  NewsArticleContainer({
    @required this.newsArticleId,
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
    NewsArticle _newsArticle =
        NewsArticleService.getNewsArticle(widget.newsArticleId);

    return Container(
      color: Colors.blue,
      child: Column(
        children: <Widget>[
          Text(_newsArticle.headline),
          Text(_newsArticle.date.toDate().toString()),
          Text(_newsArticle.tweetLink),
          Text("is retweet: ${_newsArticle.isRetweet}"),
          Text(_newsArticle.newsSourceId),
        ],
      ),
    );
  }
}
