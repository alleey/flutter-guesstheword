
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:guess_the_word/services/app_data_service.dart';

import '../models/puzzle.dart';
import 'data_service.dart';

class PuzzleService {
  final DataService dataService;
  final _random = math.Random();

  PuzzleService({required this.dataService});

  Future resetData() async {
    await dataService.puzzleBox.clear();
    await importAll();
  }

  Future<Puzzle?> popOne() async {
    if (dataService.puzzleBox.isEmpty) {
      return null;
    }

    final index = _random.nextInt(dataService.puzzleBox.length);
    final puzzle = dataService.puzzleBox.getAt(index)!;

    await dataService.puzzleBox.deleteAt(index);
    await dataService.puzzleBox.flush();
    return puzzle;
  }

  Future importAll() async {
    await importPuzzles("assets/puzzles/animals.json");
    await importPuzzles("assets/puzzles/car-makers.json");
    await importPuzzles("assets/puzzles/countries.json");
    await importPuzzles("assets/puzzles/famous-cartoon-chars.json");
    await importPuzzles("assets/puzzles/fruits.json");
    log("total number of puzzles: ${dataService.puzzleBox.length}");
  }

  Future<void> importPuzzles(String fileName) async {

    final appDataService = AppDataService(dataService: dataService);
    final key = "$fileName.imported";
    final alreadyImported = appDataService.getFlag(key);

    if (alreadyImported ?? false) {
      log("$fileName already imported");
      return;
    }

    final data = jsonDecode(await rootBundle.loadString(fileName));
    final String hint = data["hint"];
    final List<String> values = List<String>.from(data["values"]);

    for (var element in values) {
      await dataService.puzzleBox.add(Puzzle(hint: hint, value: element));
    }
    await appDataService.putFlag(key, true);
  }
}
