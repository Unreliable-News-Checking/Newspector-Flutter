import 'dart:collection';
import 'package:newspector_flutter/models/news_group.dart';


class NewsArticleStore {
  int _counter;
  HashMap<String, NewsGroup> _betGroups;

  NewsArticleStore() {
    _counter = 0;
    _betGroups = HashMap<String, NewsGroup>();
  }

  NewsGroup createFreshNewsArticle(String id) {
    var id = generateRandomId();
    var betGroup = NewsGroup(id);
    _betGroups.addEntries([MapEntry<String, NewsGroup>(id, betGroup)]);
    return betGroup;
  }

  String generateRandomId() {
    _counter++;
    return (_counter - 1).toString();
  }
}
