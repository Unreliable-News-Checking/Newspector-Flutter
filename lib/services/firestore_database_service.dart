import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newspector_flutter/models/user.dart';

class FirestoreService {
  static Firestore db = Firestore.instance;

  static Future<DocumentSnapshot> getSource(String newsSourceId) async {
    var documentSnapshot =
        await db.collection('accounts').document(newsSourceId).get();

    return documentSnapshot;
  }

  static Future<QuerySnapshot> getSources(int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('accounts')
        .orderBy("name", descending: false)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getSourcesAfterDocument(
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

  static Future<QuerySnapshot> getNewsGroups(int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('news_groups')
        .orderBy("date", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getNewsGroupsAfterDocument(
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

  static Future<QuerySnapshot> getNewsInNewsGroup(
      String newsGroupId, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('tweets')
        .where('news_group_id', isEqualTo: newsGroupId)
        .orderBy("date", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getNewsInNewsGroupAfterDocument(
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

  static Future<DocumentSnapshot> getUserWithFirebaseId(
      String userFirebaseId) async {
    QuerySnapshot querySnapshot = await db
        .collection('users')
        .where('uid', isEqualTo: userFirebaseId)
        .getDocuments();

    if (querySnapshot.documents.length == 0) {
      return null;
    }

    return querySnapshot.documents[0];
  }

  static Future<DocumentSnapshot> getUser(String userId) async {
    DocumentSnapshot userSnapshot =
        await db.collection('users').document(userId).get();
    return userSnapshot;
  }

  static Future<User> createUser(String firebaseUserId) async {
    Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = firebaseUserId;

    DocumentReference userToBeAddedReferebce =
        Firestore.instance.collection('users').document();

    await db
        .collection('users')
        .document(userToBeAddedReferebce.documentID)
        .setData(data);
    User user = User.fromMap(data, userToBeAddedReferebce.documentID);
    return user;
  }

  static Future<String> checkUserFollowsNewsGroupDocument(
      String userId, String newsGroupId) async {
    var documentsToBeDeleted = await db
        .collection('user_follows_news_group')
        .where('user_id', isEqualTo: userId)
        .where('news_group_id', isEqualTo: newsGroupId)
        .getDocuments();

    if (documentsToBeDeleted.documents.length <= 0) return null;

    var documentToBeDeletedId = documentsToBeDeleted.documents[0].documentID;

    return documentToBeDeletedId;
  }

  static Future<void> createUserFollowsNewsGroupDocument(
      String userId, String newsGroupId) async {
    var documentToBeDeletedId =
        await checkUserFollowsNewsGroupDocument(userId, newsGroupId);

    if (documentToBeDeletedId != null) return;

    Map<String, dynamic> data = Map<String, dynamic>();
    data['user_id'] = userId;
    data['news_group_id'] = newsGroupId;
    data['date'] = Timestamp.now();

    db.collection('user_follows_news_group').add(data);
  }

  static Future<void> deleteUserFollowsNewsGroupDocument(
      String userId, String newsGroupId) async {
    var documentToBeDeletedId =
        await checkUserFollowsNewsGroupDocument(userId, newsGroupId);

    if (documentToBeDeletedId == null) return;

    db
        .collection('user_follows_news_group')
        .document(documentToBeDeletedId)
        .delete();
  }

  static Future<DocumentSnapshot> getNewsGroup(String newsGroupId) async {
    DocumentSnapshot userSnapshot =
        await db.collection('news_groups').document(newsGroupId).get();
    return userSnapshot;
  }

  static Future<QuerySnapshot> getUsers(int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('users')
        .orderBy("name", descending: false)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getUsersAfterDocument(
      DocumentSnapshot document, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('users')
        .orderBy("name", descending: false)
        .startAfter([document])
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> gerUserFollowsNewsGroups(
      String userId, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('user_follows_news_group')
        .where('user_id', isEqualTo: userId)
        .orderBy("date", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getUserFollowsNewsGroupAfterDocument(
      String userId, String lastDocumentId, int pageLimit) async {
    var lastDocument =
        await db.collection('news_groups').document(lastDocumentId).get();

    QuerySnapshot querySnapshot = await db
        .collection('user_follows_news_group')
        .where('user_id', isEqualTo: userId)
        .orderBy("date", descending: true)
        .startAfterDocument(lastDocument)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getUserFollowsNewsGroups(
      String newsGroupId, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('user_follows_news_group')
        .where('news_group_id', isEqualTo: newsGroupId)
        .orderBy("date", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }
}
