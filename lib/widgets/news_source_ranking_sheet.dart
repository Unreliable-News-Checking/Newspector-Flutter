import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/widgets/news_sources_page/news_source_photo_container.dart';

class NewsSourcesRankingSheet extends StatefulWidget {
  final Feed<String> newsSources;
  final NewsTag newsTag;

  const NewsSourcesRankingSheet(
      {Key key, @required this.newsSources, @required this.newsTag})
      : super(key: key);

  @override
  _NewsSourcesRankingSheetState createState() =>
      _NewsSourcesRankingSheetState();
}

class _NewsSourcesRankingSheetState extends State<NewsSourcesRankingSheet> {
  List<NewsSource> rankedNewsSources;

  @override
  void initState() {
    super.initState();
    rankedNewsSources = List();
    for (var i = 0; i < widget.newsSources.getItemCount(); i++) {
      var newsSourceId = widget.newsSources.getItem(i);
      var newsSource = NewsSourceService.getNewsSource(newsSourceId);
      rankedNewsSources.add(newsSource);
    }

    rankedNewsSources.sort((a, b) =>
        b.tagMap.map[widget.newsTag].compareTo(a.tagMap.map[widget.newsTag]));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: app_const.backgroundColor,
            ),
            child: Column(
              children: [
                Container(
                  height: 4,
                  width: 40,
                  margin: EdgeInsets.fromLTRB(0, 15, 0, 30),
                  decoration: BoxDecoration(
                    color: app_const.inactiveColor,
                    borderRadius: BorderRadius.circular(360),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    widget.newsTag.toReadableString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoScrollbar(
                    controller: scrollController,
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: BouncingScrollPhysics()
                          .applyTo(AlwaysScrollableScrollPhysics()),
                      slivers: <Widget>[
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return NewsSourcePage(
                                      newsSourceId: rankedNewsSources[index].id,
                                    );
                                  }));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        child: Text(
                                            utils.numberToOrdinal(index + 1)),
                                        width: 30,
                                      ),
                                      SizedBox(width: 10),
                                      NewsSourcePhotoContainer(
                                        size: 50,
                                        newsSource: rankedNewsSources[index],
                                        borderRadius: 360,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        rankedNewsSources[index].name,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Expanded(child: Container()),
                                      Text(
                                        rankedNewsSources[index]
                                            .tagMap
                                            .map[widget.newsTag]
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: rankedNewsSources.length,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
