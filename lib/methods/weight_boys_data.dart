import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightBoysData extends StatefulWidget {
  final String babyName;
  final Timestamp age;

  WeightBoysData({this.babyName, this.age});

  @override
  _WeightBoysDataState createState() => _WeightBoysDataState();
}

class _WeightBoysDataState extends State<WeightBoysData> {
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
          padding: EdgeInsets.only(left: 15, right: 10, bottom: 25, top: 25),
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
                      "Weight Curve",
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
                          maxY: 25,
                          lineTouchData: LineTouchData(
                            enabled: false,
                            touchCallback: (LineTouchResponse touchResponse) {},
                            handleBuiltInTouches: true,
                          ),
                          gridData: FlGridData(
                            drawVerticalLine: true,
                            show: true,
                            getDrawingHorizontalLine: (value) =>
                                FlLine(color: Colors.black12, strokeWidth: 1),
                            getDrawingVerticalLine: (value) =>
                                FlLine(color: Colors.black12, strokeWidth: 1),
                            horizontalInterval: currentUnit == 0 ? 1 : 2.2675,
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
                                FlSpot(0, 3.3),
                                FlSpot(1, 4.5),
                                FlSpot(2, 5.6),
                                FlSpot(3, 6.4),
                                FlSpot(4, 7.0),
                                FlSpot(5, 7.5),
                                FlSpot(6, 7.9),
                                FlSpot(7, 8.3),
                                FlSpot(8, 8.6),
                                FlSpot(9, 8.9),
                                FlSpot(10, 9.2),
                                FlSpot(11, 9.4),
                                FlSpot(12, 9.6),
                                FlSpot(13, 9.9),
                                FlSpot(14, 10.1),
                                FlSpot(15, 10.3),
                                FlSpot(16, 10.5),
                                FlSpot(17, 10.7),
                                FlSpot(18, 10.9),
                                FlSpot(19, 11.1),
                                FlSpot(20, 11.3),
                                FlSpot(21, 11.5),
                                FlSpot(22, 11.8),
                                FlSpot(23, 12.0),
                                FlSpot(24, 12.2),
                                FlSpot(25, 12.4),
                                FlSpot(26, 12.5),
                                FlSpot(27, 12.7),
                                FlSpot(28, 12.9),
                                FlSpot(29, 13.1),
                                FlSpot(30, 13.3),
                                FlSpot(31, 13.5),
                                FlSpot(32, 13.7),
                                FlSpot(33, 13.8),
                                FlSpot(34, 14.0),
                                FlSpot(35, 14.2),
                                FlSpot(36, 14.3),
                                FlSpot(37, 14.5),
                                FlSpot(38, 14.7),
                                FlSpot(39, 14.8),
                                FlSpot(40, 15.0),
                                FlSpot(41, 15.2),
                                FlSpot(42, 15.3),
                                FlSpot(43, 15.5),
                                FlSpot(44, 15.7),
                                FlSpot(45, 15.8),
                                FlSpot(46, 16.0),
                                FlSpot(47, 16.2),
                                FlSpot(48, 16.3),
                                FlSpot(49, 16.5),
                                FlSpot(50, 16.7),
                                FlSpot(51, 16.8),
                                FlSpot(52, 17.0),
                                FlSpot(53, 17.2),
                                FlSpot(54, 17.3),
                                FlSpot(55, 17.5),
                                FlSpot(56, 17.7),
                                FlSpot(57, 17.8),
                                FlSpot(58, 18.0),
                                FlSpot(59, 18.2),
                                FlSpot(60, 18.3),
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
                                FlSpot(0, 2.9),
                                FlSpot(1, 3.9),
                                FlSpot(2, 4.9),
                                FlSpot(3, 5.7),
                                FlSpot(4, 6.2),
                                FlSpot(5, 6.7),
                                FlSpot(6, 7.1),
                                FlSpot(7, 7.4),
                                FlSpot(8, 7.7),
                                FlSpot(9, 8.0),
                                FlSpot(10, 8.2),
                                FlSpot(11, 8.4),
                                FlSpot(12, 8.6),
                                FlSpot(13, 8.8),
                                FlSpot(14, 9.0),
                                FlSpot(15, 9.2),
                                FlSpot(16, 9.4),
                                FlSpot(17, 9.6),
                                FlSpot(18, 9.8),
                                FlSpot(19, 10.0),
                                FlSpot(20, 10.1),
                                FlSpot(21, 10.3),
                                FlSpot(22, 10.5),
                                FlSpot(23, 10.7),
                                FlSpot(24, 10.8),
                                FlSpot(25, 11.0),
                                FlSpot(26, 11.2),
                                FlSpot(27, 11.3),
                                FlSpot(28, 11.5),
                                FlSpot(29, 11.7),
                                FlSpot(30, 11.8),
                                FlSpot(31, 12.0),
                                FlSpot(32, 12.1),
                                FlSpot(33, 12.3),
                                FlSpot(34, 12.4),
                                FlSpot(35, 12.6),
                                FlSpot(36, 12.7),
                                FlSpot(37, 12.9),
                                FlSpot(38, 13.0),
                                FlSpot(39, 13.1),
                                FlSpot(40, 13.3),
                                FlSpot(41, 13.4),
                                FlSpot(42, 13.6),
                                FlSpot(43, 13.7),
                                FlSpot(44, 13.8),
                                FlSpot(45, 14.0),
                                FlSpot(46, 14.1),
                                FlSpot(47, 14.3),
                                FlSpot(48, 14.4),
                                FlSpot(49, 14.5),
                                FlSpot(50, 14.7),
                                FlSpot(51, 14.8),
                                FlSpot(52, 15.0),
                                FlSpot(53, 15.1),
                                FlSpot(54, 15.2),
                                FlSpot(55, 15.4),
                                FlSpot(56, 15.5),
                                FlSpot(57, 15.6),
                                FlSpot(58, 15.8),
                                FlSpot(59, 15.9),
                                FlSpot(60, 16.0),
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
                                FlSpot(0, 2.5),
                                FlSpot(1, 3.4),
                                FlSpot(2, 4.3),
                                FlSpot(3, 5.0),
                                FlSpot(4, 5.6),
                                FlSpot(5, 6.0),
                                FlSpot(6, 6.4),
                                FlSpot(7, 6.7),
                                FlSpot(8, 6.9),
                                FlSpot(9, 7.1),
                                FlSpot(10, 7.4),
                                FlSpot(11, 7.6),
                                FlSpot(12, 7.7),
                                FlSpot(13, 7.9),
                                FlSpot(14, 8.1),
                                FlSpot(15, 8.3),
                                FlSpot(16, 8.4),
                                FlSpot(17, 8.6),
                                FlSpot(18, 8.8),
                                FlSpot(19, 8.9),
                                FlSpot(20, 9.1),
                                FlSpot(21, 9.2),
                                FlSpot(22, 9.4),
                                FlSpot(23, 9.5),
                                FlSpot(24, 9.7),
                                FlSpot(25, 9.8),
                                FlSpot(26, 10.0),
                                FlSpot(27, 10.1),
                                FlSpot(28, 10.2),
                                FlSpot(29, 10.4),
                                FlSpot(30, 10.5),
                                FlSpot(31, 10.7),
                                FlSpot(32, 10.8),
                                FlSpot(33, 10.9),
                                FlSpot(34, 11.0),
                                FlSpot(35, 11.2),
                                FlSpot(36, 11.3),
                                FlSpot(37, 11.4),
                                FlSpot(38, 11.5),
                                FlSpot(39, 11.6),
                                FlSpot(40, 11.8),
                                FlSpot(41, 11.9),
                                FlSpot(42, 12.0),
                                FlSpot(43, 12.1),
                                FlSpot(44, 12.2),
                                FlSpot(45, 12.4),
                                FlSpot(46, 12.5),
                                FlSpot(47, 12.6),
                                FlSpot(48, 12.7),
                                FlSpot(49, 12.8),
                                FlSpot(50, 12.9),
                                FlSpot(51, 13.1),
                                FlSpot(52, 13.2),
                                FlSpot(53, 13.3),
                                FlSpot(54, 13.4),
                                FlSpot(55, 13.5),
                                FlSpot(56, 13.6),
                                FlSpot(57, 13.7),
                                FlSpot(58, 13.8),
                                FlSpot(59, 14.0),
                                FlSpot(60, 14.1),
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
//     FlSpot(0, 2.1),
//     FlSpot(1, 2.9),
//     FlSpot(2, 3.8),
//     FlSpot(3, 4.4),
//     FlSpot(4, 4.9),
//     FlSpot(5, 5.3),
//     FlSpot(6, 5.7),
//     FlSpot(7, 5.9),
//     FlSpot(8, 6.2),
//     FlSpot(9, 6.4),
//     FlSpot(10, 6.6),
//     FlSpot(11, 6.8),
//     FlSpot(12, 6.9),
//     FlSpot(13, 7.1),
//     FlSpot(14, 7.2),
//     FlSpot(15, 7.4),
//     FlSpot(16, 7.5),
//     FlSpot(17, 7.7),
//     FlSpot(18, 7.8),
//     FlSpot(19, 8.0),
//     FlSpot(20, 8.1),
//     FlSpot(21, 8.2),
//     FlSpot(22, 8.4),
//     FlSpot(23, 8.5),
//     FlSpot(24, 8.6),
//     FlSpot(25, 8.8),
//     FlSpot(26, 8.9),
//     FlSpot(27, 9.0),
//     FlSpot(28, 9.1),
//     FlSpot(29, 9.2),
//     FlSpot(30, 9.4),
//     FlSpot(31, 9.5),
//     FlSpot(32, 9.6),
//     FlSpot(33, 9.7),
//     FlSpot(34, 9.8),
//     FlSpot(35, 9.9),
//     FlSpot(36, 10.0),
//     FlSpot(37, 10.1),
//     FlSpot(38, 10.2),
//     FlSpot(39, 10.3),
//     FlSpot(40, 10.4),
//     FlSpot(41, 10.5),
//     FlSpot(42, 10.6),
//     FlSpot(43, 10.7),
//     FlSpot(44, 10.8),
//     FlSpot(45, 10.9),
//     FlSpot(46, 11.0),
//     FlSpot(47, 11.1),
//     FlSpot(48, 11.2),
//     FlSpot(49, 11.3),
//     FlSpot(50, 11.4),
//     FlSpot(51, 11.5),
//     FlSpot(52, 11.6),
//     FlSpot(53, 11.7),
//     FlSpot(54, 11.8),
//     FlSpot(55, 11.9),
//     FlSpot(56, 12.0),
//     FlSpot(57, 12.1),
//     FlSpot(58, 12.2),
//     FlSpot(59, 12.3),
//     FlSpot(60, 12.4),
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
                                FlSpot(0, 3.9),
                                FlSpot(1, 5.1),
                                FlSpot(2, 6.3),
                                FlSpot(3, 7.2),
                                FlSpot(4, 7.8),
                                FlSpot(5, 8.4),
                                FlSpot(6, 8.8),
                                FlSpot(7, 9.2),
                                FlSpot(8, 9.6),
                                FlSpot(9, 9.9),
                                FlSpot(10, 10.2),
                                FlSpot(11, 10.5),
                                FlSpot(12, 10.8),
                                FlSpot(13, 11.0),
                                FlSpot(14, 11.3),
                                FlSpot(15, 11.5),
                                FlSpot(16, 11.7),
                                FlSpot(17, 12.0),
                                FlSpot(18, 12.2),
                                FlSpot(19, 12.5),
                                FlSpot(20, 12.7),
                                FlSpot(21, 12.9),
                                FlSpot(22, 13.2),
                                FlSpot(23, 13.4),
                                FlSpot(24, 13.6),
                                FlSpot(25, 13.9),
                                FlSpot(26, 14.1),
                                FlSpot(27, 14.3),
                                FlSpot(28, 14.5),
                                FlSpot(29, 14.8),
                                FlSpot(30, 15.0),
                                FlSpot(31, 15.2),
                                FlSpot(32, 15.4),
                                FlSpot(33, 15.6),
                                FlSpot(34, 15.8),
                                FlSpot(35, 16.0),
                                FlSpot(36, 16.2),
                                FlSpot(37, 16.4),
                                FlSpot(38, 16.6),
                                FlSpot(39, 16.8),
                                FlSpot(40, 17.0),
                                FlSpot(41, 17.2),
                                FlSpot(42, 17.4),
                                FlSpot(43, 17.6),
                                FlSpot(44, 17.8),
                                FlSpot(45, 18.0),
                                FlSpot(46, 18.2),
                                FlSpot(47, 18.4),
                                FlSpot(48, 18.6),
                                FlSpot(49, 18.8),
                                FlSpot(50, 19.0),
                                FlSpot(51, 19.2),
                                FlSpot(52, 19.4),
                                FlSpot(53, 19.6),
                                FlSpot(54, 19.8),
                                FlSpot(55, 20.0),
                                FlSpot(56, 20.2),
                                FlSpot(57, 20.4),
                                FlSpot(58, 20.6),
                                FlSpot(59, 20.8),
                                FlSpot(60, 21.0),
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
                                FlSpot(0, 4.4),
                                FlSpot(1, 5.8),
                                FlSpot(2, 7.1),
                                FlSpot(3, 8.0),
                                FlSpot(4, 8.7),
                                FlSpot(5, 9.3),
                                FlSpot(6, 9.8),
                                FlSpot(7, 10.3),
                                FlSpot(8, 10.7),
                                FlSpot(9, 11.0),
                                FlSpot(10, 11.4),
                                FlSpot(11, 11.7),
                                FlSpot(12, 12.0),
                                FlSpot(13, 12.3),
                                FlSpot(14, 12.6),
                                FlSpot(15, 12.8),
                                FlSpot(16, 13.1),
                                FlSpot(17, 13.4),
                                FlSpot(18, 13.7),
                                FlSpot(19, 13.9),
                                FlSpot(20, 14.2),
                                FlSpot(21, 14.5),
                                FlSpot(22, 14.7),
                                FlSpot(23, 15.0),
                                FlSpot(24, 15.3),
                                FlSpot(25, 15.5),
                                FlSpot(26, 15.8),
                                FlSpot(27, 16.1),
                                FlSpot(28, 16.3),
                                FlSpot(29, 16.6),
                                FlSpot(30, 16.9),
                                FlSpot(31, 17.1),
                                FlSpot(32, 17.4),
                                FlSpot(33, 17.6),
                                FlSpot(34, 17.8),
                                FlSpot(35, 18.1),
                                FlSpot(36, 18.3),
                                FlSpot(37, 18.6),
                                FlSpot(38, 18.8),
                                FlSpot(39, 19.0),
                                FlSpot(40, 19.3),
                                FlSpot(41, 19.5),
                                FlSpot(42, 19.7),
                                FlSpot(43, 20.0),
                                FlSpot(44, 20.2),
                                FlSpot(45, 20.5),
                                FlSpot(46, 20.7),
                                FlSpot(47, 20.9),
                                FlSpot(48, 21.2),
                                FlSpot(49, 21.4),
                                FlSpot(50, 21.7),
                                FlSpot(51, 21.9),
                                FlSpot(52, 22.2),
                                FlSpot(53, 22.4),
                                FlSpot(54, 22.7),
                                FlSpot(55, 22.9),
                                FlSpot(56, 23.2),
                                FlSpot(57, 23.4),
                                FlSpot(58, 23.7),
                                FlSpot(59, 23.9),
                                FlSpot(60, 24.2),
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
//     FlSpot(0, 5.0),
//     FlSpot(1, 6.6),
//     FlSpot(2, 8.0),
//     FlSpot(3, 9.0),
//     FlSpot(4, 9.7),
//     FlSpot(5, 10.4),
//     FlSpot(6, 10.9),
//     FlSpot(7, 11.4),
//     FlSpot(8, 11.9),
//     FlSpot(9, 12.3),
//     FlSpot(10, 12.7),
//     FlSpot(11, 13.0),
//     FlSpot(12, 13.3),
//     FlSpot(13, 13.7),
//     FlSpot(14, 14.0),
//     FlSpot(15, 14.3),
//     FlSpot(16, 14.6),
//     FlSpot(17, 14.9),
//     FlSpot(18, 15.3),
//     FlSpot(19, 15.6),
//     FlSpot(20, 15.9),
//     FlSpot(21, 16.2),
//     FlSpot(22, 16.5),
//     FlSpot(23, 16.8),
//     FlSpot(24, 17.1),
//     FlSpot(25, 17.5),
//     FlSpot(26, 17.8),
//     FlSpot(27, 18.1),
//     FlSpot(28, 18.4),
//     FlSpot(29, 18.7),
//     FlSpot(30, 19.0),
//     FlSpot(31, 19.3),
//     FlSpot(32, 19.6),
//     FlSpot(33, 19.9),
//     FlSpot(34, 20.2),
//     FlSpot(35, 20.4),
//     FlSpot(36, 20.7),
//     FlSpot(37, 21.0),
//     FlSpot(38, 21.3),
//     FlSpot(39, 21.6),
//     FlSpot(40, 21.9),
//     FlSpot(41, 22.1),
//     FlSpot(42, 22.4),
//     FlSpot(43, 22.7),
//     FlSpot(44, 23.0),
//     FlSpot(45, 23.3),
//     FlSpot(46, 23.6),
//     FlSpot(47, 23.9),
//     FlSpot(48, 24.2),
//     FlSpot(49, 24.5),
//     FlSpot(50, 24.8),
//     FlSpot(51, 25.1),
//     FlSpot(52, 25.4),
//     FlSpot(53, 25.7),
//     FlSpot(54, 26.0),
//     FlSpot(55, 26.3),
//     FlSpot(56, 26.6),
//     FlSpot(57, 26.9),
//     FlSpot(58, 27.2),
//     FlSpot(59, 27.6),
//     FlSpot(60, 27.9),
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
                          ],
                        ),
                        swapAnimationDuration: Duration(milliseconds: 250),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
