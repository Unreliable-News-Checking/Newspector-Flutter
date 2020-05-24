import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:newspector_flutter/models/category.dart';

import 'model.dart';

enum NewsTag { FirstReporter, CloseSecond, LateComer, SlowPoke, FollowUp }

extension TagNaming on NewsTag {
  String toReadableString() {
    switch (this) {
      case NewsTag.FirstReporter:
        return "First Reporter";
      case NewsTag.CloseSecond:
        return "Close Second";
      case NewsTag.LateComer:
        return "Late Comer";
      case NewsTag.SlowPoke:
        return "Slow Poke";
      default:
        return "FollowUp";
    }
  }

  String toIconPath() {
    var path = "assets/tag_icons/";
    var fileName = '';

    switch (this) {
      case NewsTag.FirstReporter:
        fileName = "first_reporter";
        break;
      case NewsTag.CloseSecond:
        fileName = "close_second";
        break;
      case NewsTag.LateComer:
        fileName = "late_comer";
        break;
      case NewsTag.SlowPoke:
        fileName = "slowpoke";
        break;
      default:
        fileName = "follow_up";
        break;
    }

    return path + fileName + '.png';
  }
}

class GenericMap<T> {
  Map<T, int> temp;
  LinkedHashMap<T, int> map;
  List sortedList;

  GenericMap() {
    temp = Map();
    map = LinkedHashMap();
  }

  void orderMap() {
    for (var key in temp.keys) {
      temp[key] = temp[key] ?? -1;
    }

    var sortedKeys = temp.keys.toList(growable: false)
      ..sort((k2, k1) => temp[k1].compareTo(temp[k2]));
    LinkedHashMap<T, int> sortedMap = LinkedHashMap.fromIterable(
      sortedKeys,
      key: (k) => k,
      value: (k) => temp[k],
    );
    map = sortedMap;
  }
}

class NewsSource extends Model {
  String id;
  String name;
  String twitterUsername;
  String photoUrl;

  int followerCount;
  int newsCount;

  int likes;
  int dislikes;
  int reports;
  double rating;

  int firstInGroupCount;
  int membershipCount;
  int reportCount;
  int newsGroupFollowerCount;
  int tweetCount;

  GenericMap<NewsCategory> categoryMap;
  GenericMap<NewsTag> tagMap;

  bool rated;

  String birthday;

  String websiteLink;
  String twitterLink;
  Uint8List photoInBytes;

  NewsSource.fromDocument(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data;
    id = documentSnapshot.documentID;
    twitterUsername = data['username'];
    name = data['name'];
    photoUrl = data['profile_photo'];
    birthday = data['birthday'];

    websiteLink = data['website'];
    if (!websiteLink.contains("http")) {
      websiteLink = "https://" + websiteLink;
    }

    twitterLink = 'https://twitter/$twitterUsername';

    followerCount = data['followers_count'] ?? 0;
    tweetCount = data['tweets_count'] ?? 0;
    newsCount = data['news_count'] ?? 0;
    membershipCount = data['news_group_membership_count'] ?? 0;
    reportCount = data['dislike_count'] ?? 0;

    populateCategoryMap(data['category_map']);

    populateTagMap(data);
  }

  void populateCategoryMap(Map categoryData) {
    categoryMap = GenericMap<NewsCategory>();
    var map = categoryMap.temp;
    map[NewsCategory.finance] = categoryData['Finance'];
    map[NewsCategory.jobsEducation] = categoryData['Jobs & Education'];
    map[NewsCategory.travel] = categoryData['Travel'];
    map[NewsCategory.petsAnimals] = categoryData['Pets & Animals'];
    map[NewsCategory.foodDrink] = categoryData['Food & Drink'];
    map[NewsCategory.science] = categoryData['Science'];
    map[NewsCategory.artEntertainment] = categoryData['Art & Entertainment'];
    map[NewsCategory.peopleSociety] = categoryData['People & Society'];
    map[NewsCategory.computersElectronics] =
        categoryData['Computers & Electronics'];
    map[NewsCategory.businessIndustrial] =
        categoryData['Business & Industrial'];
    map[NewsCategory.health] = categoryData['Health'];
    map[NewsCategory.lawGovernment] = categoryData['Law & Government'];
    map[NewsCategory.sports] = categoryData['Sports'];
    map[NewsCategory.other] = categoryData['Others'];

    categoryMap.orderMap();
  }

  void populateTagMap(Map data) {
    tagMap = GenericMap<NewsTag>();
    var map = tagMap.temp;
    map[NewsTag.FirstReporter] = data['first_reporter'] ?? 0;
    map[NewsTag.CloseSecond] = data['close_second'] ?? 0;
    map[NewsTag.LateComer] = data['late_comer'] ?? 0;
    map[NewsTag.SlowPoke] = data['slow_poke'] ?? 0;
    map[NewsTag.FollowUp] = data['follow_up'] ?? 0;

    tagMap.orderMap();
  }

  void updateRatingsFromDatabase(DataSnapshot dataSnapshot, bool rated) {
    var data = dataSnapshot.value;
    likes = data['likes'] ?? 0;
    dislikes = data['dislikes'] ?? 0;
    reports = data['reports'] ?? 0;

    rating = max(likes / max(likes + dislikes, 1), 0).toDouble() * 100;
    this.rated = rated;
  }
}
