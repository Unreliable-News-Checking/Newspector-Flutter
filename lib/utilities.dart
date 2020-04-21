import 'package:cloud_firestore/cloud_firestore.dart';

String timestampToMeaningfulTime(Timestamp timestamp) {
  DateTime postDate = timestamp.toDate();
  Duration diff = DateTime.now().difference(postDate);

  String dateString;
  if (diff.inDays.toInt() >= 7) {
    dateString = postDate.day.toString() +
        "/" +
        postDate.month.toString() +
        "/" +
        postDate.year.toString();
  } else if (diff.inDays.toInt() > 1) {
    dateString = diff.inDays.toInt().toString() + " DAYS AGO";
  } else if (diff.inDays.toInt() == 1) {
    dateString = "1 DAY AGO";
  } else if (diff.inHours.toInt() > 1) {
    dateString = diff.inHours.toInt().toString() + " HOURS AGO";
  } else if (diff.inHours.toInt() == 1) {
    dateString = "1 HOUR AGO";
  } else if (diff.inMinutes.toInt() > 1) {
    dateString = diff.inMinutes.toInt().toString() + " MINUTES AGO";
  } else if (diff.inMinutes.toInt() == 1) {
    dateString = "1 MINUTE AGO";
  } else {
    dateString = diff.inSeconds.toString() + " SECONDS AGO";
  }

  return dateString;
}

String countToMeaningfulString(int count) {
  int million = 1000000;
  int thousand = 1000;
  if (count > million) return "${count ~/ million}m";
  if (count > thousand) return "${count ~/ thousand}k";
  return count.toString();
}
