import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../widgets/common/responsive_layout.dart';
import '../../common/app_color_scheme.dart';
import '../../common/constants.dart';
import '../../common/layout_constants.dart';
import '../../common/utils.dart';
import '../../localizations/app_localizations.dart';
import '../../models/player_stats.dart';
import '../../services/score_service.dart';
import '../common/percentage_bar.dart';
import '../localized_text.dart';

class HighScoresListPage extends StatelessWidget {

  HighScoresListPage({
    super.key,
    required this.colorScheme,

  });

  final AppColorScheme colorScheme;
  final scoreService = ScoreService();
  final sortOrderNotifier = ValueNotifier<(PlayerStatisticsSortOrder, bool)>((PlayerStatisticsSortOrder.score, false));

  @override
  Widget build(BuildContext context) {

    final layout = context.layout;
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
    final scores = scoreService.highScores();

    return scores.isEmpty ?
      _buildNoStats(context, colorScheme) :
      DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: bodyFontSize,
          color: colorScheme.textPuzzlePanel,
        ),
        child: ValueListenableBuilder(
          valueListenable: sortOrderNotifier,
          builder: (context, sortOrder, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const LocalizedText(
                  textId: "dlg_scores_intro",
                  placeholders: {"maxScoreHistory": Constants.maxScoreHistory},
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                _buildHeader(context, colorScheme, sortOrder),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Divider(color: colorScheme.textPuzzlePanel, height: 1),
                ),

                _buildStatsList(context, scores, colorScheme, sortOrder),
              ],
            );
          },
        ),
      );
  }

  Widget _buildHeader(BuildContext context, AppColorScheme scheme, (PlayerStatisticsSortOrder, bool) sortOrder) {
    return Semantics(
      label: "Below is the list of top scores, games won and lost",
      excludeSemantics: true,
      container: true,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                InkWell(
                  onTap: () => sortOrderNotifier.value = (PlayerStatisticsSortOrder.score, sortOrder.$2),
                  child: Text(
                    context.localizations.translate("dlg_scores_score"),
                    textAlign: TextAlign.start,
                  ),
                ),
                if (sortOrder.$1 == PlayerStatisticsSortOrder.score)
                  InkWell(
                    onTap: () => sortOrderNotifier.value = (PlayerStatisticsSortOrder.score, !sortOrder.$2),
                    child: Icon(
                      sortOrder.$2 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: scheme.textPuzzlePanel, // Customize the color of the icon
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => sortOrderNotifier.value = (PlayerStatisticsSortOrder.winrate, sortOrder.$2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      context.localizations.translate("dlg_scores_winrate"),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                if (sortOrder.$1 == PlayerStatisticsSortOrder.winrate)
                  InkWell(
                    onTap: () => sortOrderNotifier.value = (PlayerStatisticsSortOrder.winrate, !sortOrder.$2),
                    child: Icon(
                      sortOrder.$2 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: scheme.textPuzzlePanel, // Customize the color of the icon
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => sortOrderNotifier.value = (PlayerStatisticsSortOrder.accuracy, sortOrder.$2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      context.localizations.translate("dlg_scores_accuracy"),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                if (sortOrder.$1 == PlayerStatisticsSortOrder.accuracy)
                  InkWell(
                    onTap: () => sortOrderNotifier.value = (PlayerStatisticsSortOrder.accuracy, !sortOrder.$2),
                    child: Icon(
                      sortOrder.$2 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: scheme.textPuzzlePanel, // Customize the color of the icon
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsList(
    BuildContext context,
    List<PlayerStatistics> scores,
    AppColorScheme scheme,
    (PlayerStatisticsSortOrder, bool) sortOrder)
  {

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
    final sorted = PlayerStatisticsSorter.sort(scores, order: sortOrder. $1,ascending: sortOrder.$2);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ...sorted.mapIndexed((i, stats) {

            return Semantics(
              label: "Item ${i + 1}. Score is ${stats.score}, ${stats.total.wins} wins and ${stats.total.losses} losses.",
              container: true,
              excludeSemantics: true,
              child: Container(
                color: i % 2 == 0 ? Colors.transparent : scheme.textPuzzlePanel.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${stats.score}-${stats.total.wins}-${stats.total.losses}",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: PercentageBar(
                                      value: stats.total.winRate,
                                      height: 25,
                                      foregroundColor: scheme.textPuzzleSymbolsFlipped,
                                      backgroundColor: scheme.backgroundPuzzleSymbolsFlipped,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: PercentageBar(
                                      value: stats.total.accuracy,
                                      height: 25,
                                      foregroundColor: scheme.textPuzzleSymbolsFlipped,
                                      backgroundColor: scheme.backgroundPuzzleSymbolsFlipped,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          Text(
                            "last played: ${formatDateTime(stats.intervalEnd)}",
                            textAlign: TextAlign.end,
                            textScaler: const TextScaler.linear(0.9),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ]
      )
    );
  }

  Widget _buildNoStats(BuildContext context, AppColorScheme scheme) {

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);

    return Center(
      child: Semantics(
        container: true,
        child: Text.rich(
          textAlign: TextAlign.center,
          TextSpan(
            children: [
              TextSpan(
                text: context.localizations.translate("dlg_scores_norecord"),
                style: TextStyle(
                  color: scheme.textPuzzlePanel,
                  fontSize: titleFontSize,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
