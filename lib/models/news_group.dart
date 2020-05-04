import 'package:cloud_firestore/cloud_firestore.dart';

import 'feed.dart';
import 'model.dart';

class NewsGroup extends Model{
  String id;
  String category;
  Timestamp date;
  Feed newsArticleFeed;
  bool followedByUser; //to control whether this user follows this news group

  NewsGroup(this.id);

  NewsGroup.fromDocument(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.documentID;
    category = documentSnapshot.data['category'];
    date = documentSnapshot.data['date'];
    followedByUser = null;
    newsArticleFeed = null;
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
