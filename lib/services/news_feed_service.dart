import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:newspector_flutter/models/category.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'firestore/firestore_service.dart' as firestore;
import 'package:newspector_flutter/application_constants.dart' as app_const;

enum FeedType {
  Home,
  Following,
  Category,
}

class NewsFeedService {
  static Feed<String> _homeFeed;
  static Feed<String> _followingFeed;
  static Map<NewsCategory, Feed<String>> _categoryFeeds = Map();

  /// Returns the existing feed.
  ///
  /// There is no null check here use it with caution.
  static Feed<String> getFeed(
    FeedType feedType, {
    NewsCategory newsCategory,
  }) {
    Feed<String> _feed;
    if (feedType == FeedType.Home) {
      _feed = _homeFeed;
    } else if (feedType == FeedType.Following) {
      _feed = _followingFeed;
    } else if (feedType == FeedType.Category) {
      var wantedCategory = newsCategory ?? NewsCategory.artEntertainment;
      _feed = _categoryFeeds[wantedCategory];
    }

    return _feed;
  }

  /// Creates an empty feed object at the spesified feed.
  static void createEmptyFeed({
    @required FeedType feedType,
    NewsCategory newsCategory,
  }) {
    if (feedType == FeedType.Home) {
      _homeFeed = Feed<String>();
    } else if (feedType == FeedType.Following) {
      _followingFeed = Feed<String>();
    } else if (feedType == FeedType.Category) {
      var wantedCategory = newsCategory ?? NewsCategory.artEntertainment;
      _categoryFeeds[wantedCategory] = Feed<String>();
    }
  }

  /// Returns true if there is a feed.
  static bool hasFeed(
    FeedType feedType, {
    NewsCategory newsCategory,
  }) {
    Feed<String> _feed = getFeed(feedType, newsCategory: newsCategory);
    return _feed != null;
  }

  /// If a news feed exists, returns it. If not fetches it from the database and then returns it.
  static Future<Feed<String>> getOrFetchFeed({
    @required FeedType feedType,
    NewsCategory newsCategory,
  }) async {
    if (hasFeed(feedType, newsCategory: newsCategory)) {
      return getFeed(feedType, newsCategory: newsCategory);
    }

    return await updateAndGetNewsFeed(
      pageSize: app_const.homePagePageSize,
      newsGroupPageSize: app_const.newsGroupPageSize,
      feedType: feedType,
      newsCategory: newsCategory,
    );
  }

  /// Clears all the feeds in this class.
  static void clearFeeds() {
    _homeFeed.clearItems();
    _followingFeed.clearItems();
    _categoryFeeds.clear();

    _homeFeed = null;
    _followingFeed = null;
    _categoryFeeds = Map();
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
    @required FeedType feedType,
    NewsCategory newsCategory,
  }) async {
    bool refreshWanted = false;

    // If there is no timestamp a refresh is wanted.
    // If there is no feed a refresh is required.
    if (lastDocumentId == null ||
        !hasFeed(feedType, newsCategory: newsCategory)) {
      refreshWanted = true;
    }

    // get the right documents from the database
    List<DocumentSnapshot> newsGroupDocuments;
    if (refreshWanted) {
      newsGroupDocuments =
          await firestore.getNewsGroups(pageSize, feedType, newsCategory);
    } else {
      newsGroupDocuments = await firestore.getNewsGroups(
        pageSize,
        feedType,
        newsCategory,
        lastDocumentId: lastDocumentId,
      );
    }

    List<String> newsGroupIds =
        await NewsGroupService.fetchAndAddNewsArticlesInNewsGroups(
      newsGroupDocuments,
      newsGroupPageSize,
    );

    // if there is no feed create one
    if (!hasFeed(feedType, newsCategory: newsCategory)) {
      createEmptyFeed(
        feedType: feedType,
        newsCategory: newsCategory,
      );
    }

    Feed<String> _feed = getFeed(feedType, newsCategory: newsCategory);

    // if refresh is wanted clear the feed
    if (refreshWanted) {
      _feed.clearItems();
    }

    // add the items to feed
    _feed.addAdditionalItems(newsGroupIds);

    return _feed;
  }
}
