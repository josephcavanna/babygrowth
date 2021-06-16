import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:BabyGrowth/screens/baby_page.dart';
import 'dart:io';

class ChildButton extends StatefulWidget {
  final String name;
  final Timestamp age;
  final double weight;
  final String weightUnit;
  final double height;
  final String heightUnit;
  final bool isGirl;
  final String babyID;
  final Function longPressAction;
  final File babyImage;

  ChildButton(
      {this.name,
      this.age,
      this.weight,
      this.weightUnit,
      this.height,
      this.heightUnit,
      this.isGirl,
      this.babyID,
      this.longPressAction,
      this.babyImage});

  @override
  _ChildButtonState createState() => _ChildButtonState();
}

class _ChildButtonState extends State<ChildButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      visualDensity: VisualDensity.compact,
      child: Container(
        child: Card(
          child: MediaQuery.of(context).orientation == Orientation.portrait
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Hero(
                          tag: widget.name,
                          child: profilePhoto(profileRadius: 60),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: Column(
                          children: [
                            nameText(),
                            SizedBox(
                              height: 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ageText(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: birthdayText(),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 20),
                      child: Hero(
                        tag: widget.name,
                        child: profilePhoto(profileRadius: 60),
                      ),
                    ),
                    Padding(
                      padding:
                          MediaQuery.of(context).size.aspectRatio >= 16 / 9
                              ? const EdgeInsets.only(bottom: 200.0, top: 10)
                              : const EdgeInsets.only(bottom: 100.0, top: 0),
                      child: nameText(),
                    ),
                  ],
                ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(75.0),
            ),
          ),
          color: Colors.white,
        ),
      ),
      onLongPress: widget.longPressAction,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BabyPage(
            babyImage: widget.babyImage,
            babyID: widget.babyID,
            weight: widget.weight,
            height: widget.height,
            babyName: widget.name,
            isGirl: widget.isGirl,
            age: DateTime.now()
                    .difference(DateTime.fromMillisecondsSinceEpoch(
                        widget.age.millisecondsSinceEpoch))
                    .inDays /
                30,
            birthDay: widget.age,
          ),
        ),
      ),
    );
  }

  Column birthdayText() {
    return Column(
      children: [
        Text(
          'Born',
          style: TextStyle(
              color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2,
        ),
        Text(
          DateTime.fromMillisecondsSinceEpoch(widget.age.millisecondsSinceEpoch)
                  .day
                  .toString() +
              '/' +
              DateTime.fromMillisecondsSinceEpoch(
                      widget.age.millisecondsSinceEpoch)
                  .month
                  .toString() +
              '/' +
              DateTime.fromMillisecondsSinceEpoch(
                      widget.age.millisecondsSinceEpoch)
                  .year
                  .toString(),
          style: TextStyle(
            color: Colors.black54,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Text nameText() {
    return Text(
      widget.name,
      style: TextStyle(
        color: genderColor(),
        fontSize: 24.0 - (widget.name.length) / 1.6,
      ),
    );
  }

  Text ageText() {
    return (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(widget.age.millisecondsSinceEpoch)).inDays / 365).round() != 0 ? Text(
      '${(DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(widget.age.millisecondsSinceEpoch)).inDays / 365).round()} years old',
      style: TextStyle(
        color: Colors.black54,
        fontSize: 12,
      ),
    ) : Text('${(DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(widget.age.millisecondsSinceEpoch)).inDays / 30).round()} months old', style: TextStyle(
      color: Colors.black54,
      fontSize: 12,
    ),);
  }

  Material profilePhoto({double profileRadius}) {
    return Material(
      type: MaterialType.circle,
      color: Colors.white,
      elevation: 4,
      child: Container(
        child: CircleAvatar(
          radius: profileRadius,
          backgroundColor: Colors.grey[200],
          backgroundImage:
              widget.babyImage != null ? FileImage(widget.babyImage) : null,
        ),
      ),
    );
  }

  Color genderColor() {
    return widget.isGirl == true ? Colors.pink[100] : Colors.blue[200];
  }
}
