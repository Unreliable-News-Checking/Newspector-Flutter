import 'dart:collection';
import 'package:newspector_flutter/models/news_group.dart';


class NewsGroupStore {
  int _counter;
  HashMap<String, NewsGroup> _betGroups;

  NewsGroupStore() {
    _counter = 0;
    _betGroups = HashMap<String, NewsGroup>();
  }

  NewsGroup createFreshNewsGroup(String id) {
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
