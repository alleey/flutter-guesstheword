import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../widgets/common/responsive_layout.dart';
import '../../common/app_color_scheme.dart';
import '../../common/layout_constants.dart';
import '../../localizations/app_localizations.dart';
import '../../models/app_settings.dart';
import '../../models/player_stats.dart';
import '../../models/statistics.dart';
import '../../services/app_data_service.dart';
import '../common/percentage_bar.dart';
import '../settings_aware_builder.dart';
import '../win_accuracy_stats.dart';

class PlayerStatisticsPage extends StatefulWidget {

  const PlayerStatisticsPage({
    super.key,
    required this.statistics,

  });

  final PlayerStatistics statistics;

  @override
  State<PlayerStatisticsPage> createState() => _PlayerStatisticsPageState();
}

class _PlayerStatisticsPageState extends State<PlayerStatisticsPage> {

  final _sortOrderNotifier = ValueNotifier<(CategoryStatisticsSortOrder, bool)>((CategoryStatisticsSortOrder.name, true));

  @override
  void dispose() {
    _sortOrderNotifier.dispose();
    super.dispose();
  }

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
    final totalPuzzles = AppDataService().getSetting("totalPuzzles", 1);

    return widget.statistics.isEmpty ?
      _buildNoStats(context, scheme) :
      DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: bodyFontSize,
          color: scheme.textPuzzlePanel,
        ),
        child: ValueListenableBuilder(
          valueListenable: _sortOrderNotifier,
          builder: (context, sortOrder, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompletionIndicator(totalPuzzles, scheme, widget.statistics),
                _buildScoreInfo(context, scheme, widget.statistics),
                _buildTotalStats(context, scheme, widget.statistics),

                _buildHeader(context, scheme, sortOrder),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Divider(color: scheme.textPuzzlePanel, height: 1),
                ),

                Expanded(
                  child: _buildStatsList(context, scheme, widget.statistics, sortOrder)
                ),
              ],
            );
          }
        )
      );
  }

  Widget _buildCompletionIndicator(int totalSize, AppColorScheme scheme, PlayerStatistics score) {
    return PercentageBar(
      showLabel: false,
      inverted: true,
      value: 1 - (score.total.totalPlayed.toDouble() / totalSize.toDouble()),
      height: 3,
      foregroundColor: scheme.textPuzzleSymbolsFlipped,
      backgroundColor: scheme.backgroundPuzzleSymbolsFlipped,
    );
  }

  Widget _buildScoreInfo(BuildContext context, AppColorScheme scheme, PlayerStatistics score) {

    final layout = context.layout;
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

    return Container(
      decoration: BoxDecoration(
        color: scheme.textPuzzlePanel.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  context.localizations.translate("dlg_playerstats_score", placeholders: { "value": score.score }),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: bodyFontSize,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                context.localizations.translate("dlg_playerstats_wins", placeholders: { "value": score.total.wins }),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: bodyFontSize,
                ),
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                context.localizations.translate("dlg_playerstats_losses", placeholders: { "value": score.total.losses }),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: bodyFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalStats(BuildContext context, AppColorScheme scheme, PlayerStatistics score) {
    return WinAccuracyStats(statistics: score);
  }

  Widget _buildHeader(BuildContext context, AppColorScheme scheme, (CategoryStatisticsSortOrder, bool) sortOrder) {
    return Semantics(
      label: "Below is the list of top scores, win rates and accuracies",
      excludeSemantics: true,
      container: true,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                InkWell(
                  onTap: () => _sortOrderNotifier.value = (CategoryStatisticsSortOrder.name, sortOrder.$2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      context.localizations.translate("dlg_playerstats_category"),
                      textAlign: TextAlign.start,
                      textScaler: const TextScaler.linear(0.9),
                    ),
                  ),
                ),
                if (sortOrder.$1 == CategoryStatisticsSortOrder.name)
                  InkWell(
                    onTap: () => _sortOrderNotifier.value = (CategoryStatisticsSortOrder.name, !sortOrder.$2),
                    child: Icon(
                      sortOrder.$2 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: scheme.textPuzzlePanel, // Customize the color of the icon
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => _sortOrderNotifier.value = (CategoryStatisticsSortOrder.winrate, sortOrder.$2),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            context.localizations.translate("dlg_playerstats_winrate"),
                            textAlign: TextAlign.start,
                            textScaler: const TextScaler.linear(0.9),
                          ),
                        ),
                      ),
                      if (sortOrder.$1 == CategoryStatisticsSortOrder.winrate)
                        InkWell(
                          onTap: () => _sortOrderNotifier.value = (CategoryStatisticsSortOrder.winrate, !sortOrder.$2),
                          child: Icon(
                            sortOrder.$2 ? Icons.arrow_upward : Icons.arrow_downward,
                            color: scheme.textPuzzlePanel,
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
                        onTap: () => _sortOrderNotifier.value = (CategoryStatisticsSortOrder.accuracy, sortOrder.$2),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            context.localizations.translate("dlg_playerstats_accuracy"),
                            textAlign: TextAlign.start,
                            textScaler: const TextScaler.linear(0.9),
                          ),
                        ),
                      ),
                      if (sortOrder.$1 == CategoryStatisticsSortOrder.accuracy)
                        InkWell(
                          onTap: () => _sortOrderNotifier.value = (CategoryStatisticsSortOrder.accuracy, !sortOrder.$2),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatsList(BuildContext context, AppColorScheme scheme, PlayerStatistics score, (CategoryStatisticsSortOrder, bool) sortOrder) {

    final layout = context.layout;
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
    final sorted = CategoryStatisticsSorter.sort(score.categoryStatistics, order: sortOrder.$1, ascending: sortOrder.$2);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...sorted.mapIndexed((i, stats) {
            return Semantics(
              label: "Category ${stats.key}",
              container: true,
              excludeSemantics: true,
              child: Container(
                color: i % 2 == 0 ? Colors.transparent : scheme.textPuzzlePanel.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            stats.key,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            textScaler: const TextScaler.linear(0.9),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: PercentageBar(
                                  value: stats.value.winRate,
                                  height: 20,
                                  foregroundColor: scheme.textPuzzleSymbolsFlipped,
                                  backgroundColor: scheme.backgroundPuzzleSymbolsFlipped,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: PercentageBar(
                                  value: stats.value.accuracy,
                                  height: 20,
                                  foregroundColor: scheme.textPuzzleSymbolsFlipped,
                                  backgroundColor: scheme.backgroundPuzzleSymbolsFlipped,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ]
      ),
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
                text: context.localizations.translate("dlg_playerstats_norecord"),
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
