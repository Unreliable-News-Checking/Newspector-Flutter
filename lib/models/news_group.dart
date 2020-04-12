import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:newspector_flutter/models/news_article.dart';

class NewsGroup {
  String id;
  String category;
  bool followed;
  List<String> newsArticleIDs;
  Timestamp date;

  NewsGroup(this.id);

  NewsGroup.fromAttributes(
      this.id, this.category, this.newsArticleIDs, this.followed);

  NewsGroup.fromDocument(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.documentID;
    category = documentSnapshot.data['category'];
    followed = null;
    newsArticleIDs = null;
    date = documentSnapshot.data['date'];
  }

  void addNewsArticles(List<String> newsArticleIDs) {
    if (this.newsArticleIDs == null) {
      this.newsArticleIDs = List<String>();
    }
    
    this.newsArticleIDs.addAll(newsArticleIDs);
  }

  int getArticleCount() {
    return newsArticleIDs.length;
  }

  String getNewsArticleID(int index) {
    return newsArticleIDs[index];
  }
}
