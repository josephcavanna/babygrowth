import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeightGirlsData extends StatefulWidget {
  final String babyName;
  final Timestamp age;
  HeightGirlsData({this.babyName, this.age});

  @override
  _HeightGirlsDataState createState() => _HeightGirlsDataState();
}

class _HeightGirlsDataState extends State<HeightGirlsData> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  int currentUnit;

  void getCurrentUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUnit = prefs.getInt('currentUnit' ?? 0);
    print(currentUnit);
  }

  @override
  void initState() {
    super.initState();
    getCurrentUnit();
  }

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
            final double heightDouble = height.toDouble();
            final Timestamp date = entry.data()['date'];
            final monthDate =
                DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
                        .difference(DateTime.fromMillisecondsSinceEpoch(
                            widget.age.millisecondsSinceEpoch))
                        .inDays /
                    30;

            final babyLogEntry = FlSpot(monthDate, heightDouble);
            babyLogEntries.add(babyLogEntry);
          }
          return Container(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 25, top: 25),
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
                        'Height Curve',
                        style: TextStyle(
                            color: Colors.deepOrangeAccent[100],
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
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
                                    fontSize: 12,
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
// median girls 0-5 years
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 49.1),
                                    FlSpot(1, 53.7),
                                    FlSpot(2, 57.1),
                                    FlSpot(3, 59.8),
                                    FlSpot(4, 62.1),
                                    FlSpot(5, 64.0),
                                    FlSpot(6, 65.7),
                                    FlSpot(7, 67.3),
                                    FlSpot(8, 68.7),
                                    FlSpot(9, 70.1),
                                    FlSpot(10, 71.5),
                                    FlSpot(11, 72.8),
                                    FlSpot(12, 74.0),
                                    FlSpot(13, 75.2),
                                    FlSpot(14, 76.4),
                                    FlSpot(15, 77.5),
                                    FlSpot(16, 78.6),
                                    FlSpot(17, 79.7),
                                    FlSpot(18, 80.7),
                                    FlSpot(19, 81.7),
                                    FlSpot(20, 82.7),
                                    FlSpot(21, 83.7),
                                    FlSpot(22, 84.6),
                                    FlSpot(23, 85.5),
                                    FlSpot(24, 86.4),
                                    FlSpot(25, 86.6),
                                    FlSpot(26, 87.4),
                                    FlSpot(27, 88.3),
                                    FlSpot(28, 89.1),
                                    FlSpot(29, 89.9),
                                    FlSpot(30, 90.7),
                                    FlSpot(31, 91.4),
                                    FlSpot(32, 92.2),
                                    FlSpot(33, 92.9),
                                    FlSpot(34, 93.6),
                                    FlSpot(35, 94.4),
                                    FlSpot(36, 95.1),
                                    FlSpot(37, 95.7),
                                    FlSpot(38, 96.4),
                                    FlSpot(39, 97.1),
                                    FlSpot(40, 97.7),
                                    FlSpot(41, 98.4),
                                    FlSpot(42, 99.0),
                                    FlSpot(43, 99.7),
                                    FlSpot(44, 100.3),
                                    FlSpot(45, 100.9),
                                    FlSpot(46, 101.5),
                                    FlSpot(47, 102.1),
                                    FlSpot(48, 102.7),
                                    FlSpot(49, 103.3),
                                    FlSpot(50, 103.9),
                                    FlSpot(51, 104.5),
                                    FlSpot(52, 105.0),
                                    FlSpot(53, 105.6),
                                    FlSpot(54, 106.2),
                                    FlSpot(55, 106.7),
                                    FlSpot(56, 107.3),
                                    FlSpot(57, 107.8),
                                    FlSpot(58, 108.4),
                                    FlSpot(59, 108.9),
                                    FlSpot(60, 109.4),
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
// sd-1 girls 0-5 years
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 47.3),
                                    FlSpot(1, 51.7),
                                    FlSpot(2, 55.0),
                                    FlSpot(3, 57.7),
                                    FlSpot(4, 59.9),
                                    FlSpot(5, 61.8),
                                    FlSpot(6, 63.5),
                                    FlSpot(7, 65.0),
                                    FlSpot(8, 66.4),
                                    FlSpot(9, 67.7),
                                    FlSpot(10, 69.0),
                                    FlSpot(11, 70.3),
                                    FlSpot(12, 71.4),
                                    FlSpot(13, 72.6),
                                    FlSpot(14, 73.7),
                                    FlSpot(15, 74.8),
                                    FlSpot(16, 75.8),
                                    FlSpot(17, 76.8),
                                    FlSpot(18, 77.8),
                                    FlSpot(19, 78.8),
                                    FlSpot(20, 79.7),
                                    FlSpot(21, 80.6),
                                    FlSpot(22, 81.5),
                                    FlSpot(23, 82.3),
                                    FlSpot(24, 83.2),
                                    FlSpot(25, 83.3),
                                    FlSpot(26, 84.1),
                                    FlSpot(27, 84.9),
                                    FlSpot(28, 85.7),
                                    FlSpot(29, 86.4),
                                    FlSpot(30, 87.1),
                                    FlSpot(31, 87.9),
                                    FlSpot(32, 88.6),
                                    FlSpot(33, 89.3),
                                    FlSpot(34, 89.9),
                                    FlSpot(35, 90.6),
                                    FlSpot(36, 91.2),
                                    FlSpot(37, 91.9),
                                    FlSpot(38, 92.5),
                                    FlSpot(39, 93.1),
                                    FlSpot(40, 93.8),
                                    FlSpot(41, 94.4),
                                    FlSpot(42, 95.0),
                                    FlSpot(43, 95.6),
                                    FlSpot(44, 96.2),
                                    FlSpot(45, 96.7),
                                    FlSpot(46, 97.3),
                                    FlSpot(47, 97.9),
                                    FlSpot(48, 98.4),
                                    FlSpot(49, 99.0),
                                    FlSpot(50, 99.5),
                                    FlSpot(51, 100.1),
                                    FlSpot(52, 100.6),
                                    FlSpot(53, 101.1),
                                    FlSpot(54, 101.6),
                                    FlSpot(55, 102.2),
                                    FlSpot(56, 102.7),
                                    FlSpot(57, 103.2),
                                    FlSpot(58, 103.7),
                                    FlSpot(59, 104.2),
                                    FlSpot(60, 104.7),
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
// sd-2 girls 0-5 years
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 45.4),
                                    FlSpot(1, 49.8),
                                    FlSpot(2, 53.0),
                                    FlSpot(3, 55.6),
                                    FlSpot(4, 57.8),
                                    FlSpot(5, 59.6),
                                    FlSpot(6, 61.2),
                                    FlSpot(7, 62.7),
                                    FlSpot(8, 64.0),
                                    FlSpot(9, 65.3),
                                    FlSpot(10, 66.5),
                                    FlSpot(11, 67.7),
                                    FlSpot(12, 68.9),
                                    FlSpot(13, 70.0),
                                    FlSpot(14, 71.0),
                                    FlSpot(15, 72.0),
                                    FlSpot(16, 73.0),
                                    FlSpot(17, 74.0),
                                    FlSpot(18, 74.9),
                                    FlSpot(19, 75.8),
                                    FlSpot(20, 76.7),
                                    FlSpot(21, 77.5),
                                    FlSpot(22, 78.4),
                                    FlSpot(23, 79.2),
                                    FlSpot(24, 80.0),
                                    FlSpot(25, 80.0),
                                    FlSpot(26, 80.8),
                                    FlSpot(27, 81.5),
                                    FlSpot(28, 82.2),
                                    FlSpot(29, 82.9),
                                    FlSpot(30, 83.6),
                                    FlSpot(31, 84.3),
                                    FlSpot(32, 84.9),
                                    FlSpot(33, 85.6),
                                    FlSpot(34, 86.2),
                                    FlSpot(35, 86.8),
                                    FlSpot(36, 87.4),
                                    FlSpot(37, 88.0),
                                    FlSpot(38, 88.6),
                                    FlSpot(39, 89.2),
                                    FlSpot(40, 89.8),
                                    FlSpot(41, 90.4),
                                    FlSpot(42, 90.9),
                                    FlSpot(43, 91.5),
                                    FlSpot(44, 92.0),
                                    FlSpot(45, 92.5),
                                    FlSpot(46, 93.1),
                                    FlSpot(47, 93.6),
                                    FlSpot(48, 94.1),
                                    FlSpot(49, 94.6),
                                    FlSpot(50, 95.1),
                                    FlSpot(51, 95.6),
                                    FlSpot(52, 96.1),
                                    FlSpot(53, 96.6),
                                    FlSpot(54, 97.1),
                                    FlSpot(55, 97.6),
                                    FlSpot(56, 98.1),
                                    FlSpot(57, 98.5),
                                    FlSpot(58, 99.0),
                                    FlSpot(59, 99.5),
                                    FlSpot(60, 99.9),
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
// sd-3 girls 0-5 years
// LineChartBarData(
//   spots: [
//     FlSpot(0, 43.6),
//     FlSpot(1, 47.8),
//     FlSpot(2, 51.0),
//     FlSpot(3, 53.5),
//     FlSpot(4, 55.6),
//     FlSpot(5, 57.4),
//     FlSpot(6, 58.9),
//     FlSpot(7, 60.3),
//     FlSpot(8, 61.7),
//     FlSpot(9, 62.9),
//     FlSpot(10, 64.1),
//     FlSpot(11, 65.2),
//     FlSpot(12, 66.3),
//     FlSpot(13, 67.3),
//     FlSpot(14, 68.3),
//     FlSpot(15, 69.3),
//     FlSpot(16, 70.2),
//     FlSpot(17, 71.1),
//     FlSpot(18, 72.0),
//     FlSpot(19, 72.8),
//     FlSpot(20, 73.7),
//     FlSpot(21, 74.5),
//     FlSpot(22, 75.2),
//     FlSpot(23, 76.0),
//     FlSpot(24, 76.7),
//     FlSpot(25, 76.8),
//     FlSpot(26, 77.5),
//     FlSpot(27, 78.1),
//     FlSpot(28, 78.8),
//     FlSpot(29, 79.5),
//     FlSpot(30, 80.1),
//     FlSpot(31, 80.7),
//     FlSpot(32, 81.3),
//     FlSpot(33, 81.9),
//     FlSpot(34, 82.5),
//     FlSpot(35, 83.1),
//     FlSpot(36, 83.6),
//     FlSpot(37, 84.2),
//     FlSpot(38, 84.7),
//     FlSpot(39, 85.3),
//     FlSpot(40, 85.8),
//     FlSpot(41, 86.3),
//     FlSpot(42, 86.8),
//     FlSpot(43, 87.4),
//     FlSpot(44, 87.9),
//     FlSpot(45, 88.4),
//     FlSpot(46, 88.9),
//     FlSpot(47, 89.3),
//     FlSpot(48, 89.8),
//     FlSpot(49, 90.3),
//     FlSpot(50, 90.7),
//     FlSpot(51, 91.2),
//     FlSpot(52, 91.7),
//     FlSpot(53, 92.1),
//     FlSpot(54, 92.6),
//     FlSpot(55, 93.0),
//     FlSpot(56, 93.4),
//     FlSpot(57, 93.9),
//     FlSpot(58, 94.3),
//     FlSpot(59, 94.7),
//     FlSpot(60, 95.2),
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
// sd+1 girls 0-5 years
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 51.0),
                                    FlSpot(1, 55.6),
                                    FlSpot(2, 59.1),
                                    FlSpot(3, 61.9),
                                    FlSpot(4, 64.3),
                                    FlSpot(5, 66.2),
                                    FlSpot(6, 68.0),
                                    FlSpot(7, 69.6),
                                    FlSpot(8, 71.1),
                                    FlSpot(9, 72.6),
                                    FlSpot(10, 73.9),
                                    FlSpot(11, 75.3),
                                    FlSpot(12, 76.6),
                                    FlSpot(13, 77.8),
                                    FlSpot(14, 79.1),
                                    FlSpot(15, 80.2),
                                    FlSpot(16, 81.4),
                                    FlSpot(17, 82.5),
                                    FlSpot(18, 83.6),
                                    FlSpot(19, 84.7),
                                    FlSpot(20, 85.7),
                                    FlSpot(21, 86.7),
                                    FlSpot(22, 87.7),
                                    FlSpot(23, 88.7),
                                    FlSpot(24, 89.6),
                                    FlSpot(25, 89.9),
                                    FlSpot(26, 90.8),
                                    FlSpot(27, 91.7),
                                    FlSpot(28, 92.5),
                                    FlSpot(29, 93.4),
                                    FlSpot(30, 94.2),
                                    FlSpot(31, 95.0),
                                    FlSpot(32, 95.8),
                                    FlSpot(33, 96.6),
                                    FlSpot(34, 97.4),
                                    FlSpot(35, 98.1),
                                    FlSpot(36, 98.9),
                                    FlSpot(37, 99.6),
                                    FlSpot(38, 100.3),
                                    FlSpot(39, 101.0),
                                    FlSpot(40, 101.7),
                                    FlSpot(41, 102.4),
                                    FlSpot(42, 103.1),
                                    FlSpot(43, 103.8),
                                    FlSpot(44, 104.5),
                                    FlSpot(45, 105.1),
                                    FlSpot(46, 105.8),
                                    FlSpot(47, 106.4),
                                    FlSpot(48, 107.0),
                                    FlSpot(49, 107.7),
                                    FlSpot(50, 108.3),
                                    FlSpot(51, 108.9),
                                    FlSpot(52, 109.5),
                                    FlSpot(53, 110.1),
                                    FlSpot(54, 110.7),
                                    FlSpot(55, 111.3),
                                    FlSpot(56, 111.9),
                                    FlSpot(57, 112.5),
                                    FlSpot(58, 113.0),
                                    FlSpot(59, 113.6),
                                    FlSpot(60, 114.2),
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
// sd+2 girls 0-5 years
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 52.9),
                                    FlSpot(1, 57.6),
                                    FlSpot(2, 61.1),
                                    FlSpot(3, 64.0),
                                    FlSpot(4, 66.4),
                                    FlSpot(5, 68.5),
                                    FlSpot(6, 70.3),
                                    FlSpot(7, 71.9),
                                    FlSpot(8, 73.5),
                                    FlSpot(9, 75.0),
                                    FlSpot(10, 76.4),
                                    FlSpot(11, 77.8),
                                    FlSpot(12, 79.2),
                                    FlSpot(13, 80.5),
                                    FlSpot(14, 81.7),
                                    FlSpot(15, 83.0),
                                    FlSpot(16, 84.2),
                                    FlSpot(17, 85.4),
                                    FlSpot(18, 86.5),
                                    FlSpot(19, 87.6),
                                    FlSpot(20, 88.7),
                                    FlSpot(21, 89.8),
                                    FlSpot(22, 90.8),
                                    FlSpot(23, 91.9),
                                    FlSpot(24, 92.9),
                                    FlSpot(25, 93.1),
                                    FlSpot(26, 94.1),
                                    FlSpot(27, 95.0),
                                    FlSpot(28, 96.0),
                                    FlSpot(29, 96.9),
                                    FlSpot(30, 97.7),
                                    FlSpot(31, 98.6),
                                    FlSpot(32, 99.4),
                                    FlSpot(33, 100.3),
                                    FlSpot(34, 101.1),
                                    FlSpot(35, 101.9),
                                    FlSpot(36, 102.7),
                                    FlSpot(37, 103.4),
                                    FlSpot(38, 104.2),
                                    FlSpot(39, 105.0),
                                    FlSpot(40, 105.7),
                                    FlSpot(41, 106.4),
                                    FlSpot(42, 107.2),
                                    FlSpot(43, 107.9),
                                    FlSpot(44, 108.6),
                                    FlSpot(45, 109.3),
                                    FlSpot(46, 110.0),
                                    FlSpot(47, 110.7),
                                    FlSpot(48, 111.3),
                                    FlSpot(49, 112.0),
                                    FlSpot(50, 112.7),
                                    FlSpot(51, 113.3),
                                    FlSpot(52, 114.0),
                                    FlSpot(53, 114.6),
                                    FlSpot(54, 115.2),
                                    FlSpot(55, 115.9),
                                    FlSpot(56, 116.5),
                                    FlSpot(57, 117.1),
                                    FlSpot(58, 117.7),
                                    FlSpot(59, 118.3),
                                    FlSpot(60, 118.9),
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
// sd+3 girls 0-5 years
// LineChartBarData(
//   spots: [
//     FlSpot(0, 54.7),
//     FlSpot(1, 59.5),
//     FlSpot(2, 63.2),
//     FlSpot(3, 66.1),
//     FlSpot(4, 68.6),
//     FlSpot(5, 70.7),
//     FlSpot(6, 72.5),
//     FlSpot(7, 74.2),
//     FlSpot(8, 75.8),
//     FlSpot(9, 77.4),
//     FlSpot(10, 78.9),
//     FlSpot(11, 80.3),
//     FlSpot(12, 81.7),
//     FlSpot(13, 83.1),
//     FlSpot(14, 84.4),
//     FlSpot(15, 85.7),
//     FlSpot(16, 87.0),
//     FlSpot(17, 88.2),
//     FlSpot(18, 89.4),
//     FlSpot(19, 90.6),
//     FlSpot(20, 91.7),
//     FlSpot(21, 92.9),
//     FlSpot(22, 94.0),
//     FlSpot(23, 95.0),
//     FlSpot(24, 96.1),
//     FlSpot(25, 96.4),
//     FlSpot(26, 97.4),
//     FlSpot(27, 98.4),
//     FlSpot(28, 99.4),
//     FlSpot(29, 100.3),
//     FlSpot(30, 101.3),
//     FlSpot(31, 102.2),
//     FlSpot(32, 103.1),
//     FlSpot(33, 103.9),
//     FlSpot(34, 104.8),
//     FlSpot(35, 105.6),
//     FlSpot(36, 106.5),
//     FlSpot(37, 107.3),
//     FlSpot(38, 108.1),
//     FlSpot(39, 108.9),
//     FlSpot(40, 109.7),
//     FlSpot(41, 110.5),
//     FlSpot(42, 111.2),
//     FlSpot(43, 112.0),
//     FlSpot(44, 112.7),
//     FlSpot(45, 113.5),
//     FlSpot(46, 114.2),
//     FlSpot(47, 114.9),
//     FlSpot(48, 115.7),
//     FlSpot(49, 116.4),
//     FlSpot(50, 117.1),
//     FlSpot(51, 117.7),
//     FlSpot(52, 118.4),
//     FlSpot(53, 119.1),
//     FlSpot(54, 119.8),
//     FlSpot(55, 120.4),
//     FlSpot(56, 121.1),
//     FlSpot(57, 121.8),
//     FlSpot(58, 122.4),
//     FlSpot(59, 123.1),
//     FlSpot(60, 123.7),
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
                                    Colors.pinkAccent,
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
