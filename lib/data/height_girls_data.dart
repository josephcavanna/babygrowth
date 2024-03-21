import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_spots.dart';

enum AgeTypeHG { baby, other }

class HeightGirlsData extends StatefulWidget {
  final String? babyName;
  final Timestamp? age;
  final AgeTypeHG? ageTypeHG;
  final bool? dotsSwitch;
  const HeightGirlsData({
    Key? key,
    this.babyName,
    this.age,
    this.ageTypeHG,
    this.dotsSwitch,
  }) : super(key: key);

  @override
  State<HeightGirlsData> createState() => _HeightGirlsDataState();
}

class _HeightGirlsDataState extends State<HeightGirlsData> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late int? currentUnit;

  void getCurrentUnit() async {
    currentUnit = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUnit = prefs.getInt('currentUnit')!;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUnit();
  }

  @override
  Widget build(BuildContext context) {
    var ageTypeHG = widget.ageTypeHG;
    List<FlSpot> girlsMedianSpots = DataSpots().girlsHeightMedianSpots;
    List<FlSpot> girlsSdMinusOneSpots = DataSpots().girlsHeightSdMinusOneSpots;
    List<FlSpot> girlsSdMinusTwoSpots = DataSpots().girlsHeightSdMinusTwoSpots;
    List<FlSpot> girlsSdPlusOneSpots = DataSpots().girlsHeightSdPlusOneSpots;
    List<FlSpot> girlsSdPlusTwoSpots = DataSpots().girlsHeightSdPlusTwoSpots;
    if (ageTypeHG == AgeTypeHG.other) {
      girlsMedianSpots.addAll(DataSpots().girlsHeightMedianSpotsExtra);
      girlsSdMinusOneSpots.addAll(DataSpots().girlsHeightSdMinusOneSpotsExtra);
      girlsSdMinusTwoSpots.addAll(DataSpots().girlsHeightSdMinusTwoSpotsExtra);
      girlsSdPlusOneSpots.addAll(DataSpots().girlsHeightSdPlusOneSpotsExtra);
      girlsSdPlusTwoSpots.addAll(DataSpots().girlsHeightSdPlusTwoSpotsExtra);
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
            final height = entry.get('height');
            if (height != null) {
              final double heightDouble = height.toDouble();
              final Timestamp date = entry.get('date');
              final monthDate = DateTime.fromMillisecondsSinceEpoch(
                          date.millisecondsSinceEpoch)
                      .difference(DateTime.fromMillisecondsSinceEpoch(
                          widget.age!.millisecondsSinceEpoch))
                      .inDays /
                  30;

              final babyLogEntry = FlSpot(monthDate, heightDouble);
              babyLogEntries.add(babyLogEntry);
            }
          }
          return Container(
            padding:
                const EdgeInsets.only(left: 15, right: 15, bottom: 25, top: 25),
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
                            maxX: ageTypeHG == AgeTypeHG.baby ? 12.001 : 60.01,
                            maxY: ageTypeHG == AgeTypeHG.baby
                                ? currentUnit == 0
                                    ? 85.001
                                    : 83.83
                                : currentUnit == 0
                                    ? 125.001
                                    : 127,
                            lineTouchData: LineTouchData(
                              enabled: false,
                              touchCallback: (FlTouchEvent? touchEvent,
                                  LineTouchResponse? touchResponse) {},
                              handleBuiltInTouches: true,
                            ),
                            gridData: FlGridData(
                              drawVerticalLine: true,
                              show: true,
                              getDrawingHorizontalLine: (value) => const FlLine(
                                  color: Colors.black12, strokeWidth: 1),
                              getDrawingVerticalLine: (value) => const FlLine(
                                  color: Colors.black12, strokeWidth: 1),
                              horizontalInterval: currentUnit == 0
                                  ? ageTypeHG == AgeTypeHG.baby
                                      ? 1
                                      : 5
                                  : 2.54,
                              verticalInterval:
                                  ageTypeHG == AgeTypeHG.baby ? 1 : 6,
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  interval: 1,
                                  showTitles: true,
                                  getTitlesWidget: ageTypeHG == AgeTypeHG.baby
                                      ? babyXAxisTitlesWidget
                                      : otherXAxisTitlesWidget,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  interval: currentUnit == 0 ? 5 : 12.7,
                                  showTitles: true,
                                  getTitlesWidget: ageTypeHG == AgeTypeHG.baby
                                      ? currentUnit == 0
                                          ? (value, meta) {
                                              switch (value.toInt()) {
                                                case 45:
                                                  return const FittedBox(
                                                      child: Text('45 cm'));
                                                case 50:
                                                  return const FittedBox(
                                                      child: Text('50 cm'));
                                                case 55:
                                                  return const FittedBox(
                                                      child: Text('55 cm'));
                                                case 60:
                                                  return const FittedBox(
                                                      child: Text('60 cm'));
                                                case 65:
                                                  return const FittedBox(
                                                      child: Text('65 cm'));
                                                case 70:
                                                  return const FittedBox(
                                                      child: Text('70 cm'));
                                                case 75:
                                                  return const FittedBox(
                                                      child: Text('75 cm'));
                                                case 80:
                                                  return const FittedBox(
                                                      child: Text('80 cm'));
                                                case 85:
                                                  return const FittedBox(
                                                      child: Text('85 cm'));
                                              }
                                              return const Text('');
                                            }
                                          : (value, meta) {
                                              return FittedBox(
                                                child: Text(
                                                    '${(value / 2.54).toStringAsFixed(0)} in'),
                                              );
                                            }
                                      : currentUnit == 0
                                          ? (value, meta) {
                                              switch (value.toInt()) {
                                                case 45:
                                                  return const FittedBox(
                                                      child: Text(' 45 cm'));
                                                case 50:
                                                  return const FittedBox(
                                                      child: Text(' 50 cm'));
                                                case 55:
                                                  return const FittedBox(
                                                      child: Text(' 55 cm'));
                                                case 60:
                                                  return const FittedBox(
                                                      child: Text(' 60 cm'));
                                                case 65:
                                                  return const FittedBox(
                                                      child: Text(' 65 cm'));
                                                case 70:
                                                  return const FittedBox(
                                                      child: Text(' 70 cm'));
                                                case 75:
                                                  return const FittedBox(
                                                      child: Text(' 75 cm'));
                                                case 80:
                                                  return const FittedBox(
                                                      child: Text(' 80 cm'));
                                                case 85:
                                                  return const FittedBox(
                                                      child: Text(' 85 cm'));
                                                case 90:
                                                  return const FittedBox(
                                                      child: Text(' 90 cm'));
                                                case 95:
                                                  return const FittedBox(
                                                      child: Text(' 95 cm'));
                                                case 100:
                                                  return const FittedBox(
                                                      child: Text('100 cm'));
                                                case 105:
                                                  return const FittedBox(
                                                      child: Text('105 cm'));
                                                case 110:
                                                  return const FittedBox(
                                                      child: Text(' 110 cm'));
                                                case 115:
                                                  return const FittedBox(
                                                      child: Text('115 cm'));
                                                case 120:
                                                  return const FittedBox(
                                                      child: Text('120 cm'));
                                                case 125:
                                                  return const FittedBox(
                                                      child: Text('125 cm'));
                                              }
                                              return const Text('');
                                            }
                                          : (value, meta) {
                                              return FittedBox(
                                                child: Text(
                                                    '${(value / 2.54).toStringAsFixed(0)} in'),
                                              );
                                            },
                                  reservedSize: 30,
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
// median girls 0-5 years
                              LineChartBarData(
                                spots: girlsMedianSpots,
                                isCurved: true,
                                color: Colors.grey,
                                barWidth: 1,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(
                                  show: false,
                                ),
                                dotData: const FlDotData(show: false),
                              ),
// sd-1 girls 0-5 years
                              LineChartBarData(
                                spots: girlsSdMinusOneSpots,
                                isCurved: true,
                                color: Colors.red.withOpacity(0.3),
                                barWidth: 1,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(
                                  show: false,
                                ),
                                dotData: const FlDotData(show: false),
                              ),
// sd-2 girls 0-5 years
                              LineChartBarData(
                                spots: girlsSdMinusTwoSpots,
                                isCurved: true,
                                color: Colors.green.withOpacity(0.3),
                                barWidth: 1,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(
                                  show: false,
                                ),
                                dotData: const FlDotData(show: false),
                              ),

// sd+1 girls 0-5 years
                              LineChartBarData(
                                spots: girlsSdPlusOneSpots,
                                isCurved: true,
                                color: Colors.red.withOpacity(0.3),
                                barWidth: 1,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(
                                  show: false,
                                ),
                                dotData: const FlDotData(show: false),
                              ),
// sd+2 girls 0-5 years
                              LineChartBarData(
                                spots: girlsSdPlusTwoSpots,
                                isCurved: true,
                                color: Colors.green.withOpacity(0.3),
                                barWidth: 1,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(
                                  show: false,
                                ),
                                dotData: const FlDotData(show: false),
                              ),

// Baby Log entries
                              LineChartBarData(
                                spots: babyLogEntries,
                                isCurved: true,
                                // preventCurveOverShooting: true,
                                color: Colors.pinkAccent,
                                barWidth: 2,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(
                                  show: false,
                                ),
                                dotData: FlDotData(
                                  show: widget.dotsSwitch!,
                                ),
                              )
                            ],
                          ),
                          // swapAnimationDuration:
                          //     const Duration(milliseconds: 250),
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

  Widget otherXAxisTitlesWidget(value, TitleMeta titleMeta) {
    switch (value.toInt()) {
      case 12:
        return const Text('1 year');
      case 24:
        return const Text('2 years');
      case 36:
        return const Text('3 years');
      case 48:
        return const Text('4 years');
      case 60:
        return const Text('5 years');
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
}
