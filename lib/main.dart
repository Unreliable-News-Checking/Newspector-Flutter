import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newspector_flutter/pages/main_navigation_frame.dart';
import 'package:newspector_flutter/pages/sign_page.dart';
import 'package:newspector_flutter/services/fcm_service.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/services/sign_in_service.dart'
    as signInService;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FCMService.requestNotificationPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Newspector',
      theme: ThemeData(
        primaryColor: app_const.backgroundColor,
        textTheme: GoogleFonts.ralewayTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: app_const.defaultTextColor,
                displayColor: app_const.defaultTextColor,
              ),
        ),
        accentColor: app_const.inactiveColor,
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
      backgroundColor: app_const.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Newspector"),
          ],
        ),
      ),
    );
  }
}
