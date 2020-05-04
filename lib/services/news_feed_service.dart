import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'firestore_database_service.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

class NewsFeedService {
  static Feed<String> _newsFeed;

  static Future<Feed<String>> getOrFetchNewsFeed() async {
    if (hasFeed()) return _newsFeed;

    return await updateAndGetNewsFeed(
        pageSize: app_const.homePagePageSize,
        newsGroupPageSize: app_const.newsGroupPageSize);
  }

  static bool hasFeed() {
    return _newsFeed != null;
  }

  static Feed<String> getFeed() {
    return _newsFeed;
  }

  static void clearFeed() {
    _newsFeed = null;
  }

  static Future<Feed<String>> updateAndGetNewsFeed({
    @required int pageSize,
    @required int newsGroupPageSize,
    String lastDocumentId,
  }) async {
    bool refreshWanted = false;

    // If there is no timestamp a refresh is wanted.
    // If there is no feed a refresh is required.
    if (lastDocumentId == null || !hasFeed()) {
      refreshWanted = true;
      _newsFeed = Feed<String>();
      _newsFeed.clearItems();
    }

    // get the right documents from the database
    QuerySnapshot newsGroupQuery;
    if (refreshWanted) {
      newsGroupQuery = await FirestoreService.getNewsGroups(pageSize);
    } else {
      newsGroupQuery = await FirestoreService.getNewsGroupsAfterDocument(
          lastDocumentId, pageSize);
    }

    List<String> newsGroupIds =
        await NewsGroupService.fetchAndAddNewsArticlesInNewsGroups(
      newsGroupQuery.documents,
      newsGroupPageSize,
    );

    // if there is no feed create one
    // if (!_hasFeed()) {
    //   _newsFeed = NewsFeed();
    // }

    // if refresh is wanted clear the feed
    // if (refreshWanted) {
    //   _newsFeed.clearItems();
    // }

    // add the items to feed
    _newsFeed.addAdditionalItems(newsGroupIds);

    return _newsFeed;
  }
}
