import 'package:flutter/material.dart';

import '../../../widgets/common/responsive_layout.dart';
import '../../common/constants.dart';
import '../../common/layout_constants.dart';
import '../../localizations/app_localizations.dart';
import '../../models/app_settings.dart';
import '../settings_aware_builder.dart';

class HowToPlayPage extends StatelessWidget {
  const HowToPlayPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return  SettingsAwareBuilder(
      builder: (context, settingsNotifier) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder(
          valueListenable: settingsNotifier,
          builder: (context, settings, child) =>  _buildContents(context, settings)
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context, AppSettings settings) {

    final scheme = settings.currentScheme;
    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Semantics(
            container: true,
            child: Text.rich(
              textAlign: TextAlign.start,
              TextSpan(
                style: TextStyle(
                  color: scheme.textPuzzlePanel,
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
                  color: scheme.textPuzzlePanel,
                  fontSize: bodyFontSize,
                ),
                children: [
                  TextSpan(
                    semanticsLabel: "Rule 1.",
                    text: '\u{273D} ',
                    style: TextStyle(
                      color: scheme.backgroundPuzzleSymbolsFlipped,
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
                  color: scheme.textPuzzlePanel,
                  fontSize: bodyFontSize,
                ),
                children: [
                  TextSpan(
                    text: '\u{2726} ',
                    semanticsLabel: "Rule 2.",
                    style: TextStyle(
                      color: scheme.backgroundPuzzleSymbolsFlipped,
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
                      color: scheme.backgroundPuzzleSymbolsFlipped,
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
