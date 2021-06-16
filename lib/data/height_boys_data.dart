import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeightBoysData extends StatefulWidget {
  final String babyName;
  final Timestamp age;
  HeightBoysData({this.babyName, this.age});

  @override
  _HeightBoysDataState createState() => _HeightBoysDataState();
}

class _HeightBoysDataState extends State<HeightBoysData> {
  GlobalKey keyHeight;
  Uint8List bytes;
  int currentUnit;

  void getCurrentUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUnit = prefs.getInt('currentUnit' ?? 0);
  }

  @override
  void initState() {
    super.initState();
    getCurrentUnit();
  }

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore
            .collection(_auth.currentUser.uid)
            .doc(widget.babyName)
            .collection('entries')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final entries = snapshot.data.docs;
          List<FlSpot> babyLogEntries = [];
          for (var entry in entries) {
            final height = entry.data()['height'];
            if (height != null) {final double heightDouble = height.toDouble();
            final Timestamp date = entry.data()['date'];
            final monthDate =
                DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
                        .difference(DateTime.fromMillisecondsSinceEpoch(
                            widget.age.millisecondsSinceEpoch))
                        .inDays /
                    30;

            final babyLogEntry = FlSpot(monthDate, heightDouble);
            babyLogEntries.add(babyLogEntry);
          }}
          return Container(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(90), topRight: Radius.circular(90)),
              color: Colors.white,
            ),
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? EdgeInsets.only(top: 40.0)
                          : EdgeInsets.only(top: 5.0),
                      child: Text(
                        "Height Curve",
                        style: TextStyle(
                            color: Colors.deepOrangeAccent[100],
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? 15
                                : 30,
                            right: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? 15
                                : 30,
                            top: 5,
                            bottom: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? 30
                                : 10),
                        child: LineChart(
                          LineChartData(
                              minY: currentUnit == 0 ? 40 : 38.1,
                              maxY: currentUnit == 0 ? 125 : 128,
                              lineTouchData: LineTouchData(
                                enabled: false,
                                touchCallback:
                                    (LineTouchResponse touchResponse) {},
                                handleBuiltInTouches: true,
                              ),
                              gridData: FlGridData(
                                drawVerticalLine: true,
                                show: true,
                                getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.black12, strokeWidth: 1),
                                getDrawingVerticalLine: (value) => FlLine(
                                    color: Colors.black12, strokeWidth: 1),
                                horizontalInterval: currentUnit == 0 ? 5 : 6.35,
                                verticalInterval: 6,
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  getTextStyles: (value) => TextStyle(
                                    color: Colors.deepOrangeAccent[100],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  margin: 10,
                                  getTitles: (value) {
                                    switch (value.toInt()) {
                                      case 0:
                                        return '0';
                                      case 12:
                                        return '1 year';
                                      case 24:
                                        return '2 years';
                                      case 36:
                                        return '3 years';
                                      case 48:
                                        return '4 years';
                                      case 60:
                                        return '5 years';
                                    }
                                    return '';
                                  },
                                ),
                                leftTitles: SideTitles(
                                  interval: currentUnit == 0 ? 5 : 12.7,
                                  showTitles: true,
                                  getTextStyles: (value) => TextStyle(
                                    color: Colors.deepOrangeAccent[100],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  getTitles: currentUnit == 0
                                      ? (value) {
                                          switch (value.toInt()) {
                                            case 50:
                                              return '50 cm';
                                            case 75:
                                              return '75 cm';
                                            case 100:
                                              return '100 cm';
                                            case 125:
                                              return '125 cm';
                                          }
                                          return '';
                                        }
                                      : (value) {
                                          return (value / 2.54)
                                                  .toStringAsFixed(1) +
                                              ' in';
                                        },
                                  margin: 8,
                                  reservedSize: 30,
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.deepOrangeAccent[100],
                                    width: 3,
                                  ),
                                  left: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  right: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  top: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              lineBarsData: [
// median boys 0-5 years
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 49.9),
                                    FlSpot(1, 54.7),
                                    FlSpot(2, 58.4),
                                    FlSpot(3, 61.4),
                                    FlSpot(4, 63.9),
                                    FlSpot(5, 65.9),
                                    FlSpot(6, 67.6),
                                    FlSpot(7, 69.2),
                                    FlSpot(8, 70.6),
                                    FlSpot(9, 72.0),
                                    FlSpot(10, 73.3),
                                    FlSpot(11, 74.5),
                                    FlSpot(12, 75.7),
                                    FlSpot(13, 76.9),
                                    FlSpot(14, 78.0),
                                    FlSpot(15, 79.1),
                                    FlSpot(16, 80.2),
                                    FlSpot(17, 81.2),
                                    FlSpot(18, 82.3),
                                    FlSpot(19, 83.2),
                                    FlSpot(20, 84.2),
                                    FlSpot(21, 85.1),
                                    FlSpot(22, 86.0),
                                    FlSpot(23, 86.9),
                                    FlSpot(24, 87.8),
                                    FlSpot(25, 88.0),
                                    FlSpot(26, 88.8),
                                    FlSpot(27, 89.6),
                                    FlSpot(28, 90.4),
                                    FlSpot(29, 91.2),
                                    FlSpot(30, 91.9),
                                    FlSpot(31, 92.7),
                                    FlSpot(32, 93.4),
                                    FlSpot(33, 94.1),
                                    FlSpot(34, 94.8),
                                    FlSpot(35, 95.4),
                                    FlSpot(36, 96.1),
                                    FlSpot(37, 96.7),
                                    FlSpot(38, 97.4),
                                    FlSpot(39, 98.0),
                                    FlSpot(40, 98.6),
                                    FlSpot(41, 99.2),
                                    FlSpot(42, 99.9),
                                    FlSpot(43, 100.4),
                                    FlSpot(44, 101.0),
                                    FlSpot(45, 101.6),
                                    FlSpot(46, 102.2),
                                    FlSpot(47, 102.8),
                                    FlSpot(48, 103.3),
                                    FlSpot(49, 103.9),
                                    FlSpot(50, 104.4),
                                    FlSpot(51, 105.0),
                                    FlSpot(52, 105.6),
                                    FlSpot(53, 106.1),
                                    FlSpot(54, 106.7),
                                    FlSpot(55, 107.2),
                                    FlSpot(56, 107.8),
                                    FlSpot(57, 108.3),
                                    FlSpot(58, 108.9),
                                    FlSpot(59, 109.4),
                                    FlSpot(60, 110.0),
                                  ],
                                  isCurved: true,
                                  colors: [
                                    Colors.grey,
                                  ],
                                  barWidth: 1,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(
                                    show: false,
                                  ),
                                  dotData: FlDotData(show: false),
                                ),
// sd-1 boys 0-5 years
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 48.0),
                                    FlSpot(1, 52.8),
                                    FlSpot(2, 56.4),
                                    FlSpot(3, 59.4),
                                    FlSpot(4, 61.8),
                                    FlSpot(5, 63.8),
                                    FlSpot(6, 65.5),
                                    FlSpot(7, 67.0),
                                    FlSpot(8, 68.4),
                                    FlSpot(9, 69.7),
                                    FlSpot(10, 71.0),
                                    FlSpot(11, 72.2),
                                    FlSpot(12, 73.4),
                                    FlSpot(13, 74.5),
                                    FlSpot(14, 75.6),
                                    FlSpot(15, 76.6),
                                    FlSpot(16, 77.6),
                                    FlSpot(17, 78.6),
                                    FlSpot(18, 79.6),
                                    FlSpot(19, 80.5),
                                    FlSpot(20, 81.4),
                                    FlSpot(21, 82.3),
                                    FlSpot(22, 83.1),
                                    FlSpot(23, 83.9),
                                    FlSpot(24, 84.8),
                                    FlSpot(25, 84.9),
                                    FlSpot(26, 85.6),
                                    FlSpot(27, 86.4),
                                    FlSpot(28, 87.1),
                                    FlSpot(29, 87.8),
                                    FlSpot(30, 88.5),
                                    FlSpot(31, 89.2),
                                    FlSpot(32, 89.9),
                                    FlSpot(33, 90.5),
                                    FlSpot(34, 91.1),
                                    FlSpot(35, 91.8),
                                    FlSpot(36, 92.4),
                                    FlSpot(37, 93.0),
                                    FlSpot(38, 93.6),
                                    FlSpot(39, 94.2),
                                    FlSpot(40, 94.7),
                                    FlSpot(41, 95.3),
                                    FlSpot(42, 95.9),
                                    FlSpot(43, 96.4),
                                    FlSpot(44, 97.0),
                                    FlSpot(45, 97.5),
                                    FlSpot(46, 98.1),
                                    FlSpot(47, 98.6),
                                    FlSpot(48, 99.1),
                                    FlSpot(49, 99.7),
                                    FlSpot(50, 100.2),
                                    FlSpot(51, 100.7),
                                    FlSpot(52, 101.2),
                                    FlSpot(53, 101.7),
                                    FlSpot(54, 102.3),
                                    FlSpot(55, 102.8),
                                    FlSpot(56, 103.3),
                                    FlSpot(57, 103.8),
                                    FlSpot(58, 104.3),
                                    FlSpot(59, 104.8),
                                    FlSpot(60, 105.3),
                                  ],
                                  isCurved: true,
                                  colors: [
                                    Colors.red.withOpacity(0.3),
                                  ],
                                  barWidth: 1,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(
                                    show: false,
                                  ),
                                  dotData: FlDotData(show: false),
                                ),
// sd-2 boys 0-5 years
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 46.1),
                                    FlSpot(1, 50.8),
                                    FlSpot(2, 54.4),
                                    FlSpot(3, 57.3),
                                    FlSpot(4, 59.7),
                                    FlSpot(5, 61.7),
                                    FlSpot(6, 63.3),
                                    FlSpot(7, 64.8),
                                    FlSpot(8, 66.2),
                                    FlSpot(9, 67.5),
                                    FlSpot(10, 68.7),
                                    FlSpot(11, 69.9),
                                    FlSpot(12, 71.0),
                                    FlSpot(13, 72.1),
                                    FlSpot(14, 73.1),
                                    FlSpot(15, 74.1),
                                    FlSpot(16, 75.0),
                                    FlSpot(17, 76.0),
                                    FlSpot(18, 76.9),
                                    FlSpot(19, 77.7),
                                    FlSpot(20, 78.6),
                                    FlSpot(21, 79.4),
                                    FlSpot(22, 80.2),
                                    FlSpot(23, 81.0),
                                    FlSpot(24, 81.7),
                                    FlSpot(25, 81.7),
                                    FlSpot(26, 82.5),
                                    FlSpot(27, 83.1),
                                    FlSpot(28, 83.8),
                                    FlSpot(29, 84.5),
                                    FlSpot(30, 85.1),
                                    FlSpot(31, 85.7),
                                    FlSpot(32, 86.4),
                                    FlSpot(33, 86.9),
                                    FlSpot(34, 87.5),
                                    FlSpot(35, 88.1),
                                    FlSpot(36, 88.7),
                                    FlSpot(37, 89.2),
                                    FlSpot(38, 89.8),
                                    FlSpot(39, 90.3),
                                    FlSpot(40, 90.9),
                                    FlSpot(41, 91.4),
                                    FlSpot(42, 91.9),
                                    FlSpot(43, 92.4),
                                    FlSpot(44, 93.0),
                                    FlSpot(45, 93.5),
                                    FlSpot(46, 94.0),
                                    FlSpot(47, 94.4),
                                    FlSpot(48, 94.9),
                                    FlSpot(49, 95.4),
                                    FlSpot(50, 95.9),
                                    FlSpot(51, 96.4),
                                    FlSpot(52, 96.9),
                                    FlSpot(53, 97.4),
                                    FlSpot(54, 97.8),
                                    FlSpot(55, 98.3),
                                    FlSpot(56, 98.8),
                                    FlSpot(57, 99.3),
                                    FlSpot(58, 99.7),
                                    FlSpot(59, 100.2),
                                    FlSpot(60, 100.7),
                                  ],
                                  isCurved: true,
                                  colors: [
                                    Colors.green.withOpacity(0.3),
                                  ],
                                  barWidth: 1,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(
                                    show: false,
                                  ),
                                  dotData: FlDotData(show: false),
                                ),
// sd-3 boys 0-5 years
// LineChartBarData(
//   spots: [
//     FlSpot(0, 44.2),
//     FlSpot(1, 48.9),
//     FlSpot(2, 52.4),
//     FlSpot(3, 55.3),
//     FlSpot(4, 57.6),
//     FlSpot(5, 59.6),
//     FlSpot(6, 61.2),
//     FlSpot(7, 62.7),
//     FlSpot(8, 64.0),
//     FlSpot(9, 65.2),
//     FlSpot(10, 66.4),
//     FlSpot(11, 67.6),
//     FlSpot(12, 68.6),
//     FlSpot(13, 69.6),
//     FlSpot(14, 70.6),
//     FlSpot(15, 71.6),
//     FlSpot(16, 72.5),
//     FlSpot(17, 73.3),
//     FlSpot(18, 74.2),
//     FlSpot(19, 75.0),
//     FlSpot(20, 75.8),
//     FlSpot(21, 76.5),
//     FlSpot(22, 77.2),
//     FlSpot(23, 78.0),
//     FlSpot(24, 78.7),
//     FlSpot(25, 78.6),
//     FlSpot(26, 79.3),
//     FlSpot(27, 79.9),
//     FlSpot(28, 80.5),
//     FlSpot(29, 81.1),
//     FlSpot(30, 81.7),
//     FlSpot(31, 82.3),
//     FlSpot(32, 82.8),
//     FlSpot(33, 83.4),
//     FlSpot(34, 83.9),
//     FlSpot(35, 84.4),
//     FlSpot(36, 85.0),
//     FlSpot(37, 85.5),
//     FlSpot(38, 86.0),
//     FlSpot(39, 86.5),
//     FlSpot(40, 87.0),
//     FlSpot(41, 87.5),
//     FlSpot(42, 88.0),
//     FlSpot(43, 88.4),
//     FlSpot(44, 88.9),
//     FlSpot(45, 89.4),
//     FlSpot(46, 89.8),
//     FlSpot(47, 90.3),
//     FlSpot(48, 90.7),
//     FlSpot(49, 91.2),
//     FlSpot(50, 91.6),
//     FlSpot(51, 92.1),
//     FlSpot(52, 92.5),
//     FlSpot(53, 93.0),
//     FlSpot(54, 93.4),
//     FlSpot(55, 93.9),
//     FlSpot(56, 94.3),
//     FlSpot(57, 94.7),
//     FlSpot(58, 95.2),
//     FlSpot(59, 95.6),
//     FlSpot(60, 96.1),
//   ],
//   dotData: FlDotData(show: false),
//   isCurved: true,
//   colors: [
//     Colors.white70,
//   ],
//   barWidth: 4,
//   isStrokeCapRound: true,
//   belowBarData: BarAreaData(
//     show: false,
//   ),
// ),
// sd+1 boys 0-5 years
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 51.8),
                                    FlSpot(1, 56.7),
                                    FlSpot(2, 60.4),
                                    FlSpot(3, 63.5),
                                    FlSpot(4, 66.0),
                                    FlSpot(5, 68.0),
                                    FlSpot(6, 69.8),
                                    FlSpot(7, 71.3),
                                    FlSpot(8, 72.8),
                                    FlSpot(9, 74.2),
                                    FlSpot(10, 75.6),
                                    FlSpot(11, 76.9),
                                    FlSpot(12, 78.1),
                                    FlSpot(13, 79.3),
                                    FlSpot(14, 80.5),
                                    FlSpot(15, 81.7),
                                    FlSpot(16, 82.8),
                                    FlSpot(17, 83.9),
                                    FlSpot(18, 85.0),
                                    FlSpot(19, 86.0),
                                    FlSpot(20, 87.0),
                                    FlSpot(21, 88.0),
                                    FlSpot(22, 89.0),
                                    FlSpot(23, 89.9),
                                    FlSpot(24, 90.9),
                                    FlSpot(25, 91.1),
                                    FlSpot(26, 92.0),
                                    FlSpot(27, 92.9),
                                    FlSpot(28, 93.7),
                                    FlSpot(29, 94.5),
                                    FlSpot(30, 95.3),
                                    FlSpot(31, 96.1),
                                    FlSpot(32, 96.9),
                                    FlSpot(33, 97.6),
                                    FlSpot(34, 98.4),
                                    FlSpot(35, 99.1),
                                    FlSpot(36, 99.8),
                                    FlSpot(37, 100.5),
                                    FlSpot(38, 101.2),
                                    FlSpot(39, 101.8),
                                    FlSpot(40, 102.5),
                                    FlSpot(41, 103.2),
                                    FlSpot(42, 103.8),
                                    FlSpot(43, 104.5),
                                    FlSpot(44, 105.1),
                                    FlSpot(45, 105.7),
                                    FlSpot(46, 106.3),
                                    FlSpot(47, 106.9),
                                    FlSpot(48, 107.5),
                                    FlSpot(49, 108.1),
                                    FlSpot(50, 108.7),
                                    FlSpot(51, 109.3),
                                    FlSpot(52, 109.9),
                                    FlSpot(53, 110.5),
                                    FlSpot(54, 111.1),
                                    FlSpot(55, 111.7),
                                    FlSpot(56, 112.3),
                                    FlSpot(57, 112.8),
                                    FlSpot(58, 113.4),
                                    FlSpot(59, 114.0),
                                    FlSpot(60, 114.6),
                                  ],
                                  isCurved: true,
                                  colors: [
                                    Colors.red.withOpacity(0.3),
                                  ],
                                  barWidth: 1,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(
                                    show: false,
                                  ),
                                  dotData: FlDotData(show: false),
                                ),
// sd+2 boys 0-5 years
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 53.7),
                                    FlSpot(1, 58.6),
                                    FlSpot(2, 62.4),
                                    FlSpot(3, 65.5),
                                    FlSpot(4, 68.0),
                                    FlSpot(5, 70.1),
                                    FlSpot(6, 71.9),
                                    FlSpot(7, 73.5),
                                    FlSpot(8, 75.0),
                                    FlSpot(9, 76.5),
                                    FlSpot(10, 77.9),
                                    FlSpot(11, 79.2),
                                    FlSpot(12, 80.5),
                                    FlSpot(13, 81.8),
                                    FlSpot(14, 83.0),
                                    FlSpot(15, 84.2),
                                    FlSpot(16, 85.4),
                                    FlSpot(17, 86.5),
                                    FlSpot(18, 87.7),
                                    FlSpot(19, 88.8),
                                    FlSpot(20, 89.8),
                                    FlSpot(21, 90.9),
                                    FlSpot(22, 91.9),
                                    FlSpot(23, 92.9),
                                    FlSpot(24, 93.9),
                                    FlSpot(25, 94.2),
                                    FlSpot(26, 95.2),
                                    FlSpot(27, 96.1),
                                    FlSpot(28, 97.0),
                                    FlSpot(29, 97.9),
                                    FlSpot(30, 98.7),
                                    FlSpot(31, 99.6),
                                    FlSpot(32, 100.4),
                                    FlSpot(33, 101.2),
                                    FlSpot(34, 102.0),
                                    FlSpot(35, 102.7),
                                    FlSpot(36, 103.5),
                                    FlSpot(37, 104.2),
                                    FlSpot(38, 105.0),
                                    FlSpot(39, 105.7),
                                    FlSpot(40, 106.4),
                                    FlSpot(41, 107.1),
                                    FlSpot(42, 107.8),
                                    FlSpot(43, 108.5),
                                    FlSpot(44, 109.1),
                                    FlSpot(45, 109.8),
                                    FlSpot(46, 110.4),
                                    FlSpot(47, 111.1),
                                    FlSpot(48, 111.7),
                                    FlSpot(49, 112.4),
                                    FlSpot(50, 113.0),
                                    FlSpot(51, 113.6),
                                    FlSpot(52, 114.2),
                                    FlSpot(53, 114.9),
                                    FlSpot(54, 115.5),
                                    FlSpot(55, 116.1),
                                    FlSpot(56, 116.7),
                                    FlSpot(57, 117.4),
                                    FlSpot(58, 118.0),
                                    FlSpot(59, 118.6),
                                    FlSpot(60, 119.2),
                                  ],
                                  isCurved: true,
                                  colors: [
                                    Colors.green.withOpacity(0.3),
                                  ],
                                  barWidth: 1,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(
                                    show: false,
                                  ),
                                  dotData: FlDotData(show: false),
                                ),
// sd+3 boys 0-5 years
// LineChartBarData(
//   spots: [
//     FlSpot(0, 55.6),
//     FlSpot(1, 60.6),
//     FlSpot(2, 64.4),
//     FlSpot(3, 67.6),
//     FlSpot(4, 70.1),
//     FlSpot(5, 72.2),
//     FlSpot(6, 74.0),
//     FlSpot(7, 75.7),
//     FlSpot(8, 77.2),
//     FlSpot(9, 78.7),
//     FlSpot(10, 80.1),
//     FlSpot(11, 81.5),
//     FlSpot(12, 82.9),
//     FlSpot(13, 84.2),
//     FlSpot(14, 85.5),
//     FlSpot(15, 86.7),
//     FlSpot(16, 88.0),
//     FlSpot(17, 89.2),
//     FlSpot(18, 90.4),
//     FlSpot(19, 91.5),
//     FlSpot(20, 92.6),
//     FlSpot(21, 93.8),
//     FlSpot(22, 94.9),
//     FlSpot(23, 95.9),
//     FlSpot(24, 97.0),
//     FlSpot(25, 97.3),
//     FlSpot(26, 98.3),
//     FlSpot(27, 99.3),
//     FlSpot(28, 100.3),
//     FlSpot(29, 101.2),
//     FlSpot(30, 102.1),
//     FlSpot(31, 103.0),
//     FlSpot(32, 103.9),
//     FlSpot(33, 104.8),
//     FlSpot(34, 105.6),
//     FlSpot(35, 106.4),
//     FlSpot(36, 107.2),
//     FlSpot(37, 108.0),
//     FlSpot(38, 108.8),
//     FlSpot(39, 109.5),
//     FlSpot(40, 110.3),
//     FlSpot(41, 111.0),
//     FlSpot(42, 111.7),
//     FlSpot(43, 112.5),
//     FlSpot(44, 113.2),
//     FlSpot(45, 113.9),
//     FlSpot(46, 114.6),
//     FlSpot(47, 115.2),
//     FlSpot(48, 115.9),
//     FlSpot(49, 116.6),
//     FlSpot(50, 117.3),
//     FlSpot(51, 117.9),
//     FlSpot(52, 118.6),
//     FlSpot(53, 119.2),
//     FlSpot(54, 119.9),
//     FlSpot(55, 120.6),
//     FlSpot(56, 121.2),
//     FlSpot(57, 121.9),
//     FlSpot(58, 122.6),
//     FlSpot(59, 123.2),
//     FlSpot(60, 123.9),
//   ],
//   isCurved: true,
//   colors: [
//     Colors.white70,
//   ],
//   barWidth: 4,
//   isStrokeCapRound: true,
//   belowBarData: BarAreaData(
//     show: false,
//   ),
//   dotData: FlDotData(show: false),
// ),

// Baby Log entries
                                LineChartBarData(
                                  spots: babyLogEntries,
                                  isCurved: true,
                                  colors: [
                                    Colors.blueAccent,
                                  ],
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(
                                    show: false,
                                  ),
                                  dotData: FlDotData(show: false),
                                )
                              ]),
                          swapAnimationDuration: Duration(milliseconds: 250),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
