

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

String numberToOrdinal(int number) {
  if (number % 100 >= 11 && number % 100 <= 13) {
    return '$number' 'th';
  } else {
    switch (number % 10) {
      case 1:
        return '$number' 'st';
      case 2:
        return '$number' 'nd';
      case 3:
        return '$number' 'rd';
      default:
        return '$number' 'th';
    }
  }
}

String formatDateTime(DateTime dateTime) {
  // List<String> months = [
  //   'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  //   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  // ];

  int day = dateTime.day;
  //String month = months[dateTime.month - 1];
  int year = dateTime.year;
  String hour = dateTime.hour.toString().padLeft(2, '0');
  String minute = dateTime.minute.toString().padLeft(2, '0');

  return '$day-${dateTime.month}-$year $hour:$minute';
}

@immutable
class StateDependentColor extends WidgetStateProperty<Color?> {
  StateDependentColor(
    this.color,
    { this.selectedColor }
  );

  final Color color;
  final Color? selectedColor;

  @override
  Color? resolve(Set<WidgetState> states) {
    log("$states");
    final c = states.contains(WidgetState.selected) ? (selectedColor ?? color) : color;
    if (states.contains(WidgetState.pressed)) {
      return c.withOpacity(0.2);
    }
    if (states.contains(WidgetState.hovered)) {
      return c.withOpacity(0.1);
    }
    if (states.contains(WidgetState.focused)) {
      return c.withOpacity(0.3);
    }
    return null;
  }
}
