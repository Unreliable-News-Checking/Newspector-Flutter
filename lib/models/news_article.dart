import 'package:newspector_flutter/models/news_source.dart';

class NewsArticle {
  String id;
  String newsGroupID;
  List<NewsArticle> history;
  NewsSource newsSource;
  String headline;
  String link;
  DateTime date;
  String analysisResult;

  NewsArticle();

  NewsArticle.fromAttributes(this.id, this.newsGroupID, this.newsSource,
      this.headline, this.link, this.date, this.analysisResult);
}
