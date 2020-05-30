import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/widgets/news_source_ranking_sheet.dart';
import 'package:newspector_flutter/widgets/news_sources_page/news_source_photo_container.dart';
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/widgets/sliver_app_bar.dart';
import 'package:newspector_flutter/widgets/pie_chart.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:newspector_flutter/widgets/twitter_button.dart';
import 'package:newspector_flutter/widgets/website_button.dart';

class NewsSourcePage extends StatefulWidget {
  final String newsSourceId;

  NewsSourcePage({Key key, @required this.newsSourceId}) : super(key: key);

  @override
  _NewsSourcePageState createState() => _NewsSourcePageState();
}

class _NewsSourcePageState extends State<NewsSourcePage> {
  NewsSource _newsSource;
  Feed<String> _newsSourceFeed;
  List<NewsSource> _newsSourceList;

  @override
  Widget build(BuildContext context) {
    if (NewsSourceService.hasFeed()) {
      _newsSource = NewsSourceService.getNewsSource(widget.newsSourceId);
      _newsSourceFeed = NewsSourceService.getNewsSourceFeed();
      return homeScaffold();
    }

    // if there is no existing feed,
    // get the latest feed and display it
    return FutureBuilder(
      future: getUpdatedNewsSource(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            _newsSource = snapshot.data;
            return homeScaffold();
            break;
          default:
            return loadingScaffold();
        }
      },
    );
  }

  Widget loadingScaffold() {
    return Scaffold(
      backgroundColor: app_const.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: app_const.backgroundColor,
      ),
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget homeScaffold() {
    return Scaffold(
      backgroundColor: app_const.backgroundColor,
      body: Container(
        child: CupertinoScrollbar(
          child: Container(
            child: CustomScrollView(
              physics: BouncingScrollPhysics()
                  .applyTo(AlwaysScrollableScrollPhysics()),
              slivers: <Widget>[
                sliverAppBar(),
                refreshControl(),
                sourceHeader(),
                sourceBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sliverAppBar() {
    return defaultSliverAppBar(
      titleText: _newsSource.name,
      actions: <Widget>[
        TwitterButton(tweetLink: _newsSource.twitterLink),
        WebsiteButton(
          websiteLink: _newsSource.websiteLink,
        ),
      ],
    );
  }

  Widget refreshControl() {
    return CupertinoSliverRefreshControl(onRefresh: () async {
      getUpdatedNewsSource();
      if (mounted) setState(() {});
    });
  }

  Future<NewsSource> getUpdatedNewsSource() async {
    _newsSourceFeed =
        await NewsSourceService.updateAndGetNewsSourceFeed(pageSize: -1);
    _newsSource =
        await NewsSourceService.getOrFetchNewsSource(widget.newsSourceId);
    return _newsSource;
  }

  Widget sourceHeader() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            labelsRow(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: 140,
                  child: sourceName(),
                ),
                SizedBox(width: 30),
                Expanded(
                  child: RaisedButton(
                    onPressed: showRateSheet,
                    color: app_const.defaultTextColor,
                    child: Text("Rate News Source"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget newsSourcePhoto() {
    return NewsSourcePhotoContainer(
      size: 140,
      newsSource: _newsSource,
      borderRadius: 10,
    );
  }

  Widget labelsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        NewsSourcePhotoContainer(
          size: 140,
          newsSource: _newsSource,
          borderRadius: 10,
        ),
        SizedBox(width: 30),
        SizedBox(
          height: 140,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              headerLabel('Birthday:'),
              headerLabel('Followers:'),
              headerLabel('News:'),
              headerLabel('Rating:'),
            ],
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          height: 140,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              headerValue(_newsSource.birthday),
              headerValue(
                utils.countToMeaningfulString(_newsSource.followerCount),
              ),
              headerValue(
                utils.countToMeaningfulString(_newsSource.newsCount),
              ),
              headerValue('${_newsSource.rating.toInt()}%'),
            ],
          ),
        )
      ],
    );
  }

  Widget headerLabel(String label) {
    return Container(
      padding: EdgeInsets.all(2),
      child: Text(
        label,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget headerValue(String value) {
    return Container(
      padding: EdgeInsets.all(2),
      child: Text(
        value,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  void showRateSheet() {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        return NewsSourceSheet(newsSourceId: widget.newsSourceId);
      },
    );
  }

  Widget sourceName() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        _newsSource.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget sourceBody() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            padding: EdgeInsets.all(20),
            childAspectRatio: MediaQuery.of(context).size.width /
                (MediaQuery.of(context).size.height / 4),
            children: <Widget>[
              statContainer(tag: NewsTag.FirstReporter),
              statContainer(tag: NewsTag.CloseSecond),
              statContainer(tag: NewsTag.LateComer),
              statContainer(tag: NewsTag.SlowPoke),
              statContainer(tag: NewsTag.FollowUp),
              statContainer(tag: NewsTag.GroupMember),
            ],
          ),
          categoryPie(),
        ],
      ),
    );
  }

  Widget statContainer({@required NewsTag tag}) {
    String iconPath = "";
    String count = "";

    if (_newsSourceList == null) {
      _newsSourceList = List<NewsSource>();
      for (var newsSource in _newsSourceFeed.getItems()) {
        _newsSourceList.add(NewsSourceService.getNewsSource(newsSource));
      }
    }

    if (tag != null) {
      _newsSourceList
          .sort((a, b) => b.tagMap.map[tag].compareTo(a.tagMap.map[tag]));
      iconPath = tag.toIconPath();
      count = _newsSource.tagMap.map[tag].toString();
    }

    int index = _newsSourceList
        .indexWhere((source) => source.id.startsWith(_newsSource.id));

    //String header = tag.toReadableString();
    return GestureDetector(
      onTap: () => showRankingSheet(tag),
      behavior: HitTestBehavior.opaque,
      child: Container(
        child: Column(
          children: [
            // Text(
            //   header,
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      child: FittedBox(
                        child: Image.asset(
                          iconPath,
                          color: app_const.defaultTextColor,
                          filterQuality: FilterQuality.high,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          utils.numberToOrdinal(index + 1),
                          style: TextStyle(fontSize: 20),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(count, style: TextStyle(fontSize: 20)),
                            SizedBox(width: 5),
                            Text('times'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showRankingSheet(NewsTag newsTag) {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        return NewsSourcesRankingSheet(
          newsSources: _newsSourceFeed,
          newsTag: newsTag,
        );
      },
    );
  }

  Widget categoryPie() {
    List<CircularSegmentEntry> items = List<CircularSegmentEntry>();
    var colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.pink,
      Colors.amber,
      Colors.deepOrange,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
      Colors.lime,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.yellow,
      Colors.lightGreen
    ];

    for (var i = 0; i < _newsSource.categoryMap.map.length; i++) {
      var category = _newsSource.categoryMap.map.keys.elementAt(i);
      var count = _newsSource.categoryMap.map[category];

      if (count == -1) continue;

      CircularSegmentEntry item = CircularSegmentEntry(
        count.toDouble(),
        colors[i],
        rankKey: category.name,
      );
      items.add(item);
    }
    if (items.length == 0) return Container();

    items.sort((a, b) => b.value.compareTo(a.value));

    List<CircularStackEntry> data = <CircularStackEntry>[
      CircularStackEntry(items)
    ];

    return PieChartContainer(
      title: "Categories",
      data: data,
      count: 3,
    );
  }
}

class NewsSourceSheet extends StatefulWidget {
  final String newsSourceId;

  const NewsSourceSheet({Key key, @required this.newsSourceId})
      : super(key: key);

  @override
  _NewsSourceSheetState createState() => _NewsSourceSheetState();
}

class _NewsSourceSheetState extends State<NewsSourceSheet> {
  bool rated = false;
  NewsSource _newsSource;
  @override
  Widget build(BuildContext context) {
    _newsSource = NewsSourceService.getNewsSource(widget.newsSourceId);

    if (_newsSource.rated) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          color: app_const.backgroundColor,
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Thank you for your feedback!",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "You can rate again next day.",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: app_const.backgroundColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 4,
            width: 40,
            margin: EdgeInsets.fromLTRB(0, 15, 0, 30),
            decoration: BoxDecoration(
              color: app_const.inactiveColor,
              borderRadius: BorderRadius.circular(360),
            ),
          ),
          Text(
            "Do you enjoy this News Source?",
            style: TextStyle(
              fontSize: 22,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150,
                padding: EdgeInsets.all(5),
                child: RaisedButton(
                  onPressed: () => rateNewsSource(Rating.Good),
                  color: Color(0xFF68B55B),
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      color: app_const.backgroundColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Container(
                width: 150,
                padding: EdgeInsets.all(5),
                child: RaisedButton(
                  onPressed: () => rateNewsSource(Rating.Bad),
                  color: Color(0xFFD04444),
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: app_const.backgroundColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void rateNewsSource(Rating rating) {
    NewsSourceService.rateNewsSource(
      widget.newsSourceId,
      rating,
    );
    setState(() {
      _newsSource.rated = true;
    });
  }
}
