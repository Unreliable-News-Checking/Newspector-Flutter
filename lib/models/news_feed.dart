import 'package:newspector_flutter/models/news_group.dart';

class NewsFeed {
  List<NewsGroup> newsGroups;

  NewsFeed();

  int getGroupCount() {
    return newsGroups.length;
  }

  NewsGroup getNewsGroup(int index){
    return newsGroups[index];
  }
}
