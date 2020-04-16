import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_feed.dart';
import 'package:newspector_flutter/widgets/home_page/news_group_container.dart';

class NewsFeedContainer extends StatefulWidget {
  final NewsFeed newsFeed;
  final Function onRefresh;

  NewsFeedContainer({Key key, @required this.newsFeed, @required this.onRefresh}) : super(key: key);

  @override
  _NewsFeedContainerState createState() => _NewsFeedContainerState();
}

class _NewsFeedContainerState extends State<NewsFeedContainer> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      child: CustomScrollView(
        controller: _scrollController,
        physics:
            BouncingScrollPhysics().applyTo(AlwaysScrollableScrollPhysics()),
        slivers: <Widget>[
          // SliverAppBar(),
          refreshControl(),
          SliverPadding(
            padding: MediaQuery.of(context)
                .removePadding(
                  removeTop: true,
                )
                .padding,
            sliver: SliverList(
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
          ),
        ],
      ),
    );
  }

  Widget refreshControl() {
    return CupertinoSliverRefreshControl(
      onRefresh: () {
        return widget.onRefresh();
      },
    );
  }
}
