import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/models/news_feed.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'firestore_database_service.dart';

class NewsFeedService {
  static NewsFeed _newsFeed;

  static NewsFeed getNewsFeed() {
    return _newsFeed;
  }

  static bool hasFeed() {
    return _newsFeed != null;
  }

  static void assignFeed(NewsFeed feed) {
    NewsFeedService._newsFeed = feed;
  }

  static void clearFeed() {
    _newsFeed = null;
  }

  static Future<NewsFeed> updateAndGetNewsFeed({
    @required int pageSize,
    String lastDocumentId,
  }) async {
    bool refreshWanted = false;

    // if there is no timestamp a refresh is wanted
    // if there is no feed a refresh is required
    if (lastDocumentId == null || !hasFeed()) {
      refreshWanted = true;
    }

    // get the right documents from the database
    QuerySnapshot newsGroupQuery;
    if (refreshWanted) {
      newsGroupQuery = await FirestoreService.getClusters(pageSize);
    } else {
      newsGroupQuery = await FirestoreService.getClustersAfterDocument(
          lastDocumentId, pageSize);
    }

    List<String> newsGroupIds =
        await addNewsGroupDocumentsToStores(newsGroupQuery.documents);

    // if there is no feed create one
    if (!hasFeed()) {
      _newsFeed = NewsFeed();
    }

    // if refresh is wanted clear the feed
    if (refreshWanted) {
      _newsFeed.clearItems();
    }

    // add the items to feed
    _newsFeed.addAdditionalItems(newsGroupIds);

    return _newsFeed;
  }

  static Future<List<String>> addNewsGroupDocumentsToStores(
      List<DocumentSnapshot> newsGroupDocuments) async {
    List<String> newsGroupIds = List<String>();
    List<Future<QuerySnapshot>> newsArticleQueryFutures =
        List<Future<QuerySnapshot>>();

    // 1) start the fetch for the news articles in parallel
    for (var newsGroupDoc in newsGroupDocuments) {
      Future<QuerySnapshot> newsArticleQueryFuture =
          FirestoreService.getNewsInCluster(newsGroupDoc.documentID, 5);
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
      NewsGroupService.updateOrAddNewsGroup(newsGroup);
      newsGroupIds.add(newsGroupDoc.documentID);
    }

    return newsGroupIds;
  }
}
