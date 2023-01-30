import 'package:shared_preferences/shared_preferences.dart';

import '/screens/add_baby.dart';
import '../widgets/baby_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BabyListScreen extends StatefulWidget {
  const BabyListScreen({Key? key}) : super(key: key);

  @override
  State<BabyListScreen> createState() => _BabyListScreenState();
}

class _BabyListScreenState extends State<BabyListScreen> {
  int? currentUnit;

  @override
  void initState() {
    getCurrentUnit();
    super.initState();
  }

  void getCurrentUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUnit = prefs.getInt('currentUnit')!;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: MediaQuery.of(context).orientation == Orientation.portrait
              ? [0.15, 0.35]
              : [0.3, 0.5],
          colors: [
            Colors.blue[200]!,
            Colors.pink[100]!,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding:
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? const EdgeInsets.only(left: 30, top: 75, right: 30)
                      : const EdgeInsets.only(left: 60, top: 3, right: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/LogoText.webp',
                    width: 250,
                  ),
                  Material(
                    color: Colors.white,
                    type: MaterialType.circle,
                    elevation: 5,
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(CupertinoIcons.plus),
                        color: Colors.grey,
                        iconSize: 20,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddBaby(
                              currentUnit: currentUnit,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 75 : 0),
            Container(
              width: width * 0.7,
              height: orientation == Orientation.portrait
                  ? height * 0.75
                  : height * 0.63,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        orientation == Orientation.portrait ? 10.0 : 0),
                    topRight: Radius.circular(
                        orientation == Orientation.portrait ? 10.0 : 0)),
              ),
              child: ListView(
                scrollDirection: orientation == Orientation.portrait
                    ? Axis.vertical
                    : Axis.horizontal,
                children: [
                  SizedBox(
                    height: height * 0.65,
                    width: width,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: orientation == Orientation.portrait ? 0 : 50,
                        bottom: orientation == Orientation.portrait ? 68.0 : 10,
                      ),
                      child: const BabyList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
