import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/models/news_source.dart';

import 'models/news_article.dart';

class MockDatabase {
  static NewsSource newsSource01 =
      NewsSource("ns_id_01", "BBC", null, "bbc.com", null);
  static NewsSource newsSource02 =
      NewsSource("ns_id_02", "NBC", null, "nbc.com", null);
  static NewsSource newsSource03 =
      NewsSource("ns_id_03", "FOX", null, "fox.com", null);

  static NewsArticle newsArticle01 = NewsArticle.fromAttributes(
    "na_id_01",
    "ng_id_01",
    newsSource01,
    "Headline01",
    "link01.com",
    DateTime.now(),
    "analysisResult01",
  );
  static NewsArticle newsArticle02 = NewsArticle.fromAttributes(
    "na_id_02",
    "ng_id_01",
    newsSource02,
    "Headline02",
    "link02.com",
    DateTime.now(),
    "analysisResult02",
  );
  static NewsArticle newsArticle03 = NewsArticle.fromAttributes(
    "na_id_03",
    "ng_id_01",
    newsSource03,
    "Headline03",
    "link03.com",
    DateTime.now(),
    "analysisResult03",
  );

  static NewsArticle newsArticle04 = NewsArticle.fromAttributes(
    "na_id_04",
    "ng_id_02",
    newsSource01,
    "Headline04",
    "link04.com",
    DateTime.now(),
    "analysisResult04",
  );
  static NewsArticle newsArticle05 = NewsArticle.fromAttributes(
    "na_id_05",
    "ng_id_02",
    newsSource02,
    "Headline05",
    "link05.com",
    DateTime.now(),
    "analysisResult05",
  );
  static NewsArticle newsArticle06 = NewsArticle.fromAttributes(
    "na_id_06",
    "ng_id_02",
    newsSource03,
    "Headline06",
    "link06.com",
    DateTime.now(),
    "analysisResult06",
  );

  static NewsArticle newsArticle07 = NewsArticle.fromAttributes(
    "na_id_07",
    "ng_id_03",
    newsSource01,
    "Headline07",
    "link07.com",
    DateTime.now(),
    "analysisResult07",
  );
  static NewsArticle newsArticle08 = NewsArticle.fromAttributes(
    "na_id_08",
    "ng_id_03",
    newsSource02,
    "Headline08",
    "link08.com",
    DateTime.now(),
    "analysisResult08",
  );
  static NewsArticle newsArticle09 = NewsArticle.fromAttributes(
    "na_id_09",
    "ng_id_03",
    newsSource03,
    "Headline09",
    "link09.com",
    DateTime.now(),
    "analysisResult09",
  );

  static NewsGroup newsGroup01 = NewsGroup.fromAttributes(
    "ng_id_01",
    "sport",
    newsArticle01,
    [newsArticle01, newsArticle02, newsArticle03],
  );

  static NewsGroup newsGroup02 = NewsGroup.fromAttributes(
    "ng_id_02",
    "politics",
    newsArticle04,
    [newsArticle04, newsArticle05, newsArticle06],
  );

  static NewsGroup newsGroup03 = NewsGroup.fromAttributes(
    "ng_id_03",
    "science",
    newsArticle07,
    [newsArticle07, newsArticle08, newsArticle09],
  );

  static List<NewsGroup> newsGroups = [newsGroup01, newsGroup02, newsGroup03];

  static Future<List<NewsGroup>> getNewsGroups() async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      return newsGroups;
    });
  }
}
