import 'package:newspector_flutter/models/news_source.dart';

class NewsArticle {
  List<NewsArticle> history;
  NewsSource newsSource;
  String headline;
  String link;
  DateTime date;
  String analysisResult;

  NewsArticle();
}
