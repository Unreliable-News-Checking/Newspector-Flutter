import 'package:flutter/material.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

class StatsRow extends StatelessWidget {
  final Widget icon;
  final String label;

  const StatsRow({Key key, @required this.icon, @required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            child: FittedBox(
              child: icon,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10)
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: app_const.shadowsForWhiteWidgets(),
            ),
          ),
        ],
      ),
    );
  }
}
