import '/models/share_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Buttons {

  IconButton shareButton({required GlobalKey key, required String babyName}) {
      return IconButton(
      icon: const Icon(CupertinoIcons.share),
      iconSize: 30,
      color: Colors.black,
      onPressed: () => ShareFunction().shareFunction(key: key, babyName: babyName),
    );
  }

  IconButton backButton({required BuildContext context}) {
    return IconButton(
        icon: const Icon(CupertinoIcons.back),
        iconSize: 30,
        color: Colors.black,
        onPressed: () => Navigator.pop(context));
  }

}