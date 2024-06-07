
class Statistics implements Comparable<Statistics> {
  final int wins;
  final int losses;
  final int correctInputs;
  final int mismatchedInputs;
  final int hintsUsed;

  double get accuracy => (correctInputs - hintsUsed) / (correctInputs + mismatchedInputs);
  double get winRate => wins / totalPlayed;
  int get totalPlayed => wins + losses;

  Statistics({
    this.wins = 0,
    this.losses = 0,
    this.correctInputs = 0,
    this.mismatchedInputs = 0,
    this.hintsUsed = 0,
  });

  Statistics copyWith({
    int? totalWins,
    int? totalLosses,
    int? correctInputs,
    int? mismatchedInputs,
    int? hintsUsed,
  }) {
    return Statistics(
      wins: totalWins ?? wins,
      losses: totalLosses ?? losses,
      correctInputs: correctInputs ?? this.correctInputs,
      mismatchedInputs: mismatchedInputs ?? this.mismatchedInputs,
      hintsUsed: hintsUsed ?? this.hintsUsed,
    );
  }

  Statistics update({ required bool win, required int correctInputs, required int mismatchedInputs, required int hintsUsed }) {
    return copyWith(
      totalWins: win ? wins + 1 : wins,
      totalLosses: win ? losses : losses + 1,
      correctInputs: this.correctInputs + correctInputs,
      mismatchedInputs: this.mismatchedInputs + mismatchedInputs,
      hintsUsed: this.hintsUsed + hintsUsed,
    );
  }

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      correctInputs: json['correctInputs'] ?? 0,
      mismatchedInputs: json['mismatchedInputs'] ?? 0,
      hintsUsed: json['hintsUsed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wins': wins,
      'losses': losses,
      'correctInputs': correctInputs,
      'mismatchedInputs': mismatchedInputs,
      'hintsUsed': hintsUsed,
    };
  }

  @override
  int compareTo(Statistics other) {
    List<int Function()> comparisons = [
      () => other.totalPlayed.compareTo(totalPlayed),
      () => wins.compareTo(other.wins),
      () => losses.compareTo(other.losses),
      () => correctInputs.compareTo(other.correctInputs),
      () => mismatchedInputs.compareTo(other.mismatchedInputs),
      () => hintsUsed.compareTo(other.hintsUsed),
    ];

    for (var compare in comparisons) {
      int result = compare();
      if (result != 0) {
        return result;
      }
    }
    return 0;
  }

  @override
  String toString() {
    return 'Statistics(wins: $wins, losses: $losses, correctInputs: $correctInputs, mismatchedInputs: $mismatchedInputs, hintsUsed: $hintsUsed, accuracy: ${accuracy.toStringAsFixed(2)}, winRate: ${winRate.toStringAsFixed(2)})';
  }
}

class CategoryStatistics {

  Map<String, Statistics> _statisticsMap;

  CategoryStatistics({
    Map<String, Statistics>? statisticsMap,
  }) : _statisticsMap = statisticsMap ?? {};

  CategoryStatistics copyWith({Map<String, Statistics>? statisticsMap}) {
    return CategoryStatistics(
      statisticsMap: statisticsMap ?? _statisticsMap,
    );
  }

  Iterable<MapEntry<String, Statistics>> get entries => _statisticsMap.entries;

  Statistics forCategory(String name) => _statisticsMap[name] ?? Statistics();

  CategoryStatistics update({
    required String category,
    required bool win,
    required int correctInputs,
    required int mismatchedInputs,
    required int hintsUsed
  }) {

    final updated = Map<String, Statistics>.from(_statisticsMap);
    updated[category] = forCategory(category).update(
      win: win,
      correctInputs:
      correctInputs,
      mismatchedInputs: mismatchedInputs,
      hintsUsed: hintsUsed
    );
    return CategoryStatistics(statisticsMap: updated);
  }

  factory CategoryStatistics.fromJson(Map<String, dynamic> json) {
    Map<String, Statistics> statisticsMap = {};
    if (json['categoryStatistics'] != null) {
      (json['categoryStatistics'] as Map<String, dynamic>).forEach((key, value) {
        statisticsMap[key] = Statistics.fromJson(value);
      });
    }
    return CategoryStatistics(
      statisticsMap: statisticsMap,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    _statisticsMap.forEach((key, value) {
      data[key] = value.toJson();
    });
    return {
      'categoryStatistics': data,
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('CateogryStatistics:');
    _statisticsMap.forEach((category, stats) {
      buffer.writeln('  $category: $stats');
    });
    return buffer.toString();
  }
}

enum CategoryStatisticsSortOrder {
  name,
  winrate,
  accuracy,
}

class CategoryStatisticsSorter {

  static List<MapEntry<String, Statistics>> sort(CategoryStatistics stats, { required CategoryStatisticsSortOrder order, bool ascending = true})
    => switch(order) {
      CategoryStatisticsSortOrder.name => sortByCategory(stats, ascending: ascending),
      CategoryStatisticsSortOrder.winrate => sortByWinRate(stats, ascending: ascending),
      CategoryStatisticsSortOrder.accuracy => sortByAccuracy(stats, ascending: ascending),
    };

  static List<MapEntry<String, Statistics>> sortByCategory(CategoryStatistics stats, {bool ascending = true}) {
    final list = stats.entries.toList();
    list.sort((a, b) => ascending ? a.key.compareTo(b.key) : b.key.compareTo(a.key));
    return list;
  }

  static List<MapEntry<String, Statistics>> sortByWinRate(CategoryStatistics stats, {bool ascending = true}) {
    final list = stats.entries.toList();
    list.sort((a, b) => ascending ? a.value.winRate.compareTo(b.value.winRate) : b.value.winRate.compareTo(a.value.winRate));
    return list;
  }

  static List<MapEntry<String, Statistics>> sortByAccuracy(CategoryStatistics stats, {bool ascending = true}) {
    final list = stats.entries.toList();
    list.sort((a, b) => ascending ? a.value.accuracy.compareTo(b.value.accuracy) : b.value.accuracy.compareTo(a.value.accuracy));
    return list;
  }
}
