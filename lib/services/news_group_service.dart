import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/services/firestore_database_service.dart';
import 'package:newspector_flutter/stores/news_group_store.dart';

import 'news_article_service.dart';

class NewsGroupService {
  static NewsGroupStore _newsGroupStore = NewsGroupStore();

  static NewsGroup getNewsGroup(String id) {
    return _newsGroupStore.getNewsGroup(id);
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
      updateAndGetNewsGroup(newsGroupId);
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
}
