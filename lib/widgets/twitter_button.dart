import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/pages/web_view_page.dart';

class TwitterButton extends StatelessWidget {
  final String tweetLink;

  const TwitterButton({Key key, @required this.tweetLink}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        EvaIcons.twitter,
        color: app_const.defaultTextColor,
      ),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) {
          return WebViewPage(
            initialUrl: tweetLink,
          );
        }));
      },
    );
  }
}
