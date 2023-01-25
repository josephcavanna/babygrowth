import 'dart:io';
import 'package:flutter/material.dart';

class ProfilePhoto {
  // Widget that displays the profile photo of the baby
  Positioned profilePhotoWidget(
      {required BuildContext context,
      required String babyName,
      required Color color,
      required File babyImage,
      required ImageProvider<Object> backgroundImage}) {
    return Positioned(
      top: MediaQuery.of(context).orientation == Orientation.portrait
          ? 117.0
          : MediaQuery.of(context).size.aspectRatio >= 16 / 9
              ? 40
              : 80,
      left: MediaQuery.of(context).orientation == Orientation.portrait
          ? (MediaQuery.of(context).size.width / 2 - 80)
          : MediaQuery.of(context).size.aspectRatio >= 16 / 9
              ? (MediaQuery.of(context).size.width / 2 - 40)
              : (MediaQuery.of(context).size.width / 2 - 80),
      child: SizedBox(
        height: avatarRadius(context),
        width: avatarRadius(context),
        child: Hero(
          tag: babyName,
          child: Material(
            type: MaterialType.circle,
            color: Colors.white,
            elevation: 4,
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: FileImage(babyImage),
            ),
          ),
        ),
      ),
    );
  }

  // This determines the radius of the profile photo
  double avatarRadius(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? 160.0
        : MediaQuery.of(context).size.aspectRatio >= 16 / 9
            ? 80
            : 160;
  }
}
