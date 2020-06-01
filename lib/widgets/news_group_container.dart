import 'dart:math';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/pages/news_group_page.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/dots_indicator.dart';
import 'package:newspector_flutter/widgets/home_page/hp_news_article_container.dart';
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
  static const double containerSize = 240;
  static const double borderRadius = 0.0;
  static const double horizontalMargin = 0.0;
  NewsGroup _newsGroup;

  @override
  Widget build(BuildContext context) {
    _newsGroup = NewsGroupService.getNewsGroup(widget.newsGroupId);
    var itemCount = min(_newsGroup.getArticleCount(), maxNewsArticleCount);

    List<Widget> listViewItems = [];
    for (var i = 0; i < itemCount; i++) {
      var listViewItem = _buildNewsGroupItem(context, i, itemCount == 1);
      listViewItems.add(listViewItem);
    }

    if (itemCount > 1) {
      listViewItems.add(seeMoreCard());
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.hardEdge,
            child: Container(
              height: containerSize,
              child: PageView(
                children: listViewItems,
                controller: _controller,
                pageSnapping: true,
              ),
            ),
          ),
          dotsIndicator(itemCount),
          fullCoverageButton(itemCount),
          followButton(),
          categoryLabel(),
        ],
      ),
    );
  }

  Widget _buildNewsGroupItem(BuildContext context, int index, bool alone) {
    return Container(
      child: SizedBox(
        height: containerSize,
        child: HomePageNewsArticleContainer(
          borderRadius: borderRadius,
          horizontalMargin: horizontalMargin,
          height: containerSize,
          newsArticleId: _newsGroup.getNewsArticleId(index),
          shorten: true,
          alone: alone,
        ),
      ),
    );
  }

  Widget fullCoverageButton(int itemCount) {
    Widget button = Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: FlatButton(
        onPressed: goToNewsGroupPage,
        child: Text(
          "Full Coverage",
          style: TextStyle(
            color: app_consts.defaultTextColor,
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
    var icon = _newsGroup.followedByUser
        ? EvaIcons.bookmark
        : EvaIcons.bookmarkOutline;

    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 5),
        child: IconButton(
          icon: Icon(
            icon,
            color: app_consts.defaultTextColor,
            size: 28,
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
      behavior: HitTestBehavior.opaque,
      onTap: goToNewsGroupPage,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Color(0xFF3484F0),
        ),
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        child: Center(
          child: Text(
            "Tap to see Full Coverage",
            style: TextStyle(
              fontSize: 16,
              color: app_consts.defaultTextColor,
              fontWeight: FontWeight.bold,
              shadows: app_consts.shadowsForWhiteWidgets(),
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
    String categoryText = _newsGroup.category.name;

    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontalMargin + 10,
          vertical: 10,
        ),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: app_consts.backgroundColor,
          borderRadius: BorderRadius.circular(360),
        ),
        child: Text(
          categoryText,
          style: TextStyle(
            fontSize: 12,
            color: app_consts.defaultTextColor,
            shadows: app_consts.shadowsForWhiteWidgets(),
          ),
        ),
      ),
    );
  }

  void goToNewsGroupPage() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return NewsGroupPage(newsGroupId: _newsGroup.id);
      },
    ));
  }
}
