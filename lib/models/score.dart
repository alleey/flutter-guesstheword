
import 'package:hive/hive.dart';

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

  Score({
    required this.instance,
    this.value = 0,
    this.wins = 0,
    this.losses = 0,
  });

  Score solved(int v) {
    return Score(
      instance: instance,
      value: value + v,
      wins: wins + 1,
      losses: losses
    );
  }

  Score failed() {
    return Score(
      instance: instance,
      value: value,
      wins: wins,
      losses: losses + 1
    );
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      instance: json["instance"],
      value: int.parse(json["value"]),
      wins: int.parse(json["wins"]),
      losses: int.parse(json["losses"]),
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
}