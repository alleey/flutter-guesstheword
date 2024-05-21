import 'package:flutter/material.dart';

import '../common/constants.dart';
import '../common/game_color_scheme.dart';
import '../widgets/color_scheme_picker.dart';
import '../widgets/dialogs/ok_dialog.dart';
import '../widgets/dialogs/yesno_dialog.dart';
import 'data_service.dart';
import 'score_service.dart';

class AlertsService {

  Future<dynamic> yesNoDialog(BuildContext context, {
    String? title,
    Widget content = const SizedBox(),
    required GameColorScheme colorScheme,
    String yesLabel = "Yes",
    String noLabel = "No",
    VoidCallback? onAccept,
    VoidCallback? onReject,
  }) => showGeneralDialog(
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
          content: content,
          onAccept: onAccept ?? () {},
          onReject: onReject,
        );
      }
    );

  Future<dynamic> okDialog(BuildContext context, {
    String? title,
    Widget content = const SizedBox(),
    required GameColorScheme colorScheme,
    String okLabel = "Continue",
    VoidCallback? callback
  }) => showGeneralDialog(
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
          content: content,
          onClose: () {}
        );
      },
    );

  Future<dynamic> resetGameDialog(BuildContext context, GameColorScheme colorScheme, {required VoidCallback onAccept}) => yesNoDialog(
      context,
      colorScheme:  colorScheme,
      title: "RESET GAME",
      content: Text.rich(
        textAlign: TextAlign.justify,
        TextSpan(
          children: [
            TextSpan(
              text: "Resetting the game will reset all puzzles already finished. High scores will be preserved\n\n",
              style: TextStyle(
                color: colorScheme.textPuzzlePanel,
              )
            ),
            TextSpan(
              text: "Continue?",
              style: TextStyle(
                color: colorScheme.textPuzzlePanel,
                fontWeight: FontWeight.bold,
              )
            ),
          ],
        ),
      ),
      onAccept:onAccept
    );

  Future<dynamic> helpDialog(BuildContext context, GameColorScheme colorScheme) => okDialog(
      context,
      colorScheme: colorScheme,
      title: "Guess The Word",
      okLabel: "Close",
      content:
        Column(children: [
        Text.rich(
          textAlign: TextAlign.center,
          TextSpan(
            children: [
              TextSpan(
                text: globalDataService.version,
                style: TextStyle(
                  color: colorScheme.backgroundTopPanel,
                )
              ),
            ],
          ),
        ),
        Text.rich(
          textAlign: TextAlign.justify,
          TextSpan(
            style: TextStyle(
              color: colorScheme.textPuzzlePanel,
            ),
            children: [
              TextSpan(
                text: '\u{273D}  ',
                style: TextStyle(
                  color: colorScheme.backgroundPuzzleSymbolsFlipped,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: "Score is calculated as the number of yellow hearts multiplied by the length of the puzzle.\n",
              ),
              TextSpan(
                text: '\u{2726}  ',
                style: TextStyle(
                  color: colorScheme.backgroundPuzzleSymbolsFlipped,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                )
              ),
              const TextSpan(
                text: "A hint token is awared for every ${Constants.scoreBumpForHintBonus} points earned. ",
              ),
              TextSpan(
                text: "Hint tokens are carried forward even if you reset the game.",
                style: TextStyle(
                  color: colorScheme.backgroundTopPanel,
                  fontWeight: FontWeight.bold,
                )
              ),
            ],
          ),
        ),
      ]),
    );

  Future<dynamic> highScoresDialog(BuildContext context, GameColorScheme colorScheme) {

    final scoreService = ScoreService(dataService: globalDataService);
    final scores = scoreService.highScores();

    return okDialog(
      context,
      colorScheme: colorScheme,
      title: "HIGH SCORES",
      okLabel: "Close",
      content:
        scores.isEmpty ?
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              children: [
                TextSpan(
                  text: "Nothing scored yet!",
                  style: TextStyle(
                    color: colorScheme.textPuzzlePanel,
                  )
                ),
              ],
            ),
          ) : DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 14),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: colorScheme.textPuzzlePanel,
            ),
            child: Column(
              children:[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Played"),
                    Text("Won"),
                    Text("Lost"),
                  ],
                ),
                ...scores.map( (e) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${e.value}"),
                          Text("${e.wins}"),
                          Text("${e.losses}"),
                        ],
                      ),
                    );
                  }
                ),
            ]),
          ),
        ),
    );
  }

  Future<dynamic> themePicker(BuildContext context, {
    required String selectedTheme,
    required ColorSchemeSelectionCallback onSelect
  }) {
    final colorScheme = GameColorSchemes.scheme(selectedTheme);
    return okDialog(
      context,
      colorScheme: colorScheme,
      title: "Pick a Theme",
      okLabel: "Close",
      content: ColorSchemePicker(selectedTheme: selectedTheme, onSelect: onSelect,),
    );
  }
}
