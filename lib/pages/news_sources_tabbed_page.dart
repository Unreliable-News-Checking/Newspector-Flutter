import 'package:flutter/material.dart';
import 'package:newspector_flutter/pages/news_sources_page.dart';
import 'package:newspector_flutter/pages/news_sources_statistics_page.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

class NewsSourcesTabbedView extends StatefulWidget {
  final ScrollController scrollController;

  NewsSourcesTabbedView({
    Key key,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _NewsSourcesTabbedViewState createState() => _NewsSourcesTabbedViewState();
}

class _NewsSourcesTabbedViewState extends State<NewsSourcesTabbedView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: app_const.backgroundColor,
          appBar: TabBar(
            tabs: [
              Tab(
                icon: Text("Sources"),
              ),
              Tab(
                icon: Text("Statistics"),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              NewsSourcesPage(
                key: PageStorageKey<String>('tab1'),
                scrollController: ScrollController(),
              ),
              NewsSourcesStatisticsPage(
                key: PageStorageKey<String>('tab2'),
                scrollController: ScrollController(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
