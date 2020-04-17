import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/models/user.dart';
import 'package:newspector_flutter/services/firestore_database_service.dart';
import 'package:newspector_flutter/services/news_group_service.dart';

import 'news_article_service.dart';

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
    return hasUser() && user.followingFeed != null;
  }

  static Future<User> updateAndGetUser() async {
    var userSnapshot =
        await FirestoreService.getUserWithFirebaseId(userFirebaseId);
    var _user = User.fromDocument(userSnapshot);
    user = _user;
    return _user;
  }

  static Future<User> updateAndGetUserFeed({
    @required int pageSize,
    Timestamp lastTimestamp,
  }) async {
    List<String> newsGroupIds = List<String>();
    User _user;
    bool refreshWanted = false;

    // if there is no timestamp a refresh is wanted
    if (lastTimestamp == null) {
      refreshWanted = true;
    }

    // If there is no user, fetch the user first
    // if there is a user, but refresh is wanted, fetch the updated user
    if (!hasUser() || refreshWanted) {
      _user = await updateAndGetUser();
    } else {
      _user = user;
    }

    // if there is a feed and no refresh is wanted,
    // save the existing feed
    if (hasUserWithFeed() && !refreshWanted) {
      newsGroupIds.addAll(user.followingFeed.items);
    }

    // get the user follows cluster documents
    // according to the wanted action (refresh, scroll down, or first load)
    QuerySnapshot userFollowsGroupQuery;
    if (refreshWanted) {
      userFollowsGroupQuery =
          await FirestoreService.gerUserFollowsClusters(_user.id, pageSize);
    } else {
      userFollowsGroupQuery =
          await FirestoreService.getUserFollowsClusterAfterTimestamp(
              _user.id, lastTimestamp, pageSize);
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

    // TODO: make a new method
    // the rest of this method can be turned into another method
    // that fetches and updates the clusters that is in a newsGroupQuery

    List<Future<QuerySnapshot>> newsArticleQueryFutures =
        List<Future<QuerySnapshot>>();
    List<String> newsArticleGroupIds = List();

    // 1) get the newsgroups and turn them into models
    // 2) add them to news group store
    // 3) start the fetch for the news articles in parallel
    for (var newsGroupDoc in newsGroupDocuments) {
      NewsGroup newsGroup = NewsGroup.fromDocument(newsGroupDoc);
      NewsGroupService.updateOrAddNewsGroup(newsGroup);
      newsGroupIds.add(newsGroup.id);

      Future<QuerySnapshot> newsArticleQueryFuture =
          FirestoreService.getNewsInCluster(newsGroup.id, 5);

      newsArticleQueryFutures.add(newsArticleQueryFuture);
      newsArticleGroupIds.add(newsGroup.id);
    }

    // 1) wait for news articles to be fetched
    // 2) turn them into models
    // 3) add them to news article store
    // 4) add the articles to news group
    var newsArticleQueries = await Future.wait(newsArticleQueryFutures);
    for (var i = 0; i < newsArticleQueries.length; i++) {
      var newsArticleQuery = newsArticleQueries[i];
      var newsArticleGroupId = newsArticleGroupIds[i];

      List<String> newsArticleIds = List<String>();
      for (var newsArticleDoc in newsArticleQuery.documents) {
        NewsArticle newsArticle = NewsArticle.fromDocument(newsArticleDoc);
        NewsArticleService.updateOrAddNewsArticle(newsArticle);
        newsArticleIds.add(newsArticle.id);
      }
      NewsGroupService.getNewsGroup(newsArticleGroupId)
          .addNewsArticles(newsArticleIds);
    }

    var _followingFeed = Feed<String>.fromItems(newsGroupIds);
    user.assignFeedToUser(_followingFeed);
    user = _user;
    return _user;
  }

  static void assingUser(User user) {
    UserService.user = user;
  }
}
