extension CategoryNaming on NewsCategory {
  String toReadableString() {
    switch (this) {
      case NewsCategory.Finance:
        return "Finance";
      case NewsCategory.JobsEducation:
        return "Jobs & Education";
      case NewsCategory.Travel:
        return "Travel";
      case NewsCategory.PetsAnimals:
        return "Pets & Animals";
      case NewsCategory.FoodDrink:
        return "Food & Drink";
      case NewsCategory.Science:
        return "Science";
      case NewsCategory.ArtEntertainment:
        return "Art & Entertainment";
      case NewsCategory.PeopleSociety:
        return "People & Society";
      case NewsCategory.ComputersElectronics:
        return "Computers & Electronics";
      case NewsCategory.BusinessIndustrial:
        return "Business & Industrial";
      case NewsCategory.Health:
        return "Health";
      case NewsCategory.LawGovernment:
        return "Law & Government";
      case NewsCategory.Sports:
        return "Sports";
      default:
        return "Other";
    }
  }

  String toImagePath() {
    var path = "assets/backgrounds/";
    var fileName = '';
    switch (this) {
      case NewsCategory.Finance:
        fileName = "bussines";
        break;
      case NewsCategory.JobsEducation:
        fileName = "jobs";
        break;
      case NewsCategory.Travel:
        fileName = "travel";
        break;
      case NewsCategory.PetsAnimals:
        fileName = "pets";
        break;
      case NewsCategory.FoodDrink:
        fileName = "food";
        break;
      case NewsCategory.Science:
        fileName = "science";
        break;
      case NewsCategory.ArtEntertainment:
        fileName = "art";
        break;
      case NewsCategory.PeopleSociety:
        fileName = "people";
        break;
      case NewsCategory.ComputersElectronics:
        fileName = "computer";
        break;
      case NewsCategory.BusinessIndustrial:
        fileName = "bussines";
        break;
      case NewsCategory.Health:
        fileName = "health";
        break;
      case NewsCategory.LawGovernment:
        fileName = "law";
        break;
      case NewsCategory.Sports:
        fileName = "sports";
        break;
      default:
        fileName = "other";
        break;
    }

    return '$path$fileName.png';
  }
}

enum NewsCategory {
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
