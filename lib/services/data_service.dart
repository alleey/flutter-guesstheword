import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import '../common/constants.dart';
import '../models/puzzle.dart';
import '../models/score.dart';

class DataService {

  static final DataService _instance = DataService._();

  DataService._();

  factory DataService() {
    return _instance;
  }

  late Box<Score> scoreBox;
  late Box<Puzzle> puzzleBox;
  late Box<dynamic> appDataBox;
  late Box<dynamic> statsBox;
  late String version;
  late int instanceId;

  Future initialize() async {

    if (!kIsWeb) {
      await cleanUpOldVersionFolders();
    }

    await Hive.initFlutter("guesstheword-v${Constants.appDataVersion}");
    Hive.registerAdapter(ScoreAdapter());
    Hive.registerAdapter(PuzzleAdapter());

    // on web for example the subdir is ignored, therefore need to put ver in filenames as well
    // as a fallback.
    scoreBox = await Hive.openBox<Score>("score-v${Constants.appDataVersion}");
    puzzleBox = await Hive.openBox<Puzzle>("puzzles-v${Constants.appDataVersion}");
    appDataBox = await Hive.openBox<dynamic>('appdata-v${Constants.appDataVersion}');
    statsBox = await Hive.openBox<dynamic>('stats-v${Constants.appDataVersion}');

    version = await getVersion();
    instanceId = await ensureInstanceId();
  }

  Future<int> ensureInstanceId() async {

    if (appDataBox.isEmpty) {
      await appDataBox.put("instanceId", DateTime.now().microsecondsSinceEpoch);
      await appDataBox.flush();
    }

    return appDataBox.get("instanceId");
  }


  Future<void> cleanUpOldVersionFolders() async {

    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final directories = Directory(appDocPath).listSync();

    const currentHiveFolderName = "guesstheword-v${Constants.appDataVersion}";
    for (FileSystemEntity entity in directories) {

      if (entity is Directory) {
        if (entity.path.contains("guesstheword-v") && !entity.path.endsWith(currentHiveFolderName)) {
          try {
            await entity.delete(recursive: true);
          } catch (e) {
            log("Error deleting folder ${entity.path}: $e");
          }
        }
      }
    }
  }

  Future<String> getVersion() async {
    final jsonString = await rootBundle.loadString('assets/version.json');
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap['version'];
  }
}