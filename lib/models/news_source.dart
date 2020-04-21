import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class NewsSource {
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

  NewsSource();

  NewsSource.fromDocument(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data;
    id = documentSnapshot.documentID;
    name = data['name'];
    twitterUsername = data['username'];
    website = data['website'];
    photoUrl = data['profile_photo'];
    followerCount = data['followers_count'];
    approvalCount = data['number_of_approvals'];
    firstInGroupCount = data['number_of_first_news_in_group'];
    reportCount = data['number_of_reports'];
    newsCount = data['number_of_total_news'];
    newsGroupFollowerCount = data['number_of_total_newsgroup_followers'];
    tweetCount = data['tweets_count'];
    websiteLink = 'https://$website';
    twitterLink = 'https//twitter/$twitterUsername';
  }
}
