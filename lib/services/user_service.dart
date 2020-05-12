import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/models/user.dart';
import 'firestore/firestore_service.dart' as firestore;
import 'package:newspector_flutter/services/news_group_service.dart';
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
    return _hasUser() && _user.hasFeed();
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
      pageSize: app_consts.followingPagePageSize,
      newsGroupPageSize: app_consts.newsGroupPageSize,
    );
  }

  /// Assigns a new user to the service.
  static void assingUser(User user) {
    UserService._user = user;
  }

  /// Clears the existing user.
  static void clearUser() {
    _user = null;
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

    // Get the correct user follows news group documents
    QuerySnapshot userFollowsGroupQuery;
    if (refreshWanted) {
      userFollowsGroupQuery =
          await firestore.getUserFollowsNewsGroups(_user.id, pageSize);
    } else {
      userFollowsGroupQuery =
          await firestore.getUserFollowsNewsGroupAfterDocument(
              _user.id, lastDocumentId, pageSize);
    }

    // From the user follows news group documents,
    // get the news group ids and start fetching the news groups in parallel
    List<Future<DocumentSnapshot>> newsGroupDocumentFutures = List();
    for (var userFollowsNewsGroupDoc in userFollowsGroupQuery.documents) {
      var newsGroupId = userFollowsNewsGroupDoc.data['news_group_id'];
      var newsGroupDocumentFuture = firestore.getNewsGroup(newsGroupId);
      newsGroupDocumentFutures.add(newsGroupDocumentFuture);
    }
    List<DocumentSnapshot> tempGroupDocuments =
        await Future.wait(newsGroupDocumentFutures);

    List<DocumentSnapshot> newsGroupDocuments = List();
    for (var document in tempGroupDocuments) {
      if (!document.exists) continue;
      newsGroupDocuments.add(document);
    }

    List<String> newsGroupIds =
        await NewsGroupService.fetchAndAddNewsArticlesInNewsGroups(
      newsGroupDocuments,
      newsGroupPageSize,
    );

    // if there is no feed create one
    if (!hasUserWithFeed()) {
      _user.followingFeed = Feed<String>();
    }

    // if refresh is wanted clear the feed
    if (refreshWanted) {
      _user.followingFeed.clearItems();
    }

    // add the items to feed
    _user.followingFeed.addAdditionalItems(newsGroupIds);

    return _user;
  }
}
