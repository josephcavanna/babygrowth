import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class UnitNotifier extends StatefulWidget with ChangeNotifier {
  UnitNotifier({Key? key}) : super(key: key);

  @override
  State<UnitNotifier> createState() => _UnitNotifierState();
}

class _UnitNotifierState extends State<UnitNotifier> {
  late List<bool> unitSelected;
  int? currentUnit;
  List<String> units = ['metric', 'imperial'];

  @override
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
    await prefs.setInt('currentUnit', currentUnit!);
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
    currentUnit = prefs.getInt('currentUnit');
     print(currentUnit);
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
      isSelected: unitSelected,
      borderRadius: BorderRadius.circular(15),
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
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Metric'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('US Customary'),
        )
      ],
    );
  }
}
