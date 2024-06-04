import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../common/constants.dart';
import '../common/game_color_scheme.dart';
import '../common/layout_constants.dart';
import '../widgets/color_scheme_picker.dart';
import '../widgets/dialogs/common.dart';
import '../widgets/dialogs/ok_dialog.dart';
import '../widgets/dialogs/popup_dialog.dart';
import '../widgets/dialogs/yesno_dialog.dart';
import '../widgets/common/responsive_layout.dart';
import 'data_service.dart';
import 'score_service.dart';

class AlertsService {

  Future<bool?> yesNoDialog(BuildContext context, {
    String? title,
    required ContentBuilder builder,
    required GameColorScheme colorScheme,
    String yesLabel = "Yes",
    String noLabel = "No",
    VoidCallback? onAccept,
    VoidCallback? onReject,
  }) {
    final screenCoverPct = ResponsiveLayoutProvider.layout(context).get<Size>(DialogLayoutConstants.screenCoverPctKey);
    return showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return YesNoDialog(
          colorScheme: colorScheme,
          title: title ?? "",
          yesLabel: yesLabel,
          noLabel: noLabel,
          builder: builder,
          width: MediaQuery.of(context).size.width * screenCoverPct.width,
          height: MediaQuery.of(context).size.height * screenCoverPct.height,
          onAccept: onAccept ?? () {},
          onReject: onReject,
        );
      }
    );
  }

  Future<dynamic> okDialog(BuildContext context, {
    String? title,
    required ContentBuilder builder,
    required GameColorScheme colorScheme,
    String okLabel = "Continue",
    VoidCallback? callback
  }) {
    final screenCoverPct = ResponsiveLayoutProvider.layout(context).get<Size>(DialogLayoutConstants.screenCoverPctKey);
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return OkDialog(
          colorScheme: colorScheme,
          title: title ?? "",
          okLabel: okLabel,
          builder: builder,
          width: MediaQuery.of(context).size.width * screenCoverPct.width,
          height: MediaQuery.of(context).size.height * screenCoverPct.height,
          onClose: callback,
        );
      },
    );
  }

  VoidCallback popupDialog(BuildContext context, GameColorScheme colorScheme, {
    String? title,
    required ContentBuilder builder,
  }) {
    final screenCoverPct = ResponsiveLayoutProvider.layout(context).get<Size>(DialogLayoutConstants.screenCoverPctKey);
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return PopupDialog(
          colorScheme: colorScheme,
          title: title ?? "",
          builder: builder,
          width: MediaQuery.of(context).size.width * screenCoverPct.width,
          height: MediaQuery.of(context).size.height * screenCoverPct.height,
        );
      },
    );
    return () => Navigator.of(context, rootNavigator: true).pop();
  }

  // Returns a function that can be used to dismiss the popup.
  //
  VoidCallback popup(BuildContext context, GameColorScheme colorScheme, {
    String title = "Processing ...",
    required String message,
  }) {
    return popupDialog(
      context,
      colorScheme,
      title: title,
      builder: (layout, scheme) {

        final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

        return Semantics(
          container: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: message,
                      style: TextStyle(
                        color: colorScheme.textPuzzlePanel,
                        fontSize: bodyFontSize,
                      )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              LinearProgressIndicator(
                color: colorScheme.textPuzzlePanel,
                backgroundColor: colorScheme.backgroundInputPanel,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> resetGameDialog(BuildContext context, GameColorScheme colorScheme, {required VoidCallback onAccept}) {
    return yesNoDialog(
      context,
      colorScheme:  colorScheme,
      title: "RESET GAME",
      builder: (layout, scheme) {

        final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
        final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

        return Semantics(
          container: true,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text.rich(
              textAlign: TextAlign.justify,
              TextSpan(
                children: [
                  TextSpan(
                    text: "Resetting the game will reset all puzzles already finished. High scores will be preserved\n\n",
                    style: TextStyle(
                      color: colorScheme.textPuzzlePanel,
                      fontSize: bodyFontSize,
                    )
                  ),
                  TextSpan(
                    text: "Would you like to reset the game?",
                    style: TextStyle(
                      color: colorScheme.textPuzzlePanel,
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                    )
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onAccept:onAccept
    );
  }

  Future<dynamic> helpDialog(BuildContext context, GameColorScheme colorScheme) => okDialog(
      context,
      colorScheme: colorScheme,
      title: "Guess The Word",
      okLabel: "Close",
      builder: (layout, scheme) {

        final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
        final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

        return SingleChildScrollView(
          child: Column(
            children: [

              Align(
                alignment: Alignment.center,
                child: Semantics(
                  label: "Game version is ${globalDataService.version}",
                  container: true,
                  excludeSemantics: true,
                  child: Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: globalDataService.version,
                          style: TextStyle(
                            color: scheme.backgroundTopPanel,
                            fontSize: bodyFontSize,
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Semantics(
                container: true,
                child: Text.rich(
                  textAlign: TextAlign.justify,
                  TextSpan(
                    style: TextStyle(
                      color: scheme.textPuzzlePanel,
                      fontSize: bodyFontSize,
                    ),
                    children: const [
                      TextSpan(
                        text: "Start by finding the most likely letters. When available a hint token can reveral a random letter.",
                      ),
                    ],
                  ),
                ),
              ),

              Semantics(
                container: true,
                child: Text.rich(
                  textAlign: TextAlign.justify,
                  TextSpan(
                    style: TextStyle(
                      color: scheme.textPuzzlePanel,
                      fontSize: bodyFontSize,
                    ),
                    children: [
                      TextSpan(
                        semanticsLabel: "Point 1.",
                        text: '\u{273D}  ',
                        style: TextStyle(
                          color: scheme.backgroundPuzzleSymbolsFlipped,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: "Score is calculated as the number of lives multiplied by the length of the puzzle.",
                      ),
                    ],
                  ),
                ),
              ),

              Semantics(
                container: true,
                child: Text.rich(
                  textAlign: TextAlign.justify,
                  TextSpan(
                    style: TextStyle(
                      color: scheme.textPuzzlePanel,
                      fontSize: bodyFontSize,
                    ),
                    children: [
                      TextSpan(
                        text: '\u{2726}  ',
                        semanticsLabel: "Point 2.",
                        style: TextStyle(
                          color: scheme.backgroundPuzzleSymbolsFlipped,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      const TextSpan(
                        text: "A hint token is awarded for every ${Constants.scoreBumpForHintBonus} points earned. ",
                      ),
                      TextSpan(
                        text: "Hint tokens are carried forward even if you reset the game.",
                        style: TextStyle(
                          color: scheme.backgroundTopPanel,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                    ],
                  ),
                ),
              ),
          ]),
        );
      },
    );

  Future<dynamic> highScoresDialog(BuildContext context, GameColorScheme colorScheme) {

    final scoreService = ScoreService(dataService: globalDataService);
    final scores = scoreService.highScores();

    return okDialog(
      context,
      colorScheme: colorScheme,
      title: "HIGH SCORES",
      okLabel: "Close",
      builder: (layout, scheme) {

        final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
        final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

        return scores.isEmpty ?
          Center(
            child: Semantics(
              container: true,
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: "No score has been recorded yet. Win some puzzles to record a score!",
                      style: TextStyle(
                        color: scheme.textPuzzlePanel,
                        fontSize: titleFontSize,
                      )
                    ),
                  ],
                ),
              ),
            ),
          ) :
          DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: bodyFontSize,
              color: scheme.textPuzzlePanel,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children:[
                  Semantics(
                    label: "Below is the list of top scores, games won and lost",
                    excludeSemantics: true,
                    container: true,
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Score',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Won',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Lost',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...scores.mapIndexed((i, e) {
                      return Semantics(
                        label: "Item ${i+1}. Score is ${e.value}, ${e.wins} wins and ${e.losses} losses.",
                        container: true,
                        excludeSemantics: true,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${e.value}",
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${e.wins}",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${e.losses}",
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ]
                        ),
                      );
                    }
                  ),
              ]),
            ),
          );
      },
    );
  }

  Future<dynamic> colorSchemePicker(BuildContext context, {
    required String selectedTheme,
    required ColorSchemeSelectionCallback onSelect
  }) {
    final colorScheme = GameColorSchemes.fromName(selectedTheme);
    return okDialog(
      context,
      colorScheme: colorScheme,
      title: "Pick a Theme",
      okLabel: "Close",
      builder: (layout, scheme) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ColorSchemePicker(selectedTheme: selectedTheme, onSelect: onSelect,),
      )
    );
  }

  Future<dynamic> gameNeedsResetDialog(BuildContext context, GameColorScheme colorScheme, {
    required VoidCallback callback
  }) {
    return okDialog(
      context,
      title: "Congratulations!",
      colorScheme: colorScheme,
      builder: (layout, scheme) => const Text("You've finished all the puzzles. To keep playing the game must reset"),
      callback: callback,
    );
  }
}
