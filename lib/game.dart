import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'blocs/game_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'common/constants.dart';
import 'common/custom_traversal_policy.dart';
import 'common/game_color_scheme.dart';
import 'common/layout_constants.dart';
import 'common/utils.dart';
import 'services/alerts_service.dart';
import 'services/app_data_service.dart';
import 'services/audio_service.dart';
import 'services/data_service.dart';
import 'widgets/common/alternating_color_squares.dart';
import 'widgets/common/blink_effect.dart';
import 'widgets/common/bump_effect.dart';
import 'widgets/common/flip_card.dart';
import 'widgets/common/party_popper_effect.dart';
import 'widgets/common/responsive_layout.dart';
import 'widgets/loading_indicator.dart';
import 'widgets/symbol_pad.dart';


class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {

  final appDataService = AppDataService(dataService: globalDataService);
  final audioService = AudioService();

  late GameColorScheme colorScheme;
  GameState? gameState;
  VoidCallback? dismissActivePopup;

  @override
  void initState() {
    super.initState();
    colorScheme = GameColorSchemes.fromName(
      appDataService.getSetting(KnownSettingsNames.settingTheme) ?? GameColorSchemes.defaultSchemeName
    );
    context.gameBloc.add(StartPuzzleEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [

        BlocListener<SettingsBloc, SettingsBlocState>(
          listener: (BuildContext context, state) {

            log("PuzzlePage> listener SettingsBlocState: $state");
            switch(state) {
              case final SettingsReadBlocState s:
              if (s.name == KnownSettingsNames.settingTheme) {
                setState(() {
                  colorScheme = GameColorSchemes.fromName(s.value);
                });
              }
              break;
            }
          }
        ),

        BlocListener<GameBloc, GameBlocState>(
          listener: (context, state) async {

            log("PuzzlePage> listener GameBloc: $state");
            switch (state) {

              case ResetPendingState s:
                dismissActivePopup = AlertsService().popup(context, colorScheme, message: s.message);
                break;

              case ResetCompleteState _:
                dismissActivePopup?.call();
                context.gameBloc.add(StartPuzzleEvent());
                break;

              case PuzzleStartState _:
                audioService.play("audio/start.mp3");
                if (Constants.enableInitialReveal) {
                  context.gameBloc.add(RequestHintEvent());
                }
                break;

              case PuzzleCompleteState s:
                if (s.isWin) {
                  audioService.play("audio/win.mp3");
                } else {
                  audioService.play("audio/lost.mp3");
                }
                break;

              case InputMatchState s:
                audioService.play("audio/match.mp3");
                break;

              case InputMismatchState _:
                audioService.play("audio/fail.mp3");
                break;

              case NoMorePuzzleState _:
                AlertsService().gameNeedsResetDialog(context,
                  colorScheme,
                  callback: () => context.gameBloc.add(ResetGameEvent())
                );
                break;
              case GameState state:
                setState(() {
                  gameState = state;
                });
                break;

            }
          }
        )
      ],
      child: Builder(
        builder: (context) {

          if (gameState == null) {
            return LoadingIndicator(colorScheme: colorScheme, message: "almost there ...");
          }

          return _buildLayout(context, gameState!);
        }
      )
    );
  }

  Widget _buildLayout(BuildContext context, GameState state) {
    var squareSize = 6.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: colorScheme.backgroundPuzzlePanel,
                      child: _buildPuzzlePanel(context, state)
                    ),
                  ),
                  Positioned(
                    //top: -5,
                    child: AlternatingColorSquares(
                      color1: colorScheme.backgroundTopPanel,
                      color2: colorScheme.backgroundPuzzlePanel,
                      squareSize: squareSize,
                    )
                  )
                ]
              ),
            ),
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: colorScheme.backgroundInputPanel,
                      child: _buildInputPanel(context, state)
                    ),
                  ),
                  Positioned(
                    //top: -5,
                    child: AlternatingColorSquares(
                      color1: colorScheme.backgroundInputPanel,
                      color2: colorScheme.backgroundPuzzlePanel,
                      squareSize: squareSize,
                    )
                  )
                ]
              ),
            ),
          ],
        ),
        if (state.isGameOver && state.isWin)
          const Positioned(
            child: PartyPopperEffect()
          ),
      ],
    );
  }

  Widget _buildTopPanel(BuildContext context, GameState state) {

    final layout = context.layout;
    final hintWidthPct = layout.get<double>(AppLayoutConstants.hintWidthPctKey);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildScorePanel(context, state),
            const SizedBox(height: 5),
            FlipCard(
              showFront: !state.isGameOver,
              frontCard: _buildStatusPanel(context, state),
              backCard: _buildGameOverPanel(context, state),
            ),
          ],
        ),

        if ( !state.isGameOver && state.isHelpAvailable)
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * hintWidthPct,
                child: _buildHintsOption(context, state)
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScorePanel(BuildContext context, GameState state) {

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);

    return Semantics(
      excludeSemantics: true,
      label: "Score is ${state.score.value}, ${state.score.wins} wins and ${state.score.losses} losses. You have ${state.score.hintTokens} available hints.",
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          textAlign: TextAlign.center,
          TextSpan(
            style: TextStyle(
              fontSize: titleFontSize,
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
                text: "${state.score.value}-${state.score.wins}-${state.score.losses}",
              ),
              const TextSpan(
                text: "      ",
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
      ),
    );
  }

  Widget _buildStatusPanel(BuildContext context, GameState state) {
    return Semantics(
      label: "${Constants.maxErrors - state.errorCount} attempts left",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
        [
          ...Iterable<int>.generate(Constants.maxErrors).map((e)
            => FlipCard(
                showFront: (e > (state.errorCount - 1)),
                frontCard: Icon(Icons.diamond, size: 32, color: colorScheme.colorHeart),
                backCard: BumpEffect(
                  autostart: (e == (state.errorCount - 1) && state.lastInputError),
                  particleColor: colorScheme.colorHeart,
                  builder: (context, fire) => SizedBox(
                    width: 32, height: 32,
                    child: Icon(Icons.diamond_outlined, size: 24, color: colorScheme.colorHeartBroken.withOpacity(0.75))
                  ),
                ),
                transitionBuilder: AnimatedSwitcher.defaultTransitionBuilder,
              )),

        ],
      ),
    );
  }

  Widget _buildGameOverPanel(BuildContext context, GameState state) {

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Semantics(
          label: state.isWin ? "You won! ${state.winBonus} points earned" : 'Sorry, you lost!',
          excludeSemantics: true,

          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: state.isWin ? colorScheme.colorSuccess : colorScheme.colorFailure,
              ),
              children: [
                TextSpan(
                  text: state.isWin ? "\u{2713} +${state.winBonus}" : '\u{2169}',
                )
              ]
            )
          ),
          //   child: Text.rich(
          //   textAlign: TextAlign.center,
          //   TextSpan(
          //     style: TextStyle(
          //       fontSize: titleFontSize,
          //       color: colorScheme.textTopPanel,
          //     ),
          //     children: [
          //       TextSpan(
          //         text: '\u{273D}',
          //         style: TextStyle(
          //           color: colorScheme.colorIcons,
          //           fontWeight: FontWeight.bold,
          //         )
          //       ),
          //       TextSpan(
          //         text: " +${state.winBonus}",
          //       ),
          //       if (state.hintBonus > 0)
          //         TextSpan(
          //           text: ' \u{2726}',
          //           style: TextStyle(
          //             color: colorScheme.colorIcons,
          //             fontWeight: FontWeight.bold,
          //           )
          //         ),
          //       if (state.hintBonus > 0)
          //         TextSpan(
          //           text: " +${state.hintBonus}",
          //         ),
          //     ],
          //   ),
          // )

        ),
        const SizedBox(width: 20,),
        FocusTraversalOrder(
          order: const GroupFocusOrder(GroupFocusOrder.groupButtons, 1),
          child: Semantics(
            button: true,
            label: "Try the next puzzle",
            excludeSemantics: true,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.backgroundTopButton,
                side: BorderSide(width: 2, color: colorScheme.textTopPanel),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              ).copyWith(
                overlayColor: StateDependentColor(colorScheme.textTopButton),
              ),
              onPressed: () {
                context.gameBloc.add(StartPuzzleEvent());
              },
              child: Text(
                "Go Next",
                style: TextStyle(
                  color: colorScheme.textTopButton,
                  fontSize: titleFontSize,
                )
              )
            ),
          ),
        )
      ],
    );
  }

  Widget _buildHintsOption(BuildContext context, GameState state) {

    final layout = context.layout;
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

    return BlinkEffect (
      child: FocusTraversalOrder(
        order: const GroupFocusOrder(GroupFocusOrder.groupButtons, 2),
        child: Semantics(
          label: "Use a hint",
          button: true,
          excludeSemantics: true,
          child: ElevatedButton (
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.backgroundHintButton,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
            ).copyWith(
              overlayColor: StateDependentColor(colorScheme.textHintButton),
            ),
            onPressed: () {
              context.gameBloc.add(UseHintTokenEvent());
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                "Use a Hint",
                style: TextStyle(
                  color: colorScheme.textHintButton,
                  fontSize: bodyFontSize
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget _buildPuzzlePanel(BuildContext context, GameState state) {

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
    final buttonSize = layout.get<Size>(AppLayoutConstants.symbolButtonSizeKey);

    return Focus(
      canRequestFocus: false,
      descendantsAreFocusable: false,
      descendantsAreTraversable: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            label: "${state.puzzle.length} lettered ${state.hint}",
            excludeSemantics: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                state.hint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.textPuzzlePanel,
                  ),
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
              buttonSize: buttonSize,
              onSelect: (c, f) {},
              symbolDecorator: (widget, index, isFront, frontLabel, backLabel) {
                final keyWidget = Semantics(
                    label: !isFront ? "${numberToOrdinal(index)} letter. ${backLabel.toLowerCase()}" :
                    "${numberToOrdinal(index)} letter. Hidden",
                    excludeSemantics: true,
                    child: widget
                );
                return isFront ? widget : Focus(
                    canRequestFocus: false,
                    descendantsAreFocusable: false,
                    child: keyWidget,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInputPanel(BuildContext context, GameState state) {

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
    final buttonSize = layout.get<Size>(AppLayoutConstants.symbolButtonSizeKey);
    final inputPanelWidthPct = layout.get<double>(AppLayoutConstants.inputPanelWidthPctKey);

    final tried = state.symbolSet
        .split('')
        .map((e) => state.puzzle.toLowerCase().contains(e) ? '\u{2713}' : '\u{2169}')
        .join();

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!state.isGameOver)
            Semantics(
              label: "Pick your letters wisely",
              excludeSemantics: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Pick your letters wisely \u{2193}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.textInputPanel,
                    ),
                  ),
              ),
            ),

          // Input keyboard
          if (!state.isGameOver)
            SizedBox(
              width: MediaQuery.of(context).size.width * inputPanelWidthPct,
              child: SymbolPad(
                autofocus: true,
                frontSymbols: state.symbolSet.toUpperCase(),
                backSymbols: tried,
                flipped: state.used,
                foregroundColor: colorScheme.textInputSymbols,
                backgroundColor: colorScheme.backgroundInputSymbols,
                foregroundColorFlipped: colorScheme.textInputSymbolsFlipped,
                backgroundColorFlipped: colorScheme.backgroundInputSymbolsFlipped,
                spacing: 3,
                runSpacing: 3,
                buttonSize: buttonSize,
                onSelect: (c, flipped) {
                  if (!flipped) context.gameBloc.add(UserInputEvent(c));
                },
                symbolDecorator: (widget, index, isFront, frontLabel, backLabel) {

                  final ticked = backLabel == "\u{2713}";
                  final keyWidget = Semantics(
                    focusable: false,
                    keyboardKey: true,
                    label: isFront ? "Key ${frontLabel.toLowerCase()}" :
                                    (ticked ? "Key ${frontLabel.toLowerCase()} is ticked" : "Key ${frontLabel.toLowerCase()} is crossed"),
                    excludeSemantics: true,
                    child: FocusTraversalOrder(
                      order: GroupFocusOrder(GroupFocusOrder.groupKeys, index),
                      child: widget
                    ),
                  );

                  return isFront ? keyWidget:
                    Focus(
                      canRequestFocus: false,
                      descendantsAreFocusable: false,
                      child: keyWidget,
                    );
                },
              ),
            ),

          // "Find more about" label
          if (state.isGameOver)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  style: TextStyle(
                    fontSize: bodyFontSize,
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
                    const TextSpan(text: ' \u{2193}\n',),
                  ],
                ),
              )
            ),

          // Google button
          if (state.isGameOver)
            FocusTraversalOrder(
              order: const GroupFocusOrder(GroupFocusOrder.groupButtons, 2),
              child: ElevatedButton(
                autofocus: true,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.backgroundInputButton,
                  side: BorderSide(width: 2, color: colorScheme.textInputPanel),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                ).copyWith(
                  overlayColor: StateDependentColor(colorScheme.textInputPanel),
                ),
                onPressed: () async {
                  final url = Uri.encodeFull("https://www.google.com/search?q=${state.hint} ${state.puzzle}");
                  await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
                },
                child: Text(
                  'Google',
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    color: colorScheme.textInputButton,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
