import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AddEntry extends StatefulWidget {
  final String? babyName;
  final bool? isGirl;
  final int? currentUnit;
  const AddEntry({Key? key, this.babyName, this.isGirl, this.currentUnit})
      : super(key: key);

  static const String id = 'add_entry';

  @override
  State<AddEntry> createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  double? heightCm;
  double? heightInches;
  double? weightKg;
  double? weightPounds;
  double? weightOunces;
  DateTime? _entryDate;
  double? height;
  double? weight;

  @override
  void initState() {
    print(widget.currentUnit);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New entry'),
        backgroundColor:
            widget.isGirl == true ? Colors.pink[100] : Colors.blue[200],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              widget.currentUnit == 0
                  ? enterWeightMetric()
                  : enterWeightImperial(),
              widget.currentUnit == 0
                  ? enterHeightMetric()
                  : enterHeightImperial(),
              pickDateWidget(),
              addButton(
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container enterWeightMetric() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal,
              child: Icon(
                Icons.scale,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (newValue) {
                  weightKg =
                      double.parse(newValue.replaceAll(RegExp(r','), '.'));
                      weight = weightKg;
                  print('weightKg: $weightKg');
                  print('weight: $weight');
                },
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Enter weight in kg',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container enterHeightMetric() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.purple,
              child: Icon(
                Icons.height,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: TextField(
                onChanged: (newValue) {
                  heightCm = double.parse(newValue);
                  height = heightCm;
                  print('heightCm: $heightCm');
                  print(height);
                },
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter height in cm',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container enterWeightImperial() {
    double? weightPoundsToKg;
    double? weightOuncesToKg = 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal,
              child: Icon(
                Icons.scale,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 10.0),
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (newValue) {
                  weightPounds = double.parse(newValue);
                  weightPoundsToKg = weightPounds! / 2.205;
                  weight = weightOuncesToKg! + weightPoundsToKg!;
                  print('weightPounds: $weightPounds');
                  print('weightPoundstoKG: $weightPoundsToKg');
                  print('weight: $weight');
                },
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Enter pounds',
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (newValue) {
                  weightOunces = double.parse(newValue);
                  weightOuncesToKg = weightOunces! / 35.274;
                  weight = weightPoundsToKg! + weightOuncesToKg!;
                  print('weightOunces: $weightOunces');
                  print('weightOuncestoKG: $weightOuncesToKg');
                  print('weight: $weight');
                },
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Enter ounces',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container enterHeightImperial() {
    double? heightInchestoCm;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.purple,
              child: Icon(
                Icons.height,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: TextField(
                onChanged: (newValue) {
                  heightInches = double.parse(newValue.replaceAll(RegExp(r','), '.'));
                  heightInchestoCm = heightInches! * 2.54;
                  height = heightInchestoCm;
                  print('heightInches: $heightInches');
                  print('heightInchestoCm: $heightInchestoCm');
                  print('height: $height');
                },
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Enter height in inches',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container addButton({
    BuildContext? context,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: MaterialButton(
        child: const Text(
          'Add',
          style: TextStyle(fontSize: 18),
        ),
        onPressed: () {
          print('height: $height');
          print('weight: $weight');
          print('entrydate: $_entryDate');
          if (_entryDate == null) {
            showDialog(
              context: context!,
              builder: (context) => AlertDialog(
                title: const Text('Please pick a date'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          } else if (height == null && weight == null) {
            showDialog(
              context: context!,
              builder: (context) => AlertDialog(
                title: const Text('Please enter new weight or height'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          } else {
            _firestore
                .collection(_auth.currentUser!.uid)
                .doc(widget.babyName)
                .collection('entries')
                .doc(_entryDate.toString())
                .set({
              'date': _entryDate,
              'height': height,
              'weight': weight,
            });
          }
          if (height != null && weight != null) {
            _firestore
                .collection(_auth.currentUser!.uid)
                .doc(widget.babyName)
                .update({'height': height, 'weight': weight});
          } else if (height != null) {
            _firestore
                .collection(_auth.currentUser!.uid)
                .doc(widget.babyName)
                .update({'height': height});
          } else if (weight != null) {
            _firestore
                .collection(_auth.currentUser!.uid)
                .doc(widget.babyName)
                .update({'weight': weight});
          }
          Navigator.pop(context!);
        },
      ),
    );
  }

  Container pickDateWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepOrangeAccent,
              child: Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: MaterialButton(
              onPressed: Platform.isAndroid ? pickDateAndroid : pickDateIOS,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _entryDate == null
                      ? const Text(
                          'Pick a date',
                          style: TextStyle(
                              color: Colors.deepOrangeAccent, fontSize: 16),
                        )
                      : Text(
                          '${_entryDate!.day}-${_entryDate!.month}-${_entryDate!.year}',
                          style: const TextStyle(
                              color: Colors.deepOrangeAccent, fontSize: 22.0),
                          textAlign: TextAlign.center,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pickDateAndroid() {
    {
      showDatePicker(
        context: context,
        initialDate: _entryDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.year,
      ).then((value) {
        setState(() {
          _entryDate = value;
        });
      });
    }
  }

  void pickDateIOS() {
    showModalBottomSheet(
      context: context,
      builder: (builder) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _entryDate ?? DateTime.now(),
            maximumDate: DateTime.now(),
            onDateTimeChanged: (value) {
              setState(() {
                _entryDate = value;
              });
            }),
      ),
    );
  }
}
