import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

import '../models/puzzle.dart';
import 'data_service.dart';

class AppDataService {
  final DataService dataService;

  AppDataService({required this.dataService});

  Future resetData() async {
    await dataService.appDataBox.clear();
  }

  bool? getFlag(String key) {
    final flags = dataService.appDataBox.get("flags", defaultValue: Map());
    if (!flags!.containsKey(key))
      return null;
    return flags![key];
  }

  Future putFlag(String key, bool value) async {
    final flags = dataService.appDataBox.get("flags", defaultValue: Map());
    flags![key] = value;
    await dataService.appDataBox.put("flags", flags);
  }

}
