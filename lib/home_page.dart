import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_word/common/game_color_scheme.dart';

import 'blocs/game_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'game.dart';
import 'services/alerts_service.dart';
import 'services/app_data_service.dart';
import 'services/data_service.dart';
import 'widgets/symbol_button.dart';

class HomePage extends StatefulWidget {

  static const dataLossWarning = "Resetting the game will reset all puzzles already finished. High scores will be preserved.\n Continue?";

  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  SettingsBloc get settingsBloc => BlocProvider.of<SettingsBloc>(context);
  late String selectedTheme;

  @override
  void initState() {
    settingsBloc.add(ReadSettingEvent(name: KnownSettingsNames.settingTheme));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => showAlert(context));
    return Scaffold(
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
                selectedTheme = s.value ?? GameColorSchemes.defaultThemeName;
              }
              break;
            }
          },
          child: const PuzzlePage(),
        )
      );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading:
        IconButton(
          icon: const Icon(Icons.description_outlined),
          onPressed: () {
            AlertsService().helpDialog(context).show();
          },
        ),

      actions: [
        IconButton(
          icon: const Icon(Icons.bar_chart),
          onPressed: () {
            AlertsService().highScoresDialog(context).show();
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            AlertsService().yesNoDialog(
                context,
                title: "RESET GAME",
                desc: HomePage.dataLossWarning,
                callback: () {
                  final bloc = BlocProvider.of<GameBloc>(context);
                  bloc.add(ResetGameEvent());
                }
            ).show();
          },
        ),
        IconButton(
          icon: const Icon(Icons.palette_outlined),
          onPressed: () {
            AlertsService().themePicker(
              context,
              selectedTheme: selectedTheme,
              callback: (newTheme) {
                settingsBloc.add(WriteSettingEvent(name: KnownSettingsNames.settingTheme, value: newTheme, reload: true));
              }
            ).show();
          },
        ),
      ],
    );
  }

  Future showAlert(BuildContext context) async {
    final appDataService = AppDataService(dataService: globalDataService);
    if (appDataService.getFlag("firstUse") ?? true) {
      AlertsService().helpDialog(context).show();
      await appDataService.putFlag("firstUse", false);
    }
  }
}
