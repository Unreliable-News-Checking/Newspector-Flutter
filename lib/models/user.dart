import 'package:cloud_firestore/cloud_firestore.dart';

import 'feed.dart';

class User {
  String id;
  String firebaseId;
  String notificationToken;
  Feed<String> followingFeed;

  User();

  User.fromDocument(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.documentID;
    firebaseId = documentSnapshot.data['uid'];
    notificationToken = null;
    followingFeed = null;
  }

  User.fromMap(Map<String, dynamic> userData, String documentId) {
    this.id = documentId;
    this.firebaseId = userData['uid'];
    notificationToken = null;
    followingFeed = null;
  }

  void assignFeedToUser(Feed<String> followingFeed) {
    this.followingFeed = followingFeed;
  }

  bool hasFeed() {
    return followingFeed != null;
  }
}
