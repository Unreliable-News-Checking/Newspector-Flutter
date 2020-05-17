import 'package:flutter/material.dart';

const int homePagePageSize = 8;
const int followingPagePageSize = 8;
const int newsGroupPageSize = 10;
const int maxNewsArticleInNewsGroup = 5;
Color backgroundColor = Color(0xFF263140);
Color selectedColor = Color(0xFF429AEC);
Color defaultTextColor = Color(0xFF9BA5AF);

List<BoxShadow> shadowsForWhiteWidgets() {
  return <BoxShadow>[
    BoxShadow(
      offset: Offset(2.0, 2.0),
      blurRadius: 4.0,
      color: Colors.black87,
    ),
    BoxShadow(
      offset: Offset(-0.25, -0.25),
      blurRadius: 3.0,
      color: Colors.black38,
    ),
  ];
}
