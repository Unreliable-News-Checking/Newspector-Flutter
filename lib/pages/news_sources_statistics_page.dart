import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/widgets/news_source_ranking_sheet.dart';
import 'package:newspector_flutter/widgets/sliver_app_bar.dart';
import 'package:newspector_flutter/widgets/pie_chart.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:newspector_flutter/models/news_source.dart';

class NewsSourcesStatisticsPage extends StatefulWidget {
  final ScrollController scrollController;

  NewsSourcesStatisticsPage({
    Key key,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _NewsSourcesStatisticsPageState createState() =>
      _NewsSourcesStatisticsPageState();
}

class _NewsSourcesStatisticsPageState extends State<NewsSourcesStatisticsPage> {
  Feed<String> _newsSourceFeed;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    if (NewsSourceService.hasFeed()) {
      _newsSourceFeed = NewsSourceService.getNewsSourceFeed();
      return homeScaffold();
    }

    // if there is no existing feed,
    // get the latest feed and display it
    return FutureBuilder(
      future: getFeed(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            // _newsSourceFeed = snapshot.data;
            return homeScaffold();
            break;
          default:
            return loadingScaffold();
        }
      },
    );
  }

  // shown when there is a feed with news groups
  Widget homeScaffold() {
    return Scaffold(
      backgroundColor: app_const.backgroundColor,
      body: CupertinoScrollbar(
        child: CustomScrollView(
          controller: _scrollController,
          physics:
              BouncingScrollPhysics().applyTo(AlwaysScrollableScrollPhysics()),
          slivers: <Widget>[
            refreshControl(),
            itemList(),
          ],
        ),
      ),
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

  Widget refreshControl() {
    return defaultRefreshControl(onRefresh: () async {
      await getFeed();
      if (mounted) setState(() {});
    });
  }

  Widget itemList() {
    var pieCharts = <Widget>[];

    for (var i = 0; i < NewsTag.values.length; i++) {
      var pie = pieChart(NewsTag.values[i]);

      if (pie == null) continue;

      pieCharts.add(pie);
    }

    if (pieCharts.length == 0) {
      return emptyList("Currently there are no statistics to show.");
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return pieCharts[index];
        },
        childCount: pieCharts.length,
      ),
    );
  }

  // shown when the page is loading the new feed
  Widget emptyList(String message) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(top: 50),
        child: Center(
          child: Text(message),
        ),
      ),
    );
  }

  Future<Feed<String>> getFeed() async {
    _newsSourceFeed = await NewsSourceService.updateAndGetNewsSourceFeed(
      pageSize: -1,
    );
    return _newsSourceFeed;
  }

  Widget pieChart(NewsTag tag) {
    List<CircularSegmentEntry> items = List<CircularSegmentEntry>();
    var colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.pink,
      Colors.cyanAccent,
      Colors.deepOrange,
      Colors.greenAccent,
      Colors.indigo,
      Colors.brown,
      Colors.yellow,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.teal,
      Colors.lightGreen,
      Colors.limeAccent,
      Colors.blueGrey,
      Colors.white,
      Colors.greenAccent
    ];

    for (var i = 0; i < _newsSourceFeed.getItemCount(); i++) {
      var newsSourceId = _newsSourceFeed.getItem(i);
      var newsSource = NewsSourceService.getNewsSource(newsSourceId);

      if (newsSource.tagMap.map[tag] == 0) continue;

      CircularSegmentEntry item = CircularSegmentEntry(
        newsSource.tagMap.map[tag].toDouble(),
        colors[i],
        rankKey: newsSource.name,
      );
      items.add(item);
    }

    if (items.length == 0) return null;

    items.sort((a, b) => b.value.compareTo(a.value));

    List<CircularStackEntry> data = <CircularStackEntry>[
      CircularStackEntry(items)
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showRankingSheet(tag),
      child: PieChartContainer(
        title: tag.toReadableString(),
        data: data,
        count: 4,
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
}
