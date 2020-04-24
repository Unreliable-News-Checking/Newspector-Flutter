import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/stores/news_article_store.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsArticleService {
  //firebase stuff here too
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
    var canLaunchUrl = await canLaunch(url);

    if (!canLaunchUrl) return false;

    await launch(url);
    return true;
  }

  static Future<bool> goToWebsite(String newsArticleId) async {
    var newsArticle = getNewsArticle(newsArticleId);
    var url = newsArticle.websiteLink;
    var canLaunchUrl = await canLaunch(url);

    if (!canLaunchUrl) return false;

    await launch(url);
    return true;
  }
}
