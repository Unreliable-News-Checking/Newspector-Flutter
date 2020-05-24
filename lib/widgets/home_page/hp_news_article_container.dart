import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/pages/news_article_page.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/application_constants.dart' as app_consts;
import 'package:newspector_flutter/widgets/twitter_button.dart';
import 'package:newspector_flutter/widgets/website_button.dart';
import 'hp_news_article_photo_container.dart';

class HomePageNewsArticleContainer extends StatefulWidget {
  final String newsArticleId;
  // final Function onTap;
  final bool shorten;
  final double height;
  final double borderRadius;
  final double horizontalMargin;
  final bool alone;

  HomePageNewsArticleContainer({
    Key key,
    @required this.newsArticleId,
    // @required this.onTap,
    @required this.shorten,
    @required this.height,
    @required this.borderRadius,
    @required this.horizontalMargin,
    @required this.alone,
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.horizontalMargin),
      child: GestureDetector(
        onTap: () {
          // widget.onTap();
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return NewsArticlePage(
              heroKey: this.hashCode.toString(),
              newsArticleId: widget.newsArticleId,
            );
          }));
        },
        child: Stack(
          children: <Widget>[
            Hero(
              tag: "${widget.newsArticleId}_${this.hashCode}",
              child: Container(
                child: HpNewsArticlePhotoContainer(
                  newsArticle: _newsArticle,
                  width: double.infinity,
                  height: widget.height,
                  borderRadius: widget.borderRadius,
                  shadow: true,
                ),
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
                      TwitterButton(tweetLink: _newsArticle.tweetLink),
                    ],
                  ),
                  headline(),
                  widget.alone ? SizedBox(height: 12) : SizedBox(height: 32),
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
          fontWeight: FontWeight.bold,
          shadows: app_consts.shadowsForWhiteWidgets(),
        ),
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
        margin: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: <Widget>[
            Text(
              newsSource.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                shadows: app_consts.shadowsForWhiteWidgets(),
              ),
            ),
            SizedBox(width: 4),
            _newsArticle.isRetweet
                ? Icon(
                    Icons.repeat,
                    color: app_consts.defaultTextColor,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget date() {
    var date = _newsArticle.date;
    var dateString = utils.timestampToMeaningfulTime(date);
    return Text(
      dateString,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        shadows: app_consts.shadowsForWhiteWidgets(),
      ),
    );
  }

  Widget websiteButton() {
    if (_newsArticle.websiteLink == null) return Container();

    return WebsiteButton(
      websiteLink: _newsArticle.websiteLink,
    );
  }

  Widget separatorDot() {
    return Container(
      width: 3,
      height: 3,
      margin: EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(360),
        color: app_consts.defaultTextColor,
      ),
    );
  }
}
