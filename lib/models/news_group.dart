import 'package:cloud_firestore/cloud_firestore.dart';

import 'feed.dart';
import 'model.dart';

class NewsGroup extends Model{
  String id;
  String category;
  Timestamp date;
  Feed newsArticleFeed;
  bool followedByUser;

  NewsGroup.fromDocument(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data;
    id = documentSnapshot.documentID;
    category = data['category'];
    date = data['date'];
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
