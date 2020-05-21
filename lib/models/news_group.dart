import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newspector_flutter/models/category.dart';

import 'feed.dart';
import 'model.dart';

class NewsGroup extends Model {
  String id;
  Category category;
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
        this.category = Category.Finance;
        break;
      case 'Jobs & Education':
        this.category = Category.JobsEducation;
        break;
      case 'Travel':
        this.category = Category.Travel;
        break;
      case 'Pets & Animals':
        this.category = Category.PetsAnimals;
        break;
      case 'Food & Drink':
        this.category = Category.FoodDrink;
        break;
      case 'Science':
        this.category = Category.Science;
        break;
      case 'Art & Entertainment':
        this.category = Category.ArtEntertainment;
        break;
      case 'People & Society':
        this.category = Category.PeopleSociety;
        break;
      case 'Computers & Electronics':
        this.category = Category.ComputersElectronics;
        break;
      case 'Business & Industrial':
        this.category = Category.BusinessIndustrial;
        break;
      case 'Health':
        this.category = Category.Health;
        break;
      case 'Law & Government':
        this.category = Category.LawGovernment;
        break;
      case 'Sports':
        this.category = Category.Sports;
        break;
      default:
        this.category = Category.Other;
        break;
    }
  }
}
