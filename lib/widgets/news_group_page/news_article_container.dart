import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/utilities.dart' as utils;

class NewsArticleContainer extends StatefulWidget {
  final String newsArticleId;
  final Function onTap;
  final bool shorten;

  NewsArticleContainer(
      {Key key,
      @required this.newsArticleId,
      @required this.onTap,
      @required this.shorten})
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              headline(),
              Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      source(),
                      date(),
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
    String headline = _newsArticle.headline;
    if (widget.shorten) {
      return Text(
        headline,
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      );
    }

    return Text(
      headline,
    );
  }

  Widget source() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return NewsSourcePage(
            newsSourceId: _newsArticle.newsSourceId,
          );
        }));
      },
      child: Row(
        children: <Widget>[
          Text(
            _newsArticle.newsSourceId,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          _newsArticle.isRetweet ? Icon(Icons.repeat) : Container(),
          // Text("is retweet: ${_newsArticle.isRetweet}"),
        ],
      ),
    );
  }

  Widget date() {
    var timestamp = _newsArticle.date;
    var dateString = utils.timestampToMeaningfulTime(timestamp);
    return Text(
      dateString,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade600,
      ),
    );
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
