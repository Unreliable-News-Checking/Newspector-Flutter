import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/widgets/sliver_app_bar.dart';

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
            _newsSourceFeed = snapshot.data;
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
    return defaultRefreshControl(onRefresh: getFeed);
  }

  Widget itemList() {
    if (_newsSourceFeed.getItemCount() == 0)
      return Text("Currently there are no news sources.");

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(child: Text("Ibne Deniz"));
        },
        childCount: _newsSourceFeed.getItemCount(),
      ),
    );
  }

  Future<Feed<String>> getFeed() async {
    _newsSourceFeed = await NewsSourceService.updateAndGetNewsSourceFeed(
      pageSize: -1,
    );

    return _newsSourceFeed;
  }
}
