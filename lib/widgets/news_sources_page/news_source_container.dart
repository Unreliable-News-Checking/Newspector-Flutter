import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/widgets/news_sources_page/news_source_photo_container.dart';

class NewsSourceContainer extends StatelessWidget {
  final String newsSourceId;
  final Function onTap;

  const NewsSourceContainer({
    Key key,
    @required this.newsSourceId,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NewsSource newsSource = NewsSourceService.getNewsSource(newsSourceId);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            sourcePhoto(newsSource),
            SizedBox(height: 5),
            sourceInfo(newsSource.name, newsSource.followerCount),
          ],
        ),
      ),
    );
  }

  Widget sourcePhoto(NewsSource newsSource) {
    return NewsSourcePhotoContainer(
      size: 120,
      newsSource: newsSource,
      borderRadius: 10,
    );
  }

  Widget sourceInfo(String sourceName, int followerCount) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            sourceName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "Followers: ${utils.countToMeaningfulString(followerCount)}",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
