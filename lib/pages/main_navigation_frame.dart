import 'dart:async';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newspector_flutter/pages/categories_page.dart';
import 'package:newspector_flutter/pages/news_sources_tabbed_page.dart';
import 'package:newspector_flutter/services/fcm_service.dart';
import 'package:flushbar/flushbar.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'package:newspector_flutter/pages/sign_page.dart';
import 'package:newspector_flutter/services/sign_in_service.dart'
    as sign_in_service;

import 'home_page.dart';
import 'news_group_page.dart';

class MainNavigationFrame extends StatefulWidget {
  @override
  _MainNavigationFrameState createState() => _MainNavigationFrameState();
}

class _MainNavigationFrameState extends State<MainNavigationFrame> {
  int currentIndex = 0;
  StreamController scrollStreamController;
  Stream scrollStream;

  final List<GlobalKey<NavigatorState>> tabNavigationKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<ScrollController> scrollControllers = [
    ScrollController(),
    ScrollController(),
    ScrollController(),
    ScrollController(),
  ];

  @override
  void initState() {
    super.initState();
    FCMService.configureFCM(
      onResume: (data) {
        var newsGroupId = data['news_group_id'];
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return NewsGroupPage(newsGroupId: newsGroupId);
        }));
      },
      onMessage: (data) {
        var newsGroupId = data['news_group_id'];
        var title = data['title'];
        var body = data['body'];
        Flushbar(
          flushbarStyle: FlushbarStyle.GROUNDED,
          flushbarPosition: FlushbarPosition.TOP,
          title: title,
          message: body,
          duration: Duration(seconds: 3),
          onTap: (a) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return NewsGroupPage(newsGroupId: newsGroupId);
            }));
          },
        ).show(context);
      },
    );

    scrollStreamController = StreamController.broadcast();
    scrollStream = scrollStreamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: CupertinoTabScaffold(
          backgroundColor: app_const.backgroundColor,
          tabBar: tabBar(),
          tabBuilder: tabBuilder,
        ),
      ),
    );
  }

  Widget tabBar() {
    return CupertinoTabBar(
      onTap: _onTapToNavBar,
      activeColor: app_const.activeColor,
      inactiveColor: app_const.inactiveColor,
      backgroundColor: app_const.backgroundColor,
      border: Border.all(
        color: app_const.backgroundColor,
        width: 0,
        style: BorderStyle.solid,
      ),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: currentIndex == 0
              ? Icon(EvaIcons.home)
              : Icon(EvaIcons.homeOutline),
          title: null,
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 1
              ? Icon(EvaIcons.grid)
              : Icon(EvaIcons.gridOutline),
          title: null,
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 2
              ? Icon(EvaIcons.bookOpen)
              : Icon(EvaIcons.bookOpenOutline),
          title: null,
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 3
              ? Icon(EvaIcons.search)
              : Icon(EvaIcons.searchOutline),
          title: null,
        ),
      ],
    );
  }

  Widget tabBuilder(BuildContext context, int index) {
    assert(index >= 0 && index <= 3);
    switch (index) {
      case 0:
        return WillPopScope(
          onWillPop: () => Future<bool>.value(false),
          child: CupertinoTabView(
            navigatorKey: tabNavigationKeys[index],
            builder: (BuildContext context) {
              return NewsFeedPage(
                scrollController: scrollControllers[index],
                feedType: FeedType.Home,
                title: "Breakpoint",
                actions: <Widget>[
                  CloseButton(
                    onPressed: () {
                      sign_in_service.signOutGoogle();
                      Navigator.of(context, rootNavigator: true)
                          .pushReplacement(
                              MaterialPageRoute(builder: (context) {
                        return SignPage();
                      }));
                    },
                  ),
                ],
              );
            },
            defaultTitle: 'Home',
          ),
        );
        break;
      case 1:
        return WillPopScope(
          onWillPop: () => Future<bool>.value(false),
          child: CupertinoTabView(
            navigatorKey: tabNavigationKeys[index],
            builder: (BuildContext context) {
              return CategoriesPage(
                getScrollStream: () => scrollStreamController.stream,
              );
            },
            defaultTitle: 'Categories',
          ),
        );
        break;
      case 2:
        return WillPopScope(
          onWillPop: () => Future<bool>.value(false),
          child: CupertinoTabView(
            navigatorKey: tabNavigationKeys[index],
            builder: (BuildContext context) {
              return NewsFeedPage(
                scrollController: scrollControllers[index],
                feedType: FeedType.Following,
                title: "Following",
              );
            },
            defaultTitle: 'Following',
          ),
        );
        break;
      case 3:
        return WillPopScope(
          onWillPop: () => Future<bool>.value(false),
          child: CupertinoTabView(
            navigatorKey: tabNavigationKeys[index],
            builder: (BuildContext context) {
              return NewsSourcesTabbedView(
                getScrollStream: () => scrollStreamController.stream,
              );
            },
            defaultTitle: 'Sources',
          ),
        );
        break;
    }
    return null;
  }

  /// Determines what to do when the current page is to be popped from the navigation frame.
  /// for example: back button pressed.
  ///
  /// If the inner navigator has a route on the [currentIndex], pop from the inner navigator.
  /// If the inner navigator has no route to pop other than it's first route, exit from the application.
  /// Whether inner navigator has a route to pop can be determined by calling [maybePop].
  Future<bool> _onWillPop() async {
    var popped = await tabNavigationKeys[currentIndex].currentState.maybePop();
    if (popped) return Future<bool>.value(!popped);

    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future<bool>.value(true);
  }

  /// Determines what to do when an item in the navigation bar is tapped.
  ///
  /// If the tapped [index] is not the same as the [currentIndex],
  /// simply changes the page to the [index]. However, if [index] is equal to [currentIndex]
  /// and the inner navigation has routes that can be popped,
  /// the inner navigator will be popped until the first element.
  /// If the inner navigator does not have any routes, scroll the page to the top.
  void _onTapToNavBar(int index) {
    if (index != currentIndex) {
      currentIndex = index;
      if (mounted) setState(() {});
      return;
    }

    var canPop = tabNavigationKeys[currentIndex].currentState.canPop();
    if (canPop) {
      tabNavigationKeys[currentIndex].currentState.popUntil((r) => r.isFirst);
      return;
    }

    if (scrollControllers[currentIndex].hasClients) {
      scrollControllers[currentIndex].animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
      return;
    }

    scrollStreamController.add("scroll_to_top");
  }
}
