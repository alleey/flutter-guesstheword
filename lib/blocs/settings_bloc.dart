
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/app_data_service.dart';

////////////////////////////////////////////

abstract class SettingsBlocEvent {}

class ReadSettingEvent extends SettingsBlocEvent {
  final String name;
  dynamic defaultValue;
  ReadSettingEvent({required this.name, this.defaultValue});
}

class WriteSettingEvent extends SettingsBlocEvent {
  final String name;
  final dynamic value;
  final bool reload;
  WriteSettingEvent({required this.name, required this.value, this.reload = false});
}

////////////////////////////////////////////

abstract class SettingsBlocState {}

class InitialSettingsBlocEvent extends SettingsBlocState {}

class SettingsReadBlocState extends SettingsBlocState {
  final String name;
  final String? value;
  SettingsReadBlocState({required this.name, required this.value});
}

////////////////////////////////////////////

class SettingsBloc extends Bloc<SettingsBlocEvent, SettingsBlocState>
{
  final _appDataService = AppDataService();

  SettingsBloc() : super(InitialSettingsBlocEvent())
  {
    on<ReadSettingEvent>((event, emit) async {
      emit(SettingsReadBlocState(
        name: event.name,
        value: _appDataService.getSetting(event.name, event.defaultValue)
      ));
    });

    on<WriteSettingEvent>((event, emit) async {
      _appDataService.putSetting(event.name, event.value);
      if (event.reload) {
        emit(SettingsReadBlocState(name: event.name, value: event.value));
      }
    });
  }
}

extension GameBlocContextExtensions on BuildContext {
  SettingsBloc get settingsBloc => BlocProvider.of<SettingsBloc>(this);
}

