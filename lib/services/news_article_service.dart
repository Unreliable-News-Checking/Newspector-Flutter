import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/stores/news_article_store.dart';

class NewsArticleService {
  //firebase stuff here too
  static NewsArticleStore newsArticleStore = NewsArticleStore();

  static NewsArticle getNewsArticle(String id) {
    return newsArticleStore.getNewsArticle(id);
  }

  static NewsArticle updateOrAddNewsArticle(NewsArticle newsArticle) {
    return newsArticleStore.updateOrAddNewsArticle(newsArticle);
  }
}
