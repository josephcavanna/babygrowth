import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';

class AddBaby extends StatefulWidget {
  final int? currentUnit;
  const AddBaby({required this.currentUnit, Key? key}) : super(key: key);

  @override
  State<AddBaby> createState() => _AddBabyState();
}

class _AddBabyState extends State<AddBaby> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? babyName;
  double? babyWeightKg;
  double? babyWeightPounds;
  double? babyWeightOunces;
  double? babyWeightUsCustomary;
  double? babyWeight;
  double? babyHeight;
  bool isGirl = true;
  DateTime? _birthDay;
  File? _pickedImage;
  File? savedImage;
  final picker = ImagePicker();
  int _currentStep = 0;

  continued() {
    _currentStep < 5 ? setState(() => _currentStep += 1) : null;
    FocusScope.of(context).requestFocus(FocusNode());
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  @override
  void initState() {
    print(widget.currentUnit);
    super.initState();
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
          colors: [Colors.blue[200]!, Colors.pink[100]!],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: MaterialButton(
          elevation: 0,
          height: 75,
          color: Colors.transparent,
          onPressed: () {
            if (babyName == null ||
                babyHeight == null ||
                (babyWeightPounds == null && babyWeightKg == null)) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Please fill in all fields'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else {
              babyWeightUsCustomary = (babyWeightPounds ?? 0) / 2.205 +
                  (babyWeightOunces ?? 0) / 35.274;
              widget.currentUnit == 0
                  ? babyWeight = babyWeightKg
                  : babyWeight = babyWeightUsCustomary;
              _firestore.collection(_auth.currentUser!.uid).doc(babyName).set({
                'birthday': _birthDay,
                'name': babyName,
                'gender': isGirl,
                'height':
                    widget.currentUnit == 0 ? babyHeight : (babyHeight! * 2.54),
                'weight': babyWeight,
                'date': DateTime.now(),
              });
              _firestore
                  .collection(_auth.currentUser!.uid)
                  .doc(babyName)
                  .collection('entries')
                  .doc(DateTime.fromMillisecondsSinceEpoch(
                          _birthDay!.millisecondsSinceEpoch)
                      .toString())
                  .set({
                'date': _birthDay,
                'height':
                    widget.currentUnit == 0 ? babyHeight : (babyHeight! * 2.54),
                'weight': babyWeight,
              });
              Navigator.pop(context);
            }
          },
          child: const Text(
            'Add Baby',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(
                CupertinoIcons.back,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context)),
          title: const Text(
            'New Baby',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          padding: const EdgeInsets.only(right: 15),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white.withOpacity(0.6),
          child: Theme(
            data: ThemeData(
              colorScheme: const ColorScheme.light(primary: Colors.black),
            ),
            child: Stepper(
              controlsBuilder: (BuildContext context, ControlsDetails details) {
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
                              onPressed: details.onStepContinue,
                              child: const Text('NEXT'),
                            )
                          : const Text(''),
                      _currentStep != 0
                          ? TextButton(
                              onPressed: details.onStepCancel,
                              child: const Text('CANCEL'),
                            )
                          : const Text(''),
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
                  title: const Text('Name'),
                  content: TextField(
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
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
                        hintStyle: const TextStyle(color: Colors.grey)),
                    onChanged: (newValue) => babyName = newValue,
                    textAlign: TextAlign.center,
                  ),
                ),
                widget.currentUnit == 0
                    ? enterMetricWeight(borderColor)
                    : enterImperialWeight(borderColor),
                Step(
                  title: const Text('Height at birth'),
                  content: TextField(
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: borderColor, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: borderColor, width: 1.3),
                        ),
                        hintText: widget.currentUnit == 0
                            ? 'Enter height in cm'
                            : 'Enter height in inches',
                        hintStyle: const TextStyle(color: Colors.grey)),
                    onChanged: (newValue) =>
                        babyHeight = double.parse(newValue),
                    textAlign: TextAlign.center,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                Step(
                  title: const Text('Gender'),
                  content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGenderSelect(
                            gender: Icons.male,
                            selected: !isGirl,
                            onTapAction: () {
                              setState(() {
                                isGirl = false;
                              });
                            }),
                        const SizedBox(width: 10),
                        _buildGenderSelect(
                            gender: Icons.female,
                            selected: isGirl,
                            onTapAction: () {
                              setState(() {
                                isGirl = true;
                              });
                            }),
                      ]),
                ),
                Step(
                  title: const Text('Birthday'),
                  content: MaterialButton(
                    onPressed:
                        Platform.isAndroid ? pickDateAndroid : pickDateIOS,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _birthDay == null
                            ? const Text(
                                'Pick a date',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 24.0),
                              )
                            : Text(
                                '${_birthDay!.day}-${_birthDay!.month}-${_birthDay!.year}',
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 30.0),
                                textAlign: TextAlign.center,
                              ),
                      ],
                    ),
                  ),
                ),
                Step(
                  title: const Text('Profile photo'),
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
                                child: const Text(
                                  'Gallery',
                                ),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  imageSourcePicker(ImageSource.camera);
                                },
                                child: const Text(
                                  'Camera',
                                ),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                              ),
                            ),
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white70,
                          radius: 50,
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : null,
                          child: _pickedImage == null
                              ? const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.black54,
                                  size: 50,
                                )
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

  Step enterMetricWeight(Color borderColor) {
    return Step(
      title: const Text('Weight at birth'),
      content: TextField(
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 2.0),
            ),
            hintText: 'Enter kilograms',
            hintStyle: const TextStyle(color: Colors.grey)),
        onChanged: (newValue) =>
            babyWeightKg = double.parse(newValue.replaceAll(RegExp(r','), '.')),
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  Step enterImperialWeight(Color borderColor) {
    return Step(
      title: const Text('Weight at birth'),
      content: Column(
        children: [
          TextField(
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 2.0),
                ),
                hintText: 'Enter pounds',
                hintStyle: const TextStyle(color: Colors.grey)),
            onChanged: (newValue) => babyWeightPounds =
                double.parse(newValue.replaceAll(RegExp(r','), '.')),
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 2.0),
                ),
                hintText: 'Enter ounces',
                hintStyle: const TextStyle(color: Colors.grey)),
            onChanged: (newValue) => babyWeightOunces =
                double.parse(newValue.replaceAll(RegExp(r','), '.')),
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  void pickDateAndroid() {
    showDatePicker(
      context: context,
      initialDate: _birthDay ?? DateTime.now(),
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
        builder: (builder) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _birthDay ?? DateTime.now(),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (value) {
                    setState(() {
                      _birthDay = value;
                    });
                  }),
            ));
  }

// Gender Picker Method
  Container _buildSelect(
      {required IconData icon,
      required Color background,
      required Color iconColor}) {
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
      {required IconData gender,
      required bool selected,
      required VoidCallback onTapAction}) {
    var button = selected
        ? _buildSelect(
            icon: gender,
            iconColor: Colors.white,
            background: isGirl ? Colors.pink[200]! : Colors.blue[200]!)
        : _buildSelect(
            icon: gender, iconColor: Colors.black, background: Colors.white);
    return GestureDetector(
      onTap: onTapAction,
      child: button,
    );
  }

  // Pick Image Source for Baby Profile Photo
  Future imageSourcePicker(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      _cropImage(picked);
    } else {}
  }

  _cropImage(picked) async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      cropStyle: CropStyle.circle,
    );
    if (cropped != null) {
      setState(() {
        _pickedImage = File(cropped.path);
      });
      final directory = await syspaths.getApplicationDocumentsDirectory();
      String directoryPath = directory.path;
      FileImage(File('$directoryPath/$babyName}.jpg')).evict();
      File savedImage =
          await _pickedImage!.copy('$directoryPath/$babyName.jpg');
    }
  }
}
