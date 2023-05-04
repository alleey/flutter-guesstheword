import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/game_bloc.dart';
import 'common/constants.dart';
import 'services/alerts_service.dart';
import 'services/audio_service.dart';
import 'widgets/flip_card.dart';
import 'widgets/symbol_pad.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {

  static const resetGameQuestion = "You've finished all the puzzles. To keep playing the game must reset";

  final audioService = AudioService();
  GameBloc get bloc => BlocProvider.of<GameBloc>(context);

  @override
  void initState() {
    super.initState();
    startPuzzle();
  }

  void startPuzzle() {
    //bloc.add(ResetGameEvent());
    bloc.add(StartPuzzleEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameBlocState>(
        listener: (context, state) {

          log("listener: $state");
          switch (state.runtimeType) {
            case ResetState:
              startPuzzle(); break;
            case PuzzleStartState:
              audioService.play("audio/start.mp3"); break;
            case InputMatchState:
              audioService.play("audio/match.mp3"); break;
            case InputMismatchState:
              audioService.play("audio/mismatch.mp3"); break;
            case NoMorePuzzleState:
              AlertsService().show(
                context,
                title: "Congratulations!",
                desc: resetGameQuestion,
                callback: () {
                  final bloc = BlocProvider.of<GameBloc>(context);
                  bloc.add(ResetGameEvent());
                }
              ).show();
              break;
          }
        },
        builder: (context, state) {

          log("builder: $state");
          if (state is GameState) {
            return _buildLayout(context, state);
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Column _buildLayout(BuildContext context, GameState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: _buildTopPanel(state),
        ),
        Expanded(
          flex: 1,
          child: _buildPuzzlePanel(state),
        ),
        Expanded(
          flex: 1,
          child: _buildInputPanel(state),
        ),
      ],
    );
  }

  Widget _buildTopPanel(GameState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
          child: _buildScorePanel(state),
        ),
        Expanded(
          child: FlipCard(
            showFront: !state.isGameOver,
            frontCard: _buildStatusPanel(state),
            backCard: _buildGameOverPanel(state),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverPanel(GameState state) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.isWin ? "\u{2713} Correct" : "Incorrect",
              style: TextStyle(
                fontSize: 64,
                color: state.isWin ? Colors.yellow : Colors.redAccent,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    side: const BorderSide(width: 5, color: Colors.white70),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.all(20)
                  ),
                  onPressed: () {
                    startPuzzle();
                  },
                  child: const Text(
                    "Go Next",
                    style: TextStyle(fontSize: 24)
                  )
                )
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildStatusPanel(GameState state) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: Iterable<int>.generate(Constants.maxErrors)
            .map((e) => FlipCard(
              showFront: (e > (state.errorCount - 1)),
              backCard: const Icon(Icons.heart_broken, size: 64, color: Colors.grey),
              frontCard: const Icon(Icons.favorite, size: 64, color: Colors.red),
              transitionBuilder: AnimatedSwitcher.defaultTransitionBuilder,
            ))
            .toList(),
        ),
      ],
    );
  }

  Widget _buildScorePanel(GameState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "SCORE: ${state.score.value}",
          style: const TextStyle(fontSize: 36, color: Constants.colorForeground),
        ),
        Text(
          "WON: ${state.score.wins}",
          style: const TextStyle(fontSize: 36, color: Constants.colorForeground),
        ),
        Text(
          "LOST: ${state.score.losses}",
          style: const TextStyle(fontSize: 36, color: Constants.colorForeground),
        ),
      ],
    );
  }

  Widget _buildPuzzlePanel(GameState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${state.hint} ?",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 32,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SymbolPad(
            frontSymbols: '?' * state.value.length,
            backSymbols: state.value.toUpperCase(),
            flipped: state.revealed,
            whiteSpace: state.whiteSpace,
            foregroundColorFlipped: Constants.colorBackground,
            backgroundColorFlipped: Constants.colorForeground,
            spacing: 2,
            runSpacing: 2,
            onSelect: (c, f) {},
          ),
        )
      ],
    );
  }

  Widget _buildInputPanel(GameState state) {
    final tried = state.symbolSet
        .split('')
        .map((e) => state.value.contains(e) ? '\u{2713}' : '\u{274C}')
        .join();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          const Text(
            "Pick you letters wisely \u{2193}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          SymbolPad(
            frontSymbols: state.symbolSet.toUpperCase(),
            backSymbols: tried,
            flipped: state.used,
            foregroundColor: Constants.colorBackground,
            backgroundColor: Constants.colorForeground,
            spacing: 2,
            runSpacing: 2,
            onSelect: (c, f) {
              if (!f) bloc.add(UserInputEvent(c));
            },
          ),
        ],
      ),
    );
  }
}
