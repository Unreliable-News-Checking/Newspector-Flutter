import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/pages/feed_page.dart';
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

  Widget sliverAppBar() {
    return defaultSliverAppBar(
      titleText: _newsSource.name,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              NewsSourcePhotoContainer(radius: 140, newsSource: _newsSource),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  headerLabel('Birthday: '),
                  headerLabel('Followers: '),
                  headerLabel('News: '),
                  headerLabel('Rating: '),
                ],
              ),
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
          name(),
        ],
      ),
    );
  }

  Widget headerLabel(String label) {
    return Text(
      label,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget headerValue(String value) {
    return Text(
      value,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 16,
      ),
    );
  }

  Widget stackedCountContainer({@required String label, @required int value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        Text(
          utils.countToMeaningfulString(value),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget name() {
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
