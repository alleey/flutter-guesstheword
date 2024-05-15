import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';

import '../common/constants.dart';
import '../models/puzzle.dart';
import '../models/score.dart';

// The only global we have to tolerate
final globalDataService = DataService();

class DataService {

  late Box<Score> scoreBox;
  late Box<Puzzle> puzzleBox;
  late Box<Map> appDataBox;
  late String version;

  Future initialize() async {

    await Hive.initFlutter();
    Hive.registerAdapter(ScoreAdapter());
    Hive.registerAdapter(PuzzleAdapter());

    scoreBox = await Hive.openBox<Score>("score-v${Constants.appDataVersion}");
    puzzleBox = await Hive.openBox<Puzzle>("puzzles-v${Constants.appDataVersion}");
    appDataBox = await Hive.openBox<Map>('appData-v${Constants.appDataVersion}');

    version = await getVersion();
  }

  Future<String> getVersion() async {
    final jsonString = await rootBundle.loadString('assets/version.json');
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap['version'];
  }
}