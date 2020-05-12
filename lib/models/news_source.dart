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

  String birthday;

  String websiteLink;
  String twitterLink;
  Uint8List photoInBytes;

  NewsSource.fromDocument(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data;
    id = documentSnapshot.documentID;
    twitterUsername = data['username'];
    name = data['name'];
    followerCount = data['followers_count'];
    tweetCount = data['tweets_count'];
    website = data['website'];
    photoUrl = data['profile_photo'];
    newsCount = data['news_count'];
    firstInGroupCount = data['news_group_leadership_count'];
    membershipCount = data['news_group_membership_count'];
    reportCount = data['dislike_count'];
    birthday = data['birthday'];

    websiteLink = website;
    twitterLink = 'https://twitter/$twitterUsername';

    populateCategoryMap(data['category_map']);
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

  void updateRatingsFromDatabase(DataSnapshot dataSnapshot) {
    var data = dataSnapshot.value;
    likes = data['likes_count'];
    dislikes = data['dislikes_count'];
    reports = data['reports_count'];

    rating = max((likes - dislikes) / max(likes + dislikes, 1), 0);
  }
}
