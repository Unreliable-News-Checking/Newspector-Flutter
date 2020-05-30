import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

Widget defaultSliverAppBar({
  @required String titleText,
  List<Widget> actions,
  Widget leading,
}) {
  return SliverAppBar(
    title: Text(
      titleText,
      style: TextStyle(
        color: app_const.defaultTextColor,
      ),
    ),
    centerTitle: true,
    floating: true,
    pinned: false,
    snap: false,
    elevation: 0,
    backgroundColor: app_const.backgroundColor,
    actions: actions,
    leading: leading,
  );
}

Widget defaultRefreshControl({
  @required Function onRefresh,
}) {
  return Theme(
    data: ThemeData(
      brightness: Brightness.dark,
      cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.dark),
    ),
    child: CupertinoSliverRefreshControl(
      onRefresh: onRefresh,
    ),
  );
}
