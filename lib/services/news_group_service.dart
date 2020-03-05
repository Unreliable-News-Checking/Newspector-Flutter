import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/stores/news_group_store.dart';

class NewsGroupService {
  static NewsGroupStore newsGroupStore = NewsGroupStore();

  static NewsGroup updateOrAddNewsGroup(NewsGroup newsArticle) {
    return newsGroupStore.updateOrAddNewsArticle(newsArticle);
  }
}
