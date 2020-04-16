// import 'news_group.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String notificationToken;
  List<String> followedGroupIds;

  User();

  User.fromAttributes(
      String id, String notificationToken, List<String> followedGroupIds) {
    this.id = id;
    this.notificationToken = notificationToken;
    this.followedGroupIds = followedGroupIds;
  }

  User.fromDocument(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.documentID;
    notificationToken = null;
    followedGroupIds = null;
  }

  int getFollowedGroupCount() {
    return followedGroupIds.length;
  }

  String getFollowedNewsGroupId(int index) {
    return followedGroupIds[index];
  }
}
