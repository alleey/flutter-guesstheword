import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/game_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'common/game_color_scheme.dart';
import 'common/utils.dart';
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
      policy: OrderedTraversalPolicy(),
      child: Scaffold(
          backgroundColor: SymbolButton.defaultColorBackground,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: _buildAppBar(context),
          ),
          body: BlocListener<SettingsBloc, SettingsBlocState>(

            listener: (BuildContext context, state) {

              switch(state) {
                case final SettingsReadBlocState s:
                if (s.name == KnownSettingsNames.settingTheme) {
                  setState(() {
                    selectedTheme = s.value ?? GameColorSchemes.defaultSchemeName;
                  });
                }
                break;
              }

              showAlert(context);
            },
            child: ready ?
              const PuzzlePage() :
              const Center(child: CircularProgressIndicator()),
          )
        ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading:
        FocusTraversalOrder(
          order: const GroupFocusOrder(GroupFocusOrder.groupAppCommands, 0),
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: 'About the game',
            child: IconButton(
              icon: const Icon(Icons.description_outlined),
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
              onPressed: () async {
                await AlertsService().resetGameDialog(
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
              onPressed: () async {
                await AlertsService().colorSchemePicker(
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

  Future showAlert(BuildContext context) async {

    final appDataService = AppDataService(dataService: globalDataService);

    if (appDataService.getFlag(KnownSettingsNames.firstUse) ?? true)
    {
      await AlertsService().helpDialog(context, GameColorSchemes.fromName(selectedTheme));
      await appDataService.putFlag(KnownSettingsNames.firstUse, false);
    }

    setState(() {
      ready = true;
    });
  }
}
