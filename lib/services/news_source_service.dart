import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:http/http.dart';
import 'package:newspector_flutter/services/user_service.dart';
import 'package:newspector_flutter/stores/store.dart';
import 'firestore/firestore_service.dart' as firestore;
import 'realtime/realtime_service.dart' as realtime;
import 'package:newspector_flutter/utilities.dart' as utils;

class NewsSourceService {
  static Store<NewsSource> _newsSourceStore = Store<NewsSource>();
  static Feed<String> _newsSourceFeed;

  /// Returns the existing news source feed.
  ///
  /// No null check use with caution.
  static Feed<String> getNewsSourceFeed() {
    return _newsSourceFeed;
  }

  /// Returns `true` if there an existing feed.
  static bool hasFeed() {
    return _newsSourceFeed != null;
  }

  /// Clears the existing feed.
  static void clearFeed() {
    _newsSourceFeed = null;
  }

  /// Returns `true` if there is a news source with the given id.
  static bool hasNewsSource(String newsSourceId) {
    return _newsSourceStore.hasItem(newsSourceId);
  }

  /// Clears the existing store.
  static void clearStore() {
    _newsSourceStore.clear();
  }

  /// Returns the news source with the given id.
  static NewsSource getNewsSource(String newsSourceId) {
    return _newsSourceStore.getItem(newsSourceId);
  }

  /// Updates the existing news source or creates a new one.
  static NewsSource updateOrAddNewsSource(NewsSource newsSource) {
    return _newsSourceStore.updateOrAddItem(newsSource);
  }

  /// Returns the existing or a new News Source.
  ///
  /// Checks if the news source exists,
  /// if it exist, returns the existing news source
  /// if not gets the news source form the database and returns it.
  static Future<NewsSource> getOrFetchNewsSource(String newsSourceId) async {
    if (hasNewsSource(newsSourceId)) return getNewsSource(newsSourceId);

    return await updateAndGetNewsSource(newsSourceId);
  }

  /// Fetches the news source with the given [newsSourceId] from the database.
  ///
  /// If the newly created news article already exists in the store, saves the photo
  /// and assigns the photo to the news version while the new photo is fetched online.
  /// By this the old photo can be used for display while the possibly new photo is fetched.
  static Future<NewsSource> updateAndGetNewsSource(String newsSourceId) async {
    var _user = UserService.getUser();

    var newsSourceDocumentFuture = firestore.getSource(newsSourceId);
    var newsSourceRatingDocumentFuture =
        realtime.getNewsSourceDocument(newsSourceId);
    var newsSourceAlreadyRatedFuture =
        firestore.getSourceRatingDocument(newsSourceId, _user.id);

    var futures = await Future.wait([
      newsSourceDocumentFuture,
      newsSourceRatingDocumentFuture,
      newsSourceAlreadyRatedFuture
    ]);
    var newsSourceDocument = futures[0];
    var newsSourceRatingDocument = futures[1];
    var newsSourceAlreadyRated = futures[2];

    Uint8List photoInBytes;
    if (NewsSourceService.hasNewsSource(newsSourceId)) {
      photoInBytes = NewsSourceService.getNewsSource(newsSourceId).photoInBytes;
    }

    var newsSource = NewsSource.fromDocument(newsSourceDocument);
    NewsSourceService.updateOrAddNewsSource(newsSource);
    newsSource.photoInBytes = photoInBytes;
    newsSource.updateRatingsFromDatabase(
        newsSourceRatingDocument, newsSourceAlreadyRated);

    return newsSource;
  }

  /// Fetches news sources from the database and returns them in a feed.
  ///
  /// The number of news sources that will be fetched is determined by [pageSize].
  /// The function will return at maximum [pageSize] number of news groups.
  /// If [pageSize] is -1, the entire collection will be returned.
  /// The [lastDocumentId] is optional and is used for pagination.
  /// If [lastDocumentId] is specified only documents after that document will be fetched.
  ///  When [lastDocumenId] is a non null value, the fetched documents
  /// will be added at the end of the existing feed.
  static Future<Feed<String>> updateAndGetNewsSourceFeed({
    @required int pageSize,
    String lastDocumentId,
  }) async {
    bool refreshWanted = false;

    var _user = UserService.getUser();

    // if there is no timestamp a refresh is wanted
    // if there is no feed a refresh is required
    if (lastDocumentId == null || !hasFeed()) {
      refreshWanted = true;
    }

    // get the right documents from the database
    QuerySnapshot newsSourceQuery;
    if (refreshWanted) {
      newsSourceQuery = await firestore.getSources(pageSize);
    } else {
      newsSourceQuery =
          await firestore.getSourcesAfterDocument(lastDocumentId, pageSize);
    }

    List<Future<DataSnapshot>> newsSourceRatingDocumentFutures = List();
    List<Future<bool>> newsSourceAlreadyRatedFutures = List();
    List<String> newsSourceIds = List();
    for (var i = 0; i < newsSourceQuery.documents.length; i++) {
      var newsSourceDocument = newsSourceQuery.documents[i];
      var newsSourceId = createAndAddNewsSource(newsSourceDocument);
      newsSourceIds.add(newsSourceId);

      var newsSourceRatingDocumentFuture =
          realtime.getNewsSourceDocument(newsSourceId);
      newsSourceRatingDocumentFutures.add(newsSourceRatingDocumentFuture);

      var newsSourceAlreadyRatedFuture =
          firestore.getSourceRatingDocument(newsSourceId, _user.id);
      newsSourceAlreadyRatedFutures.add(newsSourceAlreadyRatedFuture);
    }

    var futures = await Future.wait([
      Future.wait(newsSourceRatingDocumentFutures),
      Future.wait(newsSourceAlreadyRatedFutures)
    ]);

    var newsSourceRatingDocuments = futures[0];
    var newsSourceAlreadyRateds = futures[1];
    for (var i = 0; i < newsSourceQuery.documents.length; i++) {
      var newsSourceRatingDocument = newsSourceRatingDocuments[i];
      var newsSourceAlreadyRated = newsSourceAlreadyRateds[i];
      var newsSourceId = newsSourceIds[i];
      var newsSource = getNewsSource(newsSourceId);
      newsSource.updateRatingsFromDatabase(
        newsSourceRatingDocument,
        newsSourceAlreadyRated,
      );
    }

    // if there is no feed create one
    if (!hasFeed()) {
      _newsSourceFeed = Feed<String>();
    }

    // if refresh is wanted clear the feed
    if (refreshWanted) {
      _newsSourceFeed.clearItems();
    }

    // add the items to feed
    _newsSourceFeed.addAdditionalItems(newsSourceIds);

    return _newsSourceFeed;
  }

  /// Creates a news source from a document and adds the news article to the store.
  ///
  /// If the newly created news source already exists in the store, saves the photo
  /// and assigns the photo to the new version while the new photo is fetched online.
  /// By this the old photo can be used for display while the possibly new photo is fetched.
  static String createAndAddNewsSource(DocumentSnapshot newsSourceDoc) {
    Uint8List oldPhoto;
    if (NewsSourceService.hasNewsSource(newsSourceDoc.documentID)) {
      var oldNewsArticle =
          NewsSourceService.getNewsSource(newsSourceDoc.documentID);
      oldPhoto = oldNewsArticle.photoInBytes;
    }

    NewsSource newsSource = NewsSource.fromDocument(newsSourceDoc);
    newsSource.photoInBytes = oldPhoto;

    NewsSourceService.updateOrAddNewsSource(newsSource);
    getNewsSourceImage(newsSource);
    return newsSource.id;
  }

  /// If there is a photo url and no cached photo, fetches the photo online asynchronously.
  static void getNewsSourceImage(NewsSource newsSource) async {
    // there is no imageUrl
    if (newsSource.photoUrl == null) return;

    // There is a cached image
    if (newsSource.photoInBytes != null) return;

    try {
      // There is an imageUrl but no cached image
      var response = await get(newsSource.photoUrl);
      var photoInBytes = response.bodyBytes;
      newsSource.photoInBytes = photoInBytes;
    } catch (e) {}

    return;
  }

  /// Opens the news website url given the news article id.
  static goToSourceWebsite(String newsSourceId) async {
    var newsArticle = getNewsSource(newsSourceId);
    var url = newsArticle.websiteLink;
    return await utils.goToUrl(url);
  }

  /// Opens the tweet url given the news article id.
  static goToSourceTwitter(String newsSourceId) async {
    var newsArticle = getNewsSource(newsSourceId);
    var url = newsArticle.twitterLink;
    return await utils.goToUrl(url);
  }

  static rateNewsSource(String newsSourceId, Rating rating) {
    var userId = UserService.getUser().id;
    var boolRating = false;
    if (rating == Rating.Bad) boolRating = false;
    if (rating == Rating.Good) boolRating = true;
    // realtime.rateSource(newsSourceId, userId, boolRating);
    firestore.rateSource(newsSourceId, userId, boolRating);
  }
}

enum Rating { Good, Bad }
