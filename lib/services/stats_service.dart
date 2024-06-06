import 'dart:convert';

import '../models/statistics.dart';
import 'data_service.dart';

class StatisticsService {
  final _dataService = DataService();

  int get instanceId => _dataService.instanceId;

  Future resetData(int newInstanceId) async {
    await _dataService.statsBox.clear();
  }

  StatisticsCollection get() {
    final String jsonString = _dataService.statsBox.get("current", defaultValue: "");
    final statistics = jsonString.isNotEmpty ?
      StatisticsCollection.fromJson(jsonDecode(jsonString)):
      StatisticsCollection(instance: instanceId);
    return statistics;
  }

  Future save(StatisticsCollection statistics) async {
    await _dataService.statsBox.put("current", jsonEncode(statistics.toJson()));
  }

  // Future<StatisticsCollection> update({
  //   required String category,
  //   required bool win,
  //   required int correctInputs,
  //   required int mismatchedInputs,
  //   required int hintsUsed
  // }) async {

  //   final stats = get().update(
  //     category: category,
  //     win: win,
  //     correctInputs: correctInputs,
  //     mismatchedInputs: mismatchedInputs,
  //     hintsUsed: hintsUsed
  //   );
  //   await save(stats);
  //   return stats;
  // }
}
