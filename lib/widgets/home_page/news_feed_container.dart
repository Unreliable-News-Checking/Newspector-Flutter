import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_feed.dart';
import 'package:newspector_flutter/widgets/home_page/news_group_container.dart';

class NewsFeedContainer extends StatefulWidget {
  final NewsFeed newsFeed;

  NewsFeedContainer({Key key, @required this.newsFeed}) : super(key: key);

  @override
  _NewsFeedContainerState createState() => _NewsFeedContainerState();
}

class _NewsFeedContainerState extends State<NewsFeedContainer> {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
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
                newsGroupID: widget.newsFeed.getNewsGroup(index).id,
              ),
            );
          },
          childCount: widget.newsFeed.getGroupCount(),
        ),
      ),
    );
  }
}
