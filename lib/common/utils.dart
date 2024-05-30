

import 'package:flutter/material.dart';

String numberToOrdinal(int number) {
  if (number % 100 >= 11 && number % 100 <= 13) {
    return '$number' + 'th';
  } else {
    switch (number % 10) {
      case 1:
        return '$number' + 'st';
      case 2:
        return '$number' + 'nd';
      case 3:
        return '$number' + 'rd';
      default:
        return '$number' + 'th';
    }
  }
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
