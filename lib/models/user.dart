// import 'news_group.dart';

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

  int getFollowedGroupCount() {
    return followedGroupIDs.length;
  }

  String getFollowedNewsGroupID(int index) {
    return followedGroupIDs[index];
  }
}
