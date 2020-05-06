import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/widgets/news_sources_page/news_source_photo_container.dart';
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/application_constants.dart' as app_const;

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
    _newsSource = NewsSourceService.getNewsSource(widget.newsSourceId);

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
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: app_const.backgroundColor,
        title: Text(_newsSource.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.alternate_email),
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
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: CupertinoScrollbar(
          child: CustomScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics()
                .applyTo(AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              refreshControl(),
              SliverToBoxAdapter(
                child: sourceHeader(),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("First in Group: ${_newsSource.firstInGroupCount}"),
                    Text("Report Count: ${_newsSource.reportCount}"),
                    Text(
                        "News Group Follower Count: ${_newsSource.newsGroupFollowerCount}"),
                    Text("Tweet Count: ${_newsSource.tweetCount}"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget refreshControl() {
    return CupertinoSliverRefreshControl(onRefresh: () async {
      _newsSource =
          await NewsSourceService.updateAndGetNewsSource(widget.newsSourceId);
    });
  }

  Widget sourceHeader() {
    return Container(
      // margin: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              NewsSourcePhotoContainer(radius: 80, newsSource: _newsSource),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    stackedCountContainer(
                        count: _newsSource.newsCount, label: "News"),
                    stackedCountContainer(
                        count: _newsSource.approvalCount, label: "Approvals"),
                    stackedCountContainer(
                        count: _newsSource.followerCount, label: "Followers"),
                  ],
                ),
              ),
            ],
          ),
          bio(),
        ],
      ),
    );
  }

  Widget stackedCountContainer({@required int count, @required String label}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          utils.countToMeaningfulString(count),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget bio() {
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
}
