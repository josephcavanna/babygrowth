import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/data/height_boys_data.dart';
import '/data/height_girls_data.dart';
import '/data/weight_boys_data.dart';
import '/data/weight_girls_data.dart';

class CurveGraph {

  // Widget that displays the growth curves based on the weight and height data of a baby
  Positioned curveGraphWidget({required BuildContext context,
    required PageController pageController,
    required Timestamp birthDay,
    required String babyName,
    required bool isGirl}) {
    return Positioned(
      top: MediaQuery
          .of(context)
          .orientation == Orientation.portrait
          ? 220
          : MediaQuery
          .of(context)
          .size
          .aspectRatio >= 16 / 9
          ? 95
          : 220,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(75.0),
              topRight: Radius.circular(75.0),
            ),
            color: Colors.white),
        height: MediaQuery
            .of(context)
            .orientation == Orientation.portrait
            ? MediaQuery
            .of(context)
            .size
            .height * 0.77
            : MediaQuery
            .of(context)
            .size
            .height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Container(
          color: Colors.transparent,
          child: PageView(
            controller: pageController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              isGirl == false
                  ? HeightBoysData(
                  babyName: babyName, age: birthDay)
                  : HeightGirlsData(
                  babyName: babyName, age: birthDay),
              isGirl == false
                  ? WeightBoysData(
                babyName: babyName,
                age: birthDay,
              )
                  : WeightGirlsData(
                  babyName: babyName, age: birthDay),
            ],
          ),
        ),
      ),
    );
  }

}