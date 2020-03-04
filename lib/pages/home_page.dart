import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: NewsFeedContainer(),
      ),
      appBar: AppBar(
        leading: FlatButton(
          child: Icon(Icons.add),
          onPressed: () {
            // Navigator.of(context, rootNavigator: true)
            // .push(createRoute(CreateNewBetPage()));
          },
        ),
      ),
    );
  }
}

class NewsFeedContainer extends StatefulWidget {
  @override
  _NewsFeedContainerState createState() => _NewsFeedContainerState();
}

class _NewsFeedContainerState extends State<NewsFeedContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, itemIndex) {
          return _buildNewsFeedItem(context, itemIndex);
        },
      ),
    );
  }

  Widget _buildNewsFeedItem(BuildContext context, int itemIndex) {
    return Container(
      child: NewsGroupContainer(),
    );
  }
}

class NewsGroupContainer extends StatefulWidget {
  @override
  _NewsGroupContainerState createState() => _NewsGroupContainerState();
}

class _NewsGroupContainerState extends State<NewsGroupContainer> {
  final _controller = PageController();
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Stack(
        children: <Widget>[
          SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: 5,
              controller: _controller,
              itemBuilder: (BuildContext context, int itemIndex) {
                return _buildCarouselItem(context, itemIndex);
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DotsIndicator(
              controller: _controller,
              itemCount: 5,
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
        ],
      ),
    );
  }

  Widget _buildCarouselItem(BuildContext context, int itemIndex) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
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

  static const double _dotSize = 6.0;
  static const double _maxDotZoom = 2.0;
  static const double _dotSpacing = 25.0;

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
