import 'package:babygrowth_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:babygrowth_app/methods/child_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as syspaths;

class BabyList extends StatefulWidget {
  static const String id = 'baby_list';

  @override
  _BabyListState createState() => _BabyListState();
}

class _BabyListState extends State<BabyList> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User loggedInUser;
  int currentUnit;
  String directoryPath;

  void getDirectory() async {
    final directory = await syspaths.getApplicationDocumentsDirectory();
    directoryPath = directory.path;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getDirectory();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: _firestore.collection(_auth.currentUser.uid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final babies = snapshot.data.docs;
          List<ChildButton> babyButtons = [];
          for (var baby in babies) {
            final babyName = baby.data()['name'];
            final babyAge = baby.data()['birthday'];
            // final babyHeight = baby.data()['height'];
            // final babyWeight = baby.data()['weight'];
            final babyID = baby.id;
            final babyGender = baby.data()['gender'];
            final babyImage = File('$directoryPath/$babyName.jpg');

            final babyButton = ChildButton(
              name: babyName,
              age: babyAge,
              // weight: currentUnit == 0 ? babyWeight : (babyWeight * 2.205),
              // weightUnit: currentUnit == 0 ? ' kg' : ' lbs',
              // height: currentUnit == 0 ? babyHeight : (babyHeight / 2.54),
              // heightUnit: currentUnit == 0 ? ' cm' : '"',
              babyID: babyID,
              isGirl: babyGender,
              babyImage: babyImage,
              longPressAction: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Are you sure you want to delete this baby?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        _firestore
                            .collection(_auth.currentUser.uid)
                            .doc(babyName)
                            .collection('entries')
                            .get()
                            .then((snapshot) {
                          for (DocumentSnapshot ds in snapshot.docs) {
                            ds.reference.delete();
                          }
                        });
                        _firestore
                            .collection(_auth.currentUser.uid)
                            .doc(babyName)
                            .delete();
                        Navigator.pop(context);
                      },
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ),
            );
            babyButtons.add(babyButton);
          }
          return babyButtons.isNotEmpty
              ? MediaQuery.of(context).orientation == Orientation.portrait
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.vertical,
                              physics: BouncingScrollPhysics(),
                              children: babyButtons,
                            ),
                          ),
                        ])
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: babyButtons,
                              physics: BouncingScrollPhysics(),
                            ),
                          ),
                        ])
              : MediaQuery.of(context).orientation == Orientation.portrait
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Add your first baby :)',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ])
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                          Center(
                            child: Text(
                              'Add your first baby :)',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ]);
        },
      ),
    );
  }
}
