import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitNotifier extends StatefulWidget with ChangeNotifier {
  @override
  _UnitNotifierState createState() => _UnitNotifierState();
}

class _UnitNotifierState extends State<UnitNotifier> {
  List<bool> unitSelected;
  int currentUnit;
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
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      renderBorder: true,
      borderColor: Colors.black,
      color: Colors.black,
      borderWidth: 1,
      disabledBorderColor: Colors.black,
      selectedBorderColor: Colors.black,
      fillColor: Colors.black,
      splashColor: Colors.grey,
      selectedColor: Colors.white,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('cm / kg'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('in / lbs'),
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
        print(currentUnit);
      },
    );
  }
}
