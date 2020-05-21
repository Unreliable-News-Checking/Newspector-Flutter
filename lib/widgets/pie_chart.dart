import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_circular_text/circular_text.dart';

class PieChartContainer extends StatefulWidget {
  final String title;
  final List<CircularStackEntry> data;
  final int count;

  const PieChartContainer(
      {Key key,
      @required this.title,
      @required this.data,
      @required this.count})
      : super(key: key);

  @override
  _PieChartContainerState createState() => _PieChartContainerState();
}

class _PieChartContainerState extends State<PieChartContainer>
    with TickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: Duration(seconds: 1), upperBound: pi * 0.3);
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.elasticIn,
    );

    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    List<CircularSegmentEntry> dataToDisplay = List<CircularSegmentEntry>();
    var entries = widget.data[0].entries;
    var count = widget.count;

    if (entries.length > count) {
      int otherTotal = 0;
      for (int i = 0; i < entries.length; i++) {
        if (i > count) {
          otherTotal += entries.elementAt(i).value.toInt();
        }
      }
      dataToDisplay = entries.sublist(0, count + 1);

      CircularSegmentEntry otherSegment = CircularSegmentEntry(
        otherTotal.toDouble(),
        Colors.grey,
        rankKey: "Other",
      );

      dataToDisplay.add(otherSegment);
    } else {
      dataToDisplay = entries;
    }

    List<CircularStackEntry> stackEntry = <CircularStackEntry>[
      new CircularStackEntry(
        dataToDisplay,
      ),
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        children: <Widget>[
          header(widget.title),
          pieChart(stackEntry),
          legend(context, stackEntry),
        ],
      ),
    );
  }

  Widget header(String title) {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
        child: title == ""
            ? null
            : Text(
                title,
                style: GoogleFonts.rubik(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ));
  }

  Widget pieChart(List<CircularStackEntry> data) {
    final GlobalKey<AnimatedCircularChartState> _chartKey =
        new GlobalKey<AnimatedCircularChartState>();

    double total = 0;

    for (var entry in data[0].entries) {
      total += entry.value.toInt();
    }

    return Stack(children: [
      holeLabel(total.toInt().toString()),
      RotationTransition(
          turns: Tween(begin: 0.0, end: 0.1).animate(animationController),
          child: Stack(
            children: [
              Center(child: circularLabels(data, total)),
              Center(
                  child: AnimatedCircularChart(
                key: _chartKey,
                size: const Size(300.0, 300.0),
                initialChartData: data,
                chartType: CircularChartType.Radial,
                edgeStyle: SegmentEdgeStyle.round,
              ))
            ],
          ))
    ]);
  }

  Widget holeLabel(String label) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        height: 300,
        width: 300,
        child: Text(
          label,
          style: new TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 60.0,
          ),
        ),
      ),
    );
  }

  Widget circularLabels(List<CircularStackEntry> data, double total) {
    List<double> startAngles = List<double>();
    List<int> percentages = List<int>();
    double lastAngle = -90;
    int leftPercentage = 100;
    int percentage = 0;

    for (int i = 0; i < data[0].entries.length; i++) {
      double occupiedAngle = (data[0].entries.elementAt(i).value / total) * 360;
      startAngles.add(lastAngle + occupiedAngle / 2);
      lastAngle += occupiedAngle;

      if (i == data[0].entries.length - 1) {
        percentages.add(leftPercentage);
      } else {
        percentage =
            ((data[0].entries.elementAt(i).value / total) * 100).round();
        percentages.add(percentage);
      }

      leftPercentage -= percentage;
    }

    int index = 0;
    return CircularText(
      children: [
        for (int i = 0; i < data[0].entries.length; i++)
          TextItem(
            space: 5,
            text: Text(
              percentages[i].toString() + "%",
              style: TextStyle(
                fontSize: 20,
                color: data[0].entries.elementAt(i).color,
                fontWeight: FontWeight.bold,
              ),
            ),
            startAngle: startAngles[index++],
            startAngleAlignment: StartAngleAlignment.center,
            direction: CircularTextDirection.clockwise,
          )
      ],
      radius: 150,
      position: CircularTextPosition.inside,
    );
  }

  Widget legend(BuildContext context, List<CircularStackEntry> data) {
    return Container(
        margin: EdgeInsets.all(10),
        child: Center(
            child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / 20),
          shrinkWrap: true,
          primary: false,
          padding: const EdgeInsets.fromLTRB(60, 0, 0, 0),
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          crossAxisCount: 2,
          children: <Widget>[
            for (var category in data[0].entries)
              legendItem(category.rankKey, category.color)
          ],
        )));
  }

  Widget legendItem(String text, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0),
      child: Row(
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }
}
