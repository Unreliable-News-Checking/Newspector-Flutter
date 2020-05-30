import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/user.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'firestore/firestore_service.dart' as firestore;
import 'package:newspector_flutter/application_constants.dart' as app_consts;

class UserService {
  static String userFirebaseId;
  static User _user;

  /// Returns the current User.
  static User getUser() {
    return _user;
  }

  /// Returns `true` if there is a user.
  static bool _hasUser() {
    return _user != null;
  }

  /// Return `true` if there is a user and the user has a feed.
  static bool hasUserWithFeed() {
    return _hasUser() && NewsFeedService.hasFeed(FeedType.Following);
  }

  /// If there is an existing user returns it or fetched it from the database.
  static Future<User> getOrFetchUser() async {
    if (_hasUser()) return _user;

    return await updateAndGetUser();
  }

  /// If there is an existing user with a feed returns it
  /// or fetches the user and its feed from the database.
  static Future<User> getOrFetchUserWithFeed() async {
    if (hasUserWithFeed()) return _user;

    return await updateAndGetUserWithFeed(
      pageSize: app_consts.newsFeedPageSize,
      newsGroupPageSize: app_consts.newsGroupPageSize,
    );
  }

  /// Assigns a new user to the service.
  static void assingUser(User user, String firebaseUserId) {
    UserService._user = user;
    UserService.userFirebaseId = firebaseUserId;
  }

  /// Clears the existing user.
  static void clearUser() {
    _user = null;
    userFirebaseId = null;
  }

  /// Fetched the user with the matching [userFirebaseId] from the database.
  ///
  /// Only fetches the user document and not the news groups that the user follows.
  static Future<User> updateAndGetUser() async {
    var userSnapshot = await firestore.getUserWithFirebaseId(userFirebaseId);
    _user = User.fromDocument(userSnapshot);
    return _user;
  }

  /// Fetches the news groups that the user with [userFirebaseId] follows
  /// from the database and returns them in a feed.
  ///
  /// The number of news groups that will be fetched is determined by [pageSize].
  /// The function will return at maximum [pageSize] number of news groups. The [newsGroupPageSize]
  /// determines the maximum number of news articles will be fetched per news group. The [lastDocumentId]
  /// is optional and is used for pagination. If [lastDocumentId] is specified only documents
  /// after that document will be fetched. When [lastDocumenId] is a non null value, the fetched documents
  /// will be added at the end of the existing feed.
  static Future<User> updateAndGetUserWithFeed({
    @required int pageSize,
    @required int newsGroupPageSize,
    String lastDocumentId,
  }) async {
    bool refreshWanted = false;

    // If there is no timestamp a refresh is wanted.
    // If there is no user a refresh is required.
    if (lastDocumentId == null || !_hasUser()) {
      refreshWanted = true;
    }

    // If a refresh is wanted, fetch the user from the database.
    if (refreshWanted) {
      await updateAndGetUser();
    }

    await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      newsGroupPageSize: newsGroupPageSize,
      feedType: FeedType.Following,
      lastDocumentId: lastDocumentId,
    );

    return _user;
  }
}
