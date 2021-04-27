import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class AddEntry extends StatefulWidget {
  final String babyName;
  final bool isGirl;
  AddEntry({this.babyName, this.isGirl});

  static const String id = 'add_entry';

  @override
  _AddEntryState createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  double height;
  double weight;
  DateTime _entryDate;
  int currentUnit;

  void getCurrentUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUnit = prefs.getInt('currentUnit' ?? 0);
  }

  @override
  void initState() {
    super.initState();
    getCurrentUnit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New entry'),
        backgroundColor:
            widget.isGirl == true ? Colors.pink[100] : Colors.blue[200],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(75.0),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.teal,
                          child: Icon(
                            MaterialCommunityIcons.scale,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(right: 25.0),
                          child: TextField(
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            onChanged: (newValue) {
                              weight = double.parse(
                                  newValue.replaceAll(RegExp(r','), '.'));
                            },
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Enter weight',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.all(
                      Radius.circular(75.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.purple,
                          child: Icon(
                            MaterialCommunityIcons.altimeter,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(right: 25.0),
                          child: TextField(
                            onChanged: (newValue) {
                              height = double.parse(newValue);
                            },
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter height',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.all(
                      Radius.circular(75.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.deepOrangeAccent,
                          child: Icon(
                            FontAwesome5.calendar,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: MaterialButton(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _entryDate == null
                                  ? Text(
                                      'Pick entry date',
                                      style: TextStyle(
                                          color: Colors.deepOrangeAccent,
                                          fontSize: 16),
                                    )
                                  : Text(
                                      '${_entryDate.day}' +
                                          '-${_entryDate.month}' +
                                          '-${_entryDate.year}',
                                      style: TextStyle(
                                          color: Colors.deepOrangeAccent,
                                          fontSize: 22.0),
                                      textAlign: TextAlign.center,
                                    ),
                            ],
                          ),
                          onPressed: Platform.isAndroid
                              ? pickDateAndroid
                              : pickDateIOS,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.all(
                      Radius.circular(75.0),
                    ),
                  ),
                  child: MaterialButton(
                    child: Text('Add'),
                    onPressed: () {
                      if (_entryDate == null ||
                          height == null ||
                          weight == null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Please fill in all fields'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Try Again'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        _firestore
                            .collection(_auth.currentUser.uid)
                            .doc(widget.babyName)
                            .collection('entries')
                            .doc(_entryDate.toString())
                            .set({
                          'date': _entryDate,
                          'height': currentUnit == 0 ? height : height * 2.54,
                          'weight': currentUnit == 0 ? weight : weight / 2.205,
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Pick Birthday Method
  void pickDateAndroid() {
    {
      showDatePicker(
        context: context,
        initialDate: _entryDate == null ? DateTime.now() : _entryDate,
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
      builder: (builder) => Container(
        height: MediaQuery.of(context).size.height * 0.3,
        child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _entryDate == null ? DateTime.now() : _entryDate,
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
