import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitNotifier extends StatefulWidget with ChangeNotifier {
  @override
  _UnitNotifierState createState() => _UnitNotifierState();
}

class _UnitNotifierState extends State<UnitNotifier> {
  List<bool> unitSelected;
  int currentUnit = 0;
  List<String> units = ['metric', 'imperial'];

  void initState() {
    super.initState();
    getSelectedUnit();
    unitSelected = [true, false];
  }

  saveSelectedUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList('unitSelected',
          unitSelected.map((e) => e ? 'true' : 'false').toList());
    });
    prefs.setInt('currentUnit', currentUnit);
  }

  getSelectedUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      unitSelected = (prefs
              .getStringList('unitSelected')
              ?.map((e) => e == 'true' ? true : false)
              ?.toList() ??
          [true, false]);
    });
    currentUnit = prefs.getInt('currentUnit' ?? 0);
    print(currentUnit);
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      renderBorder: true,
      borderColor: Colors.green[300],
      color: Colors.green[300],
      borderWidth: 1,
      borderRadius: BorderRadius.circular(30),
      disabledBorderColor: Colors.green[300],
      selectedBorderColor: Colors.green[300],
      fillColor: Colors.green[300],
      splashColor: Colors.grey,
      selectedColor: Colors.white,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
          child: Text(' Metric '),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
          child: Text('Imperial'),
        )
      ],
      isSelected: unitSelected,
      onPressed: (int index) {
        setState(() {
          for (int unitIndex = 0;
              unitIndex < unitSelected.length;
              unitIndex++) {
            if (unitIndex == index) {
              unitSelected[unitIndex] = true;
            } else {
              unitSelected[unitIndex] = false;
            }
          }
        });
        currentUnit = index;
        saveSelectedUnit();
      },
    );
  }
}
