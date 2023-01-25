import 'package:flutter/material.dart';
import '/widgets/log_entry_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'add_entry.dart';

class LogsListScreen extends StatefulWidget {
  final String? babyName;
  final bool? isGirl;
  final int? currentUnit;

  const LogsListScreen({Key? key, this.babyName, this.isGirl, this.currentUnit})
      : super(key: key);

  static const String id = 'logs_screen';

  @override
  State<LogsListScreen> createState() => _LogsListScreenState();
}

class _LogsListScreenState extends State<LogsListScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late User loggedInUser;

  @override
  void initState() {
    print(widget.currentUnit);
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor =
        widget.isGirl == true ? Colors.pink[100] : Colors.blue[200];
    return StreamBuilder(
        stream: _firestore
            .collection(_auth.currentUser!.uid)
            .doc(widget.babyName)
            .collection('entries')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data!.docs;
          List<LogEntryItem> logEntries = [];
          for (var entry in entries) {
            final weight = entry.get('weight');
            final height = entry.get('height');
            final date = entry.get('date');

            final logEntry = LogEntryItem(
              date: date,
              weight: logEntryWeight(weight),
              weightPounds: logEntryWeightPounds(weight),
              weightOunces: logEntryWeightOunces(weight),
              weightUnit: widget.currentUnit == 0 ? ' kg' : ' lbs',
              height: logEntryHeight(height),
              heightUnit: widget.currentUnit == 0 ? ' cm' : '"',
              name: widget.babyName,
              isGirl: widget.isGirl,
              currentUnit: widget.currentUnit,
              longPressAction: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                      'Are you sure you want to delete this log entry?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        _firestore
                            .collection(_auth.currentUser!.uid)
                            .doc(widget.babyName)
                            .collection('entries')
                            .doc(date.toString())
                            .delete();
                        Navigator.pop(context);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ),
            );
            logEntries.add(logEntry);
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: backgroundColor,
              title: const Text('Log entries'),
              actions: [
                IconButton(
                  icon: const Icon(CupertinoIcons.plus),
                  iconSize: 30,
                  padding: const EdgeInsets.only(right: 10),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEntry(
                        babyName: widget.babyName,
                        isGirl: widget.isGirl,
                        currentUnit: widget.currentUnit,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(children: logEntries),
            ),
          );
        });
  }

  logEntryHeight(height) {
    if (widget.currentUnit == 0) {
      return height;
    } else {
      if (height != null) {
        return height / 2.54;
      } else {
        return null;
      }
    }
  }

  logEntryWeight(weight) {
    if (widget.currentUnit == 0) {
      return weight;
    } else {
      if (weight != null) {
        return weight * 2.205;
      } else {
        return null;
      }
    }
  }

  logEntryWeightPounds(weight) {
    if (widget.currentUnit == 0) {
      return weight;
    } else {
      if (weight != null) {
        final pounds = (weight * 2.205);
        final poundsDouble = pounds.floorToDouble();
        return poundsDouble;
      } else {
        return null;
      }
    }
  }

  logEntryWeightOunces(weight) {
    if (widget.currentUnit == 0) {
      return weight;
    } else {
      if (weight != null) {
        final pounds = (weight * 2.205);
        final poundsDouble = pounds.floorToDouble();
        final ounces = (pounds - poundsDouble) * 16;
        return ounces;
      } else {
        return null;
      }
    }
  }
}
