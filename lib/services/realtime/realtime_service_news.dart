import 'package:firebase_database/firebase_database.dart';

import 'realtime_service.dart';

void increaseReportCount(String documentID) async {
  final dataRef =
      fb.reference().child('tweets/' + documentID + '/report_count');

  dataRef.runTransaction((MutableData transaction) async {
    transaction.value = (transaction.value ?? 0) + 1;
    return transaction;
  });
}

Future<DataSnapshot> getNewsFromRealtimeDB(String documentID) async {
  DataSnapshot snapshot =
      (await fb.reference().child('tweets/' + documentID).once()).value;

  return snapshot;
}
