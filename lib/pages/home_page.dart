import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_feed.dart';
import 'package:newspector_flutter/pages/news_group_page.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';

import 'news_article_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NewsFeed newsFeed;
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    //

    if (NewsFeedService.hasFeed()) {
      newsFeed = NewsFeedService.getNewsFeed();
      return homeScaffold();
    }

    return FutureBuilder(
      future: NewsFeedService.updateAndGetNewsFeed(
        pageSize: 10,
        lastTimeStamp: "",
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            newsFeed = snapshot.data;
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
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget homeScaffold() {
    return Scaffold(
      body: CupertinoScrollbar(
        child: CustomScrollView(
          controller: _scrollController,
          physics:
              BouncingScrollPhysics().applyTo(AlwaysScrollableScrollPhysics()),
          slivers: <Widget>[
            SliverAppBar(),
            refreshControl(),
            SliverPadding(
              padding: MediaQuery.of(context)
                  .removePadding(
                    removeTop: true,
                  )
                  .padding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    margin: EdgeInsets.all(30),
                    alignment: Alignment.center,
                    child: Text("NO POSTS"),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget refreshControl() {
    return CupertinoSliverRefreshControl(
      onRefresh: () {
        return getRefreshedFeed();
      },
    );
  }

  // this fetches an updated user async
  // called when user tries to refresh the page
  Future<void> getRefreshedFeed() async {
    newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: 10,
      lastTimeStamp: DateTime.now(),
    );
    if (mounted) {
      setState(() {});
    }
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
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: 5,
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
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return NewsGroupPage();
                      }));
                    },
                    child: Text("Full Coverage"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsGroupItem(BuildContext context, int itemIndex) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          // return NewsGroupPage();
          return NewsArticlePage();
        }));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
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
