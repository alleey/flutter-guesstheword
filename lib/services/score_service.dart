import 'dart:developer';

import 'package:guess_the_word/common/constants.dart';

import '../models/score.dart';
import 'data_service.dart';

class ScoreService {
  final DataService dataService;

  ScoreService({required this.dataService});

  Future resetData() async {
    final current = get();
    await put(Score(instance: _randomId, hintTokens: current.hintTokens));
  }

  int get _randomId => DateTime.now().microsecondsSinceEpoch;

  Score get() => dataService.scoreBox.get("current", defaultValue: Score(instance: _randomId))!;
  Score highest(int index) => dataService.scoreBox.get("high.$index", defaultValue: Score(instance: 0))!;

  List<Score> highScores() {
    return Iterable<int>.generate(Constants.maxScoreHistory)
        .map((e) => highest(e))
        .where((e) => e.instance > 0 && e.gamesPlayed > 0)
        .toList();
  }

  Future put(Score value) async {

    log("save score: $value");

    await dataService.scoreBox.put("current", value);

    var highs = highScores();
    // Remove this score instance if present (achieves update effect)
    highs.removeWhere((element) => element.instance == value.instance);
    highs.add(value);
    highs.sort();

    int index = 0;
    for(final element in highs.take(Constants.maxScoreHistory)) {
      await dataService.scoreBox.put("high.$index", element);
      index++;
    }
  }
}
