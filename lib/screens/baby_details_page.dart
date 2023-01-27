import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:modern_form_esys_flutter_share/modern_form_esys_flutter_share.dart';

import '/data/height_boys_data.dart';
import '/data/height_girls_data.dart';
import '/data/weight_boys_data.dart';
import '/data/weight_girls_data.dart';
import '/models/save_image_from_widget.dart';
import '/models/create_image_function.dart';
import 'logs_list_screen.dart';
import 'add_entry.dart';

class BabyDetailsPage extends StatefulWidget {
  static const String id = 'baby_page';
  final String? babyID;
  final String? babyName;
  final double? height;
  final double? weight;
  final double? age;
  final bool? isGirl;
  final Timestamp? birthDay;
  final File? babyImage;

  const BabyDetailsPage({
    Key? key,
    this.babyID,
    this.babyName,
    this.height,
    this.weight,
    this.age,
    this.isGirl,
    this.birthDay,
    this.babyImage,
  }) : super(key: key);

  @override
  State<BabyDetailsPage> createState() => _BabyDetailsPageState();
}

class _BabyDetailsPageState extends State<BabyDetailsPage>
    with SingleTickerProviderStateMixin {
  late GlobalKey _keyBabyPage;
  final PageController _pageController = PageController(initialPage: 0);
  late AnimationController _animationController;
  late Animation _animation;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  dynamic data;
  late File _pickedImage;
  final picker = ImagePicker();
  late FileImage profilePhoto;
  bool dotsSwitch = true;
  int? currentUnit;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getCurrentUnit();
    getData();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic);
    _animationController.forward();
    profilePhoto = FileImage(widget.babyImage!);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

   void getCurrentUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUnit = prefs.getInt('currentUnit');
  }

  Future<dynamic> getData() async {
    final DocumentReference document =
        _firestore.collection(_auth.currentUser!.uid).doc(widget.babyName);
    await document.get().then<dynamic>((DocumentSnapshot snapshot) async {
      setState(() {
        data = snapshot.data;
      });
    });
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
            DateTime.now().subtract(Duration(days: widget.age!.toInt() * 30)),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.year,
      ).then(
        (value) {
          if (value != null) {
            _firestore
                .collection(_auth.currentUser!.uid)
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
                duration: _animationController.duration!,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: widget.isGirl!
                        ? [
                            0.1 - (_animation.value * 10),
                            0.3 - (_animation.value * 10)
                          ]
                        : [
                            0.1 + (_animation.value * 10),
                            (_animation.value) + 0.3
                          ],
                    colors: [Colors.blue[200]!, Colors.pink[100]!],
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
                      child: SizedBox(
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
              bottom: 110,
              right: 40,
              child: FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEntry(
                        babyName: widget.babyName, isGirl: widget.isGirl, currentUnit: currentUnit,),
                  ),
                ),
                backgroundColor:
                    widget.isGirl == true ? Colors.pink : Colors.blue,
                child: const Icon(
                  Icons.add,
                  size: 30,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * 0.95
                  : MediaQuery.of(context).size.height * 0.90,
              left: MediaQuery.of(context).size.width / 2 - 15,
              child: Container(
                height: 25,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: 2,
                    effect: WormEffect(dotColor: Colors.grey[400]!, activeDotColor: Colors.white, dotHeight: 7, dotWidth: 7,),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * 0.28
                  : MediaQuery.of(context).size.height * 0.25,
              left: MediaQuery.of(context).size.width / 1.35,
              child: SizedBox(
                height: 50,
                child: SizedBox(
                  height: 15,
                  child: Switch.adaptive(
                    activeColor: genderColor(),
                    value: dotsSwitch,
                    onChanged: (value) {
                      setState(() {
                        dotsSwitch = value;
                      });
                    },
                  ),
                ),
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
                        ? const EdgeInsets.symmetric(horizontal: 0)
                        : const EdgeInsets.symmetric(horizontal: 20),
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
      child: SizedBox(
        height: avatarRadius(context),
        width: avatarRadius(context),
        child: Hero(
          tag: widget.babyName!,
          child: circleAvatarPhoto(),
        ),
      ),
    );
  }

  Positioned curveGraphWidget(BuildContext context) {
    return Positioned(
      bottom: 0,
      top:
          MediaQuery.of(context).orientation == Orientation.portrait ? 220 : 90,
      child: Container(
        decoration: const BoxDecoration(
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
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              heightGraphSelection(),
              weightGraphSelection(),
            ],
          ),
        ),
      ),
    );
  }

  StatefulWidget weightGraphSelection() {
    var age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(
        widget.birthDay!.millisecondsSinceEpoch));
    var babyGraph = widget.isGirl == false
        ? WeightBoysData(
            babyName: widget.babyName!,
            age: widget.birthDay!,
            ageTypeWB: AgeTypeWB.baby,
            dotsSwitch: dotsSwitch,
          )
        : WeightGirlsData(
            babyName: widget.babyName!,
            age: widget.birthDay!,
            ageTypeWG: AgeTypeWG.baby,
            dotsSwitch: dotsSwitch,
          );
    var childGraph = widget.isGirl == false
        ? WeightBoysData(
            babyName: widget.babyName!,
            age: widget.birthDay!,
            ageTypeWB: AgeTypeWB.other,
            dotsSwitch: dotsSwitch,
          )
        : WeightGirlsData(
            babyName: widget.babyName!,
            age: widget.birthDay!,
            ageTypeWG: AgeTypeWG.other,
            dotsSwitch: dotsSwitch,
          );
    return age <= const Duration(days: 365) ? babyGraph : childGraph;
  }

  StatefulWidget heightGraphSelection() {
    var age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(
        widget.birthDay!.millisecondsSinceEpoch));
    var babyGraph = widget.isGirl == false
        ? HeightBoysData(
            babyName: widget.babyName!,
            age: widget.birthDay!,
            ageTypeHB: AgeTypeHB.baby,
            dotsSwitch: dotsSwitch,
          )
        : HeightGirlsData(
            babyName: widget.babyName!,
            age: widget.birthDay!,
            ageTypeHG: AgeTypeHG.baby,
            dotsSwitch: dotsSwitch,
          );
    var childGraph = widget.isGirl == false
        ? HeightBoysData(
            babyName: widget.babyName!,
            age: widget.birthDay!,
            ageTypeHB: AgeTypeHB.other,
            dotsSwitch: dotsSwitch,
          )
        : HeightGirlsData(
            babyName: widget.babyName!,
            age: widget.birthDay!,
            ageTypeHG: AgeTypeHG.other,
            dotsSwitch: dotsSwitch,
          );
    return age <= const Duration(days: 365) ? babyGraph : childGraph;
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
      child: CircleAvatar(
        backgroundColor: Colors.grey[300],
        backgroundImage: profilePhoto,
        child: widget.babyImage == null
            ? Icon(
                Icons.child_care_outlined,
                size: 50,
                color: genderColor(),
              )
            : null,
      ),
    );
  }

  List<Widget> babyTitle() {
    return [
      const Text(
        'Baby',
        style: TextStyle(color: Colors.white, fontSize: 25),
      ),
      Text(
        widget.babyName!,
        style: const TextStyle(
            color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
      ),
    ];
  }

  StatefulWidget threeDots(BuildContext context) {
    return CupertinoButton(
        child: const Icon(
          Icons.more_horiz,
          color: Colors.white,
        ),
        onPressed: () => showCupertinoModalPopup(
              context: context,
              builder: (context) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      showCupertinoModalPopup(
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
                          builder: (context) => LogsListScreen(
                              babyName: widget.babyName, isGirl: widget.isGirl, currentUnit: currentUnit,),
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
                            currentUnit: currentUnit,
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
      icon: const Icon(CupertinoIcons.share),
      iconSize: 30,
      color: Colors.white,
      onPressed: shareFunction,
    );
  }

  // back button functionality
  IconButton backButton(BuildContext context) {
    return IconButton(
        icon: const Icon(CupertinoIcons.back),
        iconSize: 30,
        color: Colors.white,
        onPressed: () => Navigator.pop(context));
  }

  // color value based on gender of baby
  Color genderColor() => widget.isGirl! ? Colors.pink[100]! : Colors.blue[200]!;

  TextStyle buttonTextColor() {
    return TextStyle(color: genderColor());
  }

  // Pick Image Source for Baby Profile Photo
  Future imageSourcePicker(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      _cropImage(picked);
    } else {
      print('Image not found');
    }
  }

  // crop image for profile
  _cropImage(picked) async {
    CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        cropStyle: CropStyle.circle,
        maxHeight: 500,
        maxWidth: 500);
    setState(() {
      _pickedImage = File(cropped!.path);
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
    Navigator.pop(context);
  }

  // share button functionality
  void shareFunction() async {
    final shareableImage = await CreateImageFunction.capture(_keyBabyPage);
    Share.file(widget.babyName! + DateTime.now().toString(),
        '${widget.babyName}${DateTime.now()}.png', shareableImage, 'image/png',
        text: '');
  }
}
