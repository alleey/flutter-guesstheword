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
import 'widgets/common/responsive_layout.dart';
import 'widgets/loading_indicator.dart';
import 'widgets/settings_aware_builder.dart';

class HomePage extends StatefulWidget {

  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late bool _gameInitialized = false;
  late bool _androidTvFixApplied = false;
  late bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    context.settingsBloc.add(ReadSettingsBlocEvent());
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
        child:  SettingsAwareBuilder(
          builder: (context, settingsProvider) => ValueListenableBuilder(
            valueListenable: settingsProvider,
            builder: (context, settings, child) {

              final appBarHeight = context.layout.get<double>(AppLayoutConstants.appbarHeightKey);
              final scheme = AppColorSchemes.fromName(settings.theme);

              return Scaffold(
                backgroundColor: scheme.backgroundPuzzlePanel,
                appBar: !_dialogShown ? null : PreferredSize(
                  preferredSize: Size.fromHeight(appBarHeight),
                  child: _buildAppBar(context, scheme, appBarHeight),
                ),
                body: _buildLayout(context, appBarHeight),
              );

            }
          ),
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, double appBarHeight) {

    if (!_gameInitialized) {
      return Padding(
        padding: EdgeInsets.only(top: appBarHeight),
        child: LoadingIndicator(
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
          message: context.localizations.translate("home_loading")
        ),
      );
    }

    return const PuzzlePage();
  }

  AppBar _buildAppBar(BuildContext context, AppColorScheme scheme, double appBarHeight) {
    return AppBar(
      backgroundColor: scheme.backgroundTopPanel,
      foregroundColor: scheme.textTopPanel,
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
              focusColor: scheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().helpDialog(context);
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
              focusColor: scheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().highScoresDialog(context);
              },
            ),
          ),
        ),
        FocusTraversalOrder(
          order: const GroupFocusOrder(GroupFocusOrder.groupAppCommands, 2),
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: 'Statisitcs',
            child: IconButton(
              iconSize: appBarHeight - 8,
              icon: const Icon(Icons.trending_up),
              focusColor: scheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().statsDialog(context);
              },
            ),
          ),
        ),
        FocusTraversalOrder(
          order: const GroupFocusOrder(GroupFocusOrder.groupAppCommands, 3),
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: 'Reset game',
            child: IconButton(
              iconSize: appBarHeight - 8,
              icon: const Icon(Icons.refresh),
              focusColor: scheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().resetGameDialog(context,
                  onAccept: () {
                    context.gameBloc.add(ResetGameEvent());
                  }
                );
              },
            ),
          ),
        ),
        FocusTraversalOrder(
          order: const GroupFocusOrder(GroupFocusOrder.groupAppCommands, 4),
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: 'Settings',
            child: IconButton(
              iconSize: appBarHeight - 8,
              icon: const Icon(Icons.settings),
              focusColor: scheme.textTopPanel.withOpacity(0.5),
              onPressed: () async {
                await AlertsService().settingsDialog(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future showFirstUsagePrompt() async {

    final appDataService = AppDataService();
    if (appDataService.getFlag(KnownSettingsNames.firstUse) ?? true)
    {
      await appDataService.putFlag(KnownSettingsNames.firstUse, false);
      if (mounted) {
        await AlertsService().helpDialog(context);
      }
    }
  }
}
