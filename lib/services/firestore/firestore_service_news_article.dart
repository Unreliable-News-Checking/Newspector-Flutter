import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

/// Fetches the news group given the document from the database.
Future<DocumentSnapshot> getNewsArticle(String newsGroupId) async {
  DocumentSnapshot userSnapshot =
      await db.collection('tweets').document(newsGroupId).get();
  return userSnapshot;
}
