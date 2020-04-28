import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/stores/news_source_store.dart';
import 'package:http/http.dart';
import 'firestore_database_service.dart';
import 'package:newspector_flutter/utilities.dart' as utils;

class NewsSourceService {
  static NewsSourceStore _newsSourceStore = NewsSourceStore();
  static Feed<String> _newsSourceFeed;

  static Feed<String> getNewsSourceFeed() {
    return _newsSourceFeed;
  }

  static bool hasFeed() {
    return _newsSourceFeed != null;
  }

  static void clearFeed() {
    _newsSourceFeed = null;
  }

  static bool hasNewsSource(String newsSourceId) {
    return _newsSourceStore.hasNewsSource(newsSourceId);
  }

  static void clearStore() {
    _newsSourceStore = NewsSourceStore();
  }

  static NewsSource getNewsSource(String newsSourceId) {
    return _newsSourceStore.getNewsSource(newsSourceId);
  }

  static NewsSource updateOrAddNewsSource(NewsSource newsSource) {
    return _newsSourceStore.updateOrAddNewsSource(newsSource);
  }

  static Future<NewsSource> updateAndGetNewsSource(String newsSourceId) async {
    var newsSourceDocument = await FirestoreService.getSource(newsSourceId);

    Uint8List photoInBytes;
    if (NewsSourceService.hasNewsSource(newsSourceId)) {
      photoInBytes = NewsSourceService.getNewsSource(newsSourceId).photoInBytes;
    }

    var newsSource = NewsSource.fromDocument(newsSourceDocument);
    NewsSourceService.updateOrAddNewsSource(newsSource);
    newsSource.photoInBytes = photoInBytes;

    return newsSource;
  }

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
      newsSourceQuery = await FirestoreService.getSources(pageSize);
    } else {
      newsSourceQuery = await FirestoreService.getSourcesAfterDocument(
          lastDocumentId, pageSize);
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

  static goToSourceWebsite(String newsSourceId) async {
    var newsArticle = getNewsSource(newsSourceId);
    var url = newsArticle.websiteLink;
    return await utils.goToUrl(url);
  }

  static goToSourceTwitter(String newsSourceId) async {
    var newsArticle = getNewsSource(newsSourceId);
    var url = newsArticle.twitterLink;
    return await utils.goToUrl(url);
  }
}
