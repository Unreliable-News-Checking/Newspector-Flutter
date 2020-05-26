import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newspector_flutter/pages/news_article_page.dart';
import 'firestore_service.dart';

/// Fetches the news group given the document from the database.
Future<DocumentSnapshot> getNewsArticle(String newsGroupId) async {
  DocumentSnapshot userSnapshot =
      await db.collection('tweets').document(newsGroupId).get();
  return userSnapshot;
}

void reportNews(
  String newsSourceId,
  String userId,
  String newsArticleId,
  FeedbackOption feedback,
) async {
  await db.collection("user_reports_tweet").add({
    'date': DateTime.now(),
    'news_source_id': newsSourceId,
    'news_article_id': newsArticleId,
    'user_id': userId,
    'feedback': feedback.toString(),
  });
}
