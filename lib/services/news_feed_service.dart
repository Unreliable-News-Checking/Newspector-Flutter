import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/models/news_feed.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'firestore_database_service.dart';

class NewsFeedService {
  static NewsFeed newsFeed;

  static NewsFeed getNewsFeed() {
    return newsFeed;
  }

  static bool hasFeed() {
    return newsFeed != null;
  }

  static Future<NewsFeed> updateAndGetNewsFeed({
    @required int pageSize,
    String lastDocumentId,
  }) async {
    List<NewsGroup> newsGroups = List<NewsGroup>();
    NewsFeed feed;
    bool refreshWanted = false;

    // if there is no timestamp a refresh is wanted
    if (lastDocumentId == null) {
      refreshWanted = true;
    }

    // If there is no feed, fetch the user first
    // if there is a feed, but refresh is wanted, fetch the updated feed
    if (!hasFeed() || refreshWanted) {
      feed = NewsFeed();
    } else {
      feed = newsFeed;
    }

    // if there is a feed and no refresh is wanted,
    // save the existing feed
    if (hasFeed() && !refreshWanted) {
      newsGroups.addAll(feed.newsGroups);
    }

    // get the right documents from the database
    QuerySnapshot newsGroupQuery;
    if (refreshWanted) {
      newsGroupQuery = await FirestoreService.getClusters(pageSize);
    } else {
      newsGroupQuery = await FirestoreService.getClustersAfterDocument(
          lastDocumentId, pageSize);
    }

    print(
        "returned documents length after $lastDocumentId: ${newsGroupQuery.documents.length}");

    List<Future<QuerySnapshot>> newsArticleQueryFutures =
        List<Future<QuerySnapshot>>();

    // add the existing news groups

    // 1) get the newsgroups and turn them into models
    // 2) add them to news group store
    // 3) start the fetch for the news articles in parallel
    for (var newsGroupDoc in newsGroupQuery.documents) {
      NewsGroup newsGroup = NewsGroup.fromDocument(newsGroupDoc);
      NewsGroupService.updateOrAddNewsGroup(newsGroup);
      newsGroups.add(newsGroup);

      Future<QuerySnapshot> newsArticleQueryFuture =
          FirestoreService.getNewsInCluster(newsGroup.id, 5);

      newsArticleQueryFutures.add(newsArticleQueryFuture);
    }

    // 1) wait for news articles to be fetched
    // 2) turn them into models
    // 3) add them to news article store
    // 4) add the articles to news group
    var newsArticleQueries = await Future.wait(newsArticleQueryFutures);
    for (var newsArticleQuery in newsArticleQueries) {
      List<String> newsArticleIds = List<String>();
      String newsGroupId;
      for (var newsArticleDoc in newsArticleQuery.documents) {
        NewsArticle newsArticle = NewsArticle.fromDocument(newsArticleDoc);
        NewsArticleService.updateOrAddNewsArticle(newsArticle);
        newsArticleIds.add(newsArticle.id);
        newsGroupId = newsArticle.newsGroupId;
      }
      NewsGroupService.getNewsGroup(newsGroupId)
          .addNewsArticles(newsArticleIds);
    }

    feed.newsGroups = newsGroups;
    newsFeed = feed;
    return feed;
  }
}
