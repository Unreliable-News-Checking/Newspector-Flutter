import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newspector_flutter/models/news_source.dart';

class NewsArticle {
  String id;
  String newsGroupId;
  // List<NewsArticle> history;
  NewsSource newsSource;
  String headline;
  String link;
  Timestamp date;
  String analysisResult;

  NewsArticle();

  NewsArticle.fromAttributes(this.id, this.newsGroupId, this.newsSource,
      this.headline, this.link, this.date, this.analysisResult);

  NewsArticle.fromDocument(DocumentSnapshot documentSnapshot)
  {
    id = documentSnapshot.documentID;
    newsGroupId = documentSnapshot.data['cluster_id'];
    // history = null;
    newsSource = null;
    headline = documentSnapshot.data['text'];
    link = null;
    date = documentSnapshot.data['time'];
    analysisResult = null;
  }
}
