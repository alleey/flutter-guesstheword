import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../common/constants.dart';
import '../models/puzzle.dart';
import '../models/score.dart';

class DataService {

  late Box<Score> scoreBox;
  late Box<Puzzle> puzzleBox;
  late Box<Map> appDataBox;

  Future initialize() async {

    await Hive.initFlutter();
    Hive.registerAdapter(ScoreAdapter());
    Hive.registerAdapter(PuzzleAdapter());

    scoreBox = await Hive.openBox<Score>("score-v${Constants.appVersion}");
    puzzleBox = await Hive.openBox<Puzzle>("puzzles-v${Constants.appVersion}");
    appDataBox = await Hive.openBox<Map>('appData-v${Constants.appVersion}');
  }
}