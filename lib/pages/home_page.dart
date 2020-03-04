import 'package:newspector_flutter/pages/create_new_bet_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Home Page"),
      ),
      appBar: AppBar(
        leading: FlatButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context, rootNavigator: true)
                .push(createRoute(CreateNewBetPage()));
          },
        ),
      ),
    );
  }

  Route createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

class NewsGroup extends StatefulWidget {
  @override
  _NewsGroupState createState() => _NewsGroupState();
}

class _NewsGroupState extends State<NewsGroup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}
