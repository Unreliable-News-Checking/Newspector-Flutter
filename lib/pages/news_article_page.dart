import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/pages/news_group_page.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/widgets/home_page/hp_news_article_photo_container.dart';

import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/application_constants.dart' as app_consts;

class NewsArticlePage extends StatefulWidget {
  final String newsArticleId;

  NewsArticlePage({Key key, @required this.newsArticleId}) : super(key: key);

  @override
  _NewsArticlePageState createState() => _NewsArticlePageState();
}

class _NewsArticlePageState extends State<NewsArticlePage> {
  @override
  Widget build(BuildContext context) {
    // _newsArticle = NewsArticleService.getNewsArticle(widget.newsArticleId);
    return Scaffold(
      appBar: appBar(),
      backgroundColor: app_consts.backgroundColor,
      body: Center(
        child: Container(
          child: NewsArticleContainer(
            newsArticleId: widget.newsArticleId,
            photoHeight: 200,
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: app_consts.backgroundColor,
    );
  }
}

class NewsArticleContainer extends StatefulWidget {
  final String newsArticleId;
  final double photoHeight;

  NewsArticleContainer({
    Key key,
    @required this.newsArticleId,
    @required this.photoHeight,
  }) : super(key: key);

  @override
  NewsArticleContainerState createState() => NewsArticleContainerState();
}

class NewsArticleContainerState extends State<NewsArticleContainer> {
  NewsArticle _newsArticle;

  @override
  Widget build(BuildContext context) {
    _newsArticle = NewsArticleService.getNewsArticle(widget.newsArticleId);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag: "hp_nap_${widget.newsArticleId}",
            child: Container(
              child: HpNewsArticlePhotoContainer(
                newsArticle: _newsArticle,
                height: widget.photoHeight,
                borderRadius: 10,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            child: source(),
          ),
          headline(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              date(),
              Expanded(child: Container()),
              websiteButton(),
              tweetButton(),
            ],
          ),
          RaisedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return NewsGroupPage(
                  newsGroupId: _newsArticle.newsGroupId,
                );
              }));
            },
            // color: Colors.white,
            child: Text(
              "See Full Coverage",
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget headline() {
    String headline = _newsArticle.headline;
    return Container(
      child: Text(
        headline,
        style: TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: app_consts.shadowsForWhiteWidgets(),
        ),
      ),
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
      child: Container(
        child: Row(
          children: <Widget>[
            Text(
              _newsArticle.newsSourceId,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: app_consts.shadowsForWhiteWidgets(),
              ),
            ),
            _newsArticle.isRetweet
                ? Icon(
                    Icons.repeat,
                    color: Colors.white,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget date() {
    var timestamp = _newsArticle.date;
    var dateString = utils.timestampToMeaningfulTime(timestamp);
    return Text(
      dateString,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white,
        shadows: app_consts.shadowsForWhiteWidgets(),
      ),
    );
  }

  Widget tweetButton() {
    return IconButton(
      icon: Icon(
        EvaIcons.twitter,
        color: Colors.white,
      ),
      onPressed: () async {
        await NewsArticleService.goToTweet(widget.newsArticleId);
      },
    );
  }

  Widget websiteButton() {
    if (_newsArticle.websiteLink == null) return Container();
    return IconButton(
      icon: Icon(
        Icons.web,
        color: Colors.white,
      ),
      onPressed: () async {
        await NewsArticleService.goToWebsite(widget.newsArticleId);
      },
    );
  }

  Widget separatorDot() {
    return Container(
      width: 3,
      height: 3,
      margin: EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(360),
        color: Colors.white,
      ),
    );
  }
}
