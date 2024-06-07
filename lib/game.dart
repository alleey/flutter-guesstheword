import 'dart:developer';

import 'package:bit_array/bit_array.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'blocs/game_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'common/app_color_scheme.dart';
import 'common/constants.dart';
import 'common/custom_traversal_policy.dart';
import 'common/layout_constants.dart';
import 'common/utils.dart';
import 'localizations/app_localizations.dart';
import 'services/alerts_service.dart';
import 'services/app_data_service.dart';
import 'services/audio_service.dart';
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

  final _appDataService = AppDataService();
  final _audioService = AudioService();
  final _errorEffectsDone = BitArray(Constants.maxErrors);

  late AppColorScheme _colorScheme;
  GameState? _gameState;
  VoidCallback? _dismissActivePopup;

  @override
  void initState() {
    super.initState();
    _colorScheme = AppColorSchemes.fromName(
      _appDataService.getSetting(KnownSettingsNames.settingTheme, AppColorSchemes.defaultSchemeName)
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
                  _colorScheme = AppColorSchemes.fromName(s.value);
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
                _dismissActivePopup = AlertsService().popup(context,
                  _colorScheme,
                  title: context.localizations.translate("dlg_popup_title"),
                  message: context.localizations.translate(s.messageKey)
                );
                break;

              case ResetCompleteState _:
                _dismissActivePopup?.call();
                context.gameBloc.add(StartPuzzleEvent());
                break;

              case PuzzleStartState _:
                _audioService.play("audio/start.mp3");
                _errorEffectsDone.clearAll();
                if (Constants.enableInitialReveal) {
                  context.gameBloc.add(RequestHintEvent());
                }
                break;

              case PuzzleCompleteState s:
                if (s.isWin) {
                  _audioService.play("audio/win.mp3");
                } else {
                  _audioService.play("audio/lost.mp3");
                }
                break;

              case InputMatchState s:
                _audioService.play("audio/match.mp3");
                break;

              case InputMismatchState _:
                _audioService.play("audio/fail.mp3");
                break;

              case NoMorePuzzleState _:
                AlertsService().gameNeedsResetDialog(context,
                  _colorScheme,
                  callback: () => context.gameBloc.add(ResetGameEvent())
                );
                break;
              case GameState state:
                setState(() {
                  _gameState = state;
                });
                break;

            }
          }
        )
      ],
      child: Builder(
        builder: (context) {

          if (_gameState == null) {
            return LoadingIndicator(
              colorScheme: _colorScheme,
              message: context.localizations.translate("game_loading")
            );
          }

          return _buildLayout(context, _gameState!);
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
                color: _colorScheme.backgroundTopPanel,
                child: _buildTopPanel(context, state)
              ),
            ),
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: _colorScheme.backgroundPuzzlePanel,
                      child: _buildPuzzlePanel(context, state)
                    ),
                  ),
                  Positioned(
                    //top: -5,
                    child: AlternatingColorSquares(
                      color1: _colorScheme.backgroundTopPanel,
                      color2: _colorScheme.backgroundPuzzlePanel,
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
                      color: _colorScheme.backgroundInputPanel,
                      child: _buildInputPanel(context, state)
                    ),
                  ),
                  Positioned(
                    //top: -5,
                    child: AlternatingColorSquares(
                      color1: _colorScheme.backgroundInputPanel,
                      color2: _colorScheme.backgroundPuzzlePanel,
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
    final stats = state.playerStats;

    return InkWell(
      onLongPress: () {
        AlertsService().statsDialog(context, _colorScheme, state.playerStats);
      },
      onDoubleTap: () {
        AlertsService().statsDialog(context, _colorScheme, state.playerStats);
      },
      child: Semantics(
        excludeSemantics: true,
        label: "Score is ${stats.score}, ${stats.total.wins} wins and ${stats.total.losses} losses. You have ${stats.hintTokens} available hints.",
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              style: TextStyle(
                fontSize: titleFontSize,
                color: _colorScheme.textTopPanel,
              ),
              children: [
                TextSpan(
                  text: '\u{273D}',
                  style: TextStyle(
                    color: _colorScheme.colorIcons,
                    fontWeight: FontWeight.bold,
                  )
                ),
                TextSpan(
                  text: "${stats.score}-${stats.total.wins}-${stats.total.losses}",
                ),
                const TextSpan(
                  text: "      ",
                ),
                TextSpan(
                  text: '\u{2726}',
                  style: TextStyle(
                    color: _colorScheme.colorIcons,
                    fontWeight: FontWeight.bold,
                  )
                ),
                TextSpan(
                  text: "${stats.hintTokens}",
                ),
              ],
            ),
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
                frontCard: Icon(Icons.diamond, size: 32, color: _colorScheme.colorHeart),
                backCard: BumpEffect(
                  autostart: (e == (state.errorCount - 1) && !_errorEffectsDone[e]),
                  particleColor: _colorScheme.colorHeart,
                  builder: (context, fire) => SizedBox(
                    width: 32, height: 32,
                    child: Icon(Icons.diamond_outlined, size: 24, color: _colorScheme.colorHeartBroken.withOpacity(0.75))
                  ),
                  onComplete: () => _errorEffectsDone.setBit(e), // use bitset to make sure effect is played once
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
                color: state.isWin ? _colorScheme.colorSuccess : _colorScheme.colorFailure,
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
                backgroundColor: _colorScheme.backgroundTopButton,
                side: BorderSide(width: 2, color: _colorScheme.textTopPanel),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              ).copyWith(
                overlayColor: StateDependentColor(_colorScheme.textTopButton),
              ),
              onPressed: () {
                context.gameBloc.add(StartPuzzleEvent());
              },
              child: Text(
                context.localizations.translate("game_top_gonext"),
                style: TextStyle(
                  color: _colorScheme.textTopButton,
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
              backgroundColor: _colorScheme.backgroundHintButton,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
            ).copyWith(
              overlayColor: StateDependentColor(_colorScheme.textHintButton),
            ),
            onPressed: () {
              context.gameBloc.add(UseHintTokenEvent());
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                context.localizations.translate("game_puzzle_usehint"),
                style: TextStyle(
                  color: _colorScheme.textHintButton,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
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
                    color: _colorScheme.textPuzzlePanel,
                    ),
                  ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SymbolPad(
                  frontSymbols: '?' * state.puzzle.length,
                  backSymbols: state.puzzle.toUpperCase(),
                  flipped: state.revealed,
                  whiteSpace: state.whiteSpace,
                  foregroundColor: _colorScheme.textPuzzleSymbols,
                  backgroundColor: _colorScheme.backgroundPuzzleSymbols,
                  foregroundColorFlipped: _colorScheme.textPuzzleSymbolsFlipped,
                  backgroundColorFlipped: _colorScheme.backgroundPuzzleSymbolsFlipped,
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
              ),
            )
          ],
        ),
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${context.localizations.translate('game_input_title')} \u{2193}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: _colorScheme.textInputPanel,
                      ),
                    ),
                ),
              ),
            ),

          // Input keyboard
          if (!state.isGameOver)
            Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * inputPanelWidthPct,
                child: SymbolPad(
                  autofocus: true,
                  frontSymbols: state.symbolSet.toUpperCase(),
                  backSymbols: tried,
                  flipped: state.used,
                  foregroundColor: _colorScheme.textInputSymbols,
                  backgroundColor: _colorScheme.backgroundInputSymbols,
                  foregroundColorFlipped: _colorScheme.textInputSymbolsFlipped,
                  backgroundColorFlipped: _colorScheme.backgroundInputSymbolsFlipped,
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
                    color: _colorScheme.textInputPanel,
                  ),
                  children: [
                    TextSpan(
                      text: "${context.localizations.translate('game_input_findmore')}\n",
                    ),
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
                  backgroundColor: _colorScheme.backgroundInputButton,
                  side: BorderSide(width: 2, color: _colorScheme.textInputPanel),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                ).copyWith(
                  overlayColor: StateDependentColor(_colorScheme.textInputPanel),
                ),
                onPressed: () async {
                  final url = Uri.encodeFull("https://www.google.com/search?q=${state.hint} ${state.puzzle}");
                  await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
                },
                child: Text(
                  'Google',
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    color: _colorScheme.textInputButton,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
