import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'model.dart';

class NewsArticle extends Model {
  String id;
  String newsGroupId;
  String tweetId;
  String headline;
  Timestamp date;
  String tweetLink;
  String websiteLink;
  bool isRetweet;
  String newsSourceId;

  String photoUrl;
  Uint8List photoInBytes;

  NewsArticle();

  NewsArticle.fromDocument(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data;
    id = documentSnapshot.documentID;
    newsGroupId = data['news_group_id'];
    headline = data['text'];
    date = data['date'];
    tweetId = data['tweet_id'];
    tweetLink = "https://twitter.com/user/status/$tweetId";
    isRetweet = data['is_retweet'];
    newsSourceId = data['username'];

    photoUrl = null;
    if (documentSnapshot.data['photos'].length > 0) {
      photoUrl = documentSnapshot.data['photos'][0];
    }

    if (documentSnapshot.data['urls'].length > 0) {
      websiteLink = documentSnapshot.data['urls'][0];
    }
  }
}
