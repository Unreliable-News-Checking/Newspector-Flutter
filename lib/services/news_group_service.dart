import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/services/firestore_database_service.dart';
import 'package:newspector_flutter/services/user_service.dart';
import 'package:newspector_flutter/stores/news_group_store.dart';

import 'news_article_service.dart';

class NewsGroupService {
  static NewsGroupStore _newsGroupStore = NewsGroupStore();

  static NewsGroup getNewsGroup(String id) {
    return _newsGroupStore.getNewsGroup(id);
  }

  static Future<NewsGroup> getOrFetchNewsGroup(String newsGroupId) async {
    if (hasNewsGroup(newsGroupId)) return getNewsGroup(newsGroupId);

    return await updateAndGetNewsGroup(newsGroupId);
  }

  static NewsGroup updateOrAddNewsGroup(NewsGroup newsGroup) {
    return _newsGroupStore.updateOrAddNewsArticle(newsGroup);
  }

  static void clearStore() {
    _newsGroupStore = NewsGroupStore();
  }

  static bool hasNewsGroup(String newsGroupId) {
    return _newsGroupStore.hasNewsGroup(newsGroupId);
  }

  static Future<NewsGroup> updateAndGetNewsGroup(String newsGroupId) async {
    var documentSnapshot = await FirestoreService.getCluster(newsGroupId);
    var newsGroup = NewsGroup.fromDocument(documentSnapshot);

    var _user = await UserService.getOrFetchUser();
    var followedDocumentId =
        await FirestoreService.checkUserFollowsClusterDocument(
            _user.id, newsGroupId);

    newsGroup.followedByUser = followedDocumentId != null;

    NewsGroupService.updateOrAddNewsGroup(newsGroup);
    return newsGroup;
  }

  static Future<NewsGroup> updateAndGetNewsGroupFeed({
    @required String newsGroupId,
    @required int pageSize,
    String lastDocumentId,
  }) async {
    bool refreshWanted = false;

    // if there is no timestamp a refresh is wanted
    // if there is no user a refresh is required
    if (lastDocumentId == null || !hasNewsGroup(newsGroupId)) {
      refreshWanted = true;
    }

    if (refreshWanted) {
      await updateAndGetNewsGroup(newsGroupId);
    }
    NewsGroup newsGroup = getNewsGroup(newsGroupId);

    QuerySnapshot newsArticleQuery;
    if (refreshWanted) {
      newsArticleQuery =
          await FirestoreService.getNewsInCluster(newsGroup.id, pageSize);
    } else {
      newsArticleQuery = await FirestoreService.getNewsInClusterAfterDocument(
          newsGroup.id, lastDocumentId, pageSize);
    }

    print(
        "news article query result count: ${newsArticleQuery.documents.length}");

    List<String> newsArticleIds = List<String>();
    for (var newsArticleDocument in newsArticleQuery.documents) {
      NewsArticle newsArticle = NewsArticle.fromDocument(newsArticleDocument);
      NewsArticleService.updateOrAddNewsArticle(newsArticle);
      newsArticleIds.add(newsArticle.id);
    }

    if (newsGroup.newsArticleFeed == null) {
      newsGroup.newsArticleFeed = Feed<String>();
    }

    if (refreshWanted) {
      newsGroup.newsArticleFeed.clearItems();
    }

    newsGroup.newsArticleFeed.addAdditionalItems(newsArticleIds);

    // NewsGroup newsGroup = NewsGroup.fromDocument(newsGroupDocument);
    // newsGroup.addNewsArticles(newsArticleIds);
    NewsGroupService.updateOrAddNewsGroup(newsGroup);

    return newsGroup;
  }

  static Future<void> toggleFollowNewsGroup({
    @required String newsGroupId,
    @required bool followed,
  }) async {
    var _newsGroup = await getOrFetchNewsGroup(newsGroupId);
    var _user = await UserService.getOrFetchUser();

    if (followed) {
      await FirestoreService.deleteUserFollowsClusterDocument(
          _user.id, _newsGroup.id);
    } else {
      await FirestoreService.createUserFollowsClusterDocument(
          _user.id, _newsGroup.id);
    }

    return;
  }

  static Future<List<String>> addNewsGroupDocumentsToStores(
      List<DocumentSnapshot> newsGroupDocuments, int newsGroupPageSize) async {
    var _user = await UserService.getOrFetchUser();
    List<String> newsGroupIds = List<String>();
    List<Future<QuerySnapshot>> newsArticleQueryFutures =
        List<Future<QuerySnapshot>>();

    // 1) start the fetch for the news articles in parallel
    for (var newsGroupDoc in newsGroupDocuments) {
      Future<QuerySnapshot> newsArticleQueryFuture =
          FirestoreService.getNewsInCluster(
              newsGroupDoc.documentID, newsGroupPageSize);
      newsArticleQueryFutures.add(newsArticleQueryFuture);
    }

    // 1) wait for news articles to be fetched
    // 2) turn them into models
    // 3) add them to news article store
    // 4) add the articles to news group
    // 5 add them to news group store
    var newsArticleQueries = await Future.wait(newsArticleQueryFutures);
    for (var i = 0; i < newsArticleQueries.length; i++) {
      var newsArticleQuery = newsArticleQueries[i];
      var newsGroupDoc = newsGroupDocuments[i];
      List<String> newsArticleIds = List<String>();

      for (var newsArticleDoc in newsArticleQuery.documents) {
        NewsArticle newsArticle = NewsArticle.fromDocument(newsArticleDoc);
        NewsArticleService.updateOrAddNewsArticle(newsArticle);
        newsArticleIds.add(newsArticle.id);
      }

      NewsGroup newsGroup = NewsGroup.fromDocument(newsGroupDoc);
      newsGroup.addNewsArticles(newsArticleIds);

      var followedDocumentId =
          await FirestoreService.checkUserFollowsClusterDocument(
              _user.id, newsGroup.id);

      newsGroup.followedByUser = followedDocumentId != null;

      NewsGroupService.updateOrAddNewsGroup(newsGroup);
      newsGroupIds.add(newsGroupDoc.documentID);
    }

    return newsGroupIds;
  }
}
