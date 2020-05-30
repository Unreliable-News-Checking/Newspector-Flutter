import 'package:flutter/material.dart';

const int newsFeedPageSize = 7;
const int newsGroupPageSize = 6;
const int maxNewsArticleInNewsGroup = 5;
const Color backgroundColor = Color(0xFF263140);
const Color activeColor = Color(0xFF429AEC);
const Color inactiveColor = Color(0xFF9BA5AF);
const Color defaultTextColor = Color(0xFFF0F5F5);

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
