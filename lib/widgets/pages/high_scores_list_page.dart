import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../widgets/common/responsive_layout.dart';
import '../../common/app_color_scheme.dart';
import '../../common/constants.dart';
import '../../common/layout_constants.dart';
import '../../common/utils.dart';
import '../../localizations/app_localizations.dart';
import '../../models/app_settings.dart';
import '../../models/player_stats.dart';
import '../../services/alerts_service.dart';
import '../common/focus_highlight.dart';
import '../common/percentage_bar.dart';
import '../localized_text.dart';
import '../settings_aware_builder.dart';

class HighScoresListPage extends StatefulWidget {

  const HighScoresListPage({
    super.key,
    required this.statisticsList,

  });

  final List<PlayerStatistics> statisticsList;

  @override
  State<HighScoresListPage> createState() => _HighScoresListPageState();
}

class _HighScoresListPageState extends State<HighScoresListPage> {

  final _sortOrderNotifier = ValueNotifier<(PlayerStatisticsSortOrder, bool)>((PlayerStatisticsSortOrder.score, false));

  @override
  void dispose() {
    _sortOrderNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  SettingsAwareBuilder(
      builder: (context, settingsProvider) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder(
          valueListenable: settingsProvider,
          builder: (context, settings, child) =>  _buildContents(context, settings)
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context, AppSettings settings) {

    final scheme = settings.currentScheme;
    final layout = context.layout;
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
    final scores = widget.statisticsList;

    return scores.isEmpty ?
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

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: LocalizedText(
                    textId: "dlg_scores_intro",
                    placeholders: {"maxScoreHistory": Constants.maxScoreHistory},
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                _buildHeader(context, scheme, sortOrder),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Divider(color: scheme.textPuzzlePanel, height: 1),
                ),

                Expanded(child: _buildStatsList(context, scores, scheme, sortOrder)),
              ],
            );
          },
        ),
      );
  }

  Widget _buildHeader(BuildContext context, AppColorScheme scheme, (PlayerStatisticsSortOrder, bool) sortOrder) {

    void toggleSort(PlayerStatisticsSortOrder order) {
      if (_sortOrderNotifier.value.$1 == order) {
        _sortOrderNotifier.value = (order, !_sortOrderNotifier.value.$2);
      } else {
        _sortOrderNotifier.value = (order, true);
      }
    }

    return Semantics(
      label: "Below is the list of top scores, games won and lost",
      excludeSemantics: true,
      container: true,
      child: Row(
        children: [
          Expanded(
            child: FocusHighlight(
              focusColor: scheme.textPuzzlePanel,
              child: InkWell(
                onTap: () => toggleSort(PlayerStatisticsSortOrder.score),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        context.localizations.translate("dlg_scores_score"),
                        textAlign: TextAlign.start,
                        textScaler: const TextScaler.linear(0.9),
                      ),
                    ),
                    if (sortOrder.$1 == PlayerStatisticsSortOrder.score)
                      Icon(
                        sortOrder.$2 ? Icons.arrow_upward : Icons.arrow_downward,
                        color: scheme.textPuzzlePanel, // Customize the color of the icon
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FocusHighlight(
              focusColor: scheme.textPuzzlePanel,
              child: InkWell(
                onTap: () => toggleSort(PlayerStatisticsSortOrder.winrate),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        context.localizations.translate("dlg_scores_winrate"),
                        textAlign: TextAlign.start,
                        textScaler: const TextScaler.linear(0.9),
                      ),
                    ),
                    if (sortOrder.$1 == PlayerStatisticsSortOrder.winrate)
                      Icon(
                        sortOrder.$2 ? Icons.arrow_upward : Icons.arrow_downward,
                        color: scheme.textPuzzlePanel, // Customize the color of the icon
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FocusHighlight(
              focusColor: scheme.textPuzzlePanel,
              child: InkWell(
                onTap: () => toggleSort(PlayerStatisticsSortOrder.accuracy),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        context.localizations.translate("dlg_scores_accuracy"),
                        textAlign: TextAlign.start,
                        textScaler: const TextScaler.linear(0.9),
                      ),
                    ),
                    if (sortOrder.$1 == PlayerStatisticsSortOrder.accuracy)
                      Icon(
                        sortOrder.$2 ? Icons.arrow_upward : Icons.arrow_downward,
                        color: scheme.textPuzzlePanel, // Customize the color of the icon
                      ),
                  ],
                ),
              ),
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
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
    final sorted = PlayerStatisticsSorter.sort(scores, order: sortOrder. $1,ascending: sortOrder.$2);

    return SingleChildScrollView(
      //focusColor: scheme.backgroundPuzzlePanel,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ...sorted.mapIndexed((i, stats) {

            return FocusHighlight(
              focusColor: scheme.textPuzzlePanel,
              child: InkWell(
                //canRequestFocus: false,
                onDoubleTap: () {
                  AlertsService().statsDialog(context, statstics: stats);
                },
                onLongPress: () {
                  AlertsService().statsDialog(context, statstics: stats);
                },
                child: Semantics(
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
                                fontSize: bodyFontSize,
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
                                          value: stats.total.accuracy,
                                          height: 20,
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
