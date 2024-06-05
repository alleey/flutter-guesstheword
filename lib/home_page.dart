import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/game_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'common/custom_traversal_policy.dart';
import 'common/game_color_scheme.dart';
import 'common/native.dart';
import 'game.dart';
import 'services/alerts_service.dart';
import 'services/app_data_service.dart';
import 'services/data_service.dart';
import 'widgets/loading_indicator.dart';

class HomePage extends StatefulWidget {

  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late bool settingInitialized = false;
  late bool gameInitialized = false;
  late bool androidTvFixApplied = false;
  late bool dialogShown = false;
  late String selectedTheme = GameColorSchemes.defaultSchemeName;

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
                      settingInitialized = true;
                      selectedTheme = state.value ?? GameColorSchemes.defaultSchemeName;
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
                    gameInitialized = true;
                  });
                }
              }
            ),
          ],
          child: Builder(
            builder: (context) {

              final colorScheme = GameColorSchemes.fromName(selectedTheme);

              return Scaffold(
                backgroundColor: colorScheme.backgroundPuzzlePanel,
                appBar: !dialogShown ? null : PreferredSize(
                  preferredSize: const Size.fromHeight(40.0),
                  child: _buildAppBar(context),
                ),

                body: _buildLayout(colorScheme),
              );

            }
          ),
      ),
    );
  }

  Widget _buildLayout(GameColorScheme colorScheme) {

    if (!(settingInitialized && gameInitialized)) {
      return LoadingIndicator(colorScheme: colorScheme);
    }

    if (!dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((d) async {
        if (!androidTvFixApplied) {
          // Hack neded on Android TV for autofocus effects
          await setTraditionalFocusHighlightStrategy();
          androidTvFixApplied = true;
        }
        await showFirstUsagePrompt();
        setState(() {
          dialogShown = true;
        });
      });
    }

    if (!dialogShown) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: LoadingIndicator(colorScheme: colorScheme),
      );
    }

    return const PuzzlePage();
  }

  AppBar _buildAppBar(BuildContext context) {
    final colorScheme = GameColorSchemes.fromName(selectedTheme);
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
              icon: const Icon(Icons.description_outlined),
              focusColor: colorScheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().helpDialog(context, GameColorSchemes.fromName(selectedTheme));
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
              icon: const Icon(Icons.bar_chart),
              focusColor: colorScheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().highScoresDialog(context, GameColorSchemes.fromName(selectedTheme));
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
              icon: const Icon(Icons.refresh),
              focusColor: colorScheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().resetGameDialog(
                  context,
                  GameColorSchemes.fromName(selectedTheme),
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
              icon: const Icon(Icons.palette_outlined),
              focusColor: colorScheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().colorSchemePicker(
                  context,
                  selectedTheme: selectedTheme,
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
        await AlertsService().helpDialog(context, GameColorSchemes.fromName(selectedTheme));
      }
    }
  }
}
