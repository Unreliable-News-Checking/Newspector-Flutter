import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/pages/news_sources_page.dart';

import 'following_page.dart';
import 'home_page.dart';

class MainNavigationFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future<bool>.value(true),
      child: DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: CupertinoTabScaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          tabBar: CupertinoTabBar(
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                title: null,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inbox),
                title: null,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.profile_circled),
                title: null,
              ),
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            assert(index >= 0 && index <= 2);
            switch (index) {
              case 0:
                return CupertinoTabView(
                  builder: (BuildContext context) {
                    return HomePage();
                  },
                  defaultTitle: 'Home',
                );
                break;
              case 1:
                return CupertinoTabView(
                  builder: (BuildContext context) {
                    return FollowingPage();
                  },
                  defaultTitle: 'Followed',
                );
                break;
              case 2:
                return CupertinoTabView(
                  builder: (BuildContext context) {
                    return CupertinoPageScaffold(
                      // child: ProfilePage(),
                      child: NewsSourcesPage(),
                    );
                  },
                  defaultTitle: 'Profile',
                );
                break;
            }
            return null;
          },
        ),
      ),
    );
  }
}
