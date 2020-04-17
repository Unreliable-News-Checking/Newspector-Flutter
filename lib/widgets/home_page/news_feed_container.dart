import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_feed.dart';
import 'package:newspector_flutter/widgets/home_page/news_group_container.dart';

class NewsFeedContainer extends StatefulWidget {
  final NewsFeed newsFeed;
  final Function onRefresh;
  final Function onBottomReached;

  NewsFeedContainer({
    Key key,
    @required this.newsFeed,
    @required this.onRefresh,
    @required this.onBottomReached,
  }) : super(key: key);

  @override
  _NewsFeedContainerState createState() => _NewsFeedContainerState();
}

class _NewsFeedContainerState extends State<NewsFeedContainer> {
  ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        var loadNewData = !isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent;

        if (!loadNewData) return true;

        print('reached bottom');
        onBottomReached();

        return true;
      },
      child: CupertinoScrollbar(
        child: CustomScrollView(
          controller: _scrollController,
          physics:
              BouncingScrollPhysics().applyTo(AlwaysScrollableScrollPhysics()),
          slivers: <Widget>[
            refreshControl(),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Container(
                    margin: EdgeInsets.all(30),
                    alignment: Alignment.center,
                    child: NewsGroupContainer(
                      newsGroupId: widget.newsFeed.getNewsGroup(index).id,
                    ),
                  );
                },
                childCount: widget.newsFeed.getGroupCount(),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                color: Colors.transparent,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget refreshControl() {
    return CupertinoSliverRefreshControl(
      onRefresh: widget.onRefresh,
    );
  }

  void onBottomReached() async {
    setState(() {
      isLoading = true;
    });

    await widget.onBottomReached();

    setState(() {
      isLoading = false;
    });
  }
}
