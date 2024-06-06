import 'dart:developer';

import '../common/constants.dart';
import '../models/score.dart';
import 'data_service.dart';

class ScoreService {
  final _dataService = DataService();

  int get instanceId => _dataService.instanceId;

  Future resetData(int newInstanceId) async {
    final current = get();
    await put(Score(instance: newInstanceId, hintTokens: current.hintTokens));
  }

  Score get() => _dataService.scoreBox.get("current", defaultValue: Score(instance: instanceId))!;
  Score highest(int index) => _dataService.scoreBox.get("high.$index", defaultValue: Score(instance: 0))!;

  List<Score> highScores() {
    return Iterable<int>.generate(Constants.maxScoreHistory)
        .map((e) => highest(e))
        .where((e) => e.instance > 0 && e.gamesPlayed > 0)
        .toList();
  }

  Future put(Score value) async {

    log("save score: $value");

    await _dataService.scoreBox.put("current", value);

    var highs = highScores();
    // Remove this score instance if present (achieves update effect)
    highs.removeWhere((element) => element.instance == value.instance);
    highs.add(value);
    highs.sort();

    int index = 0;
    for(final element in highs.take(Constants.maxScoreHistory)) {
      await _dataService.scoreBox.put("high.$index", element);
      index++;
    }

    await _dataService.scoreBox.flush();
  }
}
