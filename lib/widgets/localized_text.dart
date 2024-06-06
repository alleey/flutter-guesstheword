import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/app_color_scheme.dart';
import '../localizations/app_localizations.dart';
import '../localizations/locale_provider.dart';

class LocalizedText extends StatelessWidget {
  const LocalizedText({
    super.key,
    required this.textId,
    required this.schemeNotifier,
    this.style

  });

  final ValueNotifier<AppColorScheme> schemeNotifier;
  final String textId;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, value, child) => Text(
        context.localizations.translate(textId),
        style: style,
      ),
    );
  }
}
