import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/game_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'common/app_color_scheme.dart';
import 'common/custom_traversal_policy.dart';
import 'common/layout_constants.dart';
import 'common/native.dart';
import 'game.dart';
import 'localizations/app_localizations.dart';
import 'services/alerts_service.dart';
import 'services/app_data_service.dart';
import 'services/data_service.dart';
import 'widgets/common/responsive_layout.dart';
import 'widgets/loading_indicator.dart';

class HomePage extends StatefulWidget {

  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late bool _settingInitialized = false;
  late bool _gameInitialized = false;
  late bool _androidTvFixApplied = false;
  late bool _dialogShown = false;
  late String _selectedTheme = AppColorSchemes.defaultSchemeName;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    context.settingsBloc.add(ReadSettingEvent(name: KnownSettingsNames.settingTheme));
    context.gameBloc.add(InitializeGameEvent());
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FocusTraversalGroup(
      policy: const CustomOrderedTraversalPolicy(),
      child: MultiBlocListener(
          listeners: [
            BlocListener<SettingsBloc, SettingsBlocState>(
              listener: (BuildContext context, state) async {

                log("HomePage> listener SettingsBloc: $state");
                if(state is SettingsReadBlocState) {
                  if (state.name == KnownSettingsNames.settingTheme) {
                    setState(() {
                      _settingInitialized = true;
                      _selectedTheme = state.value ?? AppColorSchemes.defaultSchemeName;
                    });
                  }
                }
              }
            ),
            BlocListener<GameBloc, GameBlocState>(
              listener: (BuildContext context, state) async {
                log("HomePage> listener GameBloc: $state");
                if (state is InitializeGameCompleteState) {
                  setState(() {
                    _gameInitialized = true;
                  });
                }
              }
            ),
          ],
          child: Builder(
            builder: (context) {

              final colorScheme = AppColorSchemes.fromName(_selectedTheme);
              final appBarHeight = context.layout.get<double>(AppLayoutConstants.appbarHeightKey);

              return Scaffold(
                backgroundColor: colorScheme.backgroundPuzzlePanel,
                appBar: !_dialogShown ? null : PreferredSize(
                  preferredSize: Size.fromHeight(appBarHeight),
                  child: _buildAppBar(context, appBarHeight),
                ),

                body: _buildLayout(context, colorScheme, appBarHeight),
              );

            }
          ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, AppColorScheme colorScheme, double appBarHeight) {

    if (!(_settingInitialized && _gameInitialized)) {
      return Padding(
        padding: EdgeInsets.only(top: appBarHeight),
        child: LoadingIndicator(
          colorScheme: colorScheme,
          message: context.localizations.translate("home_loading")
        ),
      );
    }

    if (!_dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((d) async {
        if (!_androidTvFixApplied) {
          // Hack neded on Android TV for autofocus effects
          await setTraditionalFocusHighlightStrategy();
          _androidTvFixApplied = true;
        }
        await showFirstUsagePrompt();
        setState(() {
          _dialogShown = true;
        });
      });

      return Padding(
        padding: EdgeInsets.only(top: appBarHeight),
        child: LoadingIndicator(
          colorScheme: colorScheme,
          message: context.localizations.translate("home_loading")
        ),
      );
    }

    return const PuzzlePage();
  }

  AppBar _buildAppBar(BuildContext context, double appBarHeight) {
    final colorScheme = AppColorSchemes.fromName(_selectedTheme);
    return AppBar(
      backgroundColor: colorScheme.backgroundTopPanel,
      foregroundColor: colorScheme.textTopPanel,
      leading:
        FocusTraversalOrder(
          order: const GroupFocusOrder(GroupFocusOrder.groupAppCommands, 0),
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: 'About the game',
            child: IconButton(
              iconSize: appBarHeight - 8,
              icon: const Icon(Icons.description_outlined),
              focusColor: colorScheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().helpDialog(context, AppColorSchemes.fromName(_selectedTheme));
              },
            ),
          ),
        ),

      actions: [
        FocusTraversalOrder(
          order: const GroupFocusOrder(GroupFocusOrder.groupAppCommands, 1),
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: 'Open high scores',
            child: IconButton(
              iconSize: appBarHeight - 8,
              icon: const Icon(Icons.bar_chart),
              focusColor: colorScheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().highScoresDialog(context, AppColorSchemes.fromName(_selectedTheme));
              },
            ),
          ),
        ),
        FocusTraversalOrder(
          order: const GroupFocusOrder(GroupFocusOrder.groupAppCommands, 2),
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: 'Reset game',
            child: IconButton(
              iconSize: appBarHeight - 8,
              icon: const Icon(Icons.refresh),
              focusColor: colorScheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().resetGameDialog(
                  context,
                  AppColorSchemes.fromName(_selectedTheme),
                  onAccept: () {
                    context.gameBloc.add(ResetGameEvent());
                  }
                );
              },
            ),
          ),
        ),
        FocusTraversalOrder(
          order: const GroupFocusOrder(GroupFocusOrder.groupAppCommands, 3),
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: 'Change color scheme',
            child: IconButton(
              iconSize: appBarHeight - 8,
              icon: const Icon(Icons.palette_outlined),
              focusColor: colorScheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().settingsDialog(
                  context,
                  selectedTheme: _selectedTheme,
                  onSelect: (newTheme) {
                    context.settingsBloc.add(WriteSettingEvent(name: KnownSettingsNames.settingTheme, value: newTheme, reload: true));
                  }
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future showFirstUsagePrompt() async {

    final appDataService = AppDataService(dataService: globalDataService);
    if (appDataService.getFlag(KnownSettingsNames.firstUse) ?? true)
    {
      await appDataService.putFlag(KnownSettingsNames.firstUse, false);
      if (mounted) {
        await AlertsService().helpDialog(context, AppColorSchemes.fromName(_selectedTheme));
      }
    }
  }
}
