import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/game_bloc.dart';
import 'game.dart';
import 'main.dart';
import 'services/alerts_service.dart';
import 'services/app_data_service.dart';
import 'widgets/symbol_button.dart';

class HomePage extends StatelessWidget {

  static const dataLossWarning = "Resetting the game will reset all puzzles already finished. High scores will be preserved.\n Continue?";

  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => showAlert(context));
    return Scaffold(
        backgroundColor: SymbolButton.defaultColorBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: _buildAppBar(context),
        ),
        body: const PuzzlePage());
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
                desc: dataLossWarning,
                callback: () {
                  final bloc = BlocProvider.of<GameBloc>(context);
                  bloc.add(ResetGameEvent());
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
