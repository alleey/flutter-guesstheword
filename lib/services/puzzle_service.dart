
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/services.dart';

import '../common/constants.dart';
import '../models/puzzle.dart';
import 'app_data_service.dart';
import 'data_service.dart';

class PuzzleService {
  final _dataService = DataService();
  final _random = math.Random();

  PuzzleService();

  int get instanceId => _dataService.instanceId;

  Future resetData(int newInstanceId) async {
    await _dataService.puzzleBox.clear();
    await importAll();
  }

  Future<(int, Puzzle)?> randomPuzzle() async {
    if (_dataService.puzzleBox.isEmpty) {
      return null;
    }

    final index = _random.nextInt(_dataService.puzzleBox.length);
    final puzzle = _dataService.puzzleBox.getAt(index)!;
    return (index, puzzle);
  }

  Future delete(int index) async {

    if (_dataService.puzzleBox.isEmpty ||
        index < 0 ||
        index >= _dataService.puzzleBox.length)
    {
      return;
    }
    await _dataService.puzzleBox.deleteAt(index);
    await _dataService.puzzleBox.flush();
    dev.log("deleted puzzle#: $index");
  }

  Future importAll() async {

    for(final puzzleset in Constants.puzzleSets) {
      await importPuzzles("assets/puzzles/$puzzleset.json");
    }

    await applyTotalPuzzlesCountFix();

    dev.log("current number of puzzles: ${_dataService.puzzleBox.length}");
    dev.log("total number of puzzles: ${AppDataService().totalPuzzles}");
  }

  Future importPuzzles(String fileName) async {

    final appDataService = AppDataService();
    final key = "$fileName.imported";
    final alreadyImported = appDataService.getFlag(key) ?? false;

    if (alreadyImported) {
      dev.log("$fileName already imported");
      return;
    }
    //log("$fileName imported");

    final data = jsonDecode(await rootBundle.loadString(fileName));
    final String hint = data["hint"];
    final List<String> values = List<String>.from(data["values"]);

    for (var element in values) {
      await _dataService.puzzleBox.add(Puzzle(hint: hint, value: element));
    }

    await _dataService.puzzleBox.flush();
    await appDataService.putFlag(key, true);
    await appDataService.setTotalPuzzles(appDataService.totalPuzzles + values.length);
  }


  // Apply fix for previous broken versions.
  Future applyTotalPuzzlesCountFix() async {

    int totalPuzzles = 0;
    int currentPuzzles = _dataService.puzzleBox.length;

    for(final puzzleset in Constants.puzzleSets) {
      final data = jsonDecode(await rootBundle.loadString("assets/puzzles/$puzzleset.json"));
      final List<String> values = List<String>.from(data["values"]);
      totalPuzzles += values.length;
    }

    // The currentPuzzles could be greater than totalPuzzles when some puzzles are deleted in a newer version
    // of app.

    final appDataService = AppDataService();
    await appDataService.setTotalPuzzles(max(currentPuzzles, totalPuzzles));

    dev.log("applyTotalPuzzlesCountFix: ${appDataService.totalPuzzles}");
  }
}

