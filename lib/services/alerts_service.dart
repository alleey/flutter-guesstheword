import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../blocs/settings_bloc.dart';
import '../common/constants.dart';
import '../widgets/color_scheme_picker.dart';
import 'data_service.dart';
import 'score_service.dart';

class AlertsService {

  Alert yesNoDialog(BuildContext context, {
    String? title,
    String? desc,
    AlertType? type = AlertType.warning,
    String yesLabel = "Yes",
    String noLabel = "No",
    VoidCallback? callback
  }) {
    return Alert(
      context: context,
      title: title,
      desc: desc,
      style: const AlertStyle(
        descStyle: TextStyle(fontSize: 14,),
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            callback?.call();
            Navigator.pop(context);
          },
          color: Colors.red,
          child: Text(
            yesLabel,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        DialogButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(
              noLabel,
              style: const TextStyle(color: Colors.white),
            ),
        )
      ],
    );
  }

  Alert okDialog(BuildContext context, {
    String? title,
    String? desc,
    Widget content = const SizedBox(),
    String okLabel = "Continue",
    VoidCallback? callback
  }) {
    return Alert(
      context: context,
      title: title,
      desc: desc,
      content: content,
      style: const AlertStyle(
        descStyle: TextStyle(fontSize: 14,),
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            callback?.call();
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: const Color.fromRGBO(0, 179, 134, 1.0),
          child: Text(
            okLabel,
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  Alert helpDialog(BuildContext context) {
    return Alert(
      context: context,
      title: "Guess The Word",
      padding: const EdgeInsets.all(10),
      content: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(globalDataService.version)
            ),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '\u{273D}  ',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  TextSpan(
                    text: "Score is calculated as the number of yellow hearts multiplied by the length of the puzzle.\n",
                  ),
                  TextSpan(
                    text: '\u{2726}  ',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  TextSpan(
                    text: "A hint token is awared for every ${Constants.scoreBumpForHintBonus} points earned. ",
                  ),
                  TextSpan(
                    text: "Hint tokens are carried forward even if you reset the game.",
                    style: TextStyle(
                      color: Colors.red,
                    )
                  ),
                ],
              ),
            ),
          ]
        ),
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: const Color.fromRGBO(0, 179, 134, 1.0),
          child: const Text(
            "Close",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Alert highScoresDialog(BuildContext context) {

    final scoreService = ScoreService(dataService: globalDataService);
    final scores = scoreService.highScores();

    return Alert(
      context: context,
      title: "HIGH SCORES",
      content: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 14),
        child: Column(
          children:
            scores.map( (e) {
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
            ).toList(),
        ),
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: const Color.fromRGBO(0, 179, 134, 1.0),
          child: const Text(
            "Close",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Alert themePicker(BuildContext context, {
    required String selectedTheme,
    required ColorSchemeSelectionCallback callback
  }) {

    return Alert(
      context: context,
      title: "Pick a Theme",
      content: ColorSchemePicker(selectedTheme: selectedTheme, onSelect: callback,),
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: const Color.fromRGBO(0, 179, 134, 1.0),
          child: const Text(
            "Close",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
