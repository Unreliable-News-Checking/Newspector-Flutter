import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/models/user.dart';
import 'package:newspector_flutter/services/firestore_database_service.dart';
import 'news_feed_service.dart';

class UserService {
  static String userFirebaseId;
  static User user;

  static User getUser() {
    return user;
  }

  static bool hasUser() {
    return user != null;
  }

  static bool hasUserWithFeed() {
    return hasUser() && user.hasFeed();
  }

  static Future<User> updateAndGetUser() async {
    var userSnapshot =
        await FirestoreService.getUserWithFirebaseId(userFirebaseId);
    user = User.fromDocument(userSnapshot);
    return user;
  }

  static Future<User> updateAndGetUserFeed({
    @required int pageSize,
    String lastDocumentId,
  }) async {
    bool refreshWanted = false;

    // if there is no timestamp a refresh is wanted
    // if there is no user a refresh is required
    if (lastDocumentId == null || !hasUser()) {
      refreshWanted = true;
    }

    // If a refresh is wanted, fetch the user from the database
    if (refreshWanted) {
      await updateAndGetUser();
    }

    // get the user follows cluster documents
    // according to the wanted action (refresh or scroll down)
    QuerySnapshot userFollowsGroupQuery;
    if (refreshWanted) {
      userFollowsGroupQuery =
          await FirestoreService.gerUserFollowsClusters(user.id, pageSize);
    } else {
      userFollowsGroupQuery =
          await FirestoreService.getUserFollowsClusterAfterTimestamp(
              user.id, lastDocumentId, pageSize);
    }

    // from the user follows cluster documents,
    // get the clusterId and start fetching the clusters in parallel
    List<Future<DocumentSnapshot>> clusterDocumentFutures = List();
    for (var userFollowsClusterDoc in userFollowsGroupQuery.documents) {
      var clusterId = userFollowsClusterDoc.data['cluster_id'];
      var clusterDocumentFuture = FirestoreService.getCluster(clusterId);
      clusterDocumentFutures.add(clusterDocumentFuture);
    }
    List<DocumentSnapshot> newsGroupDocuments =
        await Future.wait(clusterDocumentFutures);

    List<String> newsGroupIds =
        await NewsFeedService.addNewsGroupDocumentsToStores(newsGroupDocuments);

    if (!hasUserWithFeed()) {
      user.assignFeedToUser(Feed<String>());
    }

    user.followingFeed.addAdditionalItems(newsGroupIds);

    return user;
  }

  static void assingUser(User user) {
    UserService.user = user;
  }

  static void clearUser() {
    user = null;
  }
}
