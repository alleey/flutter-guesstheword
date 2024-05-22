// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

////////////////////////////

enum ResponsiveDevice {
  small,
  medium,
  large
}

class ResponsiveValue<T> {
  final T small, medium, large;

  ResponsiveValue({
    required this.small,
    required this.medium,
    required this.large,
  });

  factory ResponsiveValue.from({T? small, T? medium, T? large}) {

    if (small == null && medium == null && large == null) {
      throw Exception("Must specify at least one of the value");
    }

    return ResponsiveValue<T>(
      small: (small ?? (medium ?? large)) as T,
      medium: (medium ?? (small ?? large)) as T,
      large: (large ?? (medium ?? small)) as T,
    );
  }

  ResponsiveValue<T> copyWith({
    T? small,
    T? medium,
    T? large,
  }) {
    return ResponsiveValue<T>(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
    );
  }
}

////////////////////////////

class ResponsiveLayout {
  final _attributes = <String,dynamic>{};
  final ResponsiveDevice _deviceType;

  ResponsiveLayout({required ResponsiveDevice deviceType})
    :_deviceType = deviceType;

  bool get isSmall => _deviceType == ResponsiveDevice.small;
  bool get isMedium => _deviceType == ResponsiveDevice.medium;
  bool get isLarge => _deviceType == ResponsiveDevice.large;

  T get<T>(String key) => _attributes[key];
  void set<T>(String key, T value) => _attributes[key] = value;
}

////////////////////////////

typedef ResponsiveLayoutBuilder = void Function(ResponsiveLayoutProvider);

class ResponsiveLayoutProvider extends InheritedWidget {

  final BoxConstraints _constraints;
  final ResponsiveValue<double> _breakpoints;
  final _layouts = <ResponsiveDevice,ResponsiveLayout>{
    ResponsiveDevice.small: ResponsiveLayout(deviceType: ResponsiveDevice.small),
    ResponsiveDevice.medium: ResponsiveLayout(deviceType: ResponsiveDevice.medium),
    ResponsiveDevice.large: ResponsiveLayout(deviceType: ResponsiveDevice.large),
  };
  late ResponsiveDevice _deviceType;

  ResponsiveLayoutProvider({
    super.key,
    required super.child,
    required BoxConstraints constraints,
    required ResponsiveValue<double> breakpoints,
    required void Function(ResponsiveLayoutProvider) provider,
  }) : _constraints = constraints, _breakpoints = breakpoints {

    _deviceType = _deviceFromConstraints(_constraints);
    provider(this);
  }

  bool get isSmall => _deviceType == ResponsiveDevice.small;
  bool get isMedium => _deviceType == ResponsiveDevice.medium;
  bool get isLarge => _deviceType == ResponsiveDevice.large;

  ResponsiveLayout get activeLayout {
    return _layouts[_deviceType]!;
  }

  void provide<T>(String key, ResponsiveValue<T> value) {
    _layouts[ResponsiveDevice.small]!.set(key, value.small);
    _layouts[ResponsiveDevice.medium]!.set(key, value.medium);
    _layouts[ResponsiveDevice.large]!.set(key, value.large);
  }

  void provideAll(Map<String, ResponsiveValue<dynamic>> values)
    => values.forEach((k,v) => provide(k, v));

  static ResponsiveLayout layout(BuildContext context) {
    return ResponsiveLayoutProvider.of(context).activeLayout;
  }

  static ResponsiveLayoutProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ResponsiveLayoutProvider>()!;
  }

  @override
  bool updateShouldNotify(ResponsiveLayoutProvider oldWidget) {
    // only update if the responsive device type has changed
    return _deviceFromConstraints(_constraints) != _deviceFromConstraints(oldWidget._constraints);
  }

  ResponsiveDevice _deviceFromConstraints(BoxConstraints constraints) {
    if (constraints.maxWidth <= _breakpoints.small) {
      return ResponsiveDevice.small;
    }
    if (constraints.maxWidth <= _breakpoints.medium) {
      return ResponsiveDevice.medium;
    }
    return ResponsiveDevice.large;
  }
}

////////////////////////////

