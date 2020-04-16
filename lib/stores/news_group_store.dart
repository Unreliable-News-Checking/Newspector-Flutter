import 'dart:collection';
import 'package:newspector_flutter/models/news_group.dart';

class NewsGroupStore {
  int _counter;
  HashMap<String, NewsGroup> _newsGroups;

  NewsGroupStore() {
    _counter = 0;
    _newsGroups = HashMap<String, NewsGroup>();
  }

  NewsGroup getNewsGroup(String id) {
    return _newsGroups[id];
  }

  NewsGroup updateOrAddNewsArticle(NewsGroup newsGroup) {
    var newsGroupId = newsGroup.id;
    _newsGroups[newsGroupId] = newsGroup;
    return newsGroup;
  }

  String generateRandomId() {
    _counter++;
    return (_counter - 1).toString();
  }
}
