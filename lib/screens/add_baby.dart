import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';

class AddBaby extends StatefulWidget {
  @override
  _AddBabyState createState() => _AddBabyState();
}

class _AddBabyState extends State<AddBaby> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String babyName;
  double babyWeight;
  double babyHeight;
  bool isGirl = true;
  DateTime _birthDay;
  int currentUnit;
  File _pickedImage;
  File savedImage;
  final picker = ImagePicker();
  int _currentStep = 0;

  @override
  void initState() {
    getCurrentUnit();
    super.initState();
  }

  // reads the user's unit preference: metric or imperial
  void getCurrentUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUnit = prefs.getInt('currentUnit' ?? 0);
  }

  continued() {
    _currentStep < 5 ? setState(() => _currentStep += 1) : null;
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.black;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: MediaQuery.of(context).orientation == Orientation.portrait
              ? [0.05, 0.35]
              : [0.3, 0.5],
          colors: [Colors.blue[200], Colors.pink[100]],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: MaterialButton(
          elevation: 0,
          height: 75,
          minWidth: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          onPressed: () {
            if (babyName == null || babyHeight == null || babyWeight == null) {
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
              _firestore.collection(_auth.currentUser.uid).doc(babyName).set({
                'birthday': _birthDay,
                'name': babyName,
                'gender': isGirl,
                'height': currentUnit == 0 ? babyHeight : (babyHeight * 2.54),
                'weight': currentUnit == 0 ? babyWeight : (babyWeight / 2.205),
                'date': DateTime.now(),
              });
              _firestore
                  .collection(_auth.currentUser.uid)
                  .doc(babyName)
                  .collection('entries')
                  .doc(DateTime.fromMillisecondsSinceEpoch(
                          _birthDay.millisecondsSinceEpoch)
                      .toString())
                  .set({
                'date': _birthDay,
                'height': currentUnit == 0 ? babyHeight : (babyHeight * 2.54),
                'weight': currentUnit == 0 ? babyWeight : (babyWeight / 2.205),
              });
              Navigator.pop(context);
            }
          },
          child: Text(
            'Add Baby',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                CupertinoIcons.back,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context)),
          title: Text(
            'New Baby',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          padding: EdgeInsets.only(right: 15),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white.withOpacity(0.6),
          child: Theme(
            data: ThemeData(
              colorScheme: ColorScheme.light(primary: Colors.black),
            ),
            child: Stepper(
              controlsBuilder: (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: <Widget>[
                      _currentStep != 5
                          ? TextButton(
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                              ),
                              onPressed: onStepContinue,
                              child: Text('NEXT'),
                            )
                          : Text(''),
                      _currentStep != 0
                          ? TextButton(
                              onPressed: onStepCancel,
                              child: Text('CANCEL'),
                            )
                          : Text(''),
                    ],
                  ),
                );
              },
              currentStep: _currentStep,
              onStepContinue: continued,
              onStepCancel: cancel,
              onStepTapped: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              steps: [
                Step(
                  title: Text('Name'),
                  content: TextField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: borderColor, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: borderColor, width: 2.0),
                        ),
                        hintText: 'Enter name',
                        hintStyle: TextStyle(color: Colors.grey)),
                    onChanged: (newValue) => babyName = newValue,
                    textAlign: TextAlign.center,
                  ),
                ),
                Step(
                  title: Text('Birth weight'),
                  content: TextField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: borderColor, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: borderColor, width: 2.0),
                        ),
                        hintText: 'Enter birth weight',
                        hintStyle: TextStyle(color: Colors.grey)),
                    onChanged: (newValue) => babyWeight =
                        double.parse(newValue.replaceAll(RegExp(r','), '.')),
                    textAlign: TextAlign.center,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                Step(
                  title: Text('Birth height'),
                  content: TextField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: borderColor, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: borderColor, width: 1.3),
                        ),
                        hintText: 'Enter birth height',
                        hintStyle: TextStyle(color: Colors.grey)),
                    onChanged: (newValue) =>
                        babyHeight = double.parse(newValue),
                    textAlign: TextAlign.center,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                Step(
                  title: Text('Gender'),
                  content: Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGenderSelect(
                              gender: MaterialCommunityIcons.gender_male,
                              selected: !isGirl,
                              onTapAction: () {
                                setState(() {
                                  isGirl = false;
                                });
                              }),
                          SizedBox(width: 10),
                          _buildGenderSelect(
                              gender: MaterialCommunityIcons.gender_female,
                              selected: isGirl,
                              onTapAction: () {
                                setState(() {
                                  isGirl = true;
                                });
                              }),
                        ]),
                  ),
                ),
                Step(
                  title: Text('Birthday'),
                  content: MaterialButton(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _birthDay == null
                            ? Text(
                                'Pick a date',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 24.0),
                              )
                            : Text(
                                '${_birthDay.day}' +
                                    '-${_birthDay.month}' +
                                    '-${_birthDay.year}',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 30.0),
                                textAlign: TextAlign.center,
                              ),
                      ],
                    ),
                    onPressed:
                        Platform.isAndroid ? pickDateAndroid : pickDateIOS,
                  ),
                ),
                Step(
                  title: Text('Profile photo'),
                  content: Column(
                    children: [
                      GestureDetector(
                        onTap: () => showCupertinoModalPopup(
                          context: context,
                          builder: (context) => CupertinoActionSheet(
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  imageSourcePicker(ImageSource.gallery);
                                },
                                child: Text(
                                  'Gallery',
                                ),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  imageSourcePicker(ImageSource.camera);
                                },
                                child: Text(
                                  'Camera',
                                ),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                              ),
                            ),
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white70,
                          radius: 50,
                          child: _pickedImage == null
                              ? Icon(
                                  Icons.add_a_photo,
                                  color: Colors.black54,
                                  size: 50,
                                )
                              : null,
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage)
                              : null,
                        ),
                      ),
                    ],
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
    showDatePicker(
      context: context,
      initialDate: _birthDay == null ? DateTime.now() : _birthDay,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
    ).then((value) {
      setState(() {
        _birthDay = value;
      });
    });
  }

  void pickDateIOS() {
    showModalBottomSheet(
        context: context,
        builder: (builder) => Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime:
                      _birthDay == null ? DateTime.now() : _birthDay,
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (value) {
                    setState(() {
                      _birthDay = value;
                    });
                  }),
            ));
  }

// Gender Picker Method
  Container _buildSelect({IconData icon, Color background, Color iconColor}) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0), color: background),
      child: Center(
          child: Icon(
        icon,
        color: iconColor,
        size: 24,
      )),
    );
  }

  Widget _buildGenderSelect(
      {IconData gender, bool selected, Function onTapAction}) {
    var button = selected
        ? _buildSelect(
            icon: gender,
            iconColor: Colors.white,
            background: isGirl ? Colors.pink[200] : Colors.blue[200])
        : _buildSelect(
            icon: gender, iconColor: Colors.black, background: Colors.white);
    return GestureDetector(
      child: button,
      onTap: onTapAction,
    );
  }

  // Pick Image Source for Baby Profile Photo
  Future imageSourcePicker(ImageSource source) async {
    final picked = await picker.getImage(source: source, imageQuality: 70);
    if (picked != null) {
      _cropImage(picked);
    } else {
      print('Image not found');
    }
  }

  _cropImage(picked) async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: picked.path, cropStyle: CropStyle.circle);
    if (cropped != null) {
      setState(() {
        _pickedImage = cropped;
      });
      final directory = await syspaths.getApplicationDocumentsDirectory();
      String directoryPath = directory.path;
      FileImage(File('$directoryPath/$babyName}.jpg')).evict();
      File savedImage = await _pickedImage.copy('$directoryPath/$babyName.jpg');
      print(savedImage.path);
    }
  }
}
