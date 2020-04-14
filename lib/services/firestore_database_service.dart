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
      String clusterID, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('tweets')
        .where('cluster_id', isEqualTo: clusterID)
        .orderBy("time", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getNewsInClusterAfterDocument(
      String clusterID, DocumentSnapshot document, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('tweets')
        .where('cluster_id', isEqualTo: clusterID)
        .orderBy("date", descending: true)
        .startAfter([document])
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<DocumentSnapshot> getUser(String userID) async {
    DocumentSnapshot userSnapshot =
        await db.collection('users').document(userID).get();
    return userSnapshot;
  }

  static Future<DocumentSnapshot> getCluster(String clusterID) async {
    DocumentSnapshot userSnapshot =
        await db.collection('clusters').document(clusterID).get();
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
  // onların içindeki ID ler ile gerekli document listini döndürücem
  // Kısa sürede yazılmazsa hatırlatın

  static Future<QuerySnapshot> getFollowedClusters(
      String userID, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('userfollowscluster')
        .where('user_id', isEqualTo: userID)
        .orderBy("date", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getFollowedClustersAfterDocument(
      String userID, Timestamp lastTimestamp, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('userfollowscluster')
        .where('user_id', isEqualTo: userID)
        .orderBy("date", descending: true)
        .startAfter([lastTimestamp])
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getUserFollowsClusters(
      String clusterID, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('userfollowscluster')
        .where('cluster_id', isEqualTo: clusterID)
        .orderBy("date", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<QuerySnapshot> getUserFollowsClustersAfterDocument(
      String clusterID, DocumentSnapshot document, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('userfollowscluster')
        .where('cluster_id', isEqualTo: clusterID)
        .orderBy("date", descending: true)
        .startAfter([document])
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot;
  }

  static Future<int> getNumberOfUsersFollowingCluster(
      String clusterID, int pageLimit) async {
    QuerySnapshot querySnapshot = await db
        .collection('userfollowscluster')
        .where('cluster_id', isEqualTo: clusterID)
        .orderBy("date", descending: true)
        .limit(pageLimit)
        .getDocuments();

    return querySnapshot.documents.length;
  }
}
