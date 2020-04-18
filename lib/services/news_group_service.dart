import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  static Future<NewsGroup> updateAndGetNewsGroup({
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

    DocumentSnapshot newsGroupDocument =
        await FirestoreService.getCluster(newsGroupId);

    QuerySnapshot newsArticleQuery;
    if (refreshWanted) {
      newsArticleQuery = await FirestoreService.getNewsInCluster(
          newsGroupDocument.documentID, pageSize);
    } else {
      newsArticleQuery = await FirestoreService.getNewsInClusterAfterDocument(
          newsGroupDocument.documentID, lastDocumentId, pageSize);
    }

    List<String> newsArticleIds = List<String>();
    for (var newsArticleDocument in newsArticleQuery.documents) {
      NewsArticle newsArticle = NewsArticle.fromDocument(newsArticleDocument);
      NewsArticleService.updateOrAddNewsArticle(newsArticle);
      newsArticleIds.add(newsArticle.id);
    }

    NewsGroup newsGroup = NewsGroup.fromDocument(newsGroupDocument);
    newsGroup.addNewsArticles(newsArticleIds);
    NewsGroupService.updateOrAddNewsGroup(newsGroup);

    return newsGroup;
  }
}
