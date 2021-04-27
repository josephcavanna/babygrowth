import 'package:babygrowth_app/methods/height_boys_data.dart';
import 'package:babygrowth_app/methods/height_girls_data.dart';
import 'package:babygrowth_app/methods/save_image_from_widget.dart';
import 'package:babygrowth_app/screens/logs_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'add_entry.dart';
import 'package:babygrowth_app/methods/weight_boys_data.dart';
import 'package:babygrowth_app/methods/weight_girls_data.dart';
import 'dart:io';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:babygrowth_app/methods/create_image_function.dart';

class BabyPage extends StatefulWidget {
  static const String id = 'baby_page';
  final String babyID;
  final String babyName;
  final double height;
  final double weight;
  final double age;
  final bool isGirl;
  final Timestamp birthDay;
  final File babyImage;

  BabyPage(
      {this.babyID,
      this.babyName,
      this.height,
      this.weight,
      this.age,
      this.isGirl,
      this.birthDay,
      this.babyImage});

  @override
  _BabyPageState createState() => _BabyPageState();
}

class _BabyPageState extends State<BabyPage>
    with SingleTickerProviderStateMixin {
  GlobalKey _keyBabyPage;
  PageController _pageController = PageController(initialPage: 0);
  AnimationController _animationController;
  Animation _animation;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  dynamic data;
  File _pickedImage;
  final picker = ImagePicker();
  FileImage profilePhoto;

  Future<dynamic> getData() async {
    final DocumentReference document =
        _firestore.collection(_auth.currentUser.uid).doc(widget.babyName);
    await document.get().then<dynamic>((DocumentSnapshot snapshot) async {
      setState(() {
        data = snapshot.data;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getData();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2500));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic);
    _animationController.forward();
    profilePhoto = FileImage(widget.babyImage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  }

  void pickDate() {
    setState(() {
      showDatePicker(
        context: context,
        initialDate:
            DateTime.now().subtract(Duration(days: widget.age.toInt() * 30)),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.year,
      ).then(
        (value) {
          if (value != null) {
            _firestore
                .collection(_auth.currentUser.uid)
                .doc(widget.babyName)
                .update({'age': value});
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            SaveImageFromWidget(builder: (key) {
              this._keyBabyPage = key;
              return AnimatedContainer(
                duration: _animationController.duration,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: widget.isGirl
                        ? [
                            0.1 - (_animation.value * 10),
                            0.3 - (_animation.value * 10)
                          ]
                        : [
                            0.1 + (_animation.value * 10),
                            (_animation.value) + 0.3
                          ],
                    colors: [Colors.blue[200], Colors.pink[100]],
                  ),
                ),
                child: Stack(
                  children: [
                    curveGraphWidget(context),
                    profilePhotoWidget(context),
                    Positioned(
                      top: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? 82
                          : 5,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: babyTitle(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Positioned(
              top: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * 0.95
                  : MediaQuery.of(context).size.height * 0.90,
              left: MediaQuery.of(context).size.width / 2 - 15,
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 2,
                effect: WormEffect(activeDotColor: genderColor()),
              ),
            ),
            Positioned(
              width: MediaQuery.of(context).size.width,
              top: MediaQuery.of(context).orientation == Orientation.portrait
                  ? 35
                  : 20,
              child: Padding(
                padding:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? EdgeInsets.symmetric(horizontal: 0)
                        : EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    backButton(context),
                    Row(
                      children: [
                        shareButton(),
                        threeDots(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Positioned profilePhotoWidget(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).orientation == Orientation.portrait
          ? 117.0
          : 40,
      left: MediaQuery.of(context).orientation == Orientation.portrait
          ? (MediaQuery.of(context).size.width / 2 - 80)
          : (MediaQuery.of(context).size.width / 2 - 40),
      child: Container(
        child: Hero(
          tag: widget.babyName,
          child: circleAvatarPhoto(),
        ),
        height: avatarRadius(context),
        width: avatarRadius(context),
      ),
    );
  }

  Positioned curveGraphWidget(BuildContext context) {
    return Positioned(
      bottom: 0,
      top:
          MediaQuery.of(context).orientation == Orientation.portrait ? 220 : 90,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(75.0),
              topRight: Radius.circular(75.0),
            ),
            color: Colors.white),
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.77
            : MediaQuery.of(context).size.height * 0.78,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.transparent,
          child: PageView(
            controller: _pageController,
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              widget.isGirl == false
                  ? HeightBoysData(
                      babyName: widget.babyName, age: widget.birthDay)
                  : HeightGirlsData(
                      babyName: widget.babyName, age: widget.birthDay),
              widget.isGirl == false
                  ? WeightBoysData(
                      babyName: widget.babyName,
                      age: widget.birthDay,
                    )
                  : WeightGirlsData(
                      babyName: widget.babyName, age: widget.birthDay),
            ],
          ),
        ),
      ),
    );
  }

  double avatarRadius(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? 160.0
        : 80;
  }

  Material circleAvatarPhoto() {
    return Material(
      type: MaterialType.circle,
      color: Colors.white,
      elevation: 4,
      child: Container(
        child: CircleAvatar(
          backgroundColor: Colors.grey[300],
          backgroundImage: profilePhoto,
          child: widget.babyImage == null
              ? Icon(
                  FontAwesome5Solid.baby,
                  size: 50,
                  color: genderColor(),
                )
              : null,
        ),
      ),
    );
  }

  List<Widget> babyTitle() {
    return [
      Text(
        'Baby',
        style: TextStyle(color: Colors.white, fontSize: 25),
      ),
      Text(
        widget.babyName,
        style: TextStyle(
            color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
      ),
    ];
  }

  StatefulWidget threeDots(BuildContext context) {
    return CupertinoButton(
        child: Icon(
          Entypo.dots_three_horizontal,
          color: Colors.white,
        ),
        onPressed: () => showCupertinoModalPopup(
              context: context,
              builder: (context) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      return showCupertinoModalPopup(
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
                                style: buttonTextColor(),
                              ),
                            ),
                            CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(context);
                                imageSourcePicker(ImageSource.camera);
                              },
                              child: Text(
                                'Camera',
                                style: buttonTextColor(),
                              ),
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: buttonTextColor(),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Change picture',
                      style: buttonTextColor(),
                    ),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogsScreen(
                              babyName: widget.babyName, isGirl: widget.isGirl),
                        ),
                      );
                    },
                    child: Text(
                      'Log entries',
                      style: buttonTextColor(),
                    ),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEntry(
                            babyName: widget.babyName,
                            isGirl: widget.isGirl,
                          ),
                        ),
                      );
                    },
                    child: Text('New entry', style: buttonTextColor()),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: buttonTextColor()),
                ),
              ),
            ));
  }

  // share button
  IconButton shareButton() {
    return IconButton(
      icon: Icon(CupertinoIcons.share),
      iconSize: 30,
      color: Colors.white,
      onPressed: shareFunction,
    );
  }

  // back button functionality
  IconButton backButton(BuildContext context) {
    return IconButton(
        icon: Icon(CupertinoIcons.back),
        iconSize: 30,
        color: Colors.white,
        onPressed: () => Navigator.pop(context));
  }

  // color value based on gender of baby
  Color genderColor() => widget.isGirl ? Colors.pink[100] : Colors.blue[200];

  TextStyle buttonTextColor() {
    return TextStyle(color: genderColor());
  }

  // Pick Image Source for Baby Profile Photo
  Future imageSourcePicker(ImageSource source) async {
    final picked = await picker.getImage(source: source);
    if (picked != null) {
      _cropImage(picked);
    } else {
      print('Image not found');
    }
  }

  // crop image for profile
  _cropImage(picked) async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: picked.path,
        cropStyle: CropStyle.circle,
        maxHeight: 500,
        maxWidth: 500);
    setState(() {
      _pickedImage = cropped;
    });
    _setPhotoProfile();
  }

  // save new profile photo
  _setPhotoProfile() async {
    final directory = await syspaths.getApplicationDocumentsDirectory();
    String directoryPath = directory.path;
    FileImage(File('$directoryPath/${widget.babyName}.jpg')).evict();
    File savedImage =
        await _pickedImage.copy('$directoryPath/${widget.babyName}.jpg');
    print(savedImage);
    Navigator.pop(context);
  }

  // share button functionality
  void shareFunction() async {
    final shareableImage = await CreateImageFunction.capture(_keyBabyPage);
    Share.file(
        widget.babyName + DateTime.now().toString(),
        widget.babyName + DateTime.now().toString() + '.png',
        shareableImage,
        'image/png',
        text: '');
  }
}
