import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/pages/news_article_page.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/services/user_service.dart';
import 'package:newspector_flutter/stores/store.dart';
import 'package:http/http.dart';
import 'firestore/firestore_service.dart' as firestore;

class NewsArticleService {
  static Store<NewsArticle> newsArticleStore = Store<NewsArticle>();

  /// Returns the news article with the given id.
  static NewsArticle getNewsArticle(String newsArticleId) {
    return newsArticleStore.getItem(newsArticleId);
  }

  /// Checks if a news article exists with the given id.
  static bool hasNewsArticle(String newsArticleId) {
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

  // /// Opens the news website url given the news article id.
  // static Future<bool> goToWebsite(String newsArticleId) async {
  //   var newsArticle = getNewsArticle(newsArticleId);
  //   var url = newsArticle.websiteLink;
  //   return await utils.goToUrl(url);
  // }

  /// Fetches the news source with the given [newsArticleId] from the database.
  ///
  /// If the newly created news article already exists in the store, saves the photo
  /// and assigns the photo to the news version while the new photo is fetched online.
  /// By this the old photo can be used for display while the possibly new photo is fetched.
  static Future<NewsArticle> updateAndGetNewsArticle(
      String newsArticleId) async {
    var newsArticleDocument = await firestore.getNewsArticle(newsArticleId);

    createAndAddNewsArticle(newsArticleDocument);
    return getNewsArticle(newsArticleId);

    // Uint8List photoInBytes;
    // if (NewsArticleService.hasNewsArticle(newsArticleId)) {
    //   photoInBytes =
    //       NewsArticleService.getNewsArticle(newsArticleId).photoInBytes;
    // }

    // var newsArticle = NewsArticle.fromDocument(newsArticleDocument);
    // NewsArticleService._updateOrAddNewsArticle(newsArticle);
    // newsArticle.photoInBytes = photoInBytes;

    // return newsArticle;
  }

  /// Creates a news article from a document and adds the news article to the store.
  ///
  /// If the newly created news article already exists in the store, saves the photo
  /// and assigns the photo to the news version while the new photo is fetched online.
  /// By this the old photo can be used for display while the possibly new photo is fetched.
  static Future<String> createAndAddNewsArticle(
    DocumentSnapshot newsArticleDoc,
  ) async {
    Uint8List oldPhoto;
    if (NewsArticleService.hasNewsArticle(newsArticleDoc.documentID)) {
      var oldNewsArticle =
          NewsArticleService.getNewsArticle(newsArticleDoc.documentID);
      oldPhoto = oldNewsArticle.photoInBytes;
    }

    NewsArticle newsArticle = NewsArticle.fromDocument(newsArticleDoc);
    newsArticle.photoInBytes = oldPhoto;

    NewsArticleService._updateOrAddNewsArticle(newsArticle);
    getNewsArticleImage(newsArticle);

    var newsSourceId = newsArticle.newsSourceId;
    await NewsSourceService.getOrFetchNewsSource(newsSourceId);

    return newsArticle.id;
  }

  /// If there is a photo url and no cached photo, fetches the photo online asynchronously.
  static void getNewsArticleImage(NewsArticle newsArticle) async {
    // there is no imageUrl
    if (newsArticle.photoUrl == null) return;

    // There is a cached image
    if (newsArticle.photoInBytes != null) return;

    try {
      // There is an imageUrl but no cached image
      var response = await get(newsArticle.photoUrl);
      var photoInBytes = response.bodyBytes;
      newsArticle.photoInBytes = photoInBytes;
    } catch (e) {}

    return;
  }

  static void giveFeedbackToNewsArticle(
    NewsArticle newsArticle,
    FeedbackOption feedbackOption,
  ) {
    firestore.reportNews(
      newsArticle.newsSourceId,
      UserService.getUser().id,
      newsArticle.id,
      feedbackOption,
    );
  }
}
