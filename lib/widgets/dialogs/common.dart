import 'package:flutter/material.dart';

import '../../models/app_settings.dart';

typedef CloseWithResult = void Function(dynamic result);

typedef ContentBuilder = Widget Function(BuildContext context, ValueNotifier<AppSettings> changeNotifier);

typedef ActionBuilder = Iterable<Widget> Function(BuildContext context, ValueNotifier<AppSettings> changeNotifier);

abstract class DialogAction extends StatelessWidget {
  const DialogAction({
    super.key,
    required this.builder,
  });

  final ContentBuilder builder;
}