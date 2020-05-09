import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newspector_flutter/services/user_service.dart';
import 'firestore_service.dart';
import 'package:newspector_flutter/models/user.dart';

/// Fetches a user given the user's firebase id.
Future<DocumentSnapshot> getUserWithFirebaseId(String userFirebaseId) async {
  QuerySnapshot querySnapshot = await db
      .collection('users')
      .where('uid', isEqualTo: userFirebaseId)
      .getDocuments();

  if (querySnapshot.documents.length == 0) {
    return null;
  }

  return querySnapshot.documents[0];
}

/// Fetches a user given the user's document id.
Future<DocumentSnapshot> getUser(String userId) async {
  DocumentSnapshot userSnapshot =
      await db.collection('users').document(userId).get();
  return userSnapshot;
}

/// Creates a user with the user's firebase id.
Future<User> createUser(String firebaseUserId) async {
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

/// Checks whether a user follows a news group or not.
Future<String> checkUserFollowsNewsGroupDocument(
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

/// Creates a document in database that represent the user following the news group.
Future<void> createUserFollowsNewsGroupDocument(
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

/// Removes the document in database that represent the user following the news group.
Future<void> deleteUserFollowsNewsGroupDocument(
    String userId, String newsGroupId) async {
  var documentToBeDeletedId =
      await checkUserFollowsNewsGroupDocument(userId, newsGroupId);

  if (documentToBeDeletedId == null) return;

  db
      .collection('user_follows_news_group')
      .document(documentToBeDeletedId)
      .delete();
}

/// Fetched the user follows news group documents given the user document id.
Future<QuerySnapshot> getUserFollowsNewsGroups(
    String userId, int pageLimit) async {
  QuerySnapshot querySnapshot = await db
      .collection('user_follows_news_group')
      .where('user_id', isEqualTo: userId)
      .orderBy("date", descending: true)
      .limit(pageLimit)
      .getDocuments();

  return querySnapshot;
}

/// Fetched the user follows news group documents after a given document given the user document id.
Future<QuerySnapshot> getUserFollowsNewsGroupAfterDocument(
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

void reportNews(String documentID, String comment) async {
  await db
      .collection("reports")
      .add({'date': DateTime.now(), 'news_id': documentID, 'user_id': UserService.getUser().id, 'comment': comment});
}

void likeAccount(String documentID) async {
  await db
      .collection("likes")
      .add({'date': DateTime.now(), 'account_id': documentID, 'user_id': UserService.getUser().id});
}

void dislikeAccount(String documentID) async {
  await db
      .collection("dislikes")
      .add({'date': DateTime.now(), 'account_id': documentID, 'user_id': UserService.getUser().id});
}
