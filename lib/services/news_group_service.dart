import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/models/user.dart';
import 'package:newspector_flutter/services/fcm_service.dart';
import 'firestore/firestore_service.dart' as firestore;
import 'package:newspector_flutter/services/user_service.dart';
import 'package:newspector_flutter/stores/store.dart';

import 'news_article_service.dart';

class NewsGroupService {
  static Store<NewsGroup> _newsGroupStore = Store<NewsGroup>();

  /// Returns the existing News Group.
  static NewsGroup getNewsGroup(String id) {
    return _newsGroupStore.getItem(id);
  }

  /// Returns `true` if the News Group exists.
  ///
  /// Check the store for the news group
  static bool hasNewsGroup(String newsGroupId) {
    return _newsGroupStore.hasItem(newsGroupId);
  }

  /// Returns the existing or a new News Group.
  ///
  /// Checks if the news group exists,
  /// if it exist, returns the existing news group
  /// if not gets the newsgroup form the database and returns it.
  static Future<NewsGroup> getOrFetchNewsGroup(String newsGroupId) async {
    if (hasNewsGroup(newsGroupId)) return getNewsGroup(newsGroupId);

    return await updateAndGetNewsGroup(newsGroupId);
  }

  /// Adds or updates an existing news group in the store.
  static NewsGroup updateOrAddNewsGroup(NewsGroup newsGroup) {
    return _newsGroupStore.updateOrAddItem(newsGroup);
  }

  /// Clears the news group store.
  static void clearStore() {
    _newsGroupStore = Store<NewsGroup>();
  }

  /// Updates and returns the news group document but not the news articles within.
  static Future<NewsGroup> updateAndGetNewsGroup(String newsGroupId) async {
    // futures for newsGroup  and User
    var newsGroupDocumentFuture = firestore.getNewsGroup(newsGroupId);
    var _userFuture = UserService.getOrFetchUser();

    // wait for futures
    var futures = await Future.wait([newsGroupDocumentFuture, _userFuture]);
    DocumentSnapshot newsGroupDocument = futures[0];
    var newsGroup = NewsGroup.fromDocument(newsGroupDocument);
    User _user = futures[1];

    // check if the user follows the news group
    var followedDocumentId = await firestore.checkUserFollowsNewsGroupDocument(
      _user.id,
      newsGroupId,
    );
    newsGroup.followedByUser = followedDocumentId != null;

    NewsGroupService.updateOrAddNewsGroup(newsGroup);
    return newsGroup;
  }

  /// Updates and returns the news group document as a whole.
  ///
  /// Updates the news group using the "updateAndGetNewsGroup" function also
  /// fetches the news articles contained in the news group
  /// and add the articles to the news groups feed.
  static Future<NewsGroup> updateAndGetNewsGroupFeed({
    @required String newsGroupId,
    @required int pageSize,
    String lastDocumentId,
  }) async {
    bool refreshWanted = false;

    // If there is no timestamp a refresh is wanted.
    // If there is no user a refresh is required.
    if (lastDocumentId == null || !hasNewsGroup(newsGroupId)) {
      refreshWanted = true;
    }

    // If a refresh is wanted we want to update the newsgroup document as well.
    if (refreshWanted) {
      await updateAndGetNewsGroup(newsGroupId);
    }

    // Get the updated news group from the store.
    NewsGroup newsGroup = getNewsGroup(newsGroupId);

    // Make the correct query to fetch the needed news articles.
    QuerySnapshot newsArticleQuery;
    if (refreshWanted) {
      newsArticleQuery =
          await firestore.getNewsArticlesInNewsGroup(newsGroup.id, pageSize);
    } else {
      newsArticleQuery =
          await firestore.getNewsArticlesInNewsGroupAfterDocument(
              newsGroup.id, lastDocumentId, pageSize);
    }

    // Create News Article models from the fetched news article documents.
    List<String> newsArticleIds = List<String>();
    for (var newsArticleDocument in newsArticleQuery.documents) {
      var newsArticleId =
          NewsArticleService.createAndAddNewsArticle(newsArticleDocument);
      newsArticleIds.add(newsArticleId);
    }

    // If there is no feed in the news group create one.
    if (newsGroup.newsArticleFeed == null) {
      newsGroup.newsArticleFeed = Feed<String>();
    }

    // If refresh is wanted clear the items in the feed.
    if (refreshWanted) {
      newsGroup.newsArticleFeed.clearItems();
    }

    // Add the newly fetched news articles to the news group's feed.
    newsGroup.newsArticleFeed.addAdditionalItems(newsArticleIds);
    NewsGroupService.updateOrAddNewsGroup(newsGroup);

    return newsGroup;
  }

  /// Toggles the state of follow on a news group
  ///
  /// (Un)Subscribes and creates/deletes documents
  /// for the user follows news group documents
  static Future<void> toggleFollowNewsGroup({
    @required String newsGroupId,
    @required bool followed,
  }) async {
    NewsGroup _newsGroup = getNewsGroup(newsGroupId);
    _newsGroup.followedByUser = !_newsGroup.followedByUser;

    // Futures for newsGroup and user.
    var newsGroupDocumentFuture = getOrFetchNewsGroup(newsGroupId);
    var _userFuture = UserService.getOrFetchUser();

    // Wait for futures.
    var futures = await Future.wait([newsGroupDocumentFuture, _userFuture]);
    _newsGroup = futures[0];
    // NewsGroup _newsGroup = NewsGroup.fromDocument(newsGroupDocument);
    User _user = futures[1];

    if (followed) {
      await firestore.deleteUserFollowsNewsGroupDocument(
          _user.id, _newsGroup.id);
      FCMService.unsubscribeFromTopic(_newsGroup.id);
      return;
    }

    if (!followed) {
      await firestore.createUserFollowsNewsGroupDocument(
          _user.id, _newsGroup.id);
      FCMService.subscribeToTopic(_newsGroup.id);
      return;
    }
  }

  /// Given a list of news group documents,
  /// fetched the news articles for all of them in parallel,
  /// updates the news groups and the respective stores.
  ///
  /// returns a List of document ids for the news groups
  static Future<List<String>> fetchAndAddNewsArticlesInNewsGroups(
    List<DocumentSnapshot> newsGroupDocuments,
    int newsGroupPageSize,
  ) async {
    var newsGroupIds = List<String>();
    var newsArticleQueryFutures = List<Future<QuerySnapshot>>();
    var followedDocumentIdsFuture = List<Future<String>>();

    var _user = await UserService.getOrFetchUser();

    // Start the news article fetch for all news groups in parallel.
    // Start the followed document check for all news groups in parallel.
    for (var newsGroupDoc in newsGroupDocuments) {
      Future<QuerySnapshot> newsArticleQueryFuture =
          firestore.getNewsArticlesInNewsGroup(
        newsGroupDoc.documentID,
        newsGroupPageSize,
      );
      newsArticleQueryFutures.add(newsArticleQueryFuture);

      var followedDocumentIdFuture = firestore
          .checkUserFollowsNewsGroupDocument(_user.id, newsGroupDoc.documentID);
      followedDocumentIdsFuture.add(followedDocumentIdFuture);
    }

    // Wait for all the futures.
    var futures = await Future.wait([
      Future.wait(newsArticleQueryFutures),
      Future.wait(followedDocumentIdsFuture),
    ]);
    List<QuerySnapshot> newsArticleQueries = futures[0];
    List<String> followedDocumentIds = futures[1];

    for (var i = 0; i < newsArticleQueries.length; i++) {
      var newsGroupDoc = newsGroupDocuments[i];
      var newsArticleQuery = newsArticleQueries[i];
      var followedDocumentId = followedDocumentIds[i];

      List<String> newsArticleIds = List<String>();

      // Create news articles from documents.
      for (var newsArticleDoc in newsArticleQuery.documents) {
        var newsArticleId =
            NewsArticleService.createAndAddNewsArticle(newsArticleDoc);
        newsArticleIds.add(newsArticleId);
      }

      if (newsArticleIds.length == 0) continue;

      // Create a news group and add the news articles and the followed information.
      NewsGroup newsGroup = NewsGroup.fromDocument(newsGroupDoc);
      newsGroup.addNewsArticles(newsArticleIds);
      newsGroup.followedByUser = followedDocumentId != null;

      NewsGroupService.updateOrAddNewsGroup(newsGroup);
      newsGroupIds.add(newsGroupDoc.documentID);
    }

    return newsGroupIds;
  }
}
