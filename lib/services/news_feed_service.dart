import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:newspector_flutter/models/news_feed.dart';
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
    @required int newsGroupPageSize,
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

    List<String> newsGroupIds = await NewsGroupService.addNewsGroupDocumentsToStores(
      newsGroupQuery.documents,
      newsGroupPageSize,
    );

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
}
