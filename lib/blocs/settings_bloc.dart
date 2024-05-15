
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_word/services/app_data_service.dart';

import '../services/data_service.dart';

////////////////////////////////////////////

abstract class SettingsBlocEvent {}

class ReadSettingEvent extends SettingsBlocEvent {
  final String name;
  ReadSettingEvent({required this.name});
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
  final appDataService = AppDataService(dataService: globalDataService);

  SettingsBloc() : super(InitialSettingsBlocEvent())
  {
    on<ReadSettingEvent>((event, emit) async {
      emit(SettingsReadBlocState(name: event.name, value: appDataService.getSetting(event.name)));
    });

    on<WriteSettingEvent>((event, emit) async {
      appDataService.putSetting(event.name, event.value);
      if (event.reload) {
        emit(SettingsReadBlocState(name: event.name, value: event.value));
      }
    });
  }
}
