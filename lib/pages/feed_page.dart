import 'package:flutter/material.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

abstract class FeedPage {
  getFeed();
  fetchAdditionalItems();
  sliverAppBar();
  loadingScaffold();
  homeScaffold();
}

Widget defaultSliverAppBar({
  @required String titleText,
  List<Widget> actions,
}) {
  return SliverAppBar(
    title: Text(
      titleText,
      style: TextStyle(color: Colors.white),
    ),
    centerTitle: true,
    floating: true,
    pinned: false,
    snap: false,
    elevation: 0,
    backgroundColor: app_const.backgroundColor,
    actions: actions,
  );
}
