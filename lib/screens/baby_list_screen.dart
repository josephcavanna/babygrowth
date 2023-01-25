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
    print(currentUnit);
    super.initState();
  }

  void getCurrentUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUnit = prefs.getInt('currentUnit')!;
  }

  @override
  Widget build(BuildContext context) {
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
                            builder: (context) => AddBaby(currentUnit: currentUnit,),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
                height:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 75
                        : 0),
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * 0.75
                  : MediaQuery.of(context).size.height * 0.63,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? 10.0
                            : 0),
                    topRight: Radius.circular(
                        MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? 10.0
                            : 0)),
              ),
              child: ListView(
                scrollDirection:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? Axis.vertical
                        : Axis.horizontal,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    width: MediaQuery.of(context).size.width,
                    child: const BabyList(),
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
