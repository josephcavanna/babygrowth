import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogEntryItem extends StatefulWidget {
  final Timestamp? date;
  final double? weight;
  final double? weightPounds;
  final double? weightOunces;
  final double? height;
  final String? name;
  final bool? isGirl;
  final Function? longPressAction;
  final String? weightUnit;
  final String? heightUnit;
  final int? currentUnit;

  const LogEntryItem({
    Key? key,
    this.date,
    this.weight,
    this.weightPounds,
    this.weightOunces,
    this.weightUnit,
    this.height,
    this.heightUnit,
    this.name,
    this.isGirl,
    this.longPressAction,
    this.currentUnit,
  }) : super(key: key);

  @override
  State<LogEntryItem> createState() => _LogEntryItemState();
}

double? newWeight;
double? newWeightPounds;
double? newWeightOunces;
double? newWeightPoundsToKg;
double? newWeightOuncestoKg;
double? newHeight;
double? newHeightInches;
double? newHeightInchestoCm;

class _LogEntryItemState extends State<LogEntryItem> {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    String formattedDateEU = DateFormat('dd-MM-yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(
            widget.date!.millisecondsSinceEpoch));
    String formattedDateUS = DateFormat('MM-dd-yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(
            widget.date!.millisecondsSinceEpoch));
    var entryFileDate =
        DateTime.fromMillisecondsSinceEpoch(widget.date!.millisecondsSinceEpoch)
            .toString();
    var entryFile = firestore
        .collection(auth.currentUser!.uid)
        .doc(widget.name)
        .collection('entries')
        .doc(entryFileDate);

    String? birthDay;

    var docName = firestore.collection(auth.currentUser!.uid).doc(widget.name);
    docName.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      final birthdayTimeStamp = data['birthday'];
      final birthday = DateTime.fromMillisecondsSinceEpoch(
              birthdayTimeStamp.millisecondsSinceEpoch)
          .toString();
      birthDay = birthday;
    });

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ListTile(
        tileColor: widget.isGirl == true ? Colors.pink[100] : Colors.blue[100],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 100,
              height: 35,
              color: Colors.transparent,
              child: Center(
                child: FittedBox(
                  child: Text(
                    widget.currentUnit == 0 ? formattedDateEU : formattedDateUS,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
            ),
            widget.currentUnit == 0
                ? Container(
                    width: 75,
                    height: 35,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                            color: widget.isGirl == true
                                ? Colors.pink
                                : Colors.blue,
                            width: 2)),
                    child: Center(child: metricWeightWidget()),
                  )
                : imperialWeightWidget(),
            Container(
              width: widget.currentUnit == 0 ? 75 : 50,
              height: 35,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                      color: widget.isGirl == true
                          ? Colors.deepOrange
                          : Colors.teal[300]!,
                      width: 2)),
              child: Center(
                child: FittedBox(
                  child: Text(
                    widget.height != null
                        ? widget.height!.toStringAsFixed(1) + widget.heightUnit!
                        : '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: widget.isGirl == true
                            ? Colors.deepOrange
                            : Colors.teal[300]),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.currentUnit == 0
                              ? [
                                  enterWeightKg(),
                                  enterHeightCm(),
                                  applyMetricButton(firestore, auth, context),
                                ]
                              : [
                                  enterWeightPounds(),
                                  enterWeightOunces(),
                                  enterHeightInches(),
                                  applyImperialButton(firestore, auth, context),
                                ],
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_sharp),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => birthDay != entryFileDate
                      ? showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text(
                                    'Are you sure you want to delete this entry?'),
                                actions: [
                                  TextButton(
                                      child: const Text('Delete'),
                                      onPressed: () {
                                        print(birthDay);
                                        print(entryFileDate);
                                        if (birthDay != entryFileDate) {
                                          entryFile.delete();
                                        }
                                        Navigator.pop(context);
                                      }),
                                  TextButton(
                                    child: const Text('No'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ))
                      : showDialog(
                          context: context,
                          builder: ((context) => AlertDialog(
                                title: Text(
                                    'You can\'t delete ${widget.name!}\'s birthday entry'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Go back'),
                                  ),
                                ],
                              )),
                        ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row imperialWeightWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 35,
          width: 100,
          decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                  color: widget.isGirl == true ? Colors.pink : Colors.blue,
                  width: 2)),
          child: Center(
            child: FittedBox(
              child: Text(
                widget.weightPounds != null
                    ? '${widget.weightPounds!.toStringAsFixed(0)} lb ${widget.weightOunces!.round()} oz'
                    : '-',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: widget.isGirl == true ? Colors.pink : Colors.blue),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Text metricWeightWidget() {
    return Text(
      widget.weight != null
          ? widget.weight!.toStringAsFixed(1) + widget.weightUnit!
          : '-',
      textAlign: TextAlign.center,
      style:
          TextStyle(color: widget.isGirl == true ? Colors.pink : Colors.blue),
    );
  }

  TextButton applyMetricButton(
      FirebaseFirestore firestore, FirebaseAuth auth, BuildContext context) {
    return TextButton(
      onPressed: () {
        if (newHeight != null) {
          firestore
              .collection(auth.currentUser!.uid)
              .doc(widget.name)
              .collection('entries')
              .doc(DateTime.fromMillisecondsSinceEpoch(
                      widget.date!.millisecondsSinceEpoch)
                  .toString())
              .update({'height': newHeight});
        }
        if (newWeight != null) {
          firestore
              .collection(auth.currentUser!.uid)
              .doc(widget.name)
              .collection('entries')
              .doc(DateTime.fromMillisecondsSinceEpoch(
                      widget.date!.millisecondsSinceEpoch)
                  .toString())
              .update({'weight': newWeight});
        }
        Navigator.pop(context);
      },
      child: const Text('Apply'),
    );
  }

  TextField enterHeightCm() {
    return TextField(
      decoration: InputDecoration(
          hintText: 'Enter height in cm',
          hintStyle: TextStyle(color: Colors.grey[400])),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onChanged: (newValue) =>
          newHeight = double.parse(newValue.replaceAll(RegExp(r','), '.')),
    );
  }

  TextField enterWeightKg() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Enter weight in kg',
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onChanged: (newValue) =>
          newWeight = double.parse(newValue.replaceAll(RegExp(r','), '.')),
    );
  }

  TextButton applyImperialButton(
      FirebaseFirestore firestore, FirebaseAuth auth, BuildContext context) {
    return TextButton(
      onPressed: () {
        if (newHeightInches != null) {
          firestore
              .collection(auth.currentUser!.uid)
              .doc(widget.name)
              .collection('entries')
              .doc(DateTime.fromMillisecondsSinceEpoch(
                      widget.date!.millisecondsSinceEpoch)
                  .toString())
              .update({'height': newHeightInchestoCm});
        }
        if (newWeightPoundsToKg != null || newWeightOuncestoKg != null) {
          final weightImperial =
              (newWeightOuncestoKg ?? 0) + (newWeightPoundsToKg ?? 0);
          firestore
              .collection(auth.currentUser!.uid)
              .doc(widget.name)
              .collection('entries')
              .doc(DateTime.fromMillisecondsSinceEpoch(
                      widget.date!.millisecondsSinceEpoch)
                  .toString())
              .update({'weight': weightImperial});
        }
        Navigator.pop(context);
      },
      child: const Text('Apply'),
    );
  }

  TextField enterHeightInches() {
    return TextField(
      decoration: InputDecoration(
          hintText: 'Enter height in inches',
          hintStyle: TextStyle(color: Colors.grey[400])),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onChanged: (newValue) {
        newHeightInches = double.parse(newValue.replaceAll(RegExp(r','), '.'));
        newHeightInchestoCm = newHeightInches! * 2.54;
      },
    );
  }

  TextField enterWeightPounds() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Enter pounds',
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      textAlign: TextAlign.center,
      onChanged: (newValue) {
        newWeightPounds = double.parse(newValue);
        newWeightPoundsToKg = (newWeightPounds ?? 0) / 2.205;
      },
    );
  }

  TextField enterWeightOunces() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Enter ounces',
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      textAlign: TextAlign.center,
      onChanged: (newValue) {
        newWeightOunces = double.parse(newValue);
        newWeightOuncestoKg = (newWeightOunces ?? 0) / 35.274;
      },
    );
  }
}
