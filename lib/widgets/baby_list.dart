import 'package:flutter/material.dart';
import '/widgets/child_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as syspaths;

class BabyList extends StatefulWidget {
  static const String id = 'baby_list';

  const BabyList({Key? key}) : super(key: key);

  @override
  State<BabyList> createState() => _BabyListState();
}

class _BabyListState extends State<BabyList> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late User loggedInUser;
  int? currentUnit;
  late String directoryPath;

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
        stream: _firestore.collection(_auth.currentUser!.uid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final babies = snapshot.data!.docs;

          List<ChildButton> babyButtons = [];
          for (var baby in babies) {
            final babyName = baby.get('name');
            final babyAge = baby.get('birthday');
            final babyHeight = baby.get('height');
            final babyWeight = baby.get('weight');
            final babyID = baby.id;
            final babyGender = baby.get('gender');
            final babyImage = File('$directoryPath/$babyName.jpg');

            final babyButton = ChildButton(
              name: babyName,
              age: babyAge,
              weight: babyWeight * 1.0,
              weightUnit: ' kg',
              height: babyHeight * 1.0,
              heightUnit: ' cm',
              babyID: babyID,
              isGirl: babyGender,
              babyImage: babyImage,
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
                              physics: const BouncingScrollPhysics(),
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
                            physics: const BouncingScrollPhysics(),
                            children: babyButtons,
                          ),
                        ),
                      ],
                    )
              : MediaQuery.of(context).orientation == Orientation.portrait
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Add your first baby :)',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        Center(
                          child: Text(
                            'Add your first baby :)',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ],
                    );
        },
      ),
    );
  }
}
