import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'model.dart';

class NewsSource extends Model {
  String id;
  String name;
  String twitterUsername;
  String website;
  String photoUrl;

  int followerCount;
  int approvalCount;
  int newsCount;

  int firstInGroupCount;
  int reportCount;
  int newsGroupFollowerCount;
  int tweetCount;

  String websiteLink;
  String twitterLink;
  Uint8List photoInBytes;

  NewsSource.fromDocument(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data;
    id = documentSnapshot.documentID;
    twitterUsername = data['username'];
    name = data['name'];
    followerCount = data['followers_count'];
    tweetCount = data['tweets_count'];
    website = data['website'];
    photoUrl = data['profile_photo'];
    newsCount = data['news_count'];
    firstInGroupCount = data['news_group_leadership_count'];
    approvalCount = data['like_count'];
    reportCount = data['dislike_count'];

    websiteLink = 'https://$website';
    twitterLink = 'https//twitter/$twitterUsername';
  }
}
