import 'package:flutter/material.dart';
import 'package:newspector_flutter/pages/sign_page.dart';
import 'package:newspector_flutter/services/sign_in_service.dart'
    as sign_in_service;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: <Widget>[
          CloseButton(
            onPressed: () {
              sign_in_service.signOutGoogle();
              Navigator.of(context, rootNavigator: true)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                return SignPage();
              }));
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text("Profile Page"),
            ),
          ],
        ),
      ),
    );
  }
}
