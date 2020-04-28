import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/stores/news_article_store.dart';
import 'package:http/http.dart';
import 'package:newspector_flutter/utilities.dart' as utils;

class NewsArticleService {
  static NewsArticleStore newsArticleStore = NewsArticleStore();

  static NewsArticle getNewsArticle(String newsArticleId) {
    return newsArticleStore.getNewsArticle(newsArticleId);
  }

  static bool hasNewsArticle(String newsArticleId) {
    return newsArticleStore.hasNewsArticle(newsArticleId);
  }

  static NewsArticle updateOrAddNewsArticle(NewsArticle newsArticle) {
    return newsArticleStore.updateOrAddNewsArticle(newsArticle);
  }

  static void clearStore() {
    newsArticleStore = NewsArticleStore();
  }

  static Future<bool> goToTweet(String newsArticleId) async {
    var newsArticle = getNewsArticle(newsArticleId);
    var url = newsArticle.tweetLink;
    return await utils.goToUrl(url);
  }

  static Future<bool> goToWebsite(String newsArticleId) async {
    var newsArticle = getNewsArticle(newsArticleId);
    var url = newsArticle.websiteLink;
    return await utils.goToUrl(url);
  }

  static String createAndAddNewsArticle(DocumentSnapshot newsArticleDoc) {
    Uint8List oldPhoto;
    if (NewsArticleService.hasNewsArticle(newsArticleDoc.documentID)) {
      var oldNewsArticle =
          NewsArticleService.getNewsArticle(newsArticleDoc.documentID);
      oldPhoto = oldNewsArticle.photoInBytes;
    }

    NewsArticle newsArticle = NewsArticle.fromDocument(newsArticleDoc);
    newsArticle.photoInBytes = oldPhoto;

    NewsArticleService.updateOrAddNewsArticle(newsArticle);
    getNewsArticleImage(newsArticle);
    return newsArticle.id;
  }

  static void getNewsArticleImage(NewsArticle newsArticle) async {
    // there is no imageUrl
    if (newsArticle.photoUrl == null) {
      return;
    }

    // There is a cached image
    if (newsArticle.photoInBytes != null) {
      return;
    }

    // There is an imageUrl but no cached image
    var response = await get(newsArticle.photoUrl);
    var photoInBytes = response.bodyBytes;
    newsArticle.photoInBytes = photoInBytes;
    return;
  }
}
