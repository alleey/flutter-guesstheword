import 'package:flutter/material.dart';

import '../../../widgets/common/responsive_layout.dart';
import '../../common/app_color_scheme.dart';
import '../../common/constants.dart';
import '../../common/layout_constants.dart';
import '../../localizations/app_localizations.dart';
import '../../services/data_service.dart';

class HowToPlayPage extends StatelessWidget {
  const HowToPlayPage({
    super.key,
    required this.colorScheme,
  });

  final AppColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
    final dataService = DataService();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Align(
            alignment: Alignment.center,
            child: Semantics(
              label: "Game version is ${dataService.version}",
              container: true,
              excludeSemantics: true,
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: context.localizations.translate("dlg_help_version", placeholders: {"version": dataService.version}),
                      style: TextStyle(
                        color: colorScheme.backgroundPuzzleSymbolsFlipped.withOpacity(0.7),
                        fontSize: bodyFontSize,
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),

          Semantics(
            container: true,
            child: Text.rich(
              textAlign: TextAlign.start,
              TextSpan(
                style: TextStyle(
                  color: colorScheme.textPuzzlePanel,
                  fontSize: bodyFontSize,
                ),
                children: [
                  TextSpan(
                    text: context.localizations.translate("dlg_help_intro"),
                  ),
                ],
              ),
            ),
          ),

          Semantics(
            container: true,
            child: Text.rich(
              textAlign: TextAlign.start,
              TextSpan(
                style: TextStyle(
                  color: colorScheme.textPuzzlePanel,
                  fontSize: bodyFontSize,
                ),
                children: [
                  TextSpan(
                    semanticsLabel: "Rule 1.",
                    text: '\u{273D} ',
                    style: TextStyle(
                      color: colorScheme.backgroundPuzzleSymbolsFlipped,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: context.localizations.translate("dlg_help_rule1"),
                  ),
                ],
              ),
            ),
          ),

          Semantics(
            container: true,
            child: Text.rich(
              textAlign: TextAlign.start,
              TextSpan(
                style: TextStyle(
                  color: colorScheme.textPuzzlePanel,
                  fontSize: bodyFontSize,
                ),
                children: [
                  TextSpan(
                    text: '\u{2726} ',
                    semanticsLabel: "Rule 2.",
                    style: TextStyle(
                      color: colorScheme.backgroundPuzzleSymbolsFlipped,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  TextSpan(
                    text: context.localizations.translate("dlg_help_rule2", placeholders: {"scoreBumpForHintBonus": Constants.scoreBumpForHintBonus}),
                  ),
                  TextSpan(
                    text: context.localizations.translate("dlg_help_rule2_1"),
                    style: TextStyle(
                      color: colorScheme.backgroundPuzzleSymbolsFlipped,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                ],
              ),
            ),
          ),
      ]),
    );
  }
}
