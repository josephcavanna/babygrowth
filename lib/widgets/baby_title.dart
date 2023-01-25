import 'package:flutter/material.dart';

class BabyTitle {

  Positioned babyTitleWidget ({required BuildContext context, required String babyName}) {
    return Positioned(
      top: MediaQuery.of(context).orientation ==
          Orientation.portrait
          ? 82
          : MediaQuery.of(context).size.aspectRatio >= 16 / 9
          ? 5
          : 35,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: babyTitle(babyName: babyName),
        ),
      ),
    );
  }


  // Widget that displays the selected baby's name
  List<Widget> babyTitle({required String babyName}) {
    return [
      const Text(
        'Baby',
        style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.w200),
      ),
      Text(
        babyName,
        style: const TextStyle(
            color: Colors.black, fontSize: 25, fontWeight: FontWeight.w400),
      ),
    ];
  }

}