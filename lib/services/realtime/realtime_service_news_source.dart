import 'package:firebase_database/firebase_database.dart';

import 'realtime_service.dart';

void rateSource(String newsSourceId, String userId, bool vote) {
  String field = vote == true ? "likes" : "dislikes";

  final DatabaseReference likeRef =
      fb.reference().child("accounts/" + newsSourceId + "/" + field);
  likeRef.runTransaction((MutableData transaction) async {
    transaction.value = (transaction.value ?? 0) + 1;
    return transaction;
  });
}

Future<DataSnapshot> getNewsSourceDocument(String documentID) async {
  DataSnapshot snapshot =
      (await fb.reference().child('accounts/' + documentID).once());

  return snapshot;
}
