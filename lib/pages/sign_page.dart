import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newspector_flutter/pages/main_navigation_frame.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/services/sign_in_service.dart'
    as sign_in_service;
import 'package:newspector_flutter/utilities.dart';

class SignPage extends StatefulWidget {
  @override
  _SignPageState createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_const.backgroundColor,
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150,
                height: 150,
                // color: Colors.white,
                child: Image.asset(
                  "assets/newspector_logo.png",
                  color: app_const.defaultTextColor,
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Welcome to",
                style: TextStyle(fontSize: 15),
              ),
              Container(
                child: Text(
                  "Newspector",
                  style: GoogleFonts.raleway(fontSize: 45),
                ),
              ),
              SizedBox(height: 30),
              GoogleSignInButton(onPressed: signIn),
              // RaisedButton(
              //   onPressed: debugSignIn,
              //   child: Text("Debug Sign In"),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signIn() async {
    await sign_in_service.signInWithGoogle();
    clearStoresAndServices();
    Navigator.of(context, rootNavigator: true)
        .pushReplacement(MaterialPageRoute(builder: (context) {
      return MainNavigationFrame();
    }));
  }

  Future<void> debugSignIn() async {
    await sign_in_service.debugSignIn();
    clearStoresAndServices();
    Navigator.of(context, rootNavigator: true)
        .pushReplacement(MaterialPageRoute(builder: (context) {
      return MainNavigationFrame();
    }));
  }
}

class GoogleSignInButton extends StatelessWidget {
  final Function onPressed;

  const GoogleSignInButton({Key key, @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      color: app_const.defaultTextColor,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      highlightElevation: 0,
      borderSide: BorderSide(
        color: app_const.defaultTextColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage("assets/google_logo.png"),
              height: 35.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: app_const.defaultTextColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
