import 'package:flutter/services.dart';

import 'feed.dart';

class NewsSource {
  String id;
  String name;
  ByteData logo;
  String link;
  Feed<String> newsArticleFeed;

  NewsSource();
}
