import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/pages/news_article_page.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/widgets/home_page/hp_news_article_photo_container.dart';
import 'package:newspector_flutter/widgets/twitter_button.dart';
import 'package:newspector_flutter/widgets/website_button.dart';

class NewsGroupPageNewsArticleContainer extends StatefulWidget {
  final String newsArticleId;
  // final Function onTap;
  final double topMargin;
  final bool dontShowDivider;

  NewsGroupPageNewsArticleContainer({
    Key key,
    @required this.newsArticleId,
    // @required this.onTap,
    @required this.topMargin,
    @required this.dontShowDivider,
  }) : super(key: key);

  @override
  _NewsGroupPageNewsArticleContainerState createState() =>
      _NewsGroupPageNewsArticleContainerState();
}

class _NewsGroupPageNewsArticleContainerState
    extends State<NewsGroupPageNewsArticleContainer> {
  NewsArticle _newsArticle;

  double topMargin = 10;

  @override
  Widget build(BuildContext context) {
    _newsArticle = NewsArticleService.getNewsArticle(widget.newsArticleId);

    return GestureDetector(
      onTap: () {
        // widget.onTap();
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return NewsArticlePage(
            newsArticleId: widget.newsArticleId,
            heroKey: this.hashCode.toString(),
          );
        }));
      },
      child: Container(
        // padding: EdgeInsets.all(10),
        margin: EdgeInsets.fromLTRB(0, topMargin, 15, 5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              date(),
              source(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: headline(),
                  ),
                  SizedBox(width: 10),
                  getArticleImage(),
                ],
              ),
              Row(
                children: <Widget>[
                  date2(),
                  Expanded(child: Container()),
                  websiteButton(),
                  TwitterButton(
                    tweetLink: _newsArticle.tweetLink,
                  ),
                ],
              ),
              widget.dontShowDivider
                  ? Container()
                  : Container(
                      height: 1,
                      color: app_const.inactiveColor,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getArticleImage() {
    var photoUrl = _newsArticle.photoUrl;
    if (photoUrl == null) return Container();

    return HpNewsArticlePhotoContainer(
      newsArticle: _newsArticle,
      width: 80,
      height: 80,
      borderRadius: 8,
      shadow: false,
    );
  }

  Widget headline() {
    String headline = _newsArticle.headline;

    return Text(
      headline,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }

  Widget source() {
    var newsSource = NewsSourceService.getNewsSource(_newsArticle.newsSourceId);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return NewsSourcePage(
            newsSourceId: _newsArticle.newsSourceId,
          );
        }));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 5),
        child: Row(
          children: <Widget>[
            Text(
              newsSource.name,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4),
            _newsArticle.isRetweet
                ? Icon(
                    Icons.repeat,
                    size: 16,
                    color: app_const.defaultTextColor,
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
    return Container(
      margin: EdgeInsets.only(bottom: topMargin),
      child: Text(
        dateString,
        style: TextStyle(
          fontSize: 13,
          color: app_const.defaultTextColor,
        ),
      ),
    );
  }

  Widget date2() {
    var date = _newsArticle.date;
    var dateString = utils.timestampToDateString(date);
    return Text(
      dateString,
      style: TextStyle(
        fontSize: 13,
        color: app_const.defaultTextColor,
      ),
    );
  }

  Widget websiteButton() {
    if (_newsArticle.websiteLink == null) return Container();

    return WebsiteButton(
      websiteLink: _newsArticle.websiteLink,
    );
  }
}
