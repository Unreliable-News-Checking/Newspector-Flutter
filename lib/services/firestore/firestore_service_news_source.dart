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
  var query = db.collection('accounts').orderBy("name", descending: false);

  if (pageLimit != -1) query = query.limit(pageLimit);

  QuerySnapshot querySnapshot = await query.getDocuments();

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

void rateSource(
  String newsSourceId,
  String userId,
  bool rating,
) {
  Map<String, dynamic> data = Map<String, dynamic>();
  data['user_id'] = userId;
  data['news_source_id'] = newsSourceId;
  data['date'] = Timestamp.now();
  data['vote'] = rating;

  db.collection('user_rates_news_source').add(data);
}

Future<bool> getSourceRatingDocument(
  String newsSourceId,
  String userId,
) async {
  var date = DateTime.now();
  date = date.subtract(Duration(days: 1));
  var timestamp = Timestamp.fromDate(date);

  var query = await db
      .collection('user_rates_news_source')
      .where('user_id', isEqualTo: userId)
      .where('news_source_id', isEqualTo: newsSourceId)
      .where('date', isGreaterThan: timestamp)
      .getDocuments();

  var alreadyRated = query.documents.length > 0;
  return alreadyRated;
}
