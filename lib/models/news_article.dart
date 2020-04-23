import 'package:cloud_firestore/cloud_firestore.dart';

class NewsArticle {
  String id;
  String newsGroupId;
  String tweetId;
  String headline;
  Timestamp date;
  String tweetLink;
  String websiteLink;
  bool isRetweet;
  String newsSourceId;
  DocumentReference newsSourceReference; // temp

  String analysisResult;

  NewsArticle();

  NewsArticle.fromDocument(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.documentID;
    newsGroupId = documentSnapshot.data['news_group_id'];
    headline = documentSnapshot.data['text'];
    date = documentSnapshot.data['date'];
    tweetId = documentSnapshot.data['tweet_id'];
    tweetLink = "https://twitter.com/user/status/$tweetId";
    isRetweet = documentSnapshot.data['is_retweet'];
    newsSourceId = documentSnapshot.data['username'];

    websiteLink = null;
    analysisResult = null;
  }
}
