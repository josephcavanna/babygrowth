import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AddEntry extends StatefulWidget {
  final String? babyName;
  final bool? isGirl;
  final int? currentUnit;
  const AddEntry({Key? key, this.babyName, this.isGirl, this.currentUnit}) : super(key: key);

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
              widget.currentUnit == 0 ? enterWeightMetric() : enterWeightImperial(),
              widget.currentUnit == 0 ? enterHeightMetric() : enterHeightImperial(),
              pickDateWidget(),
              widget.currentUnit == 0
                  ? addButton(
                      context: context,
                      heightUnit: heightCm,
                      weightUnit: weightKg,
                    )
                  : addButton(
                      context: context,
                      heightUnit: heightInches,
                      weightUnit: weightPounds,
                      weightUnitAdd: weightOunces,
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
        borderRadius: const BorderRadius.all(
          Radius.circular(75.0),
        ),
        color: Colors.grey[200],
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
        color: Colors.grey[200],
        borderRadius: const BorderRadius.all(
          Radius.circular(75.0),
        ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(75.0),
        ),
        color: Colors.grey[200],
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
                  weightPounds =
                      double.parse(newValue.replaceAll(RegExp(r','), '.'));
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
              padding: const EdgeInsets.only(right: 25.0),
              child: TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (newValue) {
                  weightOunces =
                      double.parse(newValue.replaceAll(RegExp(r','), '.'));
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.all(
          Radius.circular(75.0),
        ),
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
                  heightInches = double.parse(newValue);
                },
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
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

  Container addButton(
      {BuildContext? context,
      double? heightUnit,
      double? weightUnit,
      double? weightUnitAdd}) {
    var height = widget.currentUnit == 0 ? heightUnit : (heightUnit ?? 0) * 2.54;
    var weight = widget.currentUnit == 0
        ? weightUnit
        : (weightUnit ?? 0) / 2.205 + (weightUnitAdd ?? 0) / 35.274;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.all(
          Radius.circular(75.0),
        ),
      ),
      child: MaterialButton(
        child: const Text('Add'),
        onPressed: () {
          if (_entryDate == null) {
            showDialog(
              context: context!,
              builder: (context) => AlertDialog(
                title: const Text('Please pick a date'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (height == null || weight == null) {
            showDialog(
              context: context!,
              builder: (context) => AlertDialog(
                title: const Text('Please enter a weight or height entry'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Try Again'),
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
        color: Colors.grey[200],
        borderRadius: const BorderRadius.all(
          Radius.circular(75.0),
        ),
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
