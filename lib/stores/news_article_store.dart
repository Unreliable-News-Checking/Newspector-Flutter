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

  bool hasNewsArticle(String id) {
    return _newsArticles.containsKey(id);
  }

  NewsArticle updateOrAddNewsArticle(NewsArticle newsArticle) {
    var newsArticleId = newsArticle.id;
    _newsArticles[newsArticleId] = newsArticle;
    return newsArticle;
  }

  String generateRandomId() {
    _counter++;
    return (_counter - 1).toString();
  }
}
