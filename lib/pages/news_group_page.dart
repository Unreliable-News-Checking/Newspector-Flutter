import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/services/news_group_service.dart';

class NewsGroupPage extends StatefulWidget {
  final String newsGroupID;

  NewsGroupPage({Key key, @required this.newsGroupID}) : super(key: key);

  @override
  _NewsGroupPageState createState() => _NewsGroupPageState();
}

class _NewsGroupPageState extends State<NewsGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: NewsGroupFeed(newsGroupID: widget.newsGroupID),
      ),
    );
  }
}

class NewsGroupFeed extends StatefulWidget {
  final String newsGroupID;

  NewsGroupFeed({Key key, @required this.newsGroupID}) : super(key: key);

  @override
  _NewsGroupFeedState createState() => _NewsGroupFeedState();
}

class _NewsGroupFeedState extends State<NewsGroupFeed> {
  NewsGroup _newsGroup;
  @override
  Widget build(BuildContext context) {
    _newsGroup = NewsGroupService.getNewsGroup(widget.newsGroupID);

    return Container(
      child: ListView.builder(
        itemCount: _newsGroup.getArticleCount(),
        itemBuilder: (context, itemIndex) {
          return _buildNewsGroupFeedItem(context, itemIndex);
        },
      ),
    );
  }

  Widget _buildNewsGroupFeedItem(BuildContext context, int itemIndex) {
    return Container(
      margin: EdgeInsets.all(5),
      color: Colors.red,
      height: 100,
      child: Center(
        child: Text("News no: $itemIndex"),
      ),
    );
  }
}
