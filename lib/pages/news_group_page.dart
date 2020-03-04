import 'package:flutter/material.dart';

class NewsGroupPage extends StatefulWidget {
  @override
  _NewsGroupPageState createState() => _NewsGroupPageState();
}

class _NewsGroupPageState extends State<NewsGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: NewsGroupFeed(),
      ),
    );
  }
}

class NewsGroupFeed extends StatefulWidget {
  @override
  _NewsGroupFeedState createState() => _NewsGroupFeedState();
}

class _NewsGroupFeedState extends State<NewsGroupFeed> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: 10,
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
