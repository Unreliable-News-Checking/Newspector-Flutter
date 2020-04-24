import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/application_constants.dart' as app_consts;

class HomePageNewsArticleContainer extends StatefulWidget {
  final String newsArticleId;
  final Function onTap;
  final bool shorten;
  // final Color backgroundColor;

  HomePageNewsArticleContainer({
    Key key,
    @required this.newsArticleId,
    @required this.onTap,
    @required this.shorten,
    // @required this.backgroundColor,
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
        decoration: BoxDecoration(
          image: showNewsArticlePhoto(),
          color: app_consts.newsArticleBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  source(),
                  Expanded(child: Container()),
                  websiteButton(),
                  tweetButton(),
                  SizedBox(width: 24)
                ],
              ),
              headline(),
              date(),
            ],
          ),
        ),
      ),
    );
  }

  Widget headline() {
    String headline = _newsArticle.headline;
    var overflow = widget.shorten ? TextOverflow.ellipsis : null;
    var maxLines = widget.shorten ? 3 : null;
    return Container(
      height: 60,
      child: Text(
        headline,
        overflow: overflow,
        maxLines: maxLines,
        style: TextStyle(
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
                fontSize: 13,
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
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.normal,
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

  DecorationImage showNewsArticlePhoto() {
    var photoUrl = _newsArticle.photoUrl;
    if (photoUrl == null) return null;

    return DecorationImage(
      image: CachedNetworkImageProvider(photoUrl),
      fit: BoxFit.cover,
    );
  }
}
