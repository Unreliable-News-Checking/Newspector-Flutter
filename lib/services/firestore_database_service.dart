import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newspector_flutter/models/user.dart';

class FirestoreService {
  static Firestore db = Firestore.instance;

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

  static Future<QuerySnapshot> getClusters(int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('clusters')
        .orderBy("date", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getClustersAfterDocument(
      String lastDocumentId, int pageLimit) async {
    var lastDocument =
        await db.collection('clusters').document(lastDocumentId).get();

    QuerySnapshot querySnapshot = await db
        .collection('clusters')
        .orderBy("date", descending: true)
        .startAfterDocument(lastDocument)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getNewsInCluster(
      String clusterId, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('tweets')
        .where('cluster_id', isEqualTo: clusterId)
        .orderBy("time", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getNewsInClusterAfterDocument(
      String clusterId, String lastDocumentId, int pageLimit) async {
    var lastDocument =
        await db.collection('tweets').document(lastDocumentId).get();

    QuerySnapshot querySnapshot = await db
        .collection('tweets')
        .where('cluster_id', isEqualTo: clusterId)
        .orderBy("time", descending: true)
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

    DocumentReference postToBeAddedReference =
        Firestore.instance.collection('users').document();

    db
        .collection('users')
        .document(postToBeAddedReference.documentID)
        .setData(data);
    User user = User.fromMap(data, postToBeAddedReference.documentID);
    return user;
  }

  static Future<String> checkUserFollowsClusterDocument(
      String userId, String newsGroupId) async {
    var documentsToBeDeleted = await db
        .collection('userfollowscluster')
        .where('user_id', isEqualTo: userId)
        .where('cluster_id', isEqualTo: newsGroupId)
        .getDocuments();

    if (documentsToBeDeleted.documents.length <= 0) return null;

    var documentToBeDeletedId = documentsToBeDeleted.documents[0].documentID;

    return documentToBeDeletedId;
  }

  static Future<void> createUserFollowsClusterDocument(
      String userId, String newsGroupId) async {
    var documentToBeDeletedId =
        await checkUserFollowsClusterDocument(userId, newsGroupId);

    if (documentToBeDeletedId != null) return;

    Map<String, dynamic> data = Map<String, dynamic>();
    data['user_id'] = userId;
    data['cluster_id'] = newsGroupId;
    data['date'] = Timestamp.now();

    db.collection('userfollowscluster').add(data);
  }

  static Future<void> deleteUserFollowsClusterDocument(
      String userId, String newsGroupId) async {
    var documentToBeDeletedId =
        await checkUserFollowsClusterDocument(userId, newsGroupId);

    if (documentToBeDeletedId == null) return;

    db
        .collection('userfollowscluster')
        .document(documentToBeDeletedId)
        .delete();
  }

  static Future<DocumentSnapshot> getCluster(String clusterId) async {
    DocumentSnapshot userSnapshot =
        await db.collection('clusters').document(clusterId).get();
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

  // Burdan aşağıdakiler iki aşamalı olucak (UserFollowsCluster) documentları dönüyor,
  // onların içindeki Id ler ile gerekli document listini döndürücem
  // Kısa sürede yazılmazsa hatırlatın

  static Future<QuerySnapshot> gerUserFollowsClusters(
      String userId, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('userfollowscluster')
        .where('user_id', isEqualTo: userId)
        .orderBy("date", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getUserFollowsClusterAfterTimestamp(
      String userId, String lastDocumentId, int pageLimit) async {
    var lastDocument =
        await db.collection('clusters').document(lastDocumentId).get();

    QuerySnapshot querySnapshot = await db
        .collection('userfollowscluster')
        .where('user_id', isEqualTo: userId)
        .orderBy("date", descending: true)
        .startAfterDocument(lastDocument)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getUserFollowsClusters(
      String clusterId, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('userfollowscluster')
        .where('cluster_id', isEqualTo: clusterId)
        .orderBy("date", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getUserFollowsClustersAfterDocument(
      String clusterId, DocumentSnapshot document, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('userfollowscluster')
        .where('cluster_id', isEqualTo: clusterId)
        .orderBy("date", descending: true)
        .startAfter([document])
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<int> getNumberOfUsersFollowingCluster(
      String clusterId, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('userfollowscluster')
        .where('cluster_id', isEqualTo: clusterId)
        .orderBy("date", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot.documents.length;
  }
}
