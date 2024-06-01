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
import 'widgets/symbol_button.dart';

class HomePage extends StatefulWidget {

  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  SettingsBloc get settingsBloc => BlocProvider.of<SettingsBloc>(context);
  late String selectedTheme;
  late bool ready = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    settingsBloc.add(ReadSettingEvent(name: KnownSettingsNames.settingTheme));
    super.initState();
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
      child: Scaffold(
          backgroundColor: SymbolButton.defaultColorBackground,
          appBar: !ready ? null : PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: _buildAppBar(context),
          ),
          body: BlocListener<SettingsBloc, SettingsBlocState>(

            listener: (BuildContext context, state) async {

              // Hack neded on Android TV for autofocus effects
              await setTraditionalFocusHighlightStrategy();

              switch(state) {
                case final SettingsReadBlocState s:

                if (s.name == KnownSettingsNames.settingTheme) {
                  setState(() {
                    selectedTheme = s.value ?? GameColorSchemes.defaultSchemeName;
                    ready = true;
                    showFirstUsagePrompt(context);
                  });
                }
                break;
              }

            },
            child: ready ?
              const PuzzlePage() :
              const Center(child: CircularProgressIndicator()),
          )
        ),
    );
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
              onPressed: () {
                AlertsService().helpDialog(context, GameColorSchemes.fromName(selectedTheme));
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
              onPressed: () {
                AlertsService().highScoresDialog(context, GameColorSchemes.fromName(selectedTheme));
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
              onPressed: () {
                AlertsService().resetGameDialog(
                  context,
                  GameColorSchemes.fromName(selectedTheme),
                  onAccept: () {
                    BlocProvider.of<GameBloc>(context).add(ResetGameEvent());
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
              onPressed: () {
                AlertsService().colorSchemePicker(
                  context,
                  selectedTheme: selectedTheme,
                  onSelect: (newTheme) {
                    settingsBloc.add(WriteSettingEvent(name: KnownSettingsNames.settingTheme, value: newTheme, reload: true));
                  }
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future showFirstUsagePrompt(BuildContext context) async {

    final appDataService = AppDataService(dataService: globalDataService);
    if (appDataService.getFlag(KnownSettingsNames.firstUse) ?? true)
    {
      await appDataService.putFlag(KnownSettingsNames.firstUse, false);
      AlertsService().helpDialog(context, GameColorSchemes.fromName(selectedTheme));
    }
  }
}
