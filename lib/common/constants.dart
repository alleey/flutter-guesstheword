
import 'package:flutter/material.dart';

class Constants
{
  static const int appDataVersion = 5;
  static const int maxErrors = 6;
  static const int maxScoreHistory = 10;
  static const int scoreBumpForHintBonus = 100;

  static const double defaultFontSize = 16;

  static const String symbolSet = "abcdefghijklmnopqrstuvwxyz&";

  static const bool enableInitialReveal = true;

  static const int difficultyEasyLen = 8;
  static const int difficultyMediumLen = 12;

  static const int revealEasy = 1;
  static const int revealMedium = 2;
  static const int revealHard = 3;

  static const puzzleSets = [
    "animals", "birds", "cars", "cartoons", "capitals", "countries",
    "elements", "emotions", "flowers", "fruits",
    "olympics", "sea-creatures", "vegetables",
  ];
}

class DialogConstants
{
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 25, vertical: 40);
  static const EdgeInsets insetPadding = EdgeInsets.symmetric(horizontal: 15, vertical: 20);
}
