import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

/// Fetches a news source from the database given the news source id.
Future<DocumentSnapshot> getSource(String newsSourceId) async {
  var documentSnapshot =
      await db.collection('accounts').document(newsSourceId).get();

  return documentSnapshot;
}

/// Fetches specified number of news sources from the database.
Future<QuerySnapshot> getSources(int pageLimit) async {
  QuerySnapshot querySnapshot = await db
      .collection('accounts')
      .orderBy("name", descending: false)
      .limit(pageLimit)
      .getDocuments();

  return querySnapshot;
}

/// Fetches specified number of news sources after the specified document from the database.
Future<QuerySnapshot> getSourcesAfterDocument(
    String lastDocumentId, int pageLimit) async {
  var lastDocument =
      await db.collection('accounts').document(lastDocumentId).get();

  QuerySnapshot querySnapshot = await db
      .collection('accounts')
      .orderBy("name")
      .startAfterDocument(lastDocument)
      .limit(pageLimit)
      .getDocuments();

  return querySnapshot;
}
