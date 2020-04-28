import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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
    dateString = diff.inDays.toInt().toString() + " days ago";
  } else if (diff.inDays.toInt() == 1) {
    dateString = "Yesterday";
  } else if (diff.inHours.toInt() > 1) {
    dateString = diff.inHours.toInt().toString() + " hours ago";
  } else if (diff.inHours.toInt() == 1) {
    dateString = "1 hour ago";
  } else if (diff.inMinutes.toInt() > 1) {
    dateString = diff.inMinutes.toInt().toString() + " minutes ago";
  } else if (diff.inMinutes.toInt() == 1) {
    dateString = "1 minute ago";
  } else {
    dateString = diff.inSeconds.toString() + " seconds ago";
  }

  return dateString;
}

const months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

String timestampToDateString(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  var dayString = dateTime.day.toString();
  var monthString = months[dateTime.month - 1];
  var yearString = dateTime.year.toString();
  return monthString + " " + dayString + ", " + yearString;
}

String countToMeaningfulString(int count) {
  int million = 1000000;
  int hundredThousand = 100000;
  int thousand = 1000;
  String strCount;

  if (count > million && count % million > hundredThousand) {
    strCount = "${roundDown(count / million, 1)}m";
  } else if (count > million) {
    strCount = "${(count / million).toStringAsFixed(0)}m";
  } else if (count > thousand) {
    strCount = "${count ~/ thousand}k";
  } else {
    strCount = count.toString();
  }

  return strCount;
}

String roundDown(double d, int decimals) {
  int fac = pow(10, decimals);
  d = (d * fac).truncateToDouble() / fac;
  return d.toString();
}

Future<bool> goToUrl(String url) async {
  var canLaunchUrl = await canLaunch(url);

  if (!canLaunchUrl) return false;

  await launch(url);
  return true;
}
