import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newspector_flutter/models/category.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'package:newspector_flutter/services/user_service.dart';
import 'firestore_service.dart';

/// Fetches the news group given the document from the database.
Future<DocumentSnapshot> getNewsGroup(String newsGroupId) async {
  DocumentSnapshot userSnapshot =
      await db.collection('news_groups').document(newsGroupId).get();
  return userSnapshot;
}

/// Fetches the specified number of news groups from the database.
Future<List<DocumentSnapshot>> getNewsGroups(
  int pageLimit,
  FeedType newsFeedType,
  NewsCategory newsCategory, {
  String lastDocumentId,
}) async {
  List<DocumentSnapshot> tempGroupDocuments;

  if (newsFeedType == FeedType.Following) {
    var userId = (await UserService.getOrFetchUser()).id;

    Query query = db
        .collection('user_follows_news_group')
        .where('user_id', isEqualTo: userId)
        .orderBy("date", descending: true);

    if (lastDocumentId != null) {
      var lastDocuments = await db
          .collection('user_follows_news_group')
          .where('news_group_id', isEqualTo: lastDocumentId)
          .getDocuments();
      var lastDocument = lastDocuments.documents[0];

      query = query.startAfterDocument(lastDocument);
    }

    query = query.limit(pageLimit);
    var querySnapshot = await query.getDocuments();

    // From the user follows news group documents,
    // get the news group ids and start fetching the news groups in parallel
    List<Future<DocumentSnapshot>> newsGroupDocumentFutures = List();
    for (var userFollowsNewsGroupDoc in querySnapshot.documents) {
      var newsGroupId = userFollowsNewsGroupDoc.data['news_group_id'];
      var newsGroupDocumentFuture = getNewsGroup(newsGroupId);
      newsGroupDocumentFutures.add(newsGroupDocumentFuture);
    }

    tempGroupDocuments = await Future.wait(newsGroupDocumentFutures);
  } else if (newsFeedType == FeedType.Home) {
    Query query =
        db.collection('news_groups').orderBy("updated_at", descending: true);

    if (lastDocumentId != null) {
      var lastDocument =
          await db.collection('news_groups').document(lastDocumentId).get();
      query = query.startAfterDocument(lastDocument);
    }

    query = query.limit(pageLimit);
    var querySnapshot = await query.getDocuments();

    tempGroupDocuments = querySnapshot.documents;
  } else if (newsFeedType == FeedType.Trending) {
    Query query = db
        .collection('news_groups')
        .orderBy("count", descending: true)
        .where('is_active', isEqualTo: true);

    if (lastDocumentId != null) {
      var lastDocument =
          await db.collection('news_groups').document(lastDocumentId).get();
      query = query.startAfterDocument(lastDocument);
    }

    query = query.limit(pageLimit);
    var querySnapshot = await query.getDocuments();

    tempGroupDocuments = querySnapshot.documents;
  } else if (newsFeedType == FeedType.Category) {
    Query query = db.collection('news_groups');

    if (newsCategory == NewsCategory.general) {
      query = query.where('category', whereIn: ['-', newsCategory.name]);
    } else {
      query = query.where('category', isEqualTo: newsCategory.name);
    }
    query = query.orderBy("updated_at", descending: true);

    if (lastDocumentId != null) {
      var lastDocument =
          await db.collection('news_groups').document(lastDocumentId).get();
      query = query.startAfterDocument(lastDocument);
    }

    query = query.limit(pageLimit);
    var querySnapshot = await query.getDocuments();

    tempGroupDocuments = querySnapshot.documents;
  }
  List<DocumentSnapshot> newsGroupDocuments = List();
  for (var document in tempGroupDocuments) {
    if (!document.exists) continue;
    newsGroupDocuments.add(document);
  }

  return newsGroupDocuments;
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
