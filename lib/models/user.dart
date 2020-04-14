// import 'news_group.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String notificationToken;
  List<String> followedGroupIDs;

  User();

  User.fromAttributes(
      String id, String notificationToken, List<String> followedGroupIDs) {
    this.id = id;
    this.notificationToken = notificationToken;
    this.followedGroupIDs = followedGroupIDs;
  }

  User.fromDocument(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.documentID;
    notificationToken = null;
    followedGroupIDs = null;
  }

  int getFollowedGroupCount() {
    return followedGroupIDs.length;
  }

  String getFollowedNewsGroupID(int index) {
    return followedGroupIDs[index];
  }
}
