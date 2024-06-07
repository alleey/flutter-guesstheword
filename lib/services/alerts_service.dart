import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/app_color_scheme.dart';
import '../common/layout_constants.dart';
import '../localizations/app_localizations.dart';
import '../localizations/locale_provider.dart';
import '../models/player_stats.dart';
import '../widgets/dialogs/app_dialog.dart';
import '../widgets/dialogs/common.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/localized_text.dart';
import '../widgets/pages/how_to_play_page.dart';
import '../widgets/pages/high_scores_list_page.dart';
import '../widgets/pages/player_stats_page.dart';
import '../widgets/pages/settings_page.dart';


class AlertsService {

  Future<T?> actionDialog<T>(
    BuildContext context, {
    required ContentBuilder title,
    required AppColorScheme colorScheme,
    required ContentBuilder contents,
    required ActionBuilder actions,
  }) {
    return showGeneralDialog<T>(
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
          return Consumer<LocaleProvider>(
            builder: (BuildContext context, LocaleProvider value, Widget? child) {

              return AppDialog(
                colorScheme: colorScheme,
                title: title,
                actions: actions,
                contents: contents,
              );
            }
          );
        }
      );
  }

  Future<bool?> yesNoDialog(BuildContext context, {
    required ContentBuilder title,
    required ContentBuilder contents,
    required AppColorScheme colorScheme,
    String yesLabel = "Yes",
    String noLabel = "No",
    VoidCallback? onAccept,
    VoidCallback? onReject,
  }) {
    return actionDialog(
      context,
      title: title,
      colorScheme: colorScheme,
      contents: contents,
      actions: (layout, schemeNotifier) => [
        ButtonDialogAction(
          schemeNotifier: schemeNotifier,
          isDefault: false,
          onAction: (close) {
            close(null);
            onAccept?.call();
          },
          builder: (layout, cs) {
            return Text(yesLabel, textAlign: TextAlign.center);
          }
        ),
        ButtonDialogAction(
          schemeNotifier: schemeNotifier,
          isDefault: true,
          onAction: (close) {
            close(null);
            onReject?.call();
          },
          builder: (layout, cs) {
            return Text(noLabel, textAlign: TextAlign.center);
          }
        )
      ],
    );
  }

  Future<dynamic> okDialog(BuildContext context, {
    required ContentBuilder title,
    required ContentBuilder contents,
    required AppColorScheme colorScheme,
    String okLabel = "Continue",
    VoidCallback? callback
  }) {
    return actionDialog(
      context,
      title: title,
      colorScheme: colorScheme,
      contents: contents,
      actions: (layout, schemeNotifier) => [
        ButtonDialogAction(
          schemeNotifier: schemeNotifier,
          isDefault: true,
          onAction: (close) {
            close(null);
            callback?.call();
          },
          builder: (layout, cs) {
            return Text(okLabel, textAlign: TextAlign.center);
          }
        )
      ],
    );
  }

  VoidCallback popupDialog(BuildContext context, AppColorScheme colorScheme, {
    required ContentBuilder title,
    required ContentBuilder contents,
  }) {
    actionDialog(
      context,
      title: title,
      colorScheme: colorScheme,
      contents: contents,
      actions: (_,__) => []
    );
    return () => Navigator.of(context, rootNavigator: true).pop();
  }

  // Returns a function that can be used to dismiss the popup.
  //
  VoidCallback popup(BuildContext context, AppColorScheme colorScheme, {
    required String title,
    required String message,
  }) {
    return popupDialog(
      context,
      colorScheme,
      title: (layout, schemeNotifier) {
        final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
        return Consumer<LocaleProvider>(
          builder: (context, value, child) => Text(
            title,
            style: TextStyle(
              color: schemeNotifier.value.backgroundPuzzleSymbolsFlipped,
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
            ),
          ),
        );
      },
      contents: (layout, scheme) {

        return Semantics(
          container: true,
          child: Center(
            child: LoadingIndicator(
              message: message,
              colorScheme: colorScheme,
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> resetGameDialog(BuildContext context, AppColorScheme colorScheme, {required VoidCallback onAccept}) {
    return yesNoDialog(
      context,
      colorScheme:  colorScheme,
      title: (layout, schemeNotifier) =>
        LocalizedText(
          textId: "dlg_reset_title",
          style: TextStyle(
            color: schemeNotifier.value.backgroundPuzzleSymbolsFlipped,
            fontWeight: FontWeight.bold,
            fontSize: layout.get<double>(AppLayoutConstants.titleFontSizeKey),
          ),
        ),
      yesLabel: context.localizations.translate("dlg_reset_yes"),
      noLabel: context.localizations.translate("dlg_reset_no"),
      contents: (layout, scheme) {

        final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
        final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

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
                      color: colorScheme.textPuzzlePanel,
                      fontSize: bodyFontSize,
                    )
                  ),
                  TextSpan(
                    text: context.localizations.translate('dlg_reset_question'),
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

  Future<dynamic> helpDialog(BuildContext context, AppColorScheme colorScheme) {
    return actionDialog(
      context,
      colorScheme: colorScheme,
      title: (layout, schemeNotifier) =>
        LocalizedText(
          textId: "dlg_help_title",
          style: TextStyle(
            color: schemeNotifier.value.backgroundPuzzleSymbolsFlipped,
            fontWeight: FontWeight.bold,
            fontSize: layout.get<double>(AppLayoutConstants.titleFontSizeKey),
          ),
        ),
      contents: (layout, schemeNotifier) => ValueListenableBuilder<AppColorScheme>(
          valueListenable: schemeNotifier,
          builder: (context, scheme, child) {
            return HowToPlayPage(colorScheme: scheme);
          },
        ),
      actions: (layout, schemeNotifier) => [

        ButtonDialogAction(
          schemeNotifier: schemeNotifier,
          isDefault: true,
          onAction: (close) {
            close(null);
          },
          builder: (layout, cs) {
            return Consumer<LocaleProvider>(
              builder: (context, value, child) => Text(
                context.localizations.translate("dlg_help_ok"),
                textAlign: TextAlign.center
              ),
            );
          }
        )
      ],
    );
  }

  Future<dynamic> highScoresDialog(BuildContext context, AppColorScheme colorScheme) {

    return actionDialog(
      context,
      colorScheme: colorScheme,
      title: (layout, schemeNotifier) =>
        LocalizedText(
          textId: "dlg_scores_title",
          style: TextStyle(
            color: schemeNotifier.value.backgroundPuzzleSymbolsFlipped,
            fontWeight: FontWeight.bold,
            fontSize: layout.get<double>(AppLayoutConstants.titleFontSizeKey),
          ),
        ),
      contents: (layout, schemeNotifier) => ValueListenableBuilder<AppColorScheme>(
          valueListenable: schemeNotifier,
          builder: (context, scheme, child) {
            return HighScoresListPage(colorScheme: scheme);
          }
        ),
      actions: (layout, schemeNotifier) => [

        ButtonDialogAction(
          schemeNotifier: schemeNotifier,
          isDefault: true,
          onAction: (close) {
            close(null);
          },
          builder: (layout, cs) {
            return Consumer<LocaleProvider>(
              builder: (context, value, child) => Text(
                context.localizations.translate("dlg_scores_ok"),
                textAlign: TextAlign.center
              ),
            );
          }
        )
      ],
    );
  }

  Future<dynamic> statsDialog(BuildContext context, AppColorScheme colorScheme, PlayerStatistics stats) {

    return actionDialog(
      context,
      colorScheme: colorScheme,
      title: (layout, schemeNotifier) =>
        Text(
          "Score: ${stats.score}-${stats.total.wins}-${stats.total.losses}",
          style: TextStyle(
            color: schemeNotifier.value.backgroundPuzzleSymbolsFlipped,
            fontWeight: FontWeight.bold,
            fontSize: layout.get<double>(AppLayoutConstants.titleFontSizeKey),
          ),
        ),
      contents: (layout, schemeNotifier) => ValueListenableBuilder<AppColorScheme>(
          valueListenable: schemeNotifier,
          builder: (context, scheme, child) {
            return PlayerStatisticsPage(colorScheme: scheme, statistics: stats);
          }
        ),
      actions: (layout, schemeNotifier) => [

        ButtonDialogAction(
          schemeNotifier: schemeNotifier,
          isDefault: true,
          onAction: (close) {
            close(null);
          },
          builder: (layout, cs) {
            return Consumer<LocaleProvider>(
              builder: (context, value, child) => Text(
                context.localizations.translate("dlg_playerstats_ok"),
                textAlign: TextAlign.center
              ),
            );
          }
        )
      ],
    );
  }

  Future<dynamic> settingsDialog(BuildContext context, AppColorScheme colorScheme) {

    return actionDialog(
      context,
      colorScheme: colorScheme,
      title: (layout, schemeNotifier) =>
        LocalizedText(
          textId: "dlg_settings_title",
          style: TextStyle(
            color: schemeNotifier.value.backgroundPuzzleSymbolsFlipped,
            fontWeight: FontWeight.bold,
            fontSize: layout.get<double>(AppLayoutConstants.titleFontSizeKey),
          ),
        ),
      actions: (layout, schemeNotifier) => [

        ButtonDialogAction(
          schemeNotifier: schemeNotifier,
          isDefault: true,
          onAction: (close) {
            close(null);
          },
          builder: (layout, cs) {
            return Consumer<LocaleProvider>(
              builder: (context, value, child) => Text(
                context.localizations.translate("dlg_settings_ok"),
                textAlign: TextAlign.center
              ),
            );
          }
        )
      ],
      contents: (layout, schemeNotifier) => ValueListenableBuilder<AppColorScheme>(
          valueListenable: schemeNotifier,
          builder: (context, scheme, child) => SettingsPage(colorScheme: scheme),
        )
    );
  }

  Future<dynamic> gameNeedsResetDialog(BuildContext context, AppColorScheme colorScheme, {
    required VoidCallback callback
  }) {
    return okDialog(
      context,
      title: (layout, schemeNotifier) =>
        LocalizedText(
          textId: "dlg_needreset_title",
          style: TextStyle(
            color: schemeNotifier.value.backgroundPuzzleSymbolsFlipped,
            fontWeight: FontWeight.bold,
            fontSize: layout.get<double>(AppLayoutConstants.titleFontSizeKey),
          ),
        ),
      okLabel: context.localizations.translate("dlg_needreset_ok"),
      colorScheme: colorScheme,
      contents: (layout, scheme) => Text(context.localizations.translate("dlg_needreset_message")),
      callback: callback,
    );
  }
}
