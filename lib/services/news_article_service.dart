import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/stores/news_article_store.dart';
import 'package:newspector_flutter/utilities.dart' as utils;

class NewsArticleService {
  static NewsArticleStore newsArticleStore = NewsArticleStore();

  static NewsArticle getNewsArticle(String id) {
    return newsArticleStore.getNewsArticle(id);
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

  static String createAndAddNewsArticle(newsArticleDoc) {
    NewsArticle newsArticle = NewsArticle.fromDocument(newsArticleDoc);
    NewsArticleService.updateOrAddNewsArticle(newsArticle);
    return newsArticle.id;
  }
}
