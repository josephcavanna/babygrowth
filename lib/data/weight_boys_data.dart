import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_spots.dart';

enum AgeTypeWB { baby, other }

class WeightBoysData extends StatefulWidget {
  final String? babyName;
  final Timestamp? age;
  final AgeTypeWB? ageTypeWB;
  final bool? dotsSwitch;

  const WeightBoysData({
    Key? key,
    this.babyName,
    this.age,
    this.ageTypeWB,
    this.dotsSwitch,
  }) : super(key: key);

  @override
  State<WeightBoysData> createState() => _WeightBoysDataState();
}

class _WeightBoysDataState extends State<WeightBoysData> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late int? currentUnit;

  void getCurrentUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUnit = prefs.getInt('currentUnit');
  }

  @override
  void initState() {
    super.initState();
    getCurrentUnit();
  }

  @override
  Widget build(BuildContext context) {
    var ageTypeWB = widget.ageTypeWB;
    List<FlSpot> boysMedianSpots = DataSpots().boysWeightMedianSpots;
    List<FlSpot> boysSdMinusOneSpots = DataSpots().boysWeightSdMinusOneSpots;
    List<FlSpot> boysSdMinusTwoSpots = DataSpots().boysWeightSdMinusTwoSpots;
    List<FlSpot> boysSdPlusOneSpots = DataSpots().boysWeightSdPlusOneSpots;
    List<FlSpot> boysSdPlusTwoSpots = DataSpots().boysWeightSdPlusTwoSpots;
    if (ageTypeWB == AgeTypeWB.other) {
      boysMedianSpots.addAll(DataSpots().boysWeightMedianSpotsExtra);
      boysSdMinusOneSpots.addAll(DataSpots().boysWeightSdMinusOneSpotsExtra);
      boysSdMinusTwoSpots.addAll(DataSpots().boysWeightSdMinusTwoSpotsExtra);
      boysSdPlusOneSpots.addAll(DataSpots().boysWeightSdPlusOneSpotsExtra);
      boysSdPlusTwoSpots.addAll(DataSpots().boysWeightSdPlusTwoSpotsExtra);
    }
    return StreamBuilder(
      stream: _firestore
          .collection(_auth.currentUser!.uid)
          .doc(widget.babyName)
          .collection('entries')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final entries = snapshot.data!.docs;
        List<FlSpot> babyLogEntries = [];
        for (var entry in entries) {
          final weight = entry.get('weight');
          if (weight != null) {
            final Timestamp date = entry.get('date');
            final monthDate =
                DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
                        .difference(DateTime.fromMillisecondsSinceEpoch(
                            widget.age!.millisecondsSinceEpoch))
                        .inDays /
                    30;

            final babyLogEntry = FlSpot(monthDate, weight);
            babyLogEntries.add(babyLogEntry);
          }
        }
        return Container(
          padding:
              const EdgeInsets.only(left: 15, right: 10, bottom: 25, top: 25),
          decoration: const BoxDecoration(
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
                        ? const EdgeInsets.only(top: 40.0)
                        : const EdgeInsets.only(top: 5.0),
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
                          maxX: ageTypeWB == AgeTypeWB.baby ? 12.001 : 60.01,
                          maxY: ageTypeWB == AgeTypeWB.baby ? currentUnit == 0 ? 13.001 : 13.61 : currentUnit == 0 ? 25.001 : 24.95,
                          lineTouchData: LineTouchData(
                            enabled: false,
                            touchCallback: (FlTouchEvent? touchEvent,
                                LineTouchResponse? touchResponse) {},
                            handleBuiltInTouches: true,
                          ),
                          gridData: FlGridData(
                            drawVerticalLine: true,
                            // drawHorizontalLine: true,
                            show: true,
                            getDrawingHorizontalLine: (value) =>
                                FlLine(color: Colors.black12, strokeWidth: 1),
                            getDrawingVerticalLine: (value) =>
                                FlLine(color: Colors.black12, strokeWidth: 1),
                            horizontalInterval: currentUnit == 0 ? ageTypeWB == AgeTypeWB.baby ? 0.5 : 1 : 0.453592,
                            verticalInterval:
                                ageTypeWB == AgeTypeWB.baby ? 1 : 6,
                          ),
                          titlesData: FlTitlesData(
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                reservedSize: 22,
                                getTitlesWidget: ageTypeWB == AgeTypeWB.baby
                                    ? babyXAxisTitlesWidget
                                    : otherXAxisTitlesWidget,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                interval: currentUnit == 0 ? 1 : 2.2675,
                                showTitles: true,
                                getTitlesWidget: ageTypeWB == AgeTypeWB.baby
                                    ? currentUnit == 0
                                        ? (value, titleMeta) {
                                            switch (value.toInt()) {
                                              case 3:
                                                return const FittedBox(
                                                  child: Text(' 3 kg'),
                                                );
                                              case 4:
                                                return const FittedBox(
                                                  child: Text(' 4 kg'),
                                                );
                                              case 5:
                                                return const FittedBox(
                                                  child: Text(' 5 kg'),
                                                );
                                              case 6:
                                                return const FittedBox(
                                                  child: Text(' 6 kg'),
                                                );
                                              case 7:
                                                return const FittedBox(
                                                  child: Text(' 7 kg'),
                                                );
                                              case 8:
                                                return const FittedBox(
                                                  child: Text(' 8 kg'),
                                                );
                                              case 9:
                                                return const FittedBox(
                                                  child: Text(' 9 kg'),
                                                );
                                              case 10:
                                                return const FittedBox(
                                                  child: Text('10 kg'),
                                                );
                                              case 11:
                                                return const FittedBox(
                                                  child: Text('11 kg'),
                                                );
                                              case 12:
                                                return const FittedBox(
                                                  child: Text('12 kg'),
                                                );
                                              case 13:
                                                return const FittedBox(
                                                  child: Text('13 kg'),
                                                );
                                            
                                            }
                                            return const Text('');
                                          }
                                        : (value, meta) {
                                           return FittedBox(
                                              child: Text(
                                                '${(value * 2.205).toStringAsFixed(0)} lb',
                                              ),
                                            );
                                            
                                        }
                                    : currentUnit == 0
                                        ? (value, titleMeta) {
                                            switch (value.toInt()) {
                                              case 5:
                                                return const FittedBox(
                                                  child: Text(' 5 kg'),
                                                );
                                              case 10:
                                                return const FittedBox(
                                                  child: Text('10 kg'),
                                                );
                                              case 15:
                                                return const FittedBox(
                                                  child: Text('15 kg'),
                                                );
                                              case 20:
                                                return const FittedBox(
                                                  child: Text('20 kg'),
                                                );
                                              case 25:
                                                return const FittedBox(
                                                  child: Text('25 kg'),
                                                );
                                            }
                                            return const Text('');
                                          }
                                        : (value, titleMeta) {
                                            return FittedBox(
                                              child: Text(
                                                '${(value * 2.205).toStringAsFixed(0)} lb',
                                              ),
                                            );
                                          },
                                reservedSize: 26,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.deepOrangeAccent[100]!,
                                width: 3,
                              ),
                              left: const BorderSide(
                                color: Colors.transparent,
                              ),
                              right: const BorderSide(
                                color: Colors.transparent,
                              ),
                              top: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                          lineBarsData: [
// median boys 0-5 years
                            LineChartBarData(
                              spots: boysMedianSpots,
                              isCurved: true,
                              color: Colors.grey,
                              barWidth: 1,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: false,
                              ),
                              dotData: FlDotData(show: false),
                            ),
// sd-1 boys 0-5 years
                            LineChartBarData(
                              spots: boysSdMinusOneSpots,
                              isCurved: true,
                              color: Colors.red.withOpacity(0.3),
                              barWidth: 1,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: false,
                              ),
                              dotData: FlDotData(show: false),
                            ),
// sd-2 boys 0-5 years
                            LineChartBarData(
                              spots: boysSdMinusTwoSpots,
                              isCurved: true,
                              color: Colors.green.withOpacity(0.3),
                              barWidth: 1,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: false,
                              ),
                              dotData: FlDotData(show: false),
                            ),
// sd+1 boys 0-5 years
                            LineChartBarData(
                              spots: boysSdPlusOneSpots,
                              isCurved: true,
                              color: Colors.red.withOpacity(0.3),
                              barWidth: 1,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: false,
                              ),
                              dotData: FlDotData(show: false),
                            ),
// sd+2 boys 0-5 years
                            LineChartBarData(
                              spots: boysSdPlusTwoSpots,
                              isCurved: true,
                              color: Colors.green.withOpacity(0.3),
                              barWidth: 1,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: false,
                              ),
                              dotData: FlDotData(show: false),
                            ),
// Baby Log entries
                            LineChartBarData(
                              spots: babyLogEntries,
                              isCurved: true,
                              preventCurveOverShooting: true,
                              color: Colors.blueAccent,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: false,
                              ),
                              dotData: FlDotData(
                                show: widget.dotsSwitch,
                              ),
                            )
                          ],
                        ),
                        swapAnimationDuration:
                            const Duration(milliseconds: 250),
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

  Widget otherXAxisTitlesWidget(value, TitleMeta titleMeta) {
    switch (value.toInt()) {
      // case 0:
      //   return const Text('0');
      case 12:
        return const Text('1 yr');
      case 24:
        return const Text('2 yr');
      case 36:
        return const Text('3 yr');
      case 48:
        return const Text('4 yr');
      case 60:
        return const Text('5 yr');
    }
    return const Text('');
  }

  Widget babyXAxisTitlesWidget(value, TitleMeta titleMeta) {
    switch (value.toInt()) {
      case 3:
        return const Text(' 3mo');
      case 6:
        return const Text(' 6mo');
      case 9:
        return const Text(' 9mo');
      case 12:
        return const Text('12mo');
    }
    return const Text('');
  }

  // Widget otherYAxisTitlesWidget(value, TitleMeta titleMeta)

  // Widget babyYAxisTitlesWidget(value, TitleMeta titleMeta)
}
