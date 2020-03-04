import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';

class NewsArticlePage extends StatefulWidget {
  @override
  _NewsArticlePageState createState() => _NewsArticlePageState();
}

class _NewsArticlePageState extends State<NewsArticlePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: <Widget>[
            NewsArticleContainer(newsArticleID: "bos"),
          ],
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
    // NewsArticle newsArticle = NewsArticleStore.

    return Container(
      color: Colors.blue,
      child: Column(
        children: <Widget>[
          Text("Generic News Title"),
          Text("More Information"),
        ],
      ),
    );
  }
}
