import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/widgets/news_group_page/ngp_news_article_photo_container.dart';

class NewsGroupPageNewsArticleContainer extends StatefulWidget {
  final String newsArticleId;
  final Function onTap;
  final Color backgroundColor;
  final double topMargin;
  final bool dontShowDivider;

  NewsGroupPageNewsArticleContainer({
    Key key,
    @required this.newsArticleId,
    @required this.onTap,
    @required this.backgroundColor,
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
        widget.onTap();
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        source(),
                        headline(),
                      ],
                    ),
                  ),
                  NgpNewsArticlePhotoContainer(
                    newsArticle: _newsArticle,
                    height: 80,
                    width: 80,
                    borderRadius: 8,
                  ),
                  // getArticleImage(),
                ],
              ),
              Row(
                children: <Widget>[
                  date2(),
                  Expanded(child: Container()),
                  websiteButton(),
                  tweetButton(),
                ],
              ),
              widget.dontShowDivider
                  ? Container()
                  : Container(height: 1, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget getArticleImage() {
    var photoUrl = _newsArticle.photoUrl;
    if (photoUrl == null) return Container();

    return Container(
      height: 80,
      width: 80,
      margin: EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: CachedNetworkImageProvider(photoUrl),
          fit: BoxFit.cover,
        ),
      ),
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
              _newsArticle.newsSourceId,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            _newsArticle.isRetweet
                ? Icon(
                    Icons.repeat,
                    size: 16,
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
          color: Colors.grey.shade600,
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
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget tweetButton() {
    return IconButton(
      icon: Icon(EvaIcons.twitter),
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
      ),
      onPressed: () async {
        await NewsArticleService.goToWebsite(widget.newsArticleId);
      },
    );
  }
}
