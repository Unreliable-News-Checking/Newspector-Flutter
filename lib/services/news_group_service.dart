
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/stores/news_group_store.dart';

class NewsGroupService {
  static NewsGroupStore betGroupStore = NewsGroupStore();

  static NewsGroup createFreshBetGroup(String id) {
    return betGroupStore.createFreshBetGroup(id);
  }


}
