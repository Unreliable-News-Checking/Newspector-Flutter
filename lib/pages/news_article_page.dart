import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/pages/news_group_page.dart';
import 'package:newspector_flutter/pages/news_source_page.dart';
import 'package:newspector_flutter/services/news_article_service.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/home_page/hp_news_article_photo_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/utilities.dart' as utils;
import 'package:newspector_flutter/application_constants.dart' as app_consts;
import 'package:newspector_flutter/widgets/sliver_app_bar.dart';

class NewsArticlePage extends StatefulWidget {
  final String newsArticleId;

  NewsArticlePage({Key key, @required this.newsArticleId}) : super(key: key);

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
        margin: EdgeInsets.all(20),
        child: CupertinoScrollbar(
          child: CustomScrollView(
            physics: BouncingScrollPhysics()
                .applyTo(AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              sliverAppBar(),
              refreshControl(),
              SliverToBoxAdapter(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      newsArticlePhoto(),
                      source(),
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
                      Wrap(
                        direction: Axis.horizontal,
                        spacing: 10,
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
    return CupertinoSliverRefreshControl(onRefresh: () async {
      _newsArticle = await NewsArticleService.updateAndGetNewsArticle(
          widget.newsArticleId);
      if (mounted) setState(() {});
    });
  }

  Widget newsArticlePhoto() {
    return Hero(
      tag: "hp_nap_${widget.newsArticleId}",
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
      child: Text(
        headline,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: app_consts.shadowsForWhiteWidgets(),
        ),
      ),
    );
  }

  Widget source() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: GestureDetector(
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
                  shadows: app_consts.shadowsForWhiteWidgets(),
                ),
              ),
              _newsArticle.isRetweet
                  ? Icon(
                      Icons.repeat,
                      color: app_consts.defaultTextColor,
                    )
                  : Container(),
            ],
          ),
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
        shadows: app_consts.shadowsForWhiteWidgets(),
      ),
    );
  }

  Widget tweetButton() {
    return IconButton(
      icon: Icon(
        EvaIcons.twitter,
        color: app_consts.defaultTextColor,
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
        color: app_consts.defaultTextColor,
      ),
      onPressed: () async {
        await NewsArticleService.goToWebsite(widget.newsArticleId);
      },
    );
  }

  Widget sentimentResult() {
    return Chip(label: Text(_newsArticle.readableSentiment()));
  }

  Widget category() {
    var _newsGroupId = _newsArticle.newsGroupId;
    var _newsGroup = NewsGroupService.getNewsGroup(_newsGroupId);
    String categoryText = _newsGroup.category.name;
    return Chip(label: Text(categoryText));
  }

  Widget tag() {
    var _newsGroupId = _newsArticle.newsGroupId;
    var _newsGroup = NewsGroupService.getNewsGroup(_newsGroupId);
    var newsFromSourceNo = _newsGroup.sourceCounts[_newsArticle.newsSourceId];
    var tagText = "";
    if (_newsGroup.firstReporterId == _newsArticle.id) {
      tagText = "First Reporter";
    } else if (newsFromSourceNo != null && newsFromSourceNo > 1) {
      tagText = "Follow Up";
    } else if (_newsGroup.closeSecondId == _newsArticle.id) {
      tagText = "Close Second";
    } else if (_newsGroup.lateComerId == _newsArticle.id) {
      tagText = "Late Comer";
    } else {
      tagText = "Slow Poke";
    }

    return Chip(label: Text(tagText));
  }
}
