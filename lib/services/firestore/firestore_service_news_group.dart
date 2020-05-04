import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

/// Fetches the news group given the document from the database.
Future<DocumentSnapshot> getNewsGroup(String newsGroupId) async {
  DocumentSnapshot userSnapshot =
      await db.collection('news_groups').document(newsGroupId).get();
  return userSnapshot;
}

/// Fetches the specified number of news groups from the database.
Future<QuerySnapshot> getNewsGroups(int pageLimit) async {
  QuerySnapshot querySnapshot = await db
      .collection('news_groups')
      .orderBy("date", descending: true)
      .limit(pageLimit)
      .getDocuments();

  return querySnapshot;
}

/// Fetches the specified number of news groups after a given document from the database.
Future<QuerySnapshot> getNewsGroupsAfterDocument(
    String lastDocumentId, int pageLimit) async {
  var lastDocument =
      await db.collection('news_groups').document(lastDocumentId).get();

  QuerySnapshot querySnapshot = await db
      .collection('news_groups')
      .orderBy("date", descending: true)
      .startAfterDocument(lastDocument)
      .limit(pageLimit)
      .getDocuments();

  return querySnapshot;
}

/// Fetches the specified number of news articles from a given news group
/// from the database.
Future<QuerySnapshot> getNewsArticlesInNewsGroup(
    String newsGroupId, int pageLimit) async {
  QuerySnapshot querySnapshot = await db
      .collection('tweets')
      .where('news_group_id', isEqualTo: newsGroupId)
      .orderBy("date", descending: true)
      .limit(pageLimit)
      .getDocuments();

  return querySnapshot;
}

/// Fetches the specified number of news articles after a given news article document
/// from a given news group from the database.
Future<QuerySnapshot> getNewsArticlesInNewsGroupAfterDocument(
    String newsGroupId, String lastDocumentId, int pageLimit) async {
  var lastDocument =
      await db.collection('tweets').document(lastDocumentId).get();

  QuerySnapshot querySnapshot = await db
      .collection('tweets')
      .where('news_group_id', isEqualTo: newsGroupId)
      .orderBy("date", descending: true)
      .startAfterDocument(lastDocument)
      .limit(pageLimit)
      .getDocuments();

  return querySnapshot;
}
