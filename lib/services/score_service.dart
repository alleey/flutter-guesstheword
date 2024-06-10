import 'dart:convert';
import 'dart:developer';

import '../common/constants.dart';
import '../models/player_stats.dart';
import 'data_service.dart';

class ScoreService {

  final _dataService = DataService();

  int get instanceId => _dataService.instanceId;

  Future resetData(int newInstanceId) async {
    final score = load();
    await save(PlayerStatistics(instance: newInstanceId, hintTokens: score.hintTokens));
  }

  PlayerStatistics load() =>  _load("current", instanceId);
  PlayerStatistics highest(int index) => _load("high.$index", 0);

  List<PlayerStatistics> highScores() {
    return Iterable<int>.generate(Constants.maxScoreHistory)
        .map((e) => highest(e))
        .where((e) => e.instance > 0 && e.gamesPlayed > 0)
        .toList();
  }

  bool isTopScore(PlayerStatistics? score) {
    final high = highest(0);
    return (score ?? load()).instance == high.instance;
  }

  Future save(PlayerStatistics value) async {

    log("save score: $value");

    await _save("current", value);

    var highs = highScores();
    // Remove this score instance if present (achieves update effect)
    highs.removeWhere((element) => element.instance == value.instance);
    highs.add(value);
    highs.sort();

    int index = 0;
    for(final element in highs.take(Constants.maxScoreHistory)) {
      await _save("high.$index", element);
      index++;
    }

    await _dataService.scoreBox.flush();
  }

  Future _save(String key, PlayerStatistics stats) async {
    await _dataService.scoreBox.put(key, jsonEncode(stats.toJson()));
  }

  PlayerStatistics _load(String key, int instance) {
    final String jsonString = _dataService.scoreBox.get(key, defaultValue: "")!;
    final stats = jsonString.isNotEmpty ?
      PlayerStatistics.fromJson(jsonDecode(jsonString)):
      PlayerStatistics(instance: instance);
    return stats;
  }
}

