import 'package:newspector_flutter/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NavigationFrame(),
      routes: {
        // '/create_bet': (context) => CreateNewBetPage(),
      },
    );
  }
}

class NavigationFrame extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future<bool>.value(true),
      child: DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                title: null,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search),
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
                    return CupertinoPageScaffold(
                      backgroundColor: CupertinoColors.systemGroupedBackground,
                      child: Text("Search"),
                    );
                  },
                  defaultTitle: 'Search',
                );
                break;
              case 2:
                return CupertinoTabView(
                  builder: (BuildContext context) {
                    return CupertinoPageScaffold(
                      child: Text("Profile"),
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
