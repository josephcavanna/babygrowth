import 'package:flutter/material.dart';

class Style {

  // BabyPage:

  // BabyPage > color is determined by the baby's gender
  Color genderColor({required bool isGirl}) => isGirl ? Colors.pink[100]! : Colors.blue[200]!;

  // BabyPage > text color of the menu buttons adapt to the baby's gender
  TextStyle buttonTextColor({required bool isGirl}) {
    return TextStyle(color: isGirl ? Colors.pink[100] : Colors.blue[200]);
  }

  // BabyPage > the colors used for the color animation transition when loading the page
  List<Color?> animationColors() => [Colors.blue[200], Colors.pink[100]];



}