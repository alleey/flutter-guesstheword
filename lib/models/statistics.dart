import 'package:json_annotation/json_annotation.dart';

part 'statistics.g.dart';

@JsonSerializable()
class Statistics implements Comparable<Statistics> {
  final int totalWins;
  final int totalLosses;
  final int correctInputs;
  final int mismatchedInputs;
  final int hintsUsed;

  double get accuracy => (correctInputs - hintsUsed) / (correctInputs + mismatchedInputs);
  double get winRate => totalWins / totalPlayed;
  int get totalPlayed => totalWins + totalLosses;

  Statistics({
    this.totalWins = 0,
    this.totalLosses = 0,
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
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      correctInputs: correctInputs ?? this.correctInputs,
      mismatchedInputs: mismatchedInputs ?? this.mismatchedInputs,
      hintsUsed: hintsUsed ?? this.hintsUsed,
    );
  }

  Statistics update({ required bool win, required int correctInputs, required int mismatchedInputs, required int hintsUsed }) {
    return copyWith(
      totalWins: win ? totalWins + 1 : totalWins,
      totalLosses: win ? totalLosses : totalLosses + 1,
      correctInputs: this.correctInputs + correctInputs,
      mismatchedInputs: this.mismatchedInputs + mismatchedInputs,
      hintsUsed: this.hintsUsed + hintsUsed,
    );
  }

  @override
  int compareTo(Statistics other) {
    var v = other.totalPlayed.compareTo(totalPlayed);
    if (v == 0) {
      v = totalWins.compareTo(other.totalWins);
      if (v == 0) {
        v = correctInputs.compareTo(other.correctInputs);
        if (v == 0) {
          v = mismatchedInputs.compareTo(other.mismatchedInputs);
          if (v == 0) {
            v = hintsUsed.compareTo(other.hintsUsed);
          }
        }
      }
    }
    return v;
  }

  @override
  String toString() {
    return 'Statistics(totalWins: $totalWins, totalLosses: $totalLosses, correctInputs: $correctInputs, mismatchedInputs: $mismatchedInputs, hintsUsed: $hintsUsed, accuracy: ${accuracy.toStringAsFixed(2)}, winRate: ${winRate.toStringAsFixed(2)})';
  }

  factory Statistics.fromJson(Map<String, dynamic> json) => _$StatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsToJson(this);
}

@JsonSerializable()
class StatisticsCollection {

  static const String categoryNameOverall = "overall";

  StatisticsCollection({
    int? instance,
    Map<String, Statistics>? statisticsMap,
  }) : _statisticsMap = statisticsMap ?? {}, instance = instance ?? 0;

  int instance;
  @JsonKey(name: 'statistics_collection')
  Map<String, Statistics> _statisticsMap = {};

  Statistics forCategory(String name) => _statisticsMap[name] ?? Statistics();
  Statistics get overall => forCategory(categoryNameOverall);

  List<MapEntry<String, Statistics>> get sortedByWinRate => _sortedByComparator((a, b) => b.value.winRate.compareTo(a.value.winRate));
  List<MapEntry<String, Statistics>> get sortedByAccuracy => _sortedByComparator((a, b) => b.value.accuracy.compareTo(a.value.accuracy));

  StatisticsCollection update({
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
    updated[categoryNameOverall] = overall.update(
      win: win,
      correctInputs:
      correctInputs,
      mismatchedInputs: mismatchedInputs,
      hintsUsed: hintsUsed
    );
    return StatisticsCollection(instance: instance, statisticsMap: updated);
  }

  Map<String, Statistics> getStatisticsExcludingOverall() {
    return Map.fromEntries(_statisticsMap.entries.where((entry) => entry.key != categoryNameOverall));
  }

  List<MapEntry<String, Statistics>> _sortedByComparator(Comparator<MapEntry<String, Statistics>> comparator) {
    final categoriesWithStats = getStatisticsExcludingOverall().entries.toList();
    categoriesWithStats.sort(comparator);
    return categoriesWithStats;
  }

  factory StatisticsCollection.fromJson(Map<String, dynamic> json) => _$StatisticsCollectionFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsCollectionToJson(this);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('StatisticsCollection:');
    _statisticsMap.forEach((category, stats) {
      buffer.writeln('  $category: $stats');
    });
    return buffer.toString();
  }
}
