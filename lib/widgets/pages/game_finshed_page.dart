import 'package:flutter/material.dart';

import '../../common/layout_constants.dart';
import '../../localizations/app_localizations.dart';
import '../../models/app_settings.dart';
import '../../services/score_service.dart';
import '../../widgets/common/blink_effect.dart';
import '../../widgets/common/responsive_layout.dart';
import '../../widgets/settings_aware_builder.dart';
import '../../widgets/win_accuracy_stats.dart';

class GameFinshedPage extends StatelessWidget {

  const GameFinshedPage({
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
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);

    final scoreService = ScoreService();
    final score = scoreService.load();
    final highest = scoreService.highest(0);
    final isHighScore = score.instance == highest.instance;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: Icon(
                  Icons.celebration_outlined,
                  size: constraints.maxHeight,
                  color: scheme.textPuzzlePanel,
                ),
              );
            },
          ),
        ),
        WinAccuracyStats(statistics: score),
        Flexible(
          flex: 3,
          child: SingleChildScrollView(
            child: Semantics(
              container: true,
              child: Text.rich(
                textAlign: TextAlign.start,
                TextSpan(
                  children: [
                    TextSpan(
                      text: context.localizations.translate('dlg_needreset_message'),
                      style: TextStyle(
                        color: scheme.textPuzzlePanel,
                        fontSize: bodyFontSize,
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isHighScore)
          Expanded(
            child: Center(
              child: BlinkEffect(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  color: scheme.textPuzzlePanel,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    textAlign: TextAlign.start,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: context.localizations.translate('dlg_needreset_newhigh'),
                          style: TextStyle(
                            color: scheme.backgroundPuzzlePanel,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ),
          ),
      ],
    );
  }
}
