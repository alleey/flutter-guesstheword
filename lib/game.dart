import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/game_bloc.dart';
import 'common/constants.dart';
import 'services/alerts_service.dart';
import 'services/audio_service.dart';
import 'widgets/flip_card.dart';
import 'widgets/symbol_button.dart';
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
            audioService.play("audio/start.mp3");
            if (Constants.enableInitialReveal) {
              bloc.add(RequestHintEvent());
            }
            break;
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
      }
    );
  }

  Column _buildLayout(BuildContext context, GameState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            //color: Colors.blue,\
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: _buildTopPanel(context, state)
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            ),
            child: _buildPuzzlePanel(state)
          ),
        ),
        Expanded(
          flex: 5,
          child: _buildInputPanel(state),
        ),
      ],
    );
  }

  Widget _buildTopPanel(BuildContext context, GameState state) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: _buildScorePanel(state)
        ),
        Expanded(
          flex: 3,
          child: Center(
            child: FlipCard(
              showFront: !state.isGameOver,
              frontCard: _buildStatusPanel(context, state),
              backCard: _buildGameOverPanel(context, state),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScorePanel(GameState state) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Score: ${state.score.value}",
            style: const TextStyle(fontSize: 36, color: SymbolButton.defaultColorForeground),
          ),
          const SizedBox(width: 50,),
          Text(
            "Won: ${state.score.wins}",
            style: const TextStyle(fontSize: 36, color: SymbolButton.defaultColorForeground),
          ),
          const SizedBox(width: 50,),
          Text(
            "Lost: ${state.score.losses}",
            style: const TextStyle(fontSize: 36, color: SymbolButton.defaultColorForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPanel(BuildContext context, GameState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: Iterable<int>.generate(Constants.maxErrors)
        .map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: FlipCard(
            showFront: (e > (state.errorCount - 1)),
            frontCard: const Icon(Icons.favorite, size: 32, color: Colors.red),
            backCard: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(math.pi),
              child: const Icon(Icons.heart_broken, size: 32, color: Colors.yellow)
              ),
            transitionBuilder: AnimatedSwitcher.defaultTransitionBuilder,
          ),
        ))
        .toList(),
    );
  }

  Widget _buildGameOverPanel(BuildContext context, GameState state) {
    var theme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          state.isWin ? "\u{2713} +${state.winBonus}" : '\u{274C}',
          style: TextStyle(
            fontSize: theme.headlineLarge?.fontSize ?? 24,
            fontWeight: FontWeight.bold,
            color: state.isWin ? const Color.fromARGB(255, 8, 254, 16) : Colors.redAccent,
          ),
        ),
        const SizedBox(width: 10,),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              side: const BorderSide(width: 4, color: Colors.white70),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              alignment: Alignment.center,
            ),
            onPressed: () {
              startPuzzle();
            },
            child: const Text(
              "Go Next",
              style: TextStyle(color: Colors.white)
            )
          ),
        )
      ],
    );
  }

  Widget _buildPuzzlePanel(GameState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          state.hint,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SymbolPad(
            frontSymbols: '?' * state.value.length,
            backSymbols: state.value.toUpperCase(),
            flipped: state.revealed,
            whiteSpace: state.whiteSpace,
            foregroundColorFlipped: SymbolButton.defaultColorBackground,
            backgroundColorFlipped: SymbolButton.defaultColorForeground,
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Pick you letters wisely \u{2193}",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SymbolPad(
          frontSymbols: state.symbolSet.toUpperCase(),
          backSymbols: tried,
          flipped: state.used,
          foregroundColor: SymbolButton.defaultColorBackground,
          backgroundColor: SymbolButton.defaultColorForeground,
          spacing: 3,
          runSpacing: 3,
          onSelect: (c, flipped) {
            if (!flipped) bloc.add(UserInputEvent(c));
          },
        ),
      ],
    );
  }
}
