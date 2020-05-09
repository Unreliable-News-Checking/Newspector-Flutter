import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import 'realtime_service.dart';

void rateAccount(
  String documentID,
  int changeInLike,
  int changeInDislike,
) {
  final DatabaseReference likeRef =
      fb.reference().child('accounts/' + documentID + '/likes');
  likeRef.runTransaction((MutableData transaction) async {
    transaction.value = (transaction.value ?? 0) + changeInLike;
    return transaction;
  });

  final DatabaseReference dislikeRef =
      fb.reference().child('accounts/' + documentID + '/dislikes');
  dislikeRef.runTransaction((MutableData transaction) async {
    transaction.value = (transaction.value ?? 0) + changeInDislike;
    return transaction;
  });
}

Future<DataSnapshot> getNewsSourceFromRealtimeDB(String documentID) async {
  DataSnapshot snapshot =
      (await fb.reference().child('accounts/' + documentID).once()).value;

  return snapshot;
}
