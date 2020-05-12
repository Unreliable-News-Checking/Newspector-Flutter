import 'package:firebase_database/firebase_database.dart';

import 'realtime_service.dart';

void rateAccount(
  String newsSourceId,
  String userId,
  int rating,
  // int changeInLike,
  // int changeInDislike,
) {

  // final DatabaseReference likeRef =
  //     fb.reference().child('accounts/' + newsSourceId + '/likes');
  // likeRef.runTransaction((MutableData transaction) async {
  //   transaction.value = (transaction.value ?? 0) + changeInLike;
  //   return transaction;
  // });

  // final DatabaseReference dislikeRef =
  //     fb.reference().child('accounts/' + newsSourceId + '/dislikes');
  // dislikeRef.runTransaction((MutableData transaction) async {
  //   transaction.value = (transaction.value ?? 0) + changeInDislike;
  //   return transaction;
  // });
}

Future<DataSnapshot> getNewsSourceDocument(String documentID) async {
  DataSnapshot snapshot =
      (await fb.reference().child('accounts/' + documentID).once());

  return snapshot;
}
