import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../main.dart';
import 'score_service.dart';

class AlertsService {

  Alert askYesNo(BuildContext context, {
    String? title,
    String? desc,
    VoidCallback? callback
  }) {
    return Alert(
      context: context,
      type: AlertType.warning,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          onPressed: () {
            callback?.call();
            Navigator.pop(context);
          },
          color: const Color.fromRGBO(0, 179, 134, 1.0),
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text(
              "No",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
        )
      ],
    );
  }


  Alert show(BuildContext context, {
    String? title,
    String? desc,
    VoidCallback? callback
  }) {
    return Alert(
      context: context,
      type: AlertType.info,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          onPressed: () {
            callback?.call();
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: const Color.fromRGBO(0, 179, 134, 1.0),
          child: const Text(
            "Continue",
            style: TextStyle(color: Colors.white, fontSize: 20),
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
      content: Column(
        children: scores.map(
                (e) {
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
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: const Color.fromRGBO(0, 179, 134, 1.0),
          child: const Text(
            "Close",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    );
  }
}
