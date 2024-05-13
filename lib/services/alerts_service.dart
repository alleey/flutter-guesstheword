import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../main.dart';
import 'score_service.dart';

class AlertsService {

  Alert askYesNo(BuildContext context, {
    String? title,
    String? desc,
    AlertType? type = AlertType.warning,
    String yesLabel = "Yes",
    String noLabel = "No",
    VoidCallback? callback
  }) {
    return Alert(
      context: context,
      type: type,
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

  Alert show(BuildContext context, {
    String? title,
    String? desc,
    String okLabel = "Continue",
    VoidCallback? callback
  }) {
    return Alert(
      context: context,
      type: AlertType.info,
      title: title,
      desc: desc,
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

  Alert alertHighScores(BuildContext context) {

    final scoreService = ScoreService(dataService: globalDataService);
    final scores = scoreService.highScores();

    return Alert(
      context: context,
      type: AlertType.info,
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
}
