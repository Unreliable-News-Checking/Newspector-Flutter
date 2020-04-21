import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/widgets/news_sources_page/photo_container.dart';

class NewsSourceContainer extends StatelessWidget {
  final String newsSourceId;

  const NewsSourceContainer({Key key, @required this.newsSourceId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    NewsSource newsSource = NewsSourceService.getNewsSource(newsSourceId);

    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          sourcePhoto(newsSource),
          sourceInfo(newsSource.name, newsSource.followerCount),
        ],
      ),
    );
  }

  Widget sourcePhoto(NewsSource newsSource) {
    // return Container(
    //   width: 60,
    //   height: 60,
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(360),
    //     color: Colors.blue,
    //   ),
    // );
    return PhotoContainer(radius: 60, newsSource: newsSource);
  }

  Widget sourceInfo(String sourceName, int followerCount) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sourceName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("Followers: ${utils.countToMeaningfulString(followerCount)}"),
        ],
      ),
    );
  }
}
