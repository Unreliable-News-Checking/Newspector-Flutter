import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/application_constants.dart' as app_consts;

import 'hp_news_article_photo_container.dart';

class HomePageNewsArticleContainer extends StatefulWidget {
  final String newsArticleId;
  final Function onTap;
  final bool shorten;
  final double height;

  HomePageNewsArticleContainer({
    Key key,
    @required this.newsArticleId,
    @required this.onTap,
    @required this.shorten,
    @required this.height,
  }) : super(key: key);

  @override
  _HomePageNewsArticleContainerState createState() =>
      _HomePageNewsArticleContainerState();
}

class _HomePageNewsArticleContainerState
    extends State<HomePageNewsArticleContainer> {
  NewsArticle _newsArticle;

  @override
  Widget build(BuildContext context) {
    _newsArticle = NewsArticleService.getNewsArticle(widget.newsArticleId);

    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Stack(
          children: <Widget>[
            Container(
              child: HpNewsArticlePhotoContainer(
                newsArticle: _newsArticle,
                height: widget.height,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: Container()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      source(),
                      separatorDot(),
                      date(),
                      Expanded(child: Container()),
                      websiteButton(),
                      tweetButton(),
                    ],
                  ),
                  headline(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget headline() {
    String headline = _newsArticle.headline;
    var overflow = widget.shorten ? TextOverflow.ellipsis : null;
    var maxLines = widget.shorten ? 3 : null;
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Text(
        headline,
        overflow: overflow,
        maxLines: maxLines,
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
        margin: EdgeInsets.symmetric(vertical: 15),
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
