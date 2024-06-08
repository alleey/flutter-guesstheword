import 'package:flutter/material.dart';

import '../common/app_color_scheme.dart';
import '../common/layout_constants.dart';
import '../localizations/app_localizations.dart';
import '../widgets/dialogs/app_dialog.dart';
import '../widgets/dialogs/common.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/localized_text.dart';
import '../widgets/pages/how_to_play_page.dart';
import '../widgets/pages/high_scores_list_page.dart';
import '../widgets/pages/player_stats_page.dart';
import '../widgets/pages/settings_page.dart';
import 'score_service.dart';
import '../widgets/common/responsive_layout.dart';

class AlertsService {

  Future<T?> actionDialog<T>(
    BuildContext context, {
    required ContentBuilder title,
    required ContentBuilder contents,
    required ActionBuilder actions,
  }) {
    return showGeneralDialog<T>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.8),
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 250),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return AppDialog(
            title: title,
            actions: actions,
            contents: contents,
          );
        }
      );
  }

  Future<bool?> yesNoDialog(BuildContext context, {
    required ContentBuilder title,
    required ContentBuilder contents,
    String yesLabel = "Yes",
    String noLabel = "No",
    VoidCallback? onAccept,
    VoidCallback? onReject,
  }) {
    return actionDialog(
      context,
      title: title,
      contents: contents,
      actions: (_,__) => [
        Expanded(
          child: ButtonDialogAction(
            isDefault: false,
            onAction: (close) {
              close(null);
              onAccept?.call();
            },
            builder: (_,__) {
              return Text(yesLabel, textAlign: TextAlign.center);
            }
          ),
        ),
        Expanded(
          child: ButtonDialogAction(
            isDefault: true,
            onAction: (close) {
              close(null);
              onReject?.call();
            },
            builder: (_,__) => Text(noLabel, textAlign: TextAlign.center)
          ),
        )
      ],
    );
  }

  Future<dynamic> okDialog(BuildContext context, {
    required ContentBuilder title,
    required ContentBuilder contents,
    String okLabel = "Continue",
    VoidCallback? callback
  }) {
    return actionDialog(
      context,
      title: title,
      contents: contents,
      actions: (_,__) => [
        Expanded(
          child: ButtonDialogAction(
            isDefault: true,
            onAction: (close) {
              close(null);
              callback?.call();
            },
            builder: (_,__) => Text(okLabel, textAlign: TextAlign.center)
          ),
        )
      ],
    );
  }

  VoidCallback popupDialog(BuildContext context, {
    required ContentBuilder title,
    required ContentBuilder contents,
  }) {
    actionDialog(
      context,
      title: title,
      contents: contents,
      actions: (_,__) => []
    );
    return () => Navigator.of(context, rootNavigator: true).pop();
  }

  // Returns a function that can be used to dismiss the popup.
  //
  VoidCallback popup(BuildContext context, {
    required String title,
    required String message,
  }) {
    return popupDialog(
      context,
      title: (context, settingsProvider) {

        final scheme = AppColorSchemes.fromName(settingsProvider.value.theme);
        final titleFontSize = context.layout.get<double>(AppLayoutConstants.titleFontSizeKey);

        return Text(
          title,
          style: TextStyle(
            color: scheme.backgroundPuzzleSymbolsFlipped,
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize,
          ),
        );
      },
      contents: (context, settingsProvider) {
        return Semantics(
          container: true,
          child: Center(
            child: LoadingIndicator(
              message: message,
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> resetGameDialog(BuildContext context, {required VoidCallback onAccept}) {
    return yesNoDialog(
      context,
      title: (_,__) => _localizedTextTitle("dlg_reset_title"),
      yesLabel: context.localizations.translate("dlg_reset_yes"),
      noLabel: context.localizations.translate("dlg_reset_no"),
      contents: (context, settingsProvider) {

        final layout = context.layout;
        final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
        final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
        final scheme = AppColorSchemes.fromName(settingsProvider.value.theme);

        return Semantics(
          container: true,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text.rich(
              textAlign: TextAlign.start,
              TextSpan(
                children: [
                  TextSpan(
                    text: "${context.localizations.translate('dlg_reset_intro')}\n\n",
                    style: TextStyle(
                      color: scheme.textPuzzlePanel,
                      fontSize: bodyFontSize,
                    )
                  ),
                  TextSpan(
                    text: context.localizations.translate('dlg_reset_question'),
                    style: TextStyle(
                      color: scheme.textPuzzlePanel,
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

  Future<dynamic> helpDialog(BuildContext context) {
    return actionDialog(
      context,
      title: (_, schemeNotifier) => _localizedTextTitle("dlg_help_title"),
      contents: (_,__) => const HowToPlayPage(),
      actions: (_,__) => [

        Expanded(
          child: ButtonDialogAction(
            isDefault: true,
            onAction: (close) => close(null),
            builder: (_,__) {
              return Text(
                context.localizations.translate("dlg_help_ok"),
                textAlign: TextAlign.center
              );
            }
          ),
        )
      ],
    );
  }

  Future<dynamic> highScoresDialog(BuildContext context) {

    final scoreService = ScoreService();
    return actionDialog(
      context,
      title: (_,__) => _localizedTextTitle("dlg_scores_title"),
      contents: (_,__) => HighScoresListPage(statisticsList: scoreService.highScores()),
      actions: (_,__) => [

        Expanded(
          child: ButtonDialogAction(
            isDefault: true,
            onAction: (close) => close(null),
            builder: (_,__) {
              return Text(
                context.localizations.translate("dlg_scores_ok"),
                textAlign: TextAlign.center
              );
            }
          ),
        )
      ],
    );
  }

  Future<dynamic> statsDialog(BuildContext context) {

    final scoreService = ScoreService();
    final stats = scoreService.load();

    return actionDialog(
      context,
      title: (_,__) => _localizedTextTitle("dlg_playerstats_title"),
      contents: (_,__) => PlayerStatisticsPage(statistics: stats),
      actions: (layout, schemeNotifier) => [

        Expanded(
          child: ButtonDialogAction(
            isDefault: true,
            onAction: (close) => close(null),
            builder: (_,__) {
              return Text(
                context.localizations.translate("dlg_playerstats_ok"),
                textAlign: TextAlign.center
              );
            }
          ),
        )
      ],
    );
  }

  Future<dynamic> settingsDialog(BuildContext context) {

    return actionDialog(
      context,
      title: (_,__) => _localizedTextTitle("dlg_settings_title"),
      actions: (_,__) => [

        Expanded(
          child: ButtonDialogAction(
            isDefault: true,
            onAction: (close) => close(null),
            builder: (_,__) {
              return Text(
                context.localizations.translate("dlg_settings_ok"),
                textAlign: TextAlign.center
              );
            }
          ),
        )
      ],
      contents: (_,__) => const SettingsPage()
    );
  }

  Future<dynamic> gameNeedsResetDialog(BuildContext context, {
    required VoidCallback callback
  }) {
    return okDialog(
      context,
      title: (_,__) => _localizedTextTitle("dlg_needreset_title"),
      okLabel: context.localizations.translate("dlg_needreset_ok"),
      contents: (layout, scheme) => Text(context.localizations.translate("dlg_needreset_message")),
      callback: callback,
    );
  }

  Widget _localizedTextTitle(String textId) {
    return DefaultDialogTitle(
      builder: (context, settingsProvider) {
        final scheme = AppColorSchemes.fromName(settingsProvider.value.theme);
        return LocalizedText(
          textId: textId,
          style: TextStyle(
            color: scheme.backgroundPuzzleSymbolsFlipped,
            fontWeight: FontWeight.bold,
            fontSize: context.layout.get<double>(AppLayoutConstants.titleFontSizeKey),
          ),
        );
      },
    );
  }
}
