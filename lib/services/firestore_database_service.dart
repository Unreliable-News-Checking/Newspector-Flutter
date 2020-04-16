import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static Firestore db = Firestore.instance;

  static Future<QuerySnapshot> getSources(int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('accounts')
        .orderBy("date", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getSourcesAfterDocument(
      DocumentSnapshot document, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('accounts')
        .orderBy("date", descending: true)
        .startAfter([document])
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
      Timestamp lastTimestamp, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('clusters')
        .orderBy("date", descending: true)
        .startAfter([lastTimestamp])
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
      String clusterId, DocumentSnapshot document, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('tweets')
        .where('cluster_id', isEqualTo: clusterId)
        .orderBy("date", descending: true)
        .startAfter([document])
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
      String userId, Timestamp lastTimestamp, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('userfollowscluster')
        .where('user_id', isEqualTo: userId)
        .orderBy("date", descending: true)
        .startAfter([lastTimestamp])
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
