import 'package:cloud_firestore/cloud_firestore.dart';

import 'feed.dart';

class NewsGroup {
  String id;
  String category;
  bool followed;
  // List<String> newsArticleIds;
  Feed newsArticleFeed;
  Timestamp date;

  NewsGroup(this.id);

  // NewsGroup.fromAttributes(
  // this.id, this.category, this.newsArticleIds, this.followed);

  NewsGroup.fromDocument(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.documentID;
    category = documentSnapshot.data['category'];
    followed = null;
    newsArticleFeed = null;
    date = documentSnapshot.data['date'];
  }

  void addNewsArticles(List<String> newsArticleIds) {
    if (this.newsArticleFeed == null) {
      this.newsArticleFeed = Feed<String>();
    }

    this.newsArticleFeed.addAdditionalItems(newsArticleIds);
  }

  int getArticleCount() {
    return newsArticleFeed.getItemCount();
  }

  String getNewsArticleId(int index) {
    return newsArticleFeed.getItem(index);
  }
}
