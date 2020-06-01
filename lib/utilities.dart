import 'dart:math';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/services/user_service.dart';
// import 'package:url_launcher/url_launcher.dart';

String timestampToMeaningfulTime(DateTime date) {
  Duration diff = DateTime.now().difference(date);

  var dayDifference = DateTime.now().day - date.day;
  dayDifference = dayDifference.abs();

  String dateString;
  if (dayDifference >= 7) {
    dateString = date.day.toString() +
        "/" +
        date.month.toString() +
        "/" +
        date.year.toString();
  } else if (dayDifference > 1) {
    dateString = dayDifference.toString() + " days ago";
  } else if (dayDifference == 1) {
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

String numberToOrdinal(int number) {
  int lastDigit = number % 10;

  if (number == 11 || number == 12 || number == 13) {
    return number.toString() + "th";
  }

  if (lastDigit == 1) {
    return number.toString() + "st";
  }

  if (lastDigit == 2) {
    return number.toString() + "nd";
  }

  if (lastDigit == 3) {
    return number.toString() + "rd";
  }

  return number.toString() + "th";
}

String timestampToDateString(DateTime date) {
  var dayString = date.day.toString();
  var monthString = months[date.month - 1];
  var yearString = date.year.toString();
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

// Future<bool> goToUrl(String url) async {
//   var canLaunchUrl = await canLaunch(url);

//   if (!canLaunchUrl) return false;

//   await launch(url);
//   return true;
// }

void clearStoresAndServices() {
  NewsArticleService.clearStore();
  NewsFeedService.clearFeeds();
  NewsGroupService.clearStore();
  NewsSourceService.clearFeed();
  NewsSourceService.clearStore();
  UserService.clearUser();
}
