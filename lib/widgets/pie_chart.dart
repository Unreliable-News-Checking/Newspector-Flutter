import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_circular_text/circular_text.dart';

class PieContainer extends StatelessWidget {
  final String title;
  final List<CircularStackEntry> data;
  final List<Color> colors;

  const PieContainer(
      {Key key,
      @required this.title,
      @required this.data,
      @required this.colors})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: title == "" ? null :Text(
                title,
                style: GoogleFonts.rubik(
                    fontWeight: FontWeight.bold, fontSize: 18),
              )),
          PieChartView(data: data),
          Container(
            margin: EdgeInsets.all(10),
            child: Legend(data: data),
          )
        ],
      ),
    );
  }
}

class PieChartView extends StatelessWidget {
  final List<CircularStackEntry> data;

  PieChartView({Key key, @required this.data}) : super(key: key);

  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();

  @override
  Widget build(BuildContext context) {
    double total = 0;

    for (var entry in data[0].entries) {
      total += entry.value.toInt();
    }

    return Stack(
      children: [
        Center(child: CircularLabels(data: data, total: total)),
        Center(
            child: AnimatedCircularChart(
          key: _chartKey,
          size: const Size(300.0, 300.0),
          initialChartData: data,
          chartType: CircularChartType.Radial,
          holeLabel: total.toInt().toString(),
          edgeStyle: SegmentEdgeStyle.round,
          percentageValues: false,
          labelStyle: new TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 50.0,
          ),
        ))
      ],
    );
  }
}

class CircularLabels extends StatelessWidget {
  final List<CircularStackEntry> data;
  final double total;
  const CircularLabels({Key key, @required this.data, @required this.total})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<double> startAngles = List<double>();
    double lastAngle = -90;

    for (var entry in data[0].entries) {
      double occupiedAngle = (entry.value / total) * 360;
      startAngles.add(lastAngle + occupiedAngle / 2);
      lastAngle += occupiedAngle;
    }

    int index = 0;
    return CircularText(
      children: [
        for (var entry in data[0].entries)
          TextItem(
            text: Text(
              entry.value.toInt().toString(),
              style: TextStyle(
                fontSize: 20,
                color: entry.color,
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
}

class Legend extends StatelessWidget {
  final List<CircularStackEntry> data;
  const Legend({Key key, @required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: GridView.count(
      childAspectRatio: MediaQuery.of(context).size.width /
          (MediaQuery.of(context).size.height / 10),
      shrinkWrap: true,
      primary: false,
      padding: const EdgeInsets.fromLTRB(40, 0, 20, 0),
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      crossAxisCount: 2,
      children: <Widget>[
        for (var category in data[0].entries)
          LegendItem(text: category.rankKey, color: category.color)
      ],
    ));
  }
}

class LegendItem extends StatelessWidget {
  final String text;
  final Color color;

  const LegendItem({Key key, @required this.text, @required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          SizedBox(width: 20),
          Text(text),
        ],
      ),
    );
  }
}
