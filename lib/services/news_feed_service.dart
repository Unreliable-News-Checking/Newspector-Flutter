import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'firestore/firestore_service.dart' as firestore;
import 'package:newspector_flutter/application_constants.dart' as app_const;

class NewsFeedService {
  static Feed<String> _newsFeed;

  /// If a news feed exists, returns it. If not fetches it from the database and then returns it.
  static Future<Feed<String>> getOrFetchNewsFeed() async {
    if (hasFeed()) return _newsFeed;

    return await updateAndGetNewsFeed(
        pageSize: app_const.homePagePageSize,
        newsGroupPageSize: app_const.newsGroupPageSize);
  }

  /// Returns true if there is a feed.
  static bool hasFeed() {
    return _newsFeed != null;
  }

  /// Returns the existing feed.
  ///
  /// There is no null check here use it with caution.
  static Feed<String> getFeed() {
    return _newsFeed;
  }

  static void clearFeed() {
    _newsFeed = null;
  }

  /// Fetches news groups from the database and returns them in a feed.
  ///
  /// The number of news groups that will be fetched is determined by [pageSize].
  /// The function will return at maximum [pageSize] number of news groups. The [newsGroupPageSize]
  /// determines the maximum number of news articles will be fetched per news group. The [lastDocumentId]
  /// is optional and is used for pagination. If [lastDocumentId] is specified only documents
  /// after that document will be fetched. When [lastDocumenId] is a non null value, the fetched documents
  /// will be added at the end of the existing feed.
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
    }

    // get the right documents from the database
    QuerySnapshot newsGroupQuery;
    if (refreshWanted) {
      newsGroupQuery = await firestore.getNewsGroups(pageSize);
    } else {
      newsGroupQuery =
          await firestore.getNewsGroupsAfterDocument(lastDocumentId, pageSize);
    }

    List<String> newsGroupIds =
        await NewsGroupService.fetchAndAddNewsArticlesInNewsGroups(
      newsGroupQuery.documents,
      newsGroupPageSize,
    );

    // if there is no feed create one
    if (!hasFeed()) {
      _newsFeed = Feed<String>();
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
