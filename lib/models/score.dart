
import 'dart:math' as math;

import 'package:hive/hive.dart';

import '../common/constants.dart';

part 'score.g.dart';

@HiveType(typeId: 1)
class Score implements Comparable<Score> {

  @HiveField(0)
  final int instance;
  @HiveField(1)
  final int value;
  @HiveField(2)
  final int wins;
  @HiveField(3)
  final int losses;
  @HiveField(4)
  final int hintTokens;

  Score({
    required this.instance,
    this.value = 0,
    this.wins = 0,
    this.losses = 0,
    this.hintTokens = 0,
  });

  Score solved(int bump) {

    final progress = (value % Constants.scoreBumpForHintBonus) + bump;
    final hintBonus = (progress / Constants.scoreBumpForHintBonus).floor();
    return Score(
      instance: instance,
      value: value + bump,
      wins: wins + 1,
      hintTokens: hintTokens + hintBonus,
      losses: losses
    );
  }

  Score failed() {
    return Score(
      instance: instance,
      value: value,
      wins: wins,
      hintTokens: hintTokens,
      losses: losses + 1
    );
  }

  Score consumeToken() {
    return Score(
      instance: instance,
      value: value,
      wins: wins,
      hintTokens: math.max(0, hintTokens - 1),
      losses: losses
    );
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      instance: json["instance"],
      value: int.parse(json["value"]),
      wins: int.parse(json["wins"]),
      losses: int.parse(json["losses"]),
      hintTokens: int.parse(json["hintTokens"]),
    );
  }

  int get gamesPlayed => wins + losses;

  @override
  int compareTo(Score other) {
    var v = other.value.compareTo(value);
    if (v == 0) {
      v = wins.compareTo(other.wins);
      if (v == 0) {
        v = losses.compareTo(other.losses);
      }
    }
    return v;
  }

  @override String toString() {
    return "Score[$instance, $value, $wins, $losses, $hintTokens]";
  }
}