import 'package:flutter/material.dart';

import '../widgets/common/responsive_layout.dart';

class DialogLayoutConstants
{
  // the %age of screen size covered by the dialog
  static const String screenCoverPctKey = "dlg.screenCoverPct";
  static final screenCoverPct = ResponsiveValue.from(
    small: const Size(0.8, 0.8),
    medium: const Size(0.8, 0.8),
    large: const Size(0.6, 0.6),
  );

  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 25, vertical: 25);
  static const EdgeInsets insetPadding = EdgeInsets.symmetric(horizontal: 15, vertical: 20);

  static final layout = <String, ResponsiveValue<dynamic>>{
    screenCoverPctKey: screenCoverPct,
  };
}

class AppLayoutConstants
{
  static const String titleFontSizeKey = "app.titleFontSize";
  static final titleFontSize = ResponsiveValue<double>.from(
    small: 18,
    medium: 28,
    large: 40,
  );

  static const String bodyFontSizeKey = "app.bodyFontSize";
  static final bodyFontSize = ResponsiveValue<double>.from(
    small: 16,
    medium: 24,
    large: 32,
  );

  static const String symbolButtonSizeKey = "app.symbolButtonSize";
  static final symbolButtonSize = ResponsiveValue.from(
    small: const Size(45, 30),
    medium: const Size(55, 40),
    large: const Size(65, 50),
  );

  // Only large displays force the input panel to take multiple lines instead of appearing as one long
  // linear keyboard
  static const String inputPanelWidthPctKey = "app.inputPanelWidthPct";
  static final inputPanelWidthPct = ResponsiveValue.from(
    small: 1.0,
    medium: 0.7,
    large: 0.5,
  );

  // Only large displays force the input panel to take multiple lines instead of appearing as one long
  // linear keyboard
  static const String hintWidthPctKey = "app.hintWidthPct";
  static final hintWidthPct = ResponsiveValue.from(
    small: 0.4,
    medium: 0.3,
    large: 0.2,
  );

  static const String colorSchemePickerItemSizeKey = "app.colorSchemePickerItemSize";
  static final colorSchemePickerItemSize = ResponsiveValue.from(
    small: const Size(60, 80),
    medium: const Size(80, 120),
    large: const Size(110, 140),
  );

  static final layout = <String, ResponsiveValue<dynamic>>{
    titleFontSizeKey: titleFontSize,
    bodyFontSizeKey: bodyFontSize,
    symbolButtonSizeKey: symbolButtonSize,
    inputPanelWidthPctKey: inputPanelWidthPct,
    hintWidthPctKey: hintWidthPct,
    colorSchemePickerItemSizeKey: colorSchemePickerItemSize,
  };
}
