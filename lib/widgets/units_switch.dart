import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitsSwitch extends StatefulWidget {
  const UnitsSwitch({Key? key}) : super(key: key);
  

  @override
  State<UnitsSwitch> createState() => _UnitsSwitchState();
}

class _UnitsSwitchState extends State<UnitsSwitch> {
  late int currentUnit;
  bool isImperial = false;

  void getCurrentUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUnit = prefs.getInt('currentUnit')!;
  }

  @override
  void initState() {
    getCurrentUnit();
    currentUnit == 1 ? isImperial = true : isImperial = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isImperial,
      onChanged: (value) {
        setState(() {
          isImperial = value;

        });
      },
    );
  }
}