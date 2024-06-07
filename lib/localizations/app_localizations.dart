import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../common/constants.dart';

class AppLocalizations {

  AppLocalizations(this.locale);

  final Locale locale;
  final _localizedStrings = <String, String>{};

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<bool> load() async {

    _localizedStrings.clear();
    await _loadSpecific("en");

    if (locale.languageCode != "en") {
      try {
        await _loadSpecific(locale.languageCode);
      }
      catch (_) {}
    }

    return true;
  }

Future<void> _loadSpecific(String languageCode) async {
  try {
    final localeJsonString = await rootBundle.loadString('assets/l10n/app_$languageCode.arb');
    if (localeJsonString.isNotEmpty) {
      final localeJsonMap = json.decode(localeJsonString);
      localeJsonMap.forEach((key, value) {
        if (!key.toString().startsWith("@")) {
          _localizedStrings[key.toString()] = value?.toString() ?? '';
        }
      });
    }
  } catch (e) {
    log('Failed to load ARB file for language code: $languageCode, error: $e');
    rethrow;
  }
}

  String translate(String key, {Map<String, dynamic>? placeholders}) {
    var translatedString = _localizedStrings[key] ?? '';
    if (placeholders != null) {
      placeholders.forEach((placeholderKey, placeholderValue) {
        translatedString = translatedString.replaceAll(
          '{$placeholderKey}',
          placeholderValue.toString(),
        );
      });
    }
    return translatedString;
  }

  static const delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {

  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return Constants.locales.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    //log("new locale string loaded $locale");
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationsExtensions on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this);
}
