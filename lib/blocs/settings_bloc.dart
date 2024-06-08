
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/app_settings.dart';
import '../services/app_data_service.dart';

////////////////////////////////////////////

abstract class SettingsBlocEvent {}

class ReadSettingsBlocEvent extends SettingsBlocEvent {
  ReadSettingsBlocEvent();
}

class WriteSettingsBlocEvent extends SettingsBlocEvent {
  WriteSettingsBlocEvent({required this.settings, this.reload = false});
  final AppSettings settings;
  final bool reload;
}

////////////////////////////////////////////

class SettingsBlocState {}

class SettingsReadBlocState extends SettingsBlocState {
  SettingsReadBlocState({ required this.settings });
  final AppSettings settings;
}

class SettingsWrittenBlocState extends SettingsBlocState {
  SettingsWrittenBlocState({ required this.settings });
  final AppSettings settings;
}

////////////////////////////////////////////

class SettingsBloc extends Bloc<SettingsBlocEvent, SettingsBlocState>
{
  final _appDataService = AppDataService();
  var _settings = AppSettings();
  var _needReload = true;

  // Read-only access to the current state
  AppSettings get currentSettings => _settings;

  SettingsBloc() : super(SettingsBlocState())
  {
    on<ReadSettingsBlocEvent>((event, emit) async {

      if (!_needReload) {
        emit(SettingsReadBlocState(settings: currentSettings));
      }

      try {

        final String jsonString = _appDataService.get("config", "");
        if (jsonString.isNotEmpty) {
          _settings = AppSettings.fromJson(jsonDecode(jsonString));
        } else {
          log("Settings empty");
        }

        log("Settings read $_settings");
      }
      catch(e) {
        log("Settings error $e");
      }

      emit(SettingsReadBlocState(settings: currentSettings));
    });

    on<WriteSettingsBlocEvent>((event, emit) async {

      _settings = event.settings;
      _appDataService.put("config", jsonEncode(_settings.toJson()));

      emit(SettingsWrittenBlocState(settings: currentSettings));

      log("Settings saved $_settings");
      if (event.reload) {
        emit(SettingsReadBlocState(settings: currentSettings));
      } else {
        _needReload = true;
      }
    });
  }
}

extension GameBlocContextExtensions on BuildContext {
  SettingsBloc get settingsBloc => BlocProvider.of<SettingsBloc>(this);
}

