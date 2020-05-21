import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newspector_flutter/models/category.dart';

import 'feed.dart';
import 'model.dart';

class NewsGroup extends Model {
  String id;
  NewsCategory category;
  DateTime creationDate;
  DateTime updateDate;
  Feed newsArticleFeed;
  bool followedByUser;
  String leaderId;

  String firstReporterId;
  String closeSecondId;
  String lateComerId;

  Map<String, int> sourceCounts;

  NewsGroup.fromDocument(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data;
    id = documentSnapshot.documentID;

    assignCategory(data['category']);

    leaderId = data['group_leader'];
    firstReporterId = data['first_reporter'];
    closeSecondId = data['close_second'];
    lateComerId = data['late_comer'];

    var createdAt = data['created_at']?.toInt() ?? 0;
    var updatedAt = data['updated_at']?.toInt() ?? 0;
    creationDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
    updateDate = DateTime.fromMillisecondsSinceEpoch(updatedAt);

    sourceCounts = data['source_count_map'].cast<String, int>();
  }

  void addNewsArticles(List<String> newsArticleIds) {
    if (this.newsArticleFeed == null) {
      this.newsArticleFeed = Feed<String>();
    }

    this.newsArticleFeed.addAdditionalItems(newsArticleIds);
  }

  int getArticleCount() {
    return newsArticleFeed.getItemCount();
  }

  String getNewsArticleId(int index) {
    return newsArticleFeed.getItem(index);
  }

  void assignCategory(String category) {
    switch (category) {
      case 'Finance':
        this.category = NewsCategory.Finance;
        break;
      case 'Jobs & Education':
        this.category = NewsCategory.JobsEducation;
        break;
      case 'Travel':
        this.category = NewsCategory.Travel;
        break;
      case 'Pets & Animals':
        this.category = NewsCategory.PetsAnimals;
        break;
      case 'Food & Drink':
        this.category = NewsCategory.FoodDrink;
        break;
      case 'Science':
        this.category = NewsCategory.Science;
        break;
      case 'Art & Entertainment':
        this.category = NewsCategory.ArtEntertainment;
        break;
      case 'People & Society':
        this.category = NewsCategory.PeopleSociety;
        break;
      case 'Computers & Electronics':
        this.category = NewsCategory.ComputersElectronics;
        break;
      case 'Business & Industrial':
        this.category = NewsCategory.BusinessIndustrial;
        break;
      case 'Health':
        this.category = NewsCategory.Health;
        break;
      case 'Law & Government':
        this.category = NewsCategory.LawGovernment;
        break;
      case 'Sports':
        this.category = NewsCategory.Sports;
        break;
      default:
        this.category = NewsCategory.Other;
        break;
    }
  }
}
