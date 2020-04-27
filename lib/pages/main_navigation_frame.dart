import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/pages/news_sources_page.dart';
import 'package:newspector_flutter/services/fcm_service.dart';
import 'package:flushbar/flushbar.dart';

import 'following_page.dart';
import 'home_page.dart';
import 'news_group_page.dart';

class MainNavigationFrame extends StatefulWidget {
  @override
  _MainNavigationFrameState createState() => _MainNavigationFrameState();
}

class _MainNavigationFrameState extends State<MainNavigationFrame> {
  int currentIndex = 0;

  final List<GlobalKey<NavigatorState>> tabNavigationKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future<bool>.value(true),
      child: DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: CupertinoTabScaffold(
          backgroundColor: Colors.white,
          tabBar: tabBar(),
          tabBuilder: tabBuilder,
        ),
      ),
    );
  }

  Widget tabBar() {
    return CupertinoTabBar(
      onTap: (int index) {
        if (index == currentIndex) {
          tabNavigationKeys[index].currentState.popUntil((r) => r.isFirst);
        }

        currentIndex = index;
        if (mounted) setState(() {});
      },
      activeColor: Colors.blue,
      inactiveColor: Colors.grey,
      backgroundColor: Colors.white,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          title: null,
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.bookmark),
          title: null,
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.search),
          title: null,
        ),
      ],
    );
  }

  Widget tabBuilder(BuildContext context, int index) {
    assert(index >= 0 && index <= 2);
    switch (index) {
      case 0:
        return CupertinoTabView(
          navigatorKey: tabNavigationKeys[0],
          builder: (BuildContext context) {
            return HomePage();
          },
          defaultTitle: 'Home',
        );
        break;
      case 1:
        return CupertinoTabView(
          navigatorKey: tabNavigationKeys[1],
          builder: (BuildContext context) {
            return FollowingPage();
          },
          defaultTitle: 'Followed',
        );
        break;
      case 2:
        return CupertinoTabView(
          navigatorKey: tabNavigationKeys[2],
          builder: (BuildContext context) {
            return CupertinoPageScaffold(
              child: NewsSourcesPage(),
            );
          },
          defaultTitle: 'Sources',
        );
        break;
    }
    return null;
  }
}
