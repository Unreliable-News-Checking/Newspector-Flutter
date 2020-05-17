import 'package:cloud_firestore/cloud_firestore.dart';

import 'feed.dart';
import 'model.dart';

class NewsGroup extends Model {
  String id;
  String category;
  DateTime creationDate;
  DateTime updateDate;
  Feed newsArticleFeed;
  bool followedByUser;
  String leaderId;

  String firstReporterId;
  String closeSecondId;
  String lateComerId;

  Map<String, int> sourceCounts;

  NewsGroup.fromDocument(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data;
    id = documentSnapshot.documentID;

    category = data['category'];
    leaderId = data['group_leader'];
    firstReporterId = data['first_reporter'];
    closeSecondId = data['close_second'];
    lateComerId = data['late_comer'];

    var createdAt = data['created_at']?.toInt() ?? 0;
    var updatedAt = data['updated_at']?.toInt() ?? 0;
    creationDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
    updateDate = DateTime.fromMillisecondsSinceEpoch(updatedAt);

    sourceCounts = data['source_count_map'].cast<String, int>();
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
