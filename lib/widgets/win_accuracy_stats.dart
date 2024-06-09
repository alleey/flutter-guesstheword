import 'package:flutter/material.dart';

import '../common/layout_constants.dart';
import '../localizations/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/player_stats.dart';
import '../widgets/common/responsive_layout.dart';
import '../widgets/settings_aware_builder.dart';

class WinAccuracyStats extends StatelessWidget {

  const WinAccuracyStats({
    super.key,
    required this.statistics,
  });

  final PlayerStatistics statistics;

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

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
    final scheme = settings.currentScheme;

    return Semantics(
      container: true,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: titleFontSize,
          color: scheme.backgroundPuzzlePanel,
          fontWeight: FontWeight.bold,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.textPuzzlePanel,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
               child: Column(
                 children: [
                   FittedBox(
                     fit: BoxFit.scaleDown,
                     child: Text(
                       context.localizations.translate("dlg_playerstats_winrate"),
                       textAlign: TextAlign.center,
                     ),
                   ),
                   Text(
                     "${(statistics.total.winRate * 100).toStringAsFixed(1)}%",
                     textAlign: TextAlign.center,
                   ),
                 ],
               ),
              ),
              Container(color: Colors.black, width: 1, height: 60),
              Expanded(
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.localizations.translate("dlg_playerstats_accuracy"),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      "${(statistics.total.accuracy * 100).toStringAsFixed(1)}%",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
