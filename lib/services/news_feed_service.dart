import 'package:flutter/cupertino.dart';
import 'package:newspector_flutter/mock_database.dart';
import 'package:newspector_flutter/models/news_feed.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/services/news_group_service.dart';

class NewsFeedService {
  //firebase stuff here too
  static NewsFeed newsFeed;

  static NewsFeed getNewsFeed() {
    return newsFeed;
  }

  static bool hasFeed() {
    return newsFeed != null;
  }

  static Future<NewsFeed> updateAndGetNewsFeed({
    @required int pageSize,
    @required var lastTimeStamp,
  }) async {
    NewsFeed _feed;
    bool fresh = false;

    //if there is no prior timestamp that means this is a fresh feed
    if (lastTimeStamp == "") {
      fresh = true;
      lastTimeStamp = DateTime.now();
    }

    // if there is no prior feed
    if (!hasFeed()) {
      fresh = true;
    }

    // if there is no feed get a new one,
    // else use the old one
    if (fresh) {
      _feed = NewsFeed();
    } else {
      _feed = newsFeed;
    }

    //Get the newsArticles and Groups Documents
    var _newsGroups = await MockDatabase.getNewsGroups();

    //Add the newsArticles and newsGroups to their stores
    for (var newsGroup in _newsGroups) {
      for (var newsArticle in newsGroup.newsArticles) {
        NewsArticleService.updateOrAddNewsArticle(newsArticle);
      }
      NewsGroupService.updateOrAddNewsGroup(newsGroup);
    }

    _feed.newsGroups = _newsGroups;
    newsFeed = _feed;
    return _feed;
  }
}
