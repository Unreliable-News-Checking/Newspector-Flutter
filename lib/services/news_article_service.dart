import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/stores/store.dart';
import 'package:http/http.dart';
import 'package:newspector_flutter/utilities.dart' as utils;

class NewsArticleService {
  static Store<NewsArticle> newsArticleStore = Store<NewsArticle>();

  /// Returns the news article with the given id.
  static NewsArticle getNewsArticle(String newsArticleId) {
    return newsArticleStore.getItem(newsArticleId);
  }

  /// Checks if a news article exists with the given id.
  static bool _hasNewsArticle(String newsArticleId) {
    return newsArticleStore.hasItem(newsArticleId);
  }

  /// Updates the existing news article or adds it as new to the store.
  static NewsArticle _updateOrAddNewsArticle(NewsArticle newsArticle) {
    return newsArticleStore.updateOrAddItem(newsArticle);
  }

  /// Clears the store that holds news articles.
  static void clearStore() {
    newsArticleStore.clear();
  }

  /// Opens the tweet url given the news article id.
  static Future<bool> goToTweet(String newsArticleId) async {
    var newsArticle = getNewsArticle(newsArticleId);
    var url = newsArticle.tweetLink;
    return await utils.goToUrl(url);
  }

  /// Opens the news website url given the news article id.
  static Future<bool> goToWebsite(String newsArticleId) async {
    var newsArticle = getNewsArticle(newsArticleId);
    var url = newsArticle.websiteLink;
    return await utils.goToUrl(url);
  }

  /// Creates a news article from a document and adds the news article to the store.
  /// 
  /// If the newly created news article already exists in the store, saves the photo
  /// and assigns the photo to the news version while the new photo is fetched online.
  /// By this the old photo can be used for display while the possibly new photo is fetched.
  static String createAndAddNewsArticle(DocumentSnapshot newsArticleDoc) {
    Uint8List oldPhoto;
    if (NewsArticleService._hasNewsArticle(newsArticleDoc.documentID)) {
      var oldNewsArticle =
          NewsArticleService.getNewsArticle(newsArticleDoc.documentID);
      oldPhoto = oldNewsArticle.photoInBytes;
    }

    NewsArticle newsArticle = NewsArticle.fromDocument(newsArticleDoc);
    newsArticle.photoInBytes = oldPhoto;

    NewsArticleService._updateOrAddNewsArticle(newsArticle);
    getNewsArticleImage(newsArticle);
    return newsArticle.id;
  }

  /// If there is a photo url and no cached photo, fetches the photo online asynchronously.
  static void getNewsArticleImage(NewsArticle newsArticle) async {
    // there is no imageUrl
    if (newsArticle.photoUrl == null) return;

    // There is a cached image
    if (newsArticle.photoInBytes != null) return;

    // There is an imageUrl but no cached image
    var response = await get(newsArticle.photoUrl);
    var photoInBytes = response.bodyBytes;
    newsArticle.photoInBytes = photoInBytes;
    return;
  }
}
