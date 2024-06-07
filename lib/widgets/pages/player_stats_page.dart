import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../widgets/common/responsive_layout.dart';
import '../../common/app_color_scheme.dart';
import '../../common/layout_constants.dart';
import '../../localizations/app_localizations.dart';
import '../../models/player_stats.dart';
import '../../models/statistics.dart';
import '../common/percentage_bar.dart';

class PlayerStatisticsPage extends StatelessWidget {

  PlayerStatisticsPage({
    super.key,
    required this.colorScheme,
    required this.statistics,

  });

  final PlayerStatistics statistics;
  final AppColorScheme colorScheme;
  final sortOrderNotifier = ValueNotifier<(CategoryStatisticsSortOrder, bool)>((CategoryStatisticsSortOrder.name, true));

  @override
  Widget build(BuildContext context) {

    final layout = context.layout;
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

    return statistics.isEmpty ?
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
                _buildTotalStats(context, colorScheme, statistics),
                const SizedBox(height: 10),

                _buildHeader(context, colorScheme, sortOrder),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Divider(color: colorScheme.textPuzzlePanel, height: 1),
                ),

                Expanded(
                  child: _buildStatsList(context, colorScheme, statistics, sortOrder)
                ),
              ],
            );
          }
        )
      );
  }


  Widget _buildTotalStats(BuildContext context, AppColorScheme scheme, PlayerStatistics score) {

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);

    return Center(
      child: Semantics(
        container: true,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: titleFontSize,
            color: colorScheme.backgroundPuzzlePanel,
            fontWeight: FontWeight.bold,
          ),
          child: Row(
            children: [
              Expanded(
               child: Container(
                  decoration: BoxDecoration(
                    color: scheme.textPuzzlePanel,
                    //borderRadius: BorderRadius.circular(3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Text(
                        context.localizations.translate("dlg_playerstats_winrate"),
                        textAlign: TextAlign.center,
                      ),
                      Divider(color: scheme.backgroundPuzzleSymbols, height: 1, indent: 15, endIndent: 15,),
                      Text(
                        "${(score.total.winRate * 100).toStringAsFixed(1)}%",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                ),
              ),
              VerticalDivider(color: scheme.backgroundPuzzleSymbols, width: 1, indent: 15, endIndent: 15,),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.textPuzzlePanel,
                    //borderRadius: BorderRadius.circular(3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Text(
                        context.localizations.translate("dlg_playerstats_accuracy"),
                        textAlign: TextAlign.center,
                      ),
                      Divider(color: scheme.backgroundPuzzleSymbols, height: 1, indent: 15, endIndent: 15,),
                      Text(
                        "${(score.total.accuracy * 100).toStringAsFixed(1)}%",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppColorScheme scheme, (CategoryStatisticsSortOrder, bool) sortOrder) {
    return Semantics(
      label: "Below is the list of top scores, games won and lost",
      excludeSemantics: true,
      container: true,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                InkWell(
                  onTap: () => sortOrderNotifier.value = (CategoryStatisticsSortOrder.name, sortOrder.$2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      context.localizations.translate("dlg_playerstats_category"),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                if (sortOrder.$1 == CategoryStatisticsSortOrder.name)
                  InkWell(
                    onTap: () => sortOrderNotifier.value = (CategoryStatisticsSortOrder.name, !sortOrder.$2),
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
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => sortOrderNotifier.value = (CategoryStatisticsSortOrder.winrate, sortOrder.$2),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            context.localizations.translate("dlg_playerstats_winrate"),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      if (sortOrder.$1 == CategoryStatisticsSortOrder.winrate)
                        InkWell(
                          onTap: () => sortOrderNotifier.value = (CategoryStatisticsSortOrder.winrate, !sortOrder.$2),
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
                        onTap: () => sortOrderNotifier.value = (CategoryStatisticsSortOrder.accuracy, sortOrder.$2),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            context.localizations.translate("dlg_playerstats_accuracy"),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      if (sortOrder.$1 == CategoryStatisticsSortOrder.accuracy)
                        InkWell(
                          onTap: () => sortOrderNotifier.value = (CategoryStatisticsSortOrder.accuracy, !sortOrder.$2),
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
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
    final sorted = CategoryStatisticsSorter.sort(score.categoryStatistics, order: sortOrder.$1, ascending: sortOrder.$2);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...sorted.mapIndexed((i, stats) {
            return Semantics(
              label: "",
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
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: PercentageBar(
                                  value: stats.value.winRate,
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
                                  value: stats.value.accuracy,
                                  height: 25,
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
