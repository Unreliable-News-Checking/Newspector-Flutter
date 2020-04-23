import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/pages/news_article_page.dart';
import 'package:newspector_flutter/pages/news_group_page.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/home_page/home_page_news_article_container.dart';

import '../../application_constants.dart' as app_consts;

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
  NewsGroup _newsGroup;

  static const double topPadding = 0;
  static const double bottomPadding = 0;
  static const double textContainerSize = 154;
  Color backgroundColor = app_consts.newsArticleBackgroundColor;

  @override
  Widget build(BuildContext context) {
    _newsGroup = NewsGroupService.getNewsGroup(widget.newsGroupId);
    var itemCount = min(_newsGroup.getArticleCount(), maxNewsArticleCount);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            height: topPadding + bottomPadding + textContainerSize,
            child: PageView.custom(
              childrenDelegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index == itemCount) {
                    return seeMoreCard();
                  }
                  return _buildNewsGroupItem(context, index);
                },
                childCount: itemCount + 1,
              ),
              controller: _controller,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.all(5),
              child: DotsIndicator(
                controller: _controller,
                itemCount: itemCount,
                color: Colors.white,
                onPageSelected: (page) {
                  _controller.animateToPage(
                    page,
                    duration: _kDuration,
                    curve: _kCurve,
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: fullCoverageButton(context),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: followButton(),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: firstReporterTag(),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsGroupItem(BuildContext context, int index) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            // padding for the follow and leader
            height: topPadding,
          ),
          SizedBox(
            height: textContainerSize,
            child: HomePageNewsArticleContainer(
              newsArticleId: _newsGroup.getNewsArticleId(index),
              shorten: true,
              // backgroundColor: backgroundColor,
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return NewsArticlePage(
                    newsArticleId: _newsGroup.getNewsArticleId(index),
                  );
                }));
              },
            ),
          ),
          SizedBox(
            // padding for the full coverage and dot inditicator
            height: bottomPadding,
          ),
        ],
      ),
    );
  }

  Widget firstReporterTag() {
    return Container();
    // return Container(
    //   margin: EdgeInsets.symmetric(
    //       horizontal: pageViewItemHorizontalMargin + 5, vertical: 5),
    //   padding: EdgeInsets.all(5),
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(360),
    //     color: Colors.redAccent.shade400,
    //   ),
    //   child: Text(
    //     "BBC NEWS",
    //     style: TextStyle(
    //       fontSize: 10,
    //     ),
    //   ),
    // );
  }

  Widget fullCoverageButton(BuildContext context) {
    return Container(
      child: FlatButton(
        // color: Colors.white,
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
  }

  Widget followButton() {
    var icon = _newsGroup.followedByUser ? Icons.check : Icons.add;
    return Container(
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
        ),
        onPressed: () {
          NewsGroupService.toggleFollowNewsGroup(
              newsGroupId: _newsGroup.id, followed: _newsGroup.followedByUser);
          _newsGroup.followedByUser = !_newsGroup.followedByUser;

          if (mounted) setState(() {});
        },
      ),
    );
  }

  Widget seeMoreCard() {
    return GestureDetector(
      onTap: goToNewsGroupPage,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black87,
        ),
        margin: EdgeInsets.symmetric(horizontal: 5),
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

  void goToNewsGroupPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewsGroupPage(newsGroupId: _newsGroup.id);
    }));
  }
}

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.white,
  }) : super(listenable: controller);

  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageSelected;
  final Color color;

  static const double _dotSize = 4.0;
  static const double _maxDotZoom = 2.0;
  static const double _dotSpacing = 16.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );

    double zoom = 1.0 + (_maxDotZoom - 1.0) * selectedness;

    return Container(
      width: _dotSpacing,
      padding: EdgeInsets.all(2.5),
      child: Center(
        child: Material(
          color: color,
          type: MaterialType.circle,
          child: Container(
            width: _dotSize * zoom,
            height: _dotSize * zoom,
            child: InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        itemCount,
        _buildDot,
      ),
    );
  }
}
