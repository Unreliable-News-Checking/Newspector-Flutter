abstract class Enumeration implements Comparable {
  String name;
  int id;

  Enumeration(int id, String name) {
    this.id = id;
    this.name = name;
  }

  String toString() => name;

  bool equals(Object obj) {
    var otherValue = obj as Enumeration;

    if (otherValue == null) return false;

    var typeMatches = this.runtimeType == obj.runtimeType;
    var valueMatches = this.id == otherValue.id;

    return typeMatches && valueMatches;
  }

  @override
  int compareTo(Object other) {
    var _other = other as Enumeration;
    return this.id.compareTo(_other.id);
  }
}

class NewsCategory extends Enumeration {
  static final NewsCategory finance = NewsCategory(1, "Finance", "finance");
  static final NewsCategory jobsEducation =
      NewsCategory(2, "Jobs & Education", 'jobs');
  static final NewsCategory travel = NewsCategory(3, "Travel", 'travel');
  static final NewsCategory petsAnimals =
      NewsCategory(4, "Pets & Animals", 'pets');
  static final NewsCategory foodDrink = NewsCategory(5, "Food & Drink", 'food');
  static final NewsCategory science = NewsCategory(6, "Science", 'science');
  static final NewsCategory artEntertainment =
      NewsCategory(7, "Arts & Entertainment", 'art');
  static final NewsCategory peopleSociety =
      NewsCategory(8, "People & Society", 'people');
  static final NewsCategory computersElectronics =
      NewsCategory(9, "Computers & Electronics", 'computer');
  static final NewsCategory businessIndustrial =
      NewsCategory(10, "Business & Industrial", 'bussines');
  static final NewsCategory health = NewsCategory(11, "Health", 'health');
  static final NewsCategory lawGovernment =
      NewsCategory(12, "Law & Government", 'law');
  static final NewsCategory sports = NewsCategory(13, "Sports", 'sports');
  static final NewsCategory general = NewsCategory(14, "General", 'general');

  String backgroundFileName;

  NewsCategory(int id, String name, this.backgroundFileName) : super(id, name);

  String backgroundImagePath() {
    var path = "assets/backgrounds/";
    return '$path$backgroundFileName.png';
  }

  String iconImagePath() {
    var path = "assets/category_icons/";
    return '$path$backgroundFileName.png';
  }

  static NewsCategory nameToEnum(String category) {
    switch (category) {
      case 'Finance':
        return NewsCategory.finance;
      case 'Jobs & Education':
        return NewsCategory.jobsEducation;
      case 'Travel':
        return NewsCategory.travel;
      case 'Pets & Animals':
        return NewsCategory.petsAnimals;
      case 'Food & Drink':
        return NewsCategory.foodDrink;
      case 'Science':
        return NewsCategory.science;
      case 'Arts & Entertainment':
        return NewsCategory.artEntertainment;
      case 'People & Society':
        return NewsCategory.peopleSociety;
      case 'Computers & Electronics':
        return NewsCategory.computersElectronics;
      case 'Business & Industrial':
        return NewsCategory.businessIndustrial;
      case 'Health':
        return NewsCategory.health;
      case 'Law & Government':
        return NewsCategory.lawGovernment;
      case 'Sports':
        return NewsCategory.sports;
      default:
        return NewsCategory.general;
    }
  }
}
