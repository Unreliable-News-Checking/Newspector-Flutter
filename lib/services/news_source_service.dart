import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/stores/news_source_store.dart';

import 'firestore_database_service.dart';

class NewsSourceService {
  static NewsSourceStore newsSourceStore = NewsSourceStore();
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

    print("fetched document count: ${newsSourceQuery.documents.length}");

    List<String> newsSourceIds = new List();
    for (var i = 0; i < newsSourceQuery.documents.length; i++) {
      var newsSourceDocument = newsSourceQuery.documents[i];
      var newsSourceId = newsSourceDocument.documentID;

      Uint8List photoInBytes =
          NewsSourceService.getNewsSource(newsSourceId).photoInBytes;

      var newsSource = NewsSource.fromDocument(newsSourceDocument);
      NewsSourceService.updateOrAddNewsSource(newsSource);
      newsSourceIds.add(newsSource.id);
      newsSource.photoInBytes = photoInBytes;
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

  //firebase stuff here too

  static NewsSource getNewsSource(String newsSourceId) {
    return newsSourceStore.getNewsSource(newsSourceId);
  }

  static NewsSource updateOrAddNewsSource(NewsSource newsArticle) {
    return newsSourceStore.updateOrAddNewsSource(newsArticle);
  }

  static void clearStore() {
    newsSourceStore = NewsSourceStore();
  }
}
