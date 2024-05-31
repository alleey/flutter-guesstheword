

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

@immutable
class GroupFocusOrder extends FocusOrder {

  static const int groupAppCommands = 1;
  static const int groupButtons = 2;
  static const int groupKeys = 3;

  final int groupId;
  final int order;

  const GroupFocusOrder(this.groupId, this.order);

  @override
  int doCompare(GroupFocusOrder other) {
    if (groupId != other.groupId) {
      return groupId.compareTo(other.groupId);
    }
    return order.compareTo(other.order);
  }
}

class NativeChannel {
  static const MethodChannel _channel = MethodChannel('android.native');

  static Future<bool> isAndroidTV() async {
    try {
      return await _channel.invokeMethod('isAndroidTV');
    } on PlatformException catch (e) {
      log("Failed to check feature: '${e.message}'.");
      return false;
    }
  }
}

bool _highlightModeSet = !Platform.isAndroid;

Future<void> setHighlightMode() async {
  if (!_highlightModeSet) {
    final isAndroidTV = await NativeChannel.isAndroidTV();
    if (isAndroidTV) {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    }
  }
  _highlightModeSet = true;
}
