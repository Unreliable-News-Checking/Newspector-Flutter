import 'dart:collection';
import 'package:newspector_flutter/models/news_source.dart';

class NewsSourceStore {
  HashMap<String, NewsSource> _newsSources;

  NewsSourceStore() {
    _newsSources = HashMap<String, NewsSource>();
  }

  NewsSource getNewsSource(String id) {
    return _newsSources[id];
  }

  NewsSource updateOrAddNewsSource(NewsSource newsSource) {
    var newsSourceId = newsSource.id;
    _newsSources[newsSourceId] = newsSource;
    return newsSource;
  }

  bool hasNewsSource(String newsSourceId) {
    return _newsSources.containsKey(newsSourceId);
  }
}
