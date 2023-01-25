import '../style/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PageIndicator {
  Positioned pageIndicatorWidget(
      {required PageController pageController,
      required bool isGirl,
      double? bottomPosition,
      double? leftPosition,
      double? topPosition,
      double? rightPosition}) {
    return Positioned(
      bottom: bottomPosition,
      left: leftPosition,
      right: rightPosition,
      top: topPosition,
      child: SmoothPageIndicator(
        controller: pageController,
        count: 2,
        effect: WormEffect(
          activeDotColor: Style().genderColor(isGirl: isGirl),
        ),
      ),
    );
  }
}
