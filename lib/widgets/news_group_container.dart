import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/pages/news_article_page.dart';
import 'package:newspector_flutter/pages/news_group_page.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/dots_indicator.dart';
import 'package:newspector_flutter/widgets/home_page/hp_news_article_container.dart';
import 'package:animations/animations.dart';
import 'package:newspector_flutter/application_constants.dart' as app_consts;

class NewsGroupContainer extends StatefulWidget {
  final String newsGroupId;

  NewsGroupContainer({Key key, @required this.newsGroupId}) : super(key: key);

  @override
  _NewsGroupContainerState createState() => _NewsGroupContainerState();
}

class _NewsGroupContainerState extends State<NewsGroupContainer> {
  final _controller = PageController();
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;
  static const int maxNewsArticleCount = app_consts.maxNewsArticleInNewsGroup;
  static const double containerSize = 230;
  static const double borderRadius = 10.0;
  static const double horizontalMargin = 20.0;
  Color backgroundColor = app_consts.newsArticleBackgroundColor;
  NewsGroup _newsGroup;

  @override
  Widget build(BuildContext context) {
    _newsGroup = NewsGroupService.getNewsGroup(widget.newsGroupId);
    var itemCount = min(_newsGroup.getArticleCount(), maxNewsArticleCount);

    List<Widget> listViewItems = [];
    for (var i = 0; i < itemCount; i++) {
      var listViewItem = _buildNewsGroupItem(context, i);
      listViewItems.add(listViewItem);
    }

    if (itemCount > 1) {
      listViewItems.add(seeMoreCard());
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            height: containerSize,
            child: PageView(
              children: listViewItems,
              controller: _controller,
            ),
          ),
          dotsIndicator(itemCount),
          fullCoverageButton(itemCount),
          followButton(),
          firstReporterTag(),
          categoryLabel(),
        ],
      ),
    );
  }

  Widget _buildNewsGroupItem(BuildContext context, int index) {
    return Container(
      child: SizedBox(
        height: containerSize,
        child: HomePageNewsArticleContainer(
          borderRadius: borderRadius,
          horizontalMargin: horizontalMargin,
          height: containerSize,
          newsArticleId: _newsGroup.getNewsArticleId(index),
          shorten: true,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return NewsArticlePage(
                newsArticleId: _newsGroup.getNewsArticleId(index),
              );
            }));
          },
        ),
      ),
    );
  }

  Widget firstReporterTag() {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(),
    );
  }

  Widget fullCoverageButton(int itemCount) {
    Widget button = Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: FlatButton(
        onPressed: goToNewsGroupPage,
        child: Text(
          "Full Coverage",
          style: TextStyle(
            color: Colors.white,
            shadows: app_consts.shadowsForWhiteWidgets(),
          ),
        ),
      ),
    );

    if (itemCount == 1) {
      button = Container();
    }

    return Positioned(
      bottom: 0,
      right: 0,
      child: button,
    );
  }

  Widget followButton() {
    var icon = _newsGroup.followedByUser ? Icons.check : Icons.add;

    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: IconButton(
          icon: Icon(
            icon,
            color: Colors.white,
          ),
          onPressed: () {
            NewsGroupService.toggleFollowNewsGroup(
              newsGroupId: _newsGroup.id,
              followed: _newsGroup.followedByUser,
            );
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  Widget seeMoreCard() {
    return GestureDetector(
      onTap: goToNewsGroupPage,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.black87,
        ),
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        child: Center(
          child: Text(
            "Tap to see Full Coverage",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget dotsIndicator(int itemCount) {
    var dots = Container(
      margin: EdgeInsets.all(5),
      child: DotsIndicator(
        controller: _controller,
        itemCount: itemCount + 1,
        color: Colors.white,
        onPageSelected: (page) {
          _controller.animateToPage(
            page,
            duration: _kDuration,
            curve: _kCurve,
          );
        },
      ),
    );

    if (itemCount == 1) {
      dots = Container();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: dots,
    );
  }

  Widget categoryLabel() {
    var categoryText =
        _newsGroup.category != "-" ? _newsGroup.category : "Processing";
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontalMargin + 10,
          vertical: 10,
        ),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(360),
        ),
        child: Text(
          categoryText,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void goToNewsGroupPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewsGroupPage(newsGroupId: _newsGroup.id);
    }));
  }
}
