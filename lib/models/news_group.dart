import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:newspector_flutter/models/news_article.dart';

class NewsGroup {
  String id;
  String category;
  bool followed;
  List<String> newsArticleIds;
  Timestamp date;

  NewsGroup(this.id);

  NewsGroup.fromAttributes(
      this.id, this.category, this.newsArticleIds, this.followed);

  NewsGroup.fromDocument(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.documentID;
    category = documentSnapshot.data['category'];
    followed = null;
    newsArticleIds = null;
    date = documentSnapshot.data['date'];
  }

  void addNewsArticles(List<String> newsArticleIds) {
    if (this.newsArticleIds == null) {
      this.newsArticleIds = List<String>();
    }
    
    this.newsArticleIds.addAll(newsArticleIds);
  }

  int getArticleCount() {
    return newsArticleIds.length;
  }

  String getNewsArticleId(int index) {
    return newsArticleIds[index];
  }
}
