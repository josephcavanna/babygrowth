import 'package:babygrowth_app/methods/unit_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnitSettings extends StatefulWidget {
  @override
  _UnitSettingsState createState() => _UnitSettingsState();
}

class _UnitSettingsState extends State<UnitSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: UnitNotifier()),
            IconButton(
                icon: Icon(CupertinoIcons.back),
                onPressed: () => Navigator.pop(context))
          ],
        ),
      ),
    );
  }
}
