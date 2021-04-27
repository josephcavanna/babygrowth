import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogEntryItem extends StatefulWidget {
  final Timestamp date;
  final double weight;
  final double height;
  final String name;
  final bool isGirl;
  final Function longPressAction;
  final String weightUnit;
  final String heightUnit;

  LogEntryItem(
      {this.date,
      this.weight,
      this.weightUnit,
      this.height,
      this.heightUnit,
      this.name,
      this.isGirl,
      this.longPressAction});

  @override
  _LogEntryItemState createState() => _LogEntryItemState();
}

double newWeight;
double newHeight;

class _LogEntryItemState extends State<LogEntryItem> {
  int currentUnit;

  void getCurrentUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUnit = prefs.getInt('currentUnit' ?? 0);
  }

  @override
  void initState() {
    super.initState();
    getCurrentUnit();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(
            widget.date.millisecondsSinceEpoch));
    final _auth = FirebaseAuth.instance;
    final _firestore = FirebaseFirestore.instance;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                textAlign: TextAlign.center,
              ),
              Text(
                widget.weight != null
                    ? widget.weight.toStringAsFixed(1) + widget.weightUnit
                    : '-',
                textAlign: TextAlign.center,
              ),
              Text(
                widget.height != null
                    ? widget.height.toStringAsFixed(1) + widget.heightUnit
                    : '-',
                textAlign: TextAlign.center,
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Edit weight',
                                      ),
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      textAlign: TextAlign.center,
                                      onChanged: (newValue) => newWeight =
                                          double.parse(newValue.replaceAll(
                                              RegExp(r','), '.')),
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Edit height',
                                      ),
                                      textAlign: TextAlign.center,
                                      onChanged: (newValue) =>
                                          newHeight = double.parse(newValue),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (newHeight != null) {
                                          _firestore
                                              .collection(_auth.currentUser.uid)
                                              .doc(widget.name)
                                              .collection('entries')
                                              .doc(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          widget.date
                                                              .millisecondsSinceEpoch)
                                                  .toString())
                                              .update({
                                            'height': currentUnit == 0
                                                ? newHeight
                                                : newHeight * 2.54
                                          });
                                        }
                                        if (newWeight != null) {
                                          _firestore
                                              .collection(_auth.currentUser.uid)
                                              .doc(widget.name)
                                              .collection('entries')
                                              .doc(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          widget.date
                                                              .millisecondsSinceEpoch)
                                                  .toString())
                                              .update({
                                            'weight': currentUnit == 0
                                                ? newWeight
                                                : newWeight / 2.205
                                          });
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Text('Apply'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text(
                                  'Are you sure you want to delete this entry?'),
                              actions: [
                                TextButton(
                                    child: Text('Delete'),
                                    onPressed: () {
                                      _firestore
                                          .collection(_auth.currentUser.uid)
                                          .doc(widget.name)
                                          .collection('entries')
                                          .doc(DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      widget.date
                                                          .millisecondsSinceEpoch)
                                              .toString())
                                          .delete();
                                      Navigator.pop(context);
                                    }),
                                TextButton(
                                  child: Text('No'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            )),
                  ),
                ],
              ),
            ],
          ),
        ),
        color: Colors.grey[200],
        elevation: 2,
      ),
    );
  }
}
