import 'package:flutter/material.dart';

import '../localizations/app_localizations.dart';

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
    return Text(
      context.localizations.translate(textId, placeholders: placeholders),
      style: style,
    );
  }
}
