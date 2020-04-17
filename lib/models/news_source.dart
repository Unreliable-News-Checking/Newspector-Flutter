import 'package:flutter/services.dart';

class NewsSource {
  String id;
  String name;
  ByteData logo;
  String link;
  List<String> newsArticleIds;

  NewsSource(this.id, this.name, this.logo, this.link, this.newsArticleIds);
  NewsSource.fromEmpty();
}
