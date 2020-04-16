import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/pages/main_navigation_frame.dart';
import 'package:newspector_flutter/pages/sign_page.dart';
import 'package:newspector_flutter/services/sign_in_service.dart'
    as signInService;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Newspector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: showHome(),
      routes: {},
    );
  }

  Widget showHome() {
    return FutureBuilder(
      future: signInService.hasSignedInUser(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            var hasSignedInUser = snapshot.data;
            if (hasSignedInUser) {
              return MainNavigationFrame();
            }
            return SignPage();
            break;
          default:
            return loadPage();
        }
      },
    );
  }

  Widget loadPage() {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            FlutterLogo(),
          ],
        ),
      ),
    );
  }
}
