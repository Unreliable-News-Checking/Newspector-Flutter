import 'dart:math';

import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_group.dart';
import 'package:newspector_flutter/pages/news_article_page.dart';
import 'package:newspector_flutter/pages/news_group_page.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/home_page/news_article_container.dart'
    as nac;

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
  NewsGroup _newsGroup;

  @override
  Widget build(BuildContext context) {
    _newsGroup = NewsGroupService.getNewsGroup(widget.newsGroupId);

    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: _newsGroup.getArticleCount(),
                  controller: _controller,
                  itemBuilder: (BuildContext context, int itemIndex) {
                    return _buildNewsGroupItem(context, itemIndex);
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: DotsIndicator(
                  controller: _controller,
                  itemCount: _newsGroup.getArticleCount(),
                  color: Colors.blue,
                  onPageSelected: (page) {
                    _controller.animateToPage(
                      page,
                      duration: _kDuration,
                      curve: _kCurve,
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  child: fullCoverageButton(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsGroupItem(BuildContext context, int index) {
    return nac.NewsArticleContainer(
      newsArticleId: _newsGroup.getNewsArticleId(index),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return NewsArticlePage(
            newsArticleId: _newsGroup.getNewsArticleId(index),
          );
        }));
      },
    );
  }

  Widget fullCoverageButton(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return NewsGroupPage(newsGroupId: _newsGroup.id);
        }));
      },
      child: Text("Full Coverage"),
    );
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
