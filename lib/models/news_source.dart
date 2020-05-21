import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:newspector_flutter/models/category.dart';

import 'model.dart';

enum Tag { FirstReporter, CloseSecond, LateComer, SlowPoke, FollowUp }

extension TagNaming on Tag {
  String toReadableString() {
    switch (this) {
      case Tag.FirstReporter:
        return "First Reporter";
      case Tag.CloseSecond:
        return "Close Second";
      case Tag.LateComer:
        return "Late Comer";
      case Tag.SlowPoke:
        return "Slow Poke";
      default:
        return "FollowUp";
    }
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
  String website;
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

  GenericMap<Category> categoryMap;
  GenericMap<Tag> tagMap;

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
    website = data['website'];
    photoUrl = data['profile_photo'];
    birthday = data['birthday'];
    websiteLink = website;
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
    categoryMap = GenericMap<Category>();
    var map = categoryMap.temp;
    map[Category.Finance] = categoryData['Finance'];
    map[Category.JobsEducation] = categoryData['Jobs & Education'];
    map[Category.Travel] = categoryData['Travel'];
    map[Category.PetsAnimals] = categoryData['Pets & Animals'];
    map[Category.FoodDrink] = categoryData['Food & Drink'];
    map[Category.Science] = categoryData['Science'];
    map[Category.ArtEntertainment] = categoryData['Art & Entertainment'];
    map[Category.PeopleSociety] = categoryData['People & Society'];
    map[Category.ComputersElectronics] =
        categoryData['Computers & Electronics'];
    map[Category.BusinessIndustrial] = categoryData['Business & Industrial'];
    map[Category.Health] = categoryData['Health'];
    map[Category.LawGovernment] = categoryData['Law & Government'];
    map[Category.Sports] = categoryData['Sports'];
    map[Category.Other] = categoryData['Others'];

    categoryMap.orderMap();
  }

  void populateTagMap(Map data) {
    tagMap = GenericMap<Tag>();
    var map = tagMap.temp;
    map[Tag.FirstReporter] = data['first_reporter'] ?? 0;
    map[Tag.CloseSecond] = data['close_second'] ?? 0;
    map[Tag.LateComer] = data['late_comer'] ?? 0;
    map[Tag.SlowPoke] = data['slow_poke'] ?? 0;
    map[Tag.FollowUp] = data['follow_up'] ?? 0;

    tagMap.orderMap();
  }

  void updateRatingsFromDatabase(DataSnapshot dataSnapshot, bool rated) {
    var data = dataSnapshot.value;
    likes = data['likes'] ?? 0;
    dislikes = data['dislikes'] ?? 0;
    reports = data['reports'] ?? 0;

    rating = max((likes - dislikes) / max(likes + dislikes, 1), 0).toDouble() * 100;
    this.rated = rated;
  }
}
