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

    final jsonString = await rootBundle.loadString(
      'assets/l10n/app_${locale.languageCode}.arb',
    );

    final jsonMap = json.decode(jsonString);

    _localizedStrings.clear();
    jsonMap.forEach((key, value) {
      if (!key.toString().startsWith("@")) {
        _localizedStrings[key.toString()] = value?.toString() ?? '';
      }
      //log("locale $key -> $value");
    });

    return true;
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
    log("new locale string loaded $locale");
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
