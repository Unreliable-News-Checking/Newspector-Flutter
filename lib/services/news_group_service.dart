import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/stores/news_group_store.dart';

class NewsGroupService {
  static NewsGroupStore newsGroupStore = NewsGroupStore();

  static NewsGroup getNewsGroup(String id) {
    return newsGroupStore.getNewsGroup(id);
  }

  static NewsGroup updateOrAddNewsGroup(NewsGroup newsGroup) {
    return newsGroupStore.updateOrAddNewsArticle(newsGroup);
  }
}
