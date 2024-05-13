import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'blocs/game_bloc.dart';
import 'common/constants.dart';
import 'services/alerts_service.dart';
import 'services/audio_service.dart';
import 'widgets/blink_effect.dart';
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
        switch (state) {

          case ResetState _:
            startPuzzle();
            break;

          case PuzzleStartState _:
            audioService.play("audio/start.mp3");
            if (Constants.enableInitialReveal) {
              bloc.add(RequestHintEvent());
            }
            break;

          case InputMatchState _:
            audioService.play("audio/match.mp3");
            break;

          case InputMismatchState _:
            audioService.play("audio/mismatch.mp3");
            break;

          case NoMorePuzzleState _:
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
          flex: 3,
          child: Container(
            color: Colors.green.shade700,
            child: _buildTopPanel(context, state)
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.red.shade600,
            child: _buildPuzzlePanel(context, state)
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.blue.shade600,
            child: _buildInputPanel(context, state)
          ),
        ),
      ],
    );
  }

  Widget _buildTopPanel(BuildContext context, GameState state) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 2,),
            Expanded(
              child: _buildScorePanel(context, state)
            ),
            Expanded(
              child: FlipCard(
                showFront: !state.isGameOver,
                frontCard: _buildStatusPanel(context, state),
                backCard: _buildGameOverPanel(context, state),
              ),
            ),
            const SizedBox(height: 10,),
          ],
        ),
        if (!state.isGameOver && state.isHelpAvailable && state.hasErrors)
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 35,
                child: _buildHintsOption(context, state)
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScorePanel(BuildContext context, GameState state) {
    final fontSize = Theme.of(context).textTheme.titleMedium?.fontSize ?? Constants.defaultFontSize;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            " Score: ${state.score.value}  ",
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),
          Text(
            "Won: ${state.score.wins}  ",
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),
          Text(
            "Lost: ${state.score.losses} ",
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPanel(BuildContext context, GameState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:
      [
        ...Iterable<int>.generate(Constants.maxErrors).map((e)
          => FlipCard(
              showFront: (e > (state.errorCount - 1)),
              frontCard: const Icon(Icons.favorite, size: 36, color: Colors.yellow),
              backCard: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationX(math.pi),
                child: const Icon(Icons.heart_broken, size: 36, color: Colors.black)
              ),
              transitionBuilder: AnimatedSwitcher.defaultTransitionBuilder,
            )),
      ],
    );
  }

  Widget _buildGameOverPanel(BuildContext context, GameState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            state.isWin ? "\u{2713} +${state.winBonus}" : '\u{274C}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: state.isWin ? const Color.fromARGB(255, 8, 254, 16) : Colors.redAccent,
            ),
          ),
        ),
        const SizedBox(width: 20,),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade900,
              side: const BorderSide(width: 2, color: Colors.white70),
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

  Widget _buildHintsOption(BuildContext context, GameState state) {
    return BlinkEffect (
      child: ElevatedButton (
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap
        ),
        onPressed: () {
          AlertsService().askYesNo(
              context,
              desc: "You have a total of ${state.score.hintTokens} available hint tokens.\n\nUse a token to reveal one character?",
              type: null,
              callback: () {
                bloc.add(RequestHintEvent(userInitiated: true));
              }
          ).show();
        },
        child: Text(
          "Need a Hint?",
          style: TextStyle(color: Colors.green.shade900, fontSize: 12),
        ),
      )
    );
  }

  Widget _buildPuzzlePanel(BuildContext context, GameState state) {
    final fontSize = Theme.of(context).textTheme.titleMedium?.fontSize ?? Constants.defaultFontSize;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            " ${state.hint} ",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              ),
            ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SymbolPad(
            frontSymbols: '?' * state.value.length,
            backSymbols: state.value.toUpperCase(),
            flipped: state.revealed,
            whiteSpace: state.whiteSpace,
            foregroundColorFlipped: SymbolButton.defaultColorBackground,
            backgroundColorFlipped: Colors.white,
            spacing: 3,
            runSpacing: 3,
            alignment: WrapAlignment.start,
            buttonSize: const Size(45, 30),
            onSelect: (c, f) {},
          ),
        )
      ],
    );
  }

  Widget _buildInputPanel(BuildContext context, GameState state) {
    final fontSize = Theme.of(context).textTheme.titleMedium?.fontSize ?? Constants.defaultFontSize;
    final tried = state.symbolSet
        .split('')
        .map((e) => state.value.contains(e) ? '\u{2713}' : '\u{274C}')
        .join();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!state.isGameOver)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "Pick your letters wisely \u{2193}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                ),
              ),
          ),
        if (!state.isGameOver)
          SymbolPad(
            frontSymbols: state.symbolSet.toUpperCase(),
            backSymbols: tried,
            flipped: state.used,
            foregroundColor: SymbolButton.defaultColorBackground,
            backgroundColor: SymbolButton.defaultColorForeground,
            spacing: 3,
            runSpacing: 3,
            buttonSize: const Size(45, 30),
            onSelect: (c, flipped) {
              if (!flipped) bloc.add(UserInputEvent(c));
            },
          ),
        if (state.isGameOver)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(text: 'Find more about\n',),
                  TextSpan(
                    text: state.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const TextSpan(text: ' \u{2193}',),
                ],
              ),
              textAlign: TextAlign.center,
            )
          ),
        if (state.isGameOver)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              side: const BorderSide(width: 2, color: Colors.white70),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              alignment: Alignment.bottomCenter,
            ),
            onPressed: () async {
              final url = Uri.encodeFull("https://www.google.com/search?q=${state.hint} ${state.value}");
              await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
            },
            child: Text(
              'Google',
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
