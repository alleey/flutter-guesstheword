
import 'dart:math' as math;

import '../common/constants.dart';
import 'statistics.dart';

class PlayerStatistics implements Comparable<PlayerStatistics> {

  final int instance;
  final int score;
  final int hintTokens;
  final Statistics total;
  final CategoryStatistics categoryStatistics;
  final DateTime intervalStart;
  final DateTime intervalEnd;

  PlayerStatistics({
    this.instance = 0,
    this.score = 0,
    this.hintTokens = 0,
    Statistics? total,
    CategoryStatistics? categoryStatistics,
    DateTime? intervalStart,
    DateTime? intervalEnd,
  })  : total = total ?? Statistics(),
        categoryStatistics = categoryStatistics ?? CategoryStatistics(),
        intervalStart = intervalStart ?? DateTime.now().toUtc(),
        intervalEnd = intervalEnd ?? DateTime.now().toUtc();

  PlayerStatistics copyWith({
    int? instance,
    int? score,
    int? hintTokens,
    Statistics? total,
    CategoryStatistics? categoryStatistics,
    DateTime? intervalStart,
    DateTime? intervalEnd,
  }) {
    return PlayerStatistics(
      instance: instance ?? this.instance,
      score: score ?? this.score,
      hintTokens: hintTokens ?? this.hintTokens,
      total: total ?? this.total,
      categoryStatistics: categoryStatistics ?? this.categoryStatistics,
      intervalStart: intervalStart ?? this.intervalStart,
      intervalEnd: intervalEnd ?? this.intervalEnd,
    );
  }

  PlayerStatistics updateStats({
    required String category,
    required bool win,
    required int correctInputs,
    required int mismatchedInputs,
    required int hintsUsed
  }) {

    return copyWith(
      intervalEnd: DateTime.now().toUtc(),
      total: total.update(
        win: win,
        correctInputs: correctInputs,
        mismatchedInputs:
        mismatchedInputs,
        hintsUsed: hintsUsed
      ),
      categoryStatistics: categoryStatistics.update(
        category: category,
        win: win,
        correctInputs:
        correctInputs,
        mismatchedInputs:
        mismatchedInputs,
        hintsUsed: hintsUsed
      )
    );
  }

  int get gamesPlayed => total.totalPlayed;
  bool get isEmpty => gamesPlayed == 0;
  bool get isNotEmpty => gamesPlayed > 0;

  PlayerStatistics bump(int bump) {
    final progress = (score % Constants.scoreBumpForHintBonus) + bump;
    final hintBonus = (progress / Constants.scoreBumpForHintBonus).floor();
    return copyWith(
      intervalEnd: DateTime.now().toUtc(),
      score: score + bump,
      hintTokens: hintTokens + hintBonus
    );
  }

  PlayerStatistics grantTokens(int count) => copyWith(hintTokens: hintTokens + count);
  PlayerStatistics consumeToken() => copyWith(hintTokens: math.max(0, hintTokens - 1));

  factory PlayerStatistics.fromJson(Map<String, dynamic> json) {
    return PlayerStatistics(
      instance: json['instance'] ?? 0,
      score: json['score'] ?? 0,
      hintTokens: json['hintTokens'] ?? 0,
      total: Statistics.fromJson(json['total'] ?? {}),
      categoryStatistics: CategoryStatistics.fromJson(json['categoryStatistics'] ?? {}),
      intervalStart: DateTime.tryParse(json['intervalStart'] ?? "") ?? DateTime.now().toUtc(),
      intervalEnd: DateTime.tryParse(json['intervalEnd'] ?? "") ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instance': instance,
      'score': score,
      'hintTokens': hintTokens,
      'total': total.toJson(),
      'categoryStatistics': categoryStatistics.toJson(),
      'intervalStart': intervalStart.toIso8601String(),
      'intervalEnd': intervalEnd.toIso8601String(),
    };
  }

  @override
  int compareTo(PlayerStatistics other) {
    var v = other.score.compareTo(score);
    if (v == 0) {
      v = total.compareTo(other.total);
    }
    return v;
  }

  @override String toString() {
    return "Score[$instance, $score, $hintTokens, $total]";
  }
}

enum PlayerStatisticsSortOrder {
  score,
  winrate,
  accuracy,
}

class PlayerStatisticsSorter {

  static List<PlayerStatistics> sort(List<PlayerStatistics> stats, { required PlayerStatisticsSortOrder order, bool ascending = true})
    => switch(order) {
      PlayerStatisticsSortOrder.score => sortByScore(stats, ascending: ascending),
      PlayerStatisticsSortOrder.winrate => sortByWinRate(stats, ascending: ascending),
      PlayerStatisticsSortOrder.accuracy => sortByAccuracy(stats, ascending: ascending),
    };

  static List<PlayerStatistics> sortByScore(List<PlayerStatistics> stats, {bool ascending = true}) {
    stats.sort((a, b) => ascending ? a.score.compareTo(b.score) : b.score.compareTo(a.score));
    return stats;
  }

  static List<PlayerStatistics> sortByWinRate(List<PlayerStatistics> stats, {bool ascending = true}) {
    stats.sort((a, b) => ascending ? a.total.winRate.compareTo(b.total.winRate) : b.total.winRate.compareTo(a.total.winRate));
    return stats;
  }

  static List<PlayerStatistics> sortByAccuracy(List<PlayerStatistics> stats, {bool ascending = true}) {
    stats.sort((a, b) => ascending ? a.total.accuracy.compareTo(b.total.accuracy) : b.total.accuracy.compareTo(a.total.accuracy));
    return stats;
  }
}
