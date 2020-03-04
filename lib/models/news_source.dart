import 'package:flutter/services.dart';

class NewsSource {
  String name;
  ByteData logo;
  String link;
  List<NewsSource> newsArticles;

  NewsSource(this.name, this.logo, this.link, this.newsArticles);
  NewsSource.fromEmpty();
}
