import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightGirlsData extends StatefulWidget {
  final String babyName;
  final Timestamp age;
  WeightGirlsData({this.babyName, this.age});

  @override
  _WeightGirlsDataState createState() => _WeightGirlsDataState();
}

class _WeightGirlsDataState extends State<WeightGirlsData> {
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
            final weight = entry.data()['weight'];
            final Timestamp date = entry.data()['date'];
            final monthDate =
                DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
                        .difference(DateTime.fromMillisecondsSinceEpoch(
                            widget.age.millisecondsSinceEpoch))
                        .inDays /
                    30;

            final babyLogEntry = FlSpot(monthDate, weight);
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
                        'Weight Curve',
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
                              minY: currentUnit == 0 ? 2 : 0,
                              maxY: 25.0,
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
                                horizontalInterval:
                                    currentUnit == 0 ? 1 : 2.2675,
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
                                  interval: currentUnit == 0 ? 1 : 2.2675,
                                  showTitles: true,
                                  getTextStyles: (value) => TextStyle(
                                    color: Colors.deepOrangeAccent[100],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  getTitles: currentUnit == 0
                                      ? (value) {
                                          switch (value.toInt()) {
                                            case 5:
                                              return '5 kg';
                                            case 10:
                                              return '10 kg';
                                            case 15:
                                              return '15 kg';
                                            case 20:
                                              return '20 kg';
                                            case 25:
                                              return '25 kg';
                                          }
                                          return '';
                                        }
                                      : (value) {
                                          return (value * 2.205)
                                                  .toStringAsFixed(0) +
                                              ' lbs';
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
                                    width: 2,
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
                                    FlSpot(0, 3.2),
                                    FlSpot(1, 4.2),
                                    FlSpot(2, 5.1),
                                    FlSpot(3, 5.8),
                                    FlSpot(4, 6.4),
                                    FlSpot(5, 6.9),
                                    FlSpot(6, 7.3),
                                    FlSpot(7, 7.6),
                                    FlSpot(8, 7.9),
                                    FlSpot(9, 8.2),
                                    FlSpot(10, 8.5),
                                    FlSpot(11, 8.7),
                                    FlSpot(12, 8.9),
                                    FlSpot(13, 9.2),
                                    FlSpot(14, 9.4),
                                    FlSpot(15, 9.6),
                                    FlSpot(16, 9.8),
                                    FlSpot(17, 10.0),
                                    FlSpot(18, 10.2),
                                    FlSpot(19, 10.4),
                                    FlSpot(20, 10.6),
                                    FlSpot(21, 10.9),
                                    FlSpot(22, 11.1),
                                    FlSpot(23, 11.3),
                                    FlSpot(24, 11.5),
                                    FlSpot(25, 11.7),
                                    FlSpot(26, 11.9),
                                    FlSpot(27, 12.1),
                                    FlSpot(28, 12.3),
                                    FlSpot(29, 12.5),
                                    FlSpot(30, 12.7),
                                    FlSpot(31, 12.9),
                                    FlSpot(32, 13.1),
                                    FlSpot(33, 13.3),
                                    FlSpot(34, 13.5),
                                    FlSpot(35, 13.7),
                                    FlSpot(36, 13.9),
                                    FlSpot(37, 14.0),
                                    FlSpot(38, 14.2),
                                    FlSpot(39, 14.4),
                                    FlSpot(40, 14.6),
                                    FlSpot(41, 14.8),
                                    FlSpot(42, 15.0),
                                    FlSpot(43, 15.2),
                                    FlSpot(44, 15.3),
                                    FlSpot(45, 15.5),
                                    FlSpot(46, 15.7),
                                    FlSpot(47, 15.9),
                                    FlSpot(48, 16.1),
                                    FlSpot(49, 16.3),
                                    FlSpot(50, 16.4),
                                    FlSpot(51, 16.6),
                                    FlSpot(52, 16.8),
                                    FlSpot(53, 17.0),
                                    FlSpot(54, 17.2),
                                    FlSpot(55, 17.3),
                                    FlSpot(56, 17.5),
                                    FlSpot(57, 17.7),
                                    FlSpot(58, 17.9),
                                    FlSpot(59, 18.0),
                                    FlSpot(60, 18.2),
                                  ],
                                  isCurved: true,
                                  colors: [Colors.grey],
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
                                    FlSpot(0, 2.8),
                                    FlSpot(1, 3.6),
                                    FlSpot(2, 4.5),
                                    FlSpot(3, 5.2),
                                    FlSpot(4, 5.7),
                                    FlSpot(5, 6.1),
                                    FlSpot(6, 6.5),
                                    FlSpot(7, 6.8),
                                    FlSpot(8, 7.0),
                                    FlSpot(9, 7.3),
                                    FlSpot(10, 7.5),
                                    FlSpot(11, 7.7),
                                    FlSpot(12, 7.9),
                                    FlSpot(13, 8.1),
                                    FlSpot(14, 8.3),
                                    FlSpot(15, 8.5),
                                    FlSpot(16, 8.7),
                                    FlSpot(17, 8.9),
                                    FlSpot(18, 9.1),
                                    FlSpot(19, 9.2),
                                    FlSpot(20, 9.4),
                                    FlSpot(21, 9.6),
                                    FlSpot(22, 9.8),
                                    FlSpot(23, 10.0),
                                    FlSpot(24, 10.2),
                                    FlSpot(25, 10.3),
                                    FlSpot(26, 10.5),
                                    FlSpot(27, 10.7),
                                    FlSpot(28, 10.9),
                                    FlSpot(29, 11.1),
                                    FlSpot(30, 11.2),
                                    FlSpot(31, 11.4),
                                    FlSpot(32, 11.6),
                                    FlSpot(33, 11.7),
                                    FlSpot(34, 11.9),
                                    FlSpot(35, 12.0),
                                    FlSpot(36, 12.2),
                                    FlSpot(37, 12.4),
                                    FlSpot(38, 12.5),
                                    FlSpot(39, 12.7),
                                    FlSpot(40, 12.8),
                                    FlSpot(41, 13.0),
                                    FlSpot(42, 13.1),
                                    FlSpot(43, 13.3),
                                    FlSpot(44, 13.4),
                                    FlSpot(45, 13.6),
                                    FlSpot(46, 13.7),
                                    FlSpot(47, 13.9),
                                    FlSpot(48, 14.0),
                                    FlSpot(49, 14.2),
                                    FlSpot(50, 14.3),
                                    FlSpot(51, 14.5),
                                    FlSpot(52, 14.6),
                                    FlSpot(53, 14.8),
                                    FlSpot(54, 14.9),
                                    FlSpot(55, 15.1),
                                    FlSpot(56, 15.2),
                                    FlSpot(57, 15.3),
                                    FlSpot(58, 15.5),
                                    FlSpot(59, 15.6),
                                    FlSpot(60, 15.8),
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
                                    FlSpot(0, 2.4),
                                    FlSpot(1, 3.2),
                                    FlSpot(2, 3.9),
                                    FlSpot(3, 4.5),
                                    FlSpot(4, 5.0),
                                    FlSpot(5, 5.4),
                                    FlSpot(6, 5.7),
                                    FlSpot(7, 6.0),
                                    FlSpot(8, 6.3),
                                    FlSpot(9, 6.5),
                                    FlSpot(10, 6.7),
                                    FlSpot(11, 6.9),
                                    FlSpot(12, 7.0),
                                    FlSpot(13, 7.2),
                                    FlSpot(14, 7.4),
                                    FlSpot(15, 7.6),
                                    FlSpot(16, 7.7),
                                    FlSpot(17, 7.9),
                                    FlSpot(18, 8.1),
                                    FlSpot(19, 8.2),
                                    FlSpot(20, 8.4),
                                    FlSpot(21, 8.6),
                                    FlSpot(22, 8.7),
                                    FlSpot(23, 8.9),
                                    FlSpot(24, 9.0),
                                    FlSpot(25, 9.2),
                                    FlSpot(26, 9.4),
                                    FlSpot(27, 9.5),
                                    FlSpot(28, 9.7),
                                    FlSpot(29, 9.8),
                                    FlSpot(30, 10.0),
                                    FlSpot(31, 10.1),
                                    FlSpot(32, 10.3),
                                    FlSpot(33, 10.4),
                                    FlSpot(34, 10.5),
                                    FlSpot(35, 10.7),
                                    FlSpot(36, 10.8),
                                    FlSpot(37, 10.9),
                                    FlSpot(38, 11.1),
                                    FlSpot(39, 11.2),
                                    FlSpot(40, 11.3),
                                    FlSpot(41, 11.5),
                                    FlSpot(42, 11.6),
                                    FlSpot(43, 11.7),
                                    FlSpot(44, 11.8),
                                    FlSpot(45, 12.0),
                                    FlSpot(46, 12.1),
                                    FlSpot(47, 12.2),
                                    FlSpot(48, 12.3),
                                    FlSpot(49, 12.4),
                                    FlSpot(50, 12.6),
                                    FlSpot(51, 12.7),
                                    FlSpot(52, 12.8),
                                    FlSpot(53, 12.9),
                                    FlSpot(54, 13.0),
                                    FlSpot(55, 13.2),
                                    FlSpot(56, 13.3),
                                    FlSpot(57, 13.4),
                                    FlSpot(58, 13.5),
                                    FlSpot(59, 13.6),
                                    FlSpot(60, 13.7),
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
//     FlSpot(0, 2.0),
//     FlSpot(1, 2.7),
//     FlSpot(2, 3.4),
//     FlSpot(3, 4.0),
//     FlSpot(4, 4.4),
//     FlSpot(5, 4.8),
//     FlSpot(6, 5.1),
//     FlSpot(7, 5.3),
//     FlSpot(8, 5.6),
//     FlSpot(9, 5.8),
//     FlSpot(10, 5.9),
//     FlSpot(11, 6.1),
//     FlSpot(12, 6.3),
//     FlSpot(13, 6.4),
//     FlSpot(14, 6.6),
//     FlSpot(15, 6.7),
//     FlSpot(16, 6.9),
//     FlSpot(17, 7.0),
//     FlSpot(18, 7.2),
//     FlSpot(19, 7.3),
//     FlSpot(20, 7.5),
//     FlSpot(21, 7.6),
//     FlSpot(22, 7.8),
//     FlSpot(23, 7.9),
//     FlSpot(24, 8.1),
//     FlSpot(25, 8.2),
//     FlSpot(26, 8.4),
//     FlSpot(27, 8.5),
//     FlSpot(28, 8.6),
//     FlSpot(29, 8.8),
//     FlSpot(30, 8.9),
//     FlSpot(31, 9.0),
//     FlSpot(32, 9.1),
//     FlSpot(33, 9.3),
//     FlSpot(34, 9.4),
//     FlSpot(35, 9.5),
//     FlSpot(36, 9.6),
//     FlSpot(37, 9.7),
//     FlSpot(38, 9.8),
//     FlSpot(39, 9.9),
//     FlSpot(40, 10.1),
//     FlSpot(41, 10.2),
//     FlSpot(42, 10.3),
//     FlSpot(43, 10.4),
//     FlSpot(44, 10.5),
//     FlSpot(45, 10.6),
//     FlSpot(46, 10.7),
//     FlSpot(47, 10.8),
//     FlSpot(48, 10.9),
//     FlSpot(49, 11.0),
//     FlSpot(50, 11.1),
//     FlSpot(51, 11.2),
//     FlSpot(52, 11.3),
//     FlSpot(53, 11.4),
//     FlSpot(54, 11.5),
//     FlSpot(55, 11.6),
//     FlSpot(56, 11.7),
//     FlSpot(57, 11.8),
//     FlSpot(58, 11.9),
//     FlSpot(59, 12.0),
//     FlSpot(60, 12.1),
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
                                    FlSpot(0, 3.7),
                                    FlSpot(1, 4.8),
                                    FlSpot(2, 5.8),
                                    FlSpot(3, 6.6),
                                    FlSpot(4, 7.3),
                                    FlSpot(5, 7.8),
                                    FlSpot(6, 8.2),
                                    FlSpot(7, 8.6),
                                    FlSpot(8, 9.0),
                                    FlSpot(9, 9.3),
                                    FlSpot(10, 9.6),
                                    FlSpot(11, 9.9),
                                    FlSpot(12, 10.1),
                                    FlSpot(13, 10.4),
                                    FlSpot(14, 10.6),
                                    FlSpot(15, 10.9),
                                    FlSpot(16, 11.1),
                                    FlSpot(17, 11.4),
                                    FlSpot(18, 11.6),
                                    FlSpot(19, 11.8),
                                    FlSpot(20, 12.1),
                                    FlSpot(21, 12.3),
                                    FlSpot(22, 12.5),
                                    FlSpot(23, 12.8),
                                    FlSpot(24, 13.0),
                                    FlSpot(25, 13.3),
                                    FlSpot(26, 13.5),
                                    FlSpot(27, 13.7),
                                    FlSpot(28, 14.0),
                                    FlSpot(29, 14.2),
                                    FlSpot(30, 14.4),
                                    FlSpot(31, 14.7),
                                    FlSpot(32, 14.9),
                                    FlSpot(33, 15.1),
                                    FlSpot(34, 15.4),
                                    FlSpot(35, 15.6),
                                    FlSpot(36, 15.8),
                                    FlSpot(37, 16.0),
                                    FlSpot(38, 16.3),
                                    FlSpot(39, 16.5),
                                    FlSpot(40, 16.7),
                                    FlSpot(41, 16.9),
                                    FlSpot(42, 17.2),
                                    FlSpot(43, 17.4),
                                    FlSpot(44, 17.6),
                                    FlSpot(45, 17.8),
                                    FlSpot(46, 18.1),
                                    FlSpot(47, 18.3),
                                    FlSpot(48, 18.5),
                                    FlSpot(49, 18.8),
                                    FlSpot(50, 19.0),
                                    FlSpot(51, 19.2),
                                    FlSpot(52, 19.4),
                                    FlSpot(53, 19.7),
                                    FlSpot(54, 19.9),
                                    FlSpot(55, 20.1),
                                    FlSpot(56, 20.3),
                                    FlSpot(57, 20.6),
                                    FlSpot(58, 20.8),
                                    FlSpot(59, 21.0),
                                    FlSpot(60, 21.2),
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
                                    FlSpot(0, 4.2),
                                    FlSpot(1, 5.5),
                                    FlSpot(2, 6.6),
                                    FlSpot(3, 7.5),
                                    FlSpot(4, 8.2),
                                    FlSpot(5, 8.8),
                                    FlSpot(6, 9.3),
                                    FlSpot(7, 9.8),
                                    FlSpot(8, 10.2),
                                    FlSpot(9, 10.5),
                                    FlSpot(10, 10.9),
                                    FlSpot(11, 11.2),
                                    FlSpot(12, 11.5),
                                    FlSpot(13, 11.8),
                                    FlSpot(14, 12.1),
                                    FlSpot(15, 12.4),
                                    FlSpot(16, 12.6),
                                    FlSpot(17, 12.9),
                                    FlSpot(18, 13.2),
                                    FlSpot(19, 13.5),
                                    FlSpot(20, 13.7),
                                    FlSpot(21, 14.0),
                                    FlSpot(22, 14.3),
                                    FlSpot(23, 14.6),
                                    FlSpot(24, 14.8),
                                    FlSpot(25, 15.1),
                                    FlSpot(26, 15.4),
                                    FlSpot(27, 15.7),
                                    FlSpot(28, 16.0),
                                    FlSpot(29, 16.2),
                                    FlSpot(30, 16.5),
                                    FlSpot(31, 16.8),
                                    FlSpot(32, 17.1),
                                    FlSpot(33, 17.3),
                                    FlSpot(34, 17.6),
                                    FlSpot(35, 17.9),
                                    FlSpot(36, 18.1),
                                    FlSpot(37, 18.4),
                                    FlSpot(38, 18.7),
                                    FlSpot(39, 19.0),
                                    FlSpot(40, 19.2),
                                    FlSpot(41, 19.5),
                                    FlSpot(42, 19.8),
                                    FlSpot(43, 20.1),
                                    FlSpot(44, 20.4),
                                    FlSpot(45, 20.7),
                                    FlSpot(46, 20.9),
                                    FlSpot(47, 21.2),
                                    FlSpot(48, 21.5),
                                    FlSpot(49, 21.8),
                                    FlSpot(50, 22.1),
                                    FlSpot(51, 22.4),
                                    FlSpot(52, 22.6),
                                    FlSpot(53, 22.9),
                                    FlSpot(54, 23.2),
                                    FlSpot(55, 23.5),
                                    FlSpot(56, 23.8),
                                    FlSpot(57, 24.1),
                                    FlSpot(58, 24.4),
                                    FlSpot(59, 24.6),
                                    FlSpot(60, 24.9),
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
//     FlSpot(0, 4.8),
//     FlSpot(1, 6.2),
//     FlSpot(2, 7.5),
//     FlSpot(3, 8.5),
//     FlSpot(4, 9.3),
//     FlSpot(5, 10.0),
//     FlSpot(6, 10.6),
//     FlSpot(7, 11.1),
//     FlSpot(8, 11.6),
//     FlSpot(9, 12.0),
//     FlSpot(10, 12.4),
//     FlSpot(11, 12.8),
//     FlSpot(12, 13.1),
//     FlSpot(13, 13.5),
//     FlSpot(14, 13.8),
//     FlSpot(15, 14.1),
//     FlSpot(16, 14.5),
//     FlSpot(17, 14.8),
//     FlSpot(18, 15.1),
//     FlSpot(19, 15.4),
//     FlSpot(20, 15.7),
//     FlSpot(21, 16.0),
//     FlSpot(22, 16.4),
//     FlSpot(23, 16.7),
//     FlSpot(24, 17.0),
//     FlSpot(25, 17.3),
//     FlSpot(26, 17.7),
//     FlSpot(27, 18.0),
//     FlSpot(28, 18.3),
//     FlSpot(29, 18.7),
//     FlSpot(30, 19.0),
//     FlSpot(31, 19.3),
//     FlSpot(32, 19.6),
//     FlSpot(33, 20.0),
//     FlSpot(34, 20.3),
//     FlSpot(35, 20.6),
//     FlSpot(36, 20.9),
//     FlSpot(37, 21.3),
//     FlSpot(38, 21.6),
//     FlSpot(39, 22.0),
//     FlSpot(40, 22.3),
//     FlSpot(41, 22.7),
//     FlSpot(42, 23.0),
//     FlSpot(43, 23.4),
//     FlSpot(44, 23.7),
//     FlSpot(45, 24.1),
//     FlSpot(46, 24.5),
//     FlSpot(47, 24.8),
//     FlSpot(48, 25.2),
//     FlSpot(49, 25.5),
//     FlSpot(50, 25.9),
//     FlSpot(51, 26.3),
//     FlSpot(52, 26.6),
//     FlSpot(53, 27.0),
//     FlSpot(54, 27.4),
//     FlSpot(55, 27.7),
//     FlSpot(56, 28.1),
//     FlSpot(57, 28.5),
//     FlSpot(58, 28.8),
//     FlSpot(59, 29.2),
//     FlSpot(60, 29.5),
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
                          swapAnimationDuration: Duration(milliseconds: 1000),
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
