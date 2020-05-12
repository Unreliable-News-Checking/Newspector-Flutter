import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/widgets/news_sources_page/news_source_photo_container.dart';
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/widgets/sliver_app_bar.dart';

class NewsSourcePage extends StatefulWidget {
  final String newsSourceId;

  NewsSourcePage({Key key, @required this.newsSourceId}) : super(key: key);

  @override
  _NewsSourcePageState createState() => _NewsSourcePageState();
}

class _NewsSourcePageState extends State<NewsSourcePage> {
  NewsSource _newsSource;

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (NewsSourceService.hasNewsSource(widget.newsSourceId)) {
      _newsSource = NewsSourceService.getNewsSource(widget.newsSourceId);
      return homeScaffold();
    }

    // if there is no existing feed,
    // get the latest feed and display it
    return FutureBuilder(
      future: NewsSourceService.updateAndGetNewsSource(widget.newsSourceId),
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
        title: Text(
          "",
          style: TextStyle(color: Colors.white),
        ),
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
        margin: EdgeInsets.all(15),
        child: CupertinoScrollbar(
          child: CustomScrollView(
            controller: _scrollController,
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
    );
  }

  Widget sliverAppBar() {
    return defaultSliverAppBar(
      titleText: _newsSource.name,
      actions: <Widget>[
        IconButton(
          icon: Icon(EvaIcons.twitter),
          onPressed: () async {
            await NewsSourceService.goToSourceTwitter(widget.newsSourceId);
          },
        ),
        IconButton(
          icon: Icon(Icons.web),
          onPressed: () async {
            await NewsSourceService.goToSourceWebsite(widget.newsSourceId);
          },
        ),
      ],
    );
  }

  Widget refreshControl() {
    return CupertinoSliverRefreshControl(onRefresh: () async {
      _newsSource =
          await NewsSourceService.updateAndGetNewsSource(widget.newsSourceId);
    });
  }

  Widget sourceHeader() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                NewsSourcePhotoContainer(
                  size: 140,
                  newsSource: _newsSource,
                  borderRadius: 10,
                ),
                SizedBox(width: 30),
                Expanded(child: labelsRow()),
              ],
            ),
            sourceName(),
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
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                headerLabel('Birthday:'),
                headerLabel('Followers:'),
                headerLabel('News:'),
                headerLabel('Rating:'),
              ],
            ),
            SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                headerValue(_newsSource.birthday),
                headerValue(
                  utils.countToMeaningfulString(_newsSource.followerCount),
                ),
                headerValue(
                  utils.countToMeaningfulString(_newsSource.newsCount),
                ),
                headerValue(_newsSource.rating.toStringAsFixed(2)),
              ],
            )
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(
            onPressed: showRateSheet,
            color: Colors.white,
            child: Text("Rate News Source"),
          ),
        ),
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
          fontSize: 16,
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
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                bigCountLabel(
                  "First Reporter",
                  _newsSource.firstInGroupCount.toString(),
                ),
                SizedBox(width: 20),
                bigCountLabel(
                  "Group Member",
                  _newsSource.membershipCount.toString(),
                ),
              ],
            ),
          ),
          categoryPie(),
        ],
      ),
    );
  }

  Widget bigCountLabel(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget categoryPie() {
    var radius = 70.0;
    var sections = List<PieChartSectionData>();
    var indicators = List<Indicator>();
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

    var colorIndex = 0;
    for (var i = 0; i < _newsSource.categoryMap.map.length; i++) {
      var category = _newsSource.categoryMap.map.keys.elementAt(i);
      var count = _newsSource.categoryMap.map[category];

      if (count == -1) continue;

      var section = PieChartSectionData(
        color: colors[colorIndex],
        value: count.toDouble(),
        showTitle: false,
        titlePositionPercentageOffset: 0,
        radius: radius,
      );

      var indicator = Indicator(
        color: colors[colorIndex],
        text: category.toReadableString(),
        isSquare: true,
      );

      colorIndex++;
      sections.add(section);
      indicators.add(indicator);
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: radius * 2,
            height: radius * 2,
            margin: EdgeInsets.only(right: 20),
            child: PieChart(
              PieChartData(
                startDegreeOffset: 150,
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: sections,
              ),
            ),
          ),
          Wrap(
            spacing: 2,
            direction: Axis.vertical,
            children: indicators,
          )
        ],
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;

  const Indicator({
    Key key,
    this.color,
    this.text,
    this.isSquare,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
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

  @override
  Widget build(BuildContext context) {
    if (rated) {
      return Container(
        height: 200,
        color: app_const.backgroundColor,
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Thank you for your feedback!",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      color: app_const.backgroundColor,
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Do you enjoy this News Source?",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150,
                padding: EdgeInsets.all(5),
                child: RaisedButton(
                  onPressed: () => rateNewsSource(Rating.Good),
                  color: Colors.green,
                  child: Text("Yes"),
                ),
              ),
              Container(
                width: 150,
                padding: EdgeInsets.all(5),
                child: RaisedButton(
                  onPressed: () => rateNewsSource(Rating.Bad),
                  color: Colors.red,
                  child: Text("No"),
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
      rated = true;
    });
  }
}
