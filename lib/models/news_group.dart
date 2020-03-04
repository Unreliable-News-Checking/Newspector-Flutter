import 'package:newspector_flutter/models/news_article.dart';

class NewsGroup {
  String id;
  String category;
  NewsArticle mainNewsArticle;
  List<NewsArticle> newsArticles;

  NewsGroup(this.id);
}
