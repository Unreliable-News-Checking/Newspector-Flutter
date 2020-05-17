import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'model.dart';

class NewsArticle extends Model {
  String id;
  String newsGroupId;
  String tweetId;
  String headline;
  DateTime date;
  String tweetLink;
  String websiteLink;
  bool isRetweet;
  String newsSourceId;
  String category;
  double sentiment;

  String photoUrl;
  Uint8List photoInBytes;

  NewsArticle();

  NewsArticle.fromDocument(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data;
    id = documentSnapshot.documentID;
    newsSourceId = data['username'];
    isRetweet = data['is_retweet'];
    newsGroupId = data['news_group_id'];
    category = data['perceived_category'];
    headline = data['text'];
    tweetId = data['tweet_id'];
    tweetLink = "https://twitter.com/user/status/$tweetId";

    var _date = data['date']?.toInt() ?? 0;
    date = DateTime.fromMillisecondsSinceEpoch(_date);
    sentiment = data['sentiment_score'] ?? 0.0;

    if (documentSnapshot.data['photos'].length > 0) {
      photoUrl = documentSnapshot.data['photos'][0];
    }

    if (documentSnapshot.data['urls'].length > 0) {
      websiteLink = documentSnapshot.data['urls'][0];
    }
  }

  String readableSentiment() {
    var rangeSteps = [0.2, 0.4, 0.8];
    if (sentiment >= rangeSteps[2]) return "Strongly Positive";
    if (sentiment >= rangeSteps[1]) return "Positive";
    if (sentiment >= rangeSteps[0]) return "Slightly Positive";
    if (sentiment >= -rangeSteps[0]) return "Neutral";
    if (sentiment >= -rangeSteps[1]) return "Slightly Negative";
    if (sentiment >= -rangeSteps[2]) return "Negative";

    return "Strongly Negative";
  }
}
