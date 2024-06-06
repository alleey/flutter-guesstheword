import 'data_service.dart';

class KnownSettingsNames
{
  static const String firstUse = "firstUse";
  static const String settingTheme = "theme";
  static const String settingLocale = "locale";
}

class AppDataService {
  final _dataService = DataService();

  AppDataService();

  int get instanceId => _dataService.instanceId;

  Future<int> resetData() async {
    await _dataService.appDataBox.clear();
    return await _dataService.ensureInstanceId();
  }

  bool? getFlag(String key) {
    return get<bool?>("flags.$key", null);
  }

  Future putFlag(String key, bool value) async {
    await put("flags.$key", value);
  }

  T getSetting<T>(String key, T defaultValue) {
    return get<T>("settings.$key", defaultValue);
  }

  Future putSetting<T>(String key, T value) async {
    await put("settings.$key", value);
  }

  T get<T>(String key, T defaultValue) {
    final value = _dataService.appDataBox.get(key);
    if (value == null) {
      return defaultValue;
    }
    return value as T;
  }

  Future put<T>(String key, T value) async {
    await _dataService.appDataBox.put(key, value);
    await _dataService.appDataBox.flush();
  }
}
