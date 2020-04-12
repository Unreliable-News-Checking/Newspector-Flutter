import 'package:newspector_flutter/models/news_article.dart';

class NewsGroup {
  String id;
  String category;
  bool followed;
  List<NewsArticle> newsArticles;

  NewsGroup(this.id);

  NewsGroup.fromAttributes(
      this.id, this.category, this.newsArticles, this.followed);

  int getArticleCount() {
    return newsArticles.length;
  }

  NewsArticle getNewsArticle(int index) {
    return newsArticles[index];
  }
}
