import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/pages/news_group_page.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/pages/web_view_page.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/widgets/home_page/hp_news_article_photo_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/widgets/news_sources_page/news_source_photo_container.dart';
import 'package:newspector_flutter/widgets/sliver_app_bar.dart';
import 'package:newspector_flutter/widgets/twitter_button.dart';

class NewsArticlePage extends StatefulWidget {
  final String newsArticleId;
  final String heroKey;

  NewsArticlePage({
    Key key,
    @required this.newsArticleId,
    @required this.heroKey,
  }) : super(key: key);

  @override
  _NewsArticlePageState createState() => _NewsArticlePageState();
}

class _NewsArticlePageState extends State<NewsArticlePage> {
  NewsArticle _newsArticle;

  @override
  Widget build(BuildContext context) {
    if (NewsArticleService.hasNewsArticle(widget.newsArticleId)) {
      _newsArticle = NewsArticleService.getNewsArticle(widget.newsArticleId);
      return homeScaffold();
    }

    // if there is no existing feed,
    // get the latest feed and display it
    return FutureBuilder(
      future: NewsArticleService.updateAndGetNewsArticle(widget.newsArticleId),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            _newsArticle = snapshot.data;
            return homeScaffold();
            break;
          default:
            return loadingScaffold();
        }
      },
    );
  }

  Widget loadingScaffold() {
    return Scaffold(
      backgroundColor: app_const.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: app_const.backgroundColor,
      ),
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget homeScaffold() {
    return Scaffold(
      backgroundColor: app_const.backgroundColor,
      body: Container(
        child: CupertinoScrollbar(
          child: CustomScrollView(
            physics: BouncingScrollPhysics()
                .applyTo(AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              sliverAppBar(),
              refreshControl(),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      newsArticlePhoto(),
                      SizedBox(height: 20),
                      headline(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          date(),
                          Expanded(child: Container()),
                          websiteButton(),
                          TwitterButton(tweetLink: _newsArticle.tweetLink),
                        ],
                      ),
                      source(),
                      SizedBox(height: 7),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          tag(),
                          category(),
                          sentimentResult(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sliverAppBar() {
    return defaultSliverAppBar(
      titleText: "",
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.fullscreen),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return NewsGroupPage(
                newsGroupId: _newsArticle.newsGroupId,
              );
            }));
          },
        ),
      ],
    );
  }

  Widget refreshControl() {
    return defaultRefreshControl(onRefresh: () async {
      _newsArticle = await NewsArticleService.updateAndGetNewsArticle(
          widget.newsArticleId);
      if (mounted) setState(() {});
    });
  }

  Widget newsArticlePhoto() {
    return Hero(
      tag: "${widget.newsArticleId}_${widget.heroKey}",
      child: Container(
        child: HpNewsArticlePhotoContainer(
          newsArticle: _newsArticle,
          height: 200,
          width: double.infinity,
          borderRadius: 10,
          shadow: false,
        ),
      ),
    );
  }

  Widget headline() {
    String headline = _newsArticle.headline;
    return Container(
      // margin: EdgeInsets.symmetric(vertical: 15),
      child: Text(
        headline,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
          shadows: app_const.shadowsForWhiteWidgets(),
        ),
      ),
    );
  }

  Widget source() {
    var newsSource = NewsSourceService.getNewsSource(_newsArticle.newsSourceId);
    return Container(
      // margin: EdgeInsets.symmetric(vertical: 15),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return NewsSourcePage(
              newsSourceId: _newsArticle.newsSourceId,
            );
          }));
        },
        child: Row(
          children: [
            NewsSourcePhotoContainer(
              size: 60,
              borderRadius: 10,
              newsSource: newsSource,
            ),
            SizedBox(width: 15),
            Row(
              children: <Widget>[
                Text(
                  newsSource.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    shadows: app_const.shadowsForWhiteWidgets(),
                  ),
                ),
                SizedBox(width: 4),
                _newsArticle.isRetweet
                    ? Icon(
                        Icons.repeat,
                        color: app_const.defaultTextColor,
                      )
                    : Container(),
              ],
            ),
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
        fontSize: 15,
        fontWeight: FontWeight.normal,
        shadows: app_const.shadowsForWhiteWidgets(),
      ),
    );
  }

  Widget websiteButton() {
    if (_newsArticle.websiteLink == null) return Container();

    return IconButton(
      icon: Icon(
        Icons.web,
        color: app_const.defaultTextColor,
      ),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) {
          return WebViewPage(
            initialUrl: _newsArticle.websiteLink,
          );
        }));
      },
    );
  }

  Widget statsRow(Widget icon, String label) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            child: FittedBox(
              child: icon,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 15),
          Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: app_const.shadowsForWhiteWidgets(),
            ),
          ),
        ],
      ),
    );
  }

  Widget sentimentResult() {
    var sentiment = _newsArticle.readableSentiment();
    var sentimentIconPath = 'assets/sentiment_icons/';

    var sentimentFileName = const <String, String>{
      "Strongly Positive": 'positive',
      "Positive": 'positive',
      "Slightly Positive": 'positive',
      "Neutral": 'neutral',
      "Slightly Negative": 'negative',
      "Negative": 'negative',
      "Strongly Negative": 'negative',
    }[sentiment];

    sentimentIconPath = sentimentIconPath + sentimentFileName + '.png';

    return statsRow(Image.asset(sentimentIconPath), sentiment);
  }

  Widget category() {
    var _newsGroupId = _newsArticle.newsGroupId;
    var _newsGroup = NewsGroupService.getNewsGroup(_newsGroupId);
    String categoryText = _newsGroup.category.name;
    var categoryIconPath = _newsGroup.category.iconImagePath();
    return statsRow(Image.asset(categoryIconPath), categoryText);
  }

  Widget tag() {
    var _newsGroupId = _newsArticle.newsGroupId;
    var _newsGroup = NewsGroupService.getNewsGroup(_newsGroupId);
    var newsFromSourceNo = _newsGroup.sourceCounts[_newsArticle.newsSourceId];
    NewsTag tag;
    if (_newsGroup.firstReporterId == _newsArticle.id) {
      tag = NewsTag.FirstReporter;
    } else if (_newsGroup.closeSecondId == _newsArticle.id &&
        _newsGroup.closeSecondId != _newsGroup.firstReporterId) {
      tag = NewsTag.CloseSecond;
    } else if (_newsGroup.lateComerId == _newsArticle.id &&
        _newsGroup.lateComerId != _newsGroup.firstReporterId &&
        _newsGroup.lateComerId != _newsGroup.closeSecondId) {
      tag = NewsTag.LateComer;
    } else if (newsFromSourceNo != null && newsFromSourceNo > 1) {
      tag = NewsTag.FollowUp;
    } else {
      tag = NewsTag.SlowPoke;
    }
    return statsRow(
      Image.asset(tag.toIconPath()),
      tag.toReadableString(),
    );
  }
}
