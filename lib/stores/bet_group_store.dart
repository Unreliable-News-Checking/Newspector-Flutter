import 'dart:collection';

import 'package:newspector_flutter/models/news_group.dart';


class BetGroupStore {
  int _counter;
  HashMap<String, NewsGroup> _betGroups;

  BetGroupStore() {
    _counter = 0;
    _betGroups = HashMap<String, NewsGroup>();
  }

  NewsGroup createFreshBetGroup(String id) {
    var id = generateRandomId();
    var betGroup = NewsGroup(id);
    _betGroups.addEntries([MapEntry<String, NewsGroup>(id, betGroup)]);
    return betGroup;
  }

  void removeBetGroup(String id) {
    _betGroups.remove(id);
  }

  NewsGroup getBetGroup(String id) {
    return _betGroups[id];
  }

  String generateRandomId() {
    _counter++;
    return (_counter - 1).toString();
  }
}
