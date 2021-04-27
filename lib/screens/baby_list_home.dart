import 'package:babygrowth_app/screens/add_baby.dart';
import 'package:babygrowth_app/screens/baby_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BabyListHome extends StatefulWidget {
  @override
  _BabyListHomeState createState() => _BabyListHomeState();
}

class _BabyListHomeState extends State<BabyListHome> {
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
          colors: [Colors.blue[200], Colors.pink[100]],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding:
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? EdgeInsets.only(left: 30, top: 75, right: 30)
                      : EdgeInsets.only(left: 60, top: 3, right: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image.asset(
                      //   'assets/LogoGraphic.webp',
                      //   width: 50,
                      // ),
                      Image.asset(
                        'assets/LogoText.webp',
                        width: 250,
                      ),
                    ],
                  ),

                  // Row(
                  //   children: [
                  //     Text(
                  //       'Baby',
                  //       style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: MediaQuery.of(context).orientation ==
                  //                   Orientation.portrait
                  //               ? 45
                  //               : 40),
                  //     ),
                  //     Text(
                  //       'List',
                  //       style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: MediaQuery.of(context).orientation ==
                  //                   Orientation.portrait
                  //               ? 45
                  //               : 40,
                  //           fontWeight: FontWeight.bold),
                  //     ),
                  //   ],
                  // ),
                  Material(
                    color: Colors.white,
                    type: MaterialType.circle,
                    elevation: 5,
                    child: Container(
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 20,
                        child: IconButton(
                          icon: Icon(CupertinoIcons.plus),
                          color: Colors.grey,
                          iconSize: 20,
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddBaby())),
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
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * 0.75
                  : MediaQuery.of(context).size.height * 0.63,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? 75.0
                            : 0),
                    topRight: Radius.circular(
                        MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? 75.0
                            : 0)),
              ),
              child: ListView(
                scrollDirection:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? Axis.vertical
                        : Axis.horizontal,
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height * 0.65,
                      width: MediaQuery.of(context).size.width,
                      child: BabyList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
