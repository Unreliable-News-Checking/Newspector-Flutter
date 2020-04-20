import 'package:cloud_firestore/cloud_firestore.dart';

class NewsArticle {
  String id;
  String newsGroupId;
  String tweetId;
  String headline;
  Timestamp date;
  String link;
  bool isRetweet;
  String newsSourceId;
  DocumentReference newsSourceReference; // temp

  String analysisResult;

  NewsArticle();

  NewsArticle.fromDocument(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.documentID;
    newsGroupId = documentSnapshot.data['cluster_id'];
    headline = documentSnapshot.data['text'];
    date = documentSnapshot.data['time'];
    tweetId = documentSnapshot.data['tweet_id'];
    link = "twitter.com/user/status/$tweetId";
    isRetweet = documentSnapshot.data['is_retweet'];
    newsSourceId = documentSnapshot.data['username'];

    analysisResult = null;
  }
}
