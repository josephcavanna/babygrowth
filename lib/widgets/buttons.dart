import 'package:BabyGrowth/models/share_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Buttons {

  // Button with share functionality built in
  IconButton shareButton({@required GlobalKey key, @required String babyName}) {
      return IconButton(
      icon: Icon(CupertinoIcons.share),
      iconSize: 30,
      color: Colors.black,
      onPressed: () => ShareFunction().shareFunction(key: key, babyName: babyName),
    );
  }

  // a simple back button
  IconButton backButton({@required BuildContext context}) {
    return IconButton(
        icon: Icon(CupertinoIcons.back),
        iconSize: 30,
        color: Colors.black,
        onPressed: () => Navigator.pop(context));
  }

}