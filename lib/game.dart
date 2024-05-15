import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'blocs/game_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'common/constants.dart';
import 'common/game_color_scheme.dart';
import 'services/alerts_service.dart';
import 'services/app_data_service.dart';
import 'services/audio_service.dart';
import 'services/data_service.dart';
import 'widgets/blink_effect.dart';
import 'widgets/flip_card.dart';
import 'widgets/symbol_pad.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {

  static const resetGameQuestion = "You've finished all the puzzles. To keep playing the game must reset";

  final appDataService = AppDataService(dataService: globalDataService);
  final audioService = AudioService();
  late GameColorScheme colorScheme;

  GameBloc get gameBloc => BlocProvider.of<GameBloc>(context);
  SettingsBloc get settingsBloc => BlocProvider.of<SettingsBloc>(context);

  @override
  void initState() {
    super.initState();
    colorScheme = GameColorSchemes.scheme(appDataService.getSetting("theme") ?? "default");
    startPuzzle();
  }

  void startPuzzle() {
    //bloc.add(ResetGameEvent());
    gameBloc.add(StartPuzzleEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsBlocState>(
      listener: (BuildContext context, state) {

        log("listener(SettingsBloc): $state");
        switch(state) {
          case final SettingsReadBlocState s:
          if (s.name == KnownSettingsNames.settingTheme) {
            setState(() {
              log("listener(SettingsBloc): $state");
              colorScheme = GameColorSchemes.scheme(s.value);
            });
          }
          break;
        }
      },
      child: BlocConsumer<GameBloc, GameBlocState>(
        listener: (context, state) {

          log("listener(GameBloc): $state");
          switch (state) {

            case ResetState _:
              startPuzzle();
              break;

            case PuzzleStartState _:
              audioService.play("audio/start.mp3");
              if (Constants.enableInitialReveal) {
                gameBloc.add(RequestHintEvent());
              }
              break;

            case InputMatchState _:
              audioService.play("audio/match.mp3");
              break;

            case InputMismatchState _:
              audioService.play("audio/mismatch.mp3");
              break;

            case NoMorePuzzleState _:
              AlertsService().okDialog(
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

          log("builder(GameBloc): $state");
          if (state is GameState) {
            return _buildLayout(context, state);
          }

          return const Center(child: CircularProgressIndicator());
        }
      ),
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
            color: colorScheme.backgroundTopPanel,
            child: _buildTopPanel(context, state)
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            color: colorScheme.backgroundPuzzlePanel,
            child: _buildPuzzlePanel(context, state)
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            color: colorScheme.backgroundInputPanel,
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

        if (!state.isGameOver && state.isHelpAvailable)
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 30,
                child: _buildHintsOption(context, state)
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScorePanel(BuildContext context, GameState state) {
    final fontSize = Theme.of(context).textTheme.titleLarge?.fontSize ?? Constants.defaultFontSize;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          style: TextStyle(
            fontSize: fontSize,
            color: colorScheme.textTopPanel,
          ),
          children: [
            TextSpan(
              text: '\u{273D}',
              style: TextStyle(
                color: colorScheme.colorIcons,
                fontWeight: FontWeight.bold,
              )
            ),
            TextSpan(
              text: "${state.score.value}-${state.score.wins}-${state.score.losses}      ",
            ),
            TextSpan(
              text: '\u{2726}',
              style: TextStyle(
                color: colorScheme.colorIcons,
                fontWeight: FontWeight.bold,
              )
            ),
            TextSpan(
              text: "${state.score.hintTokens}",
            ),
          ],
        ),
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
              frontCard: Icon(Icons.favorite, size: 36, color: colorScheme.colorHeart),
              backCard: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationX(math.pi),
                child: Icon(Icons.heart_broken, size: 36, color: colorScheme.colorHeartBroken)
              ),
              transitionBuilder: AnimatedSwitcher.defaultTransitionBuilder,
            )),
      ],
    );
  }

  Widget _buildGameOverPanel(BuildContext context, GameState state) {
    final fontSize = Theme.of(context).textTheme.titleLarge?.fontSize ?? Constants.defaultFontSize;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            state.isWin ? "\u{2713} +${state.winBonus}" : '\u{2717}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: state.isWin ? colorScheme.colorSuccess : colorScheme.colorFailure,
            ),
          ),
        ),
        const SizedBox(width: 20,),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.backgroundTopButton,
              side: BorderSide(width: 2, color: colorScheme.textTopPanel),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              alignment: Alignment.center,
            ),
            onPressed: () {
              startPuzzle();
            },
            child: Text(
              "Go Next",
              style: TextStyle(color: colorScheme.textTopButton)
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
          backgroundColor: colorScheme.textHintButton,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.bottomCenter
        ),
        onPressed: () {
          gameBloc.add(UseHintTokenEvent());
        },
        child: Text(
          "Use a Hint",
          style: TextStyle(color: colorScheme.backgroundHintButton),
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
              color: colorScheme.textInputPanel,
              ),
            ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SymbolPad(
            frontSymbols: '?' * state.puzzle.length,
            backSymbols: state.puzzle.toUpperCase(),
            flipped: state.revealed,
            whiteSpace: state.whiteSpace,
            foregroundColor: colorScheme.textPuzzleSymbols,
            backgroundColor: colorScheme.backgroundPuzzleSymbols,
            foregroundColorFlipped: colorScheme.textPuzzleSymbolsFlipped,
            backgroundColorFlipped: colorScheme.backgroundPuzzleSymbolsFlipped,
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
        .map((e) => state.puzzle.toLowerCase().contains(e) ? '\u{2713}' : '\u{2717}')
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
                color: colorScheme.textInputPanel,
                ),
              ),
          ),
        if (!state.isGameOver)
          SymbolPad(
            frontSymbols: state.symbolSet.toUpperCase(),
            backSymbols: tried,
            flipped: state.used,
            foregroundColor: colorScheme.textInputSymbols,
            backgroundColor: colorScheme.backgroundInputSymbols,
            foregroundColorFlipped: colorScheme.textInputSymbolsFlipped,
            backgroundColorFlipped: colorScheme.backgroundInputSymbolsFlipped,
            spacing: 3,
            runSpacing: 3,
            buttonSize: const Size(45, 30),
            onSelect: (c, flipped) {
              if (!flipped) gameBloc.add(UserInputEvent(c));
            },
          ),
        if (state.isGameOver)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                style: TextStyle(
                  fontSize: fontSize,
                  color: colorScheme.textInputPanel,
                ),
                children: [
                  const TextSpan(text: 'Find more about\n',),
                  TextSpan(
                    text: state.puzzle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' \u{2193}',),
                ],
              ),
            )
          ),
        if (state.isGameOver)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.backgroundInputButton,
              side: BorderSide(width: 2, color: colorScheme.textInputPanel),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              alignment: Alignment.bottomCenter,
            ),
            onPressed: () async {
              final url = Uri.encodeFull("https://www.google.com/search?q=${state.hint} ${state.puzzle}");
              await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
            },
            child: Text(
              'Google',
              style: TextStyle(
                fontSize: fontSize,
                color: colorScheme.textInputButton,
              ),
            ),
          ),
      ],
    );
  }
}
