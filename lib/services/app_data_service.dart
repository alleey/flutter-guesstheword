import 'data_service.dart';

class KnownSettingsNames
{
  static const String firstUse = "firstUse";
  static const String settingTheme = "theme";
}

class AppDataService {
  final DataService dataService;

  AppDataService({required this.dataService});

  Future resetData() async {
    await dataService.appDataBox.clear();
  }

  bool? getFlag(String key) {
    final flags = getObject("flags");
    if (!flags.containsKey(key)) {
      return null;
    }
    return flags[key];
  }

  Future putFlag(String key, bool value) async {
    final flags = getObject("flags");
    flags[key] = value;
    await dataService.appDataBox.put("flags", flags);
  }

  String? getSetting(String key) {
    final flags = getObject("strings");
    if (!flags.containsKey(key)) {
      return null;
    }
    return flags[key];
  }

  Future putSetting(String key, String value) async {
    final flags = getObject("strings");
    flags[key] = value;
    await dataService.appDataBox.put("strings", flags);
  }

  Map<dynamic, dynamic> getObject(String key) =>
    dataService.appDataBox.get(key, defaultValue: {})!;

  Future putObject(String key, Map<dynamic, dynamic> value) async =>
    await dataService.appDataBox.put(key, value);
}
