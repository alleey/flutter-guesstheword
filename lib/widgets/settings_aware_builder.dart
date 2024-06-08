import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/settings_bloc.dart';
import '../models/app_settings.dart';

class SettingsAwareBuilder extends StatefulWidget {

  const SettingsAwareBuilder({
    super.key,
    required this.builder,
    this.onChange
  });

  final Widget Function(BuildContext context, ValueNotifier<AppSettings> settingsProvider) builder;
  final void Function(AppSettings newSettings)? onChange;

  @override
  State<SettingsAwareBuilder> createState() => _SettingsAwareBuilderState();
}

class _SettingsAwareBuilderState extends State<SettingsAwareBuilder> {

  late ValueNotifier<AppSettings> _changeNotifier;

  @override
  void initState() {
    _changeNotifier  = ValueNotifier<AppSettings>(context.settingsBloc.currentSettings);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsBlocState>(
      listener: (BuildContext context, state) {
        if(state is SettingsReadBlocState) {
          _changeNotifier.value = state.settings;

          log("SettingsAwareBuilder> new settings: ${state.settings}");
          widget.onChange?.call(state.settings);
        }
      },
      child: widget.builder(context, _changeNotifier),
    );
  }
}