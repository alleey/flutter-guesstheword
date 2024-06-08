import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/settings_bloc.dart';
import '../models/app_settings.dart';

class SettingsAwareBuilder extends StatefulWidget {

  const SettingsAwareBuilder({
    super.key,
    required this.builder,
    this.onSettingsChange,
    this.onSettingsAvailable
  });

  final Widget Function(BuildContext context, ValueNotifier<AppSettings> settingsProvider) builder;
  final void Function(AppSettings newSettings)? onSettingsChange;
  final void Function(AppSettings settings)? onSettingsAvailable;

  @override
  State<SettingsAwareBuilder> createState() => _SettingsAwareBuilderState();
}

class _SettingsAwareBuilderState extends State<SettingsAwareBuilder> {

  late ValueNotifier<AppSettings> _changeNotifier;

  @override
  void initState() {
    super.initState();
    _changeNotifier  = ValueNotifier<AppSettings>(context.settingsBloc.currentSettings);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onSettingsAvailable?.call(_changeNotifier.value);
      }
    });
  }

  @override
  void dispose() {
    _changeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsBlocState>(
      listener: (BuildContext context, state) {
        if(state is SettingsReadBlocState) {
          _changeNotifier.value = state.settings;

          log("SettingsAwareBuilder> New settings received: ${state.settings}");
          widget.onSettingsAvailable?.call(state.settings);
          widget.onSettingsChange?.call(state.settings);
        }
      },
      child: widget.builder(context, _changeNotifier),
    );
  }
}