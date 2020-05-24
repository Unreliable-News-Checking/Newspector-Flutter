import 'package:flutter/material.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/pages/web_view_page.dart';

class WebsiteButton extends StatelessWidget {
  final String websiteLink;

  const WebsiteButton({Key key, @required this.websiteLink}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.web,
        color: app_const.defaultTextColor,
      ),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) {
          return WebViewPage(
            initialUrl: websiteLink,
          );
        }));
      },
    );
  }
}
