import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import 'model.dart';

class NewsSource extends Model {
  String id;
  String name;
  String twitterUsername;
  String website;
  String photoUrl;

  int followerCount;
  int newsCount;

  int likes;
  int dislikes;
  int reports;
  double rating;

  int firstInGroupCount;
  int reportCount;
  int newsGroupFollowerCount;
  int tweetCount;

  String birthday;

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
    reportCount = data['dislike_count'];
    birthday = data['birthday'];

    websiteLink = website;
    twitterLink = 'https://twitter/$twitterUsername';
  }

  void updateRatingsFromDatabase(DataSnapshot dataSnapshot) {
    var data = dataSnapshot.value;
    likes = data['likes_count'];
    dislikes = data['dislikes_count'];
    reports = data['reports_count'];

    rating = max((likes - dislikes) / max(likes + dislikes, 1), 0);
  }
}
