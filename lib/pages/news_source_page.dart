import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/widgets/news_sources_page/photo_container.dart';

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
    return Scaffold(
      appBar: AppBar(
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

  Widget sourceHeader() {
    return Container(
      // margin: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              PhotoContainer(radius: 80, newsSource: _newsSource),
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
