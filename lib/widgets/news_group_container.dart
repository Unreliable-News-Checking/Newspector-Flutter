import 'dart:math';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/pages/news_group_page.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/home_page/hp_news_article_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_consts;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:transformer_page_view/transformer_page_view.dart';
import 'page_transformer.dart';

class NewsGroupContainer extends StatefulWidget {
  final String newsGroupId;

  NewsGroupContainer({Key key, @required this.newsGroupId}) : super(key: key);

  @override
  _NewsGroupContainerState createState() => _NewsGroupContainerState();
}

class _NewsGroupContainerState extends State<NewsGroupContainer> {
  final _controller = PageController();
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
          pageView(listViewItems),
          dotsIndicator(itemCount),
          fullCoverageButton(itemCount),
          followButton(),
          categoryLabel(),
        ],
      ),
    );
  }

  Widget pageView(List<Widget> listViewItems) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.hardEdge,
      child: Container(
        height: containerSize,
        child: PageTransformer(
          pageViewBuilder: (context, pageVisibilityResolver) {
            return PageView.builder(
              controller: _controller,
              itemCount: listViewItems.length,
              itemBuilder: (context, index) {
                final pageVisibility =
                    pageVisibilityResolver.resolvePageVisibility(index);

                // Use these two properties to transform your "Hello World" text widget!
                // In this example, the text widget fades in and out of view, since we use
                // the visibleFraction property, which can be between 0.0 - 1.0.
                // final position = pageVisibility.pagePosition;
                final visibleFraction = pageVisibility.visibleFraction;

                return Opacity(
                  opacity: visibleFraction,
                  child: listViewItems[index],
                );
              },
            );
          },
        ),
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
          color: app_consts.activeColor,//Color(0xFF3484F0),
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
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.all(5),
      child: SmoothPageIndicator(
        controller: _controller, // PageController
        count: itemCount + 1,
        effect: ExpandingDotsEffect(
          activeDotColor: app_consts.activeColor,
          dotColor: app_consts.defaultTextColor,
          dotWidth: 5,
          dotHeight: 5,
        ),
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
