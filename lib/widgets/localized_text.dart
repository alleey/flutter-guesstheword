import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localizations/app_localizations.dart';
import '../localizations/locale_provider.dart';

class LocalizedText extends StatelessWidget {
  const LocalizedText({
    super.key,
    required this.textId,
    this.placeholders,
    this.style
  });

  final String textId;
  final Map<String, dynamic>? placeholders;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, value, child) => Text(
        context.localizations.translate(textId, placeholders: placeholders),
        style: style,
      ),
    );
  }
}
