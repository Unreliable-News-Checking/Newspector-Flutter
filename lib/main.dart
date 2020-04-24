import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/pages/main_navigation_frame.dart';
import 'package:newspector_flutter/pages/sign_page.dart';
import 'package:newspector_flutter/services/fcm_service.dart';
import 'package:newspector_flutter/services/sign_in_service.dart'
    as signInService;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

const MaterialColor white = const MaterialColor(
  0xFFFFFFFF,
  const <int, Color>{
    50: const Color(0xFFFFFFFF),
    100: const Color(0xFFFFFFFF),
    200: const Color(0xFFFFFFFF),
    300: const Color(0xFFFFFFFF),
    400: const Color(0xFFFFFFFF),
    500: const Color(0xFFFFFFFF),
    600: const Color(0xFFFFFFFF),
    700: const Color(0xFFFFFFFF),
    800: const Color(0xFFFFFFFF),
    900: const Color(0xFFFFFFFF),
  },
);

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
        primarySwatch: Colors.grey,
        accentColor: Colors.white,
        primaryTextTheme: TextTheme(),
        // scaffoldBackgroundColor: Colors.grey.shade200,
        // fontFamily: 'Noticia',
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
      appBar: AppBar(
        title: Text("Newspector"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlutterLogo(),
          ],
        ),
      ),
    );
  }
}
