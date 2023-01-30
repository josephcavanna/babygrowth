import 'package:babygrowth/style/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/baby_details_page.dart';
import 'dart:io';

class ChildButton extends StatefulWidget {
  final String? name;
  final Timestamp? age;
  final double? weight;
  final String? weightUnit;
  final double? height;
  final String? heightUnit;
  final bool? isGirl;
  final String? babyID;

  final File? babyImage;

  const ChildButton(
      {Key? key,
      this.name,
      this.age,
      this.weight,
      this.weightUnit,
      this.height,
      this.heightUnit,
      this.isGirl,
      this.babyID,
      this.babyImage})
      : super(key: key);

  @override
  State<ChildButton> createState() => _ChildButtonState();
}

class _ChildButtonState extends State<ChildButton> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(
          top: orientation == Orientation.portrait ? 10.0 : 0.0,
          left: 20,
          right: 20,
          bottom: 10),
      child: Center(
        child: Dismissible(
          background: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
              color: Colors.red,
            ),
            child: const Center(
              child: Icon(
                Icons.delete,
                size: 40,
                color: Colors.black,
              ),
            ),
          ),
          direction: orientation == Orientation.portrait
              ? DismissDirection.endToStart
              : DismissDirection.up,
          confirmDismiss: (direction) => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Are you sure you want to delete this entry?'),
              actions: [
                TextButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      _firestore
                          .collection(_auth.currentUser!.uid)
                          .doc(widget.name)
                          .collection('entries')
                          .get()
                          .then((snapshot) {
                        for (DocumentSnapshot ds in snapshot.docs) {
                          ds.reference.delete();
                        }
                      });
                      _firestore
                          .collection(_auth.currentUser!.uid)
                          .doc(widget.name)
                          .delete();
                      Navigator.pop(context);
                    }),
                TextButton(
                  child: const Text('No'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          key: Key(widget.babyID!),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BabyDetailsPage(
                  babyImage: widget.babyImage!,
                  babyID: widget.babyID!,
                  weight: widget.weight!,
                  height: widget.height!,
                  babyName: widget.name!,
                  isGirl: widget.isGirl!,
                  age: DateTime.now()
                          .difference(DateTime.fromMillisecondsSinceEpoch(
                              widget.age!.millisecondsSinceEpoch))
                          .inDays /
                      30,
                  birthDay: widget.age!,
                ),
              ),
            ),
            child: Container(
              width: orientation == Orientation.portrait ? width : null,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                    color: Style().genderColor(isGirl: widget.isGirl!),
                    width: 4),
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18.0, vertical: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: widget.name!,
                      child: profilePhoto(
                          profileRadius: orientation == Orientation.portrait
                              ? height * 0.09
                              : height * 0.18),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 100,
                      height: 35,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: FittedBox(
                        child: Text(
                          widget.name!,
                          style: TextStyle(
                            color: Style().genderColor(isGirl: widget.isGirl!),
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Material profilePhoto({required double profileRadius}) {
    return Material(
      type: MaterialType.circle,
      color: Colors.transparent,
      elevation: 4,
      child: CircleAvatar(
        radius: profileRadius,
        backgroundColor: Colors.grey[200],
        backgroundImage: const AssetImage('assets/LogoGraphic.webp'),
        foregroundImage: FileImage(widget.babyImage!),
      ),
    );
  }

  Color? genderColor() {
    return widget.isGirl == true ? Colors.pink[100] : Colors.blue[200];
  }
}
