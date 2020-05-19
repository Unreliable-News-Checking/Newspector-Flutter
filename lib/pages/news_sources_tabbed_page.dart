import 'package:flutter/material.dart';
import 'package:newspector_flutter/pages/news_sources_page.dart';
import 'package:newspector_flutter/pages/news_sources_statistics_page.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

class NewsSourcesTabbedView extends StatefulWidget {
  final Stream Function() getScrollStream;

  NewsSourcesTabbedView({
    Key key,
    @required this.getScrollStream,
  }) : super(key: key);

  @override
  _NewsSourcesTabbedViewState createState() => _NewsSourcesTabbedViewState();
}

class _NewsSourcesTabbedViewState extends State<NewsSourcesTabbedView> {
  var currentIndex = 0;
  final List<ScrollController> scrollControllers = [
    ScrollController(),
    ScrollController(),
  ];

  @override
  void initState() {
    super.initState();
    widget.getScrollStream().listen((event) {
      scrollControllers[getCurrentIndex()].animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  int getCurrentIndex() {
    return currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: app_const.backgroundColor,
          appBar: TabBar(
            indicatorColor: app_const.activeColor,
            onTap: (index) {
              currentIndex = index;
            },
            tabs: [
              Tab(icon: Text("Sources")),
              Tab(icon: Text("Statistics")),
            ],
          ),
          body: TabBarView(
            children: [
              NewsSourcesPage(
                key: PageStorageKey<String>('tab1'),
                scrollController: scrollControllers[0],
              ),
              NewsSourcesStatisticsPage(
                key: PageStorageKey<String>('tab2'),
                scrollController: scrollControllers[1],
              )
            ],
          ),
        ),
      ),
    );
  }
}
