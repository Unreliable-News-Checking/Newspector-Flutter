import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import 'model.dart';

extension CategoryNaming on Categories {
  String toReadableString() {
    switch (this) {
      case Categories.Finance:
        return "Finance";
      case Categories.JobsEducation:
        return "Jobs & Education";
      case Categories.Travel:
        return "Travel";
      case Categories.PetsAnimals:
        return "Pets & Animals";
      case Categories.FoodDrink:
        return "Food & Drink";
      case Categories.Science:
        return "Science";
      case Categories.ArtEntertainment:
        return "Art & Entertainment";
      case Categories.PeopleSociety:
        return "People & Society";
      case Categories.ComputersElectronics:
        return "Computers & Electronics";
      case Categories.BusinessIndustrial:
        return "Business & Industrial";
      case Categories.Health:
        return "Health";
      case Categories.LawGovernment:
        return "Law & Government";
      case Categories.Sports:
        return "Sports";
      default:
        return "Other";
    }
  }
}

enum Categories {
  Finance,
  JobsEducation,
  Travel,
  PetsAnimals,
  FoodDrink,
  Science,
  ArtEntertainment,
  PeopleSociety,
  ComputersElectronics,
  BusinessIndustrial,
  Health,
  LawGovernment,
  Sports,
  Other,
}

class CategoryMap {
  Map<Categories, int> temp;
  LinkedHashMap<Categories, int> map;
  List sortedList;

  CategoryMap() {
    temp = Map();
    map = LinkedHashMap();
  }

  void orderMap() {
    for (var key in temp.keys) {
      temp[key] = temp[key] ?? -1;
    }

    var sortedKeys = temp.keys.toList(growable: false)
      ..sort((k2, k1) => temp[k1].compareTo(temp[k2]));
    LinkedHashMap<Categories, int> sortedMap = LinkedHashMap.fromIterable(
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

  CategoryMap categoryMap;

  int firstReporterCount;
  int closeSecondCount;
  int lateComerCount;
  int slowPokeCount;
  int followUpCount;

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

    firstReporterCount = data['first_reporter'] ?? 0;
    closeSecondCount = data['close_second'] ?? 0;
    lateComerCount = data['late_comer'] ?? 0;
    slowPokeCount = data['slow_poke'] ?? 0;
    followUpCount = data['follow_up'] ?? 0;
  }

  void populateCategoryMap(Map categoryData) {
    categoryMap = CategoryMap();
    var map = categoryMap.temp;
    map[Categories.Finance] = categoryData['Finance'];
    map[Categories.JobsEducation] = categoryData['Jobs & Education'];
    map[Categories.Travel] = categoryData['Travel'];
    map[Categories.PetsAnimals] = categoryData['Pets & Animals'];
    map[Categories.FoodDrink] = categoryData['Food & Drink'];
    map[Categories.Science] = categoryData['Science'];
    map[Categories.ArtEntertainment] = categoryData['Art & Entertainment'];
    map[Categories.PeopleSociety] = categoryData['People & Society'];
    map[Categories.ComputersElectronics] =
        categoryData['Computers & Electronics'];
    map[Categories.BusinessIndustrial] = categoryData['Business & Industrial'];
    map[Categories.Health] = categoryData['Health'];
    map[Categories.LawGovernment] = categoryData['Law & Government'];
    map[Categories.Sports] = categoryData['Sports'];
    map[Categories.Other] = categoryData['Others'];

    categoryMap.orderMap();
  }

  void updateRatingsFromDatabase(DataSnapshot dataSnapshot, bool rated) {
    var data = dataSnapshot.value;
    likes = data['likes'] ?? 0;
    dislikes = data['dislikes'] ?? 0;
    reports = data['reports'] ?? 0;

    rating = max((likes - dislikes) / max(likes + dislikes, 1), 0) * 100;
    this.rated = rated;
  }
}
