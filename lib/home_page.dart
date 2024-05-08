import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/game_bloc.dart';
import 'common/constants.dart';
import 'game.dart';
import 'services/alerts_service.dart';
import 'widgets/symbol_button.dart';

class HomePage extends StatelessWidget {

  static const dataLossWarning = "Resetting the game will reset all data. High scores will be preserved.\n Are you sure you'd like to reset?";

  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: SymbolButton.defaultColorBackground,
        appBar: AppBar(
          title: const Text("Guess The Word"),
          actions: [
            IconButton(
              icon: const Icon(Icons.show_chart),
              onPressed: () {
                AlertsService().alertHighScores(context).show();
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                AlertsService().askYesNo(
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
            IconButton(
              icon: const Icon(Icons.help_center_outlined),
              onPressed: () {
                AlertsService().show(
                    context,
                    title: "Guess The Word",
                    desc: "Version: ${Constants.appVersion}",
                    callback: () {}
                ).show();
              },
            ),
          ],
        ),
        body: const PuzzlePage());
  }
}
