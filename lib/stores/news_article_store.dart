import 'dart:collection';
import 'package:newspector_flutter/models/news_article.dart';

class NewsArticleStore {
  int _counter;
  HashMap<String, NewsArticle> _newsArticles;

  NewsArticleStore() {
    _counter = 0;
    _newsArticles = HashMap<String, NewsArticle>();
  }

  NewsArticle getNewsArticle(String id) {
    return _newsArticles[id];
  }

  NewsArticle updateOrAddNewsArticle(NewsArticle newsArticle) {
    var newsArticleID = newsArticle.id;
    _newsArticles[newsArticleID] = newsArticle;
    return newsArticle;
  }

  String generateRandomId() {
    _counter++;
    return (_counter - 1).toString();
  }
}
