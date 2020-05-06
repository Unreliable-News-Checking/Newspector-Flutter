import 'package:cloud_firestore/cloud_firestore.dart';

import 'feed.dart';
import 'model.dart';

class NewsGroup extends Model{
  String id;
  String category;
  DateTime creationDate;
  DateTime updateDate;
  Feed newsArticleFeed;
  bool followedByUser;
  String leaderId;

  NewsGroup.fromDocument(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data;
    id = documentSnapshot.documentID;

    category = data['category'];
    creationDate = DateTime.fromMillisecondsSinceEpoch(data['created_at'].toInt());
    updateDate = DateTime.fromMillisecondsSinceEpoch(data['updated_at'].toInt());
    leaderId = data['group_leader'];
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
