

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
  // Define the list of month names
  List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  // Extract the components of the DateTime
  int day = dateTime.day;
  //String month = months[dateTime.month - 1];
  int year = dateTime.year;
  String hour = dateTime.hour.toString().padLeft(2, '0');
  String minute = dateTime.minute.toString().padLeft(2, '0');

  // Format the string
  return '$day-${dateTime.month}-$year $hour:$minute';
}

@immutable
class StateDependentColor extends WidgetStateProperty<Color?> {
  StateDependentColor(this.color);

  final Color color;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return color.withOpacity(0.1);
    }
    if (states.contains(WidgetState.hovered)) {
      return color.withOpacity(0.08);
    }
    if (states.contains(WidgetState.focused)) {
      return color.withOpacity(0.5);
    }
    return null;
  }
}
