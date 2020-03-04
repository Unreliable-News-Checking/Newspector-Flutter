
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/stores/bet_group_store.dart';

class BetGroupService {
  static BetGroupStore betGroupStore = BetGroupStore();

  static NewsGroup createFreshBetGroup(String id) {
    return betGroupStore.createFreshBetGroup(id);
  }
}
