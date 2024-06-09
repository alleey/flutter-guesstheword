import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import '../common/constants.dart';
import '../models/puzzle.dart';

class DataService {

  static final DataService _instance = DataService._();

  DataService._();

  factory DataService() {
    return _instance;
  }

  late Box<String> scoreBox;
  late Box<Puzzle> puzzleBox;
  late Box<dynamic> appDataBox;
  late String version;
  late int instanceId;

  Future initialize() async {

    if (!kIsWeb) {
      await _cleanUpOldVersionFolders();
    }

    await Hive.initFlutter("guesstheword-v${Constants.appDataVersion}");
    Hive.registerAdapter(PuzzleAdapter());

    // on web for example the subdir is ignored, therefore need to put ver in filenames as well
    // as a fallback.
    scoreBox = await Hive.openBox<String>("stats-v${Constants.appDataVersion}");
    puzzleBox = await Hive.openBox<Puzzle>("puzzles-v${Constants.appDataVersion}");
    appDataBox = await Hive.openBox<dynamic>('appdata-v${Constants.appDataVersion}');

    version = await getLinkDonate();
    instanceId = await ensureInstanceId();
  }

  Future<int> ensureInstanceId() async {

    if (appDataBox.isEmpty) {
      await appDataBox.put("instanceId", DateTime.now().microsecondsSinceEpoch);
      await appDataBox.flush();
    }

    return appDataBox.get("instanceId");
  }

  Future<String> getVersion() async {
    final jsonString = await rootBundle.loadString('assets/version.json');
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap['version'];
  }

  Future<String> getLinkDonate() async {
    final jsonString = await rootBundle.loadString('assets/version.json');
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap['link_donate'];
  }

  Future<void> _cleanUpOldVersionFolders() async {

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
}