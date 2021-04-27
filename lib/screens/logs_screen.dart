import 'package:flutter/material.dart';
import 'package:babygrowth_app/methods/log_entry_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'add_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogsScreen extends StatefulWidget {
  final String babyName;
  final bool isGirl;

  LogsScreen({this.babyName, this.isGirl});

  static const String id = 'logs_screen';

  @override
  _LogsScreenState createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User loggedInUser;
  int currentUnit;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getCurrentUnit();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  }

  void getCurrentUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUnit = prefs.getInt('currentUnit' ?? 0);
    print(currentUnit);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore
            .collection(_auth.currentUser.uid)
            .doc(widget.babyName)
            .collection('entries')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data.docs;
          List<LogEntryItem> logEntries = [];
          for (var entry in entries) {
            final weight = entry.data()['weight'];
            final height = entry.data()['height'];
            final date = entry.data()['date'];
            print(widget.babyName);
            print(weight);

            final logEntry = LogEntryItem(
              date: date,
              weight: currentUnit == 0 ? weight : (weight * 2.205),
              weightUnit: currentUnit == 0 ? ' kg' : ' lbs',
              height: currentUnit == 0 ? height : (height / 2.54),
              heightUnit: currentUnit == 0 ? ' cm' : '"',
              name: widget.babyName,
              isGirl: widget.isGirl,
              longPressAction: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title:
                      Text('Are you sure you want to delete this log entry?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        _firestore
                            .collection(_auth.currentUser.uid)
                            .doc(widget.babyName)
                            .collection('entries')
                            .doc(date.toString())
                            .delete();
                        Navigator.pop(context);
                      },
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ),
            );
            logEntries.add(logEntry);
          }
          return Scaffold(
              appBar: AppBar(
                backgroundColor:
                    widget.isGirl == true ? Colors.pink[100] : Colors.blue[200],
                title: Text('Log entries'),
                actions: [
                  IconButton(
                    icon: Icon(CupertinoIcons.plus),
                    iconSize: 30,
                    padding: EdgeInsets.only(right: 10),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEntry(
                          babyName: widget.babyName,
                          isGirl: widget.isGirl,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                  child: Container(child: Column(children: logEntries))));
        });
  }
}
