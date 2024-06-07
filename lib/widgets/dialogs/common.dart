import 'package:flutter/material.dart';

import '../../common/app_color_scheme.dart';
import '../common/responsive_layout.dart';

typedef CloseWithResult = void Function(dynamic result);
typedef ContentBuilder = Widget Function(
  ResponsiveLayout layout,
  ValueNotifier<AppColorScheme> colorScheme
);

typedef ActionBuilder = Iterable<Widget> Function(
  ResponsiveLayout layout,
  ValueNotifier<AppColorScheme> colorScheme
);

abstract class DialogAction extends StatelessWidget {
  const DialogAction({
    super.key,
    required this.schemeNotifier,
    required this.builder,
  });

  final ValueNotifier<AppColorScheme> schemeNotifier;
  final ContentBuilder builder;
}