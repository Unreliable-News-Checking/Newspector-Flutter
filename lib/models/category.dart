extension CategoryNaming on Category {
  String toReadableString() {
    switch (this) {
      case Category.Finance:
        return "Finance";
      case Category.JobsEducation:
        return "Jobs & Education";
      case Category.Travel:
        return "Travel";
      case Category.PetsAnimals:
        return "Pets & Animals";
      case Category.FoodDrink:
        return "Food & Drink";
      case Category.Science:
        return "Science";
      case Category.ArtEntertainment:
        return "Art & Entertainment";
      case Category.PeopleSociety:
        return "People & Society";
      case Category.ComputersElectronics:
        return "Computers & Electronics";
      case Category.BusinessIndustrial:
        return "Business & Industrial";
      case Category.Health:
        return "Health";
      case Category.LawGovernment:
        return "Law & Government";
      case Category.Sports:
        return "Sports";
      default:
        return "Other";
    }
  }

  String toImagePath() {
    var path = "assets/backgrounds/";
    var fileName = '';
    switch (this) {
      case Category.Finance:
        fileName = "bussines";
        break;
      case Category.JobsEducation:
        fileName = "jobs";
        break;
      case Category.Travel:
        fileName = "travel";
        break;
      case Category.PetsAnimals:
        fileName = "pets";
        break;
      case Category.FoodDrink:
        fileName = "food";
        break;
      case Category.Science:
        fileName = "science";
        break;
      case Category.ArtEntertainment:
        fileName = "art";
        break;
      case Category.PeopleSociety:
        fileName = "people";
        break;
      case Category.ComputersElectronics:
        fileName = "computer";
        break;
      case Category.BusinessIndustrial:
        fileName = "bussines";
        break;
      case Category.Health:
        fileName = "health";
        break;
      case Category.LawGovernment:
        fileName = "law";
        break;
      case Category.Sports:
        fileName = "sports";
        break;
      default:
        fileName = "other";
        break;
    }

    return '$path$fileName.png';
  }
}

enum Category {
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
