import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/utilities.dart' as utils;

class NewsArticleContainer extends StatefulWidget {
  final String newsArticleId;
  final Function onTap;

  NewsArticleContainer(
      {Key key, @required this.newsArticleId, @required this.onTap})
      : super(key: key);

  @override
  _NewsArticleContainerState createState() => _NewsArticleContainerState();
}

class _NewsArticleContainerState extends State<NewsArticleContainer> {
  NewsArticle _newsArticle;

  @override
  Widget build(BuildContext context) {
    _newsArticle = NewsArticleService.getNewsArticle(widget.newsArticleId);

    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.white,
        child: Center(
          child: Column(
            children: <Widget>[
              headline(),
              Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      date(),
                      source(),
                    ],
                  ),
                  Expanded(child: Container()),
                  websiteButton(),
                  tweetButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget headline() {
    return Text(_newsArticle.headline);
  }

  Widget source() {
    return Row(
      children: <Widget>[
        Text(_newsArticle.newsSourceId),
        Text("is retweet: ${_newsArticle.isRetweet}"),
      ],
    );
  }

  Widget date() {
    var timestamp = _newsArticle.date;
    var dateString = utils.timestampToMeaningfulTime(timestamp);
    return Text(dateString);
  }

  Widget tweetButton() {
    return IconButton(
      icon: Icon(Icons.alternate_email),
      onPressed: () async {
        await NewsArticleService.goToTweet(widget.newsArticleId);
      },
    );
  }

  Widget websiteButton() {
    if (_newsArticle.websiteLink == null) return Container();
    return IconButton(
      icon: Icon(Icons.web),
      onPressed: () {},
    );
  }
}
