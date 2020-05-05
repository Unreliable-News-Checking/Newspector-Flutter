import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:http/http.dart';
import 'package:newspector_flutter/stores/store.dart';
import 'firestore/firestore_service.dart' as firestore;
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

  /// Fetches the news source with the given [newsSourceId] from the database.
  ///
  /// If the newly created news article already exists in the store, saves the photo
  /// and assigns the photo to the news version while the new photo is fetched online.
  /// By this the old photo can be used for display while the possibly new photo is fetched.
  static Future<NewsSource> updateAndGetNewsSource(String newsSourceId) async {
    var newsSourceDocument = await firestore.getSource(newsSourceId);

    Uint8List photoInBytes;
    if (NewsSourceService.hasNewsSource(newsSourceId)) {
      photoInBytes = NewsSourceService.getNewsSource(newsSourceId).photoInBytes;
    }

    var newsSource = NewsSource.fromDocument(newsSourceDocument);
    NewsSourceService.updateOrAddNewsSource(newsSource);
    newsSource.photoInBytes = photoInBytes;

    return newsSource;
  }

  /// Fetches news sources from the database and returns them in a feed.
  ///
  /// The number of news sources that will be fetched is determined by [pageSize].
  /// The function will return at maximum [pageSize] number of news groups. The [lastDocumentId]
  /// is optional and is used for pagination. If [lastDocumentId] is specified only documents
  /// after that document will be fetched. When [lastDocumenId] is a non null value, the fetched documents
  /// will be added at the end of the existing feed.
  static Future<Feed<String>> updateAndGetNewsSourceFeed({
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
    QuerySnapshot newsSourceQuery;
    if (refreshWanted) {
      newsSourceQuery = await firestore.getSources(pageSize);
    } else {
      newsSourceQuery =
          await firestore.getSourcesAfterDocument(lastDocumentId, pageSize);
    }

    List<String> newsSourceIds = new List();
    for (var i = 0; i < newsSourceQuery.documents.length; i++) {
      var newsSourceDocument = newsSourceQuery.documents[i];
      var newsSourceId = createAndAddNewsSource(newsSourceDocument);
      newsSourceIds.add(newsSourceId);
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

    // There is an imageUrl but no cached image
    var response = await get(newsSource.photoUrl);
    var photoInBytes = response.bodyBytes;
    newsSource.photoInBytes = photoInBytes;
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
}
