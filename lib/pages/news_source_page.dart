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
              Expanded(child: headerRow()),
            ],
          ),
          name(),
        ],
      ),
    );
  }

  Widget headerRow() {
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

  void showRateSheet() {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return NewsSourceSheet(newsSourceId: widget.newsSourceId);
      },
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
