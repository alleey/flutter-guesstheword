import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../blocs/settings_bloc.dart';
import '../common/app_color_scheme.dart';
import '../common/constants.dart';
import '../common/layout_constants.dart';
import '../localizations/app_localizations.dart';
import '../localizations/locale_provider.dart';
import '../widgets/color_scheme_picker.dart';
import '../widgets/dialogs/app_dialog.dart';
import '../widgets/dialogs/common.dart';
import '../widgets/localized_text.dart';
import 'app_data_service.dart';
import 'data_service.dart';
import 'score_service.dart';


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
          context: context,
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
          context: context,
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
          context: context,
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

  Future<dynamic> resetGameDialog(BuildContext context, AppColorScheme colorScheme, {required VoidCallback onAccept}) {
    return yesNoDialog(
      context,
      colorScheme:  colorScheme,
      title: (layout, schemeNotifier) =>
        LocalizedText(
          textId: "dlg_reset_title",
          schemeNotifier: schemeNotifier,
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

  Future<dynamic> helpDialog(BuildContext context, AppColorScheme colorScheme) => okDialog(
      context,
      colorScheme: colorScheme,
      title: (layout, schemeNotifier) =>
        LocalizedText(
          textId: "dlg_help_title",
          schemeNotifier: schemeNotifier,
          style: TextStyle(
            color: schemeNotifier.value.backgroundPuzzleSymbolsFlipped,
            fontWeight: FontWeight.bold,
            fontSize: layout.get<double>(AppLayoutConstants.titleFontSizeKey),
          ),
        ),
      okLabel: context.localizations.translate("dlg_help_ok"),
      contents: (layout, schemeNotifier) {

        final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
        final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
        final dataService = DataService();

        return ValueListenableBuilder<AppColorScheme>(
          valueListenable: schemeNotifier,
          builder: (context, scheme, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Align(
                    alignment: Alignment.center,
                    child: Semantics(
                      label: "Game version is ${dataService.version}",
                      container: true,
                      excludeSemantics: true,
                      child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          children: [
                            TextSpan(
                              text: context.localizations.translate("dlg_help_version", placeholders: {"version": dataService.version}),
                              style: TextStyle(
                                color: scheme.backgroundPuzzleSymbolsFlipped.withOpacity(0.7),
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
                      textAlign: TextAlign.start,
                      TextSpan(
                        style: TextStyle(
                          color: scheme.textPuzzlePanel,
                          fontSize: bodyFontSize,
                        ),
                        children: [
                          TextSpan(
                            text: context.localizations.translate("dlg_help_intro"),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Semantics(
                    container: true,
                    child: Text.rich(
                      textAlign: TextAlign.start,
                      TextSpan(
                        style: TextStyle(
                          color: scheme.textPuzzlePanel,
                          fontSize: bodyFontSize,
                        ),
                        children: [
                          TextSpan(
                            semanticsLabel: "Rule 1.",
                            text: '\u{273D} ',
                            style: TextStyle(
                              color: scheme.backgroundPuzzleSymbolsFlipped,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: context.localizations.translate("dlg_help_rule1"),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Semantics(
                    container: true,
                    child: Text.rich(
                      textAlign: TextAlign.start,
                      TextSpan(
                        style: TextStyle(
                          color: scheme.textPuzzlePanel,
                          fontSize: bodyFontSize,
                        ),
                        children: [
                          TextSpan(
                            text: '\u{2726} ',
                            semanticsLabel: "Rule 2.",
                            style: TextStyle(
                              color: scheme.backgroundPuzzleSymbolsFlipped,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            )
                          ),
                          TextSpan(
                            text: context.localizations.translate("dlg_help_rule2", placeholders: {"scoreBumpForHintBonus": Constants.scoreBumpForHintBonus}),
                          ),
                          TextSpan(
                            text: context.localizations.translate("dlg_help_rule2_1"),
                            style: TextStyle(
                              color: scheme.backgroundPuzzleSymbolsFlipped,
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
      },
    );

  Future<dynamic> highScoresDialog(BuildContext context, AppColorScheme colorScheme) {

    final scoreService = ScoreService();
    final scores = scoreService.highScores();

    return okDialog(
      context,
      colorScheme: colorScheme,
      title: (layout, schemeNotifier) =>
        LocalizedText(
          textId: "dlg_scores_title",
          schemeNotifier: schemeNotifier,
          style: TextStyle(
            color: schemeNotifier.value.backgroundPuzzleSymbolsFlipped,
            fontWeight: FontWeight.bold,
            fontSize: layout.get<double>(AppLayoutConstants.titleFontSizeKey),
          ),
        ),
      okLabel: context.localizations.translate("dlg_scores_ok"),
      contents: (layout, schemeCahnge) {

        final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
        final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

        return ValueListenableBuilder<AppColorScheme>(
          valueListenable: schemeCahnge,
          builder: (context, scheme, child) => scores.isEmpty
              ? Center(
                  child: Semantics(
                    container: true,
                    child: Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        children: [
                          TextSpan(
                              text: context.localizations
                                  .translate("dlg_scores_norecord"),
                              style: TextStyle(
                                color: scheme.textPuzzlePanel,
                                fontSize: titleFontSize,
                              )),
                        ],
                      ),
                    ),
                  ),
                )
              : DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    color: scheme.textPuzzlePanel,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Semantics(
                            label: "Below is the list of top scores, games won and lost",
                            excludeSemantics: true,
                            container: true,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    context.localizations.translate("dlg_scores_score"),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    context.localizations.translate("dlg_scores_won"),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    context.localizations.translate("dlg_scores_lost"),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ...scores.mapIndexed((i, e) {
                            return Semantics(
                              label:
                                  "Item ${i + 1}. Score is ${e.value}, ${e.wins} wins and ${e.losses} losses.",
                              container: true,
                              excludeSemantics: true,
                              child: Row(children: [
                                Expanded(
                                  child: Text(
                                    "${e.value}",
                                    textAlign: TextAlign.start,
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
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ]),
                            );
                          }),
                        ]
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<dynamic> settingsDialog(BuildContext context, {
    required String selectedTheme,
    required ColorSchemeSelectionCallback onSelect
  }) {

    final colorScheme = AppColorSchemes.fromName(selectedTheme);

    return actionDialog(
      context,
      colorScheme: colorScheme,
      title: (layout, schemeNotifier) =>
        LocalizedText(
          textId: "dlg_settings_title",
          schemeNotifier: schemeNotifier,
          style: TextStyle(
            color: schemeNotifier.value.backgroundPuzzleSymbolsFlipped,
            fontWeight: FontWeight.bold,
            fontSize: layout.get<double>(AppLayoutConstants.titleFontSizeKey),
          ),
        ),
      actions: (layout, schemeNotifier) => [

        ButtonDialogAction(
          context: context,
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
      contents: (layout, schemeNotifier) {

        final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

        return ValueListenableBuilder<AppColorScheme>(
          valueListenable: schemeNotifier,
          builder: (context, scheme, child) {

            return Consumer<LocaleProvider>(
              builder: (context, localProvider, child) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      container: true,
                      child: Text.rich(
                        textAlign: TextAlign.start,
                        TextSpan(
                          style: TextStyle(
                            color: scheme.textPuzzlePanel,
                            fontSize: bodyFontSize,
                          ),
                          children: [
                            TextSpan(
                              text: context.localizations.translate("dlg_settings_selecttheme"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    ColorSchemePicker(
                      alignment: WrapAlignment.start,
                      selectedTheme: selectedTheme, onSelect: onSelect
                    ),


                    const SizedBox(height: 2),
                  if (Constants.locales.length > 1)
                    ...[
                      Semantics(
                        container: true,
                        child: Text.rich(
                          textAlign: TextAlign.start,
                          TextSpan(
                            style: TextStyle(
                              color: scheme.textPuzzlePanel,
                              fontSize: bodyFontSize,
                            ),
                            children: [
                              TextSpan(
                                text: context.localizations.translate("dlg_settings_chooselanguage"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      DropdownButton<String>(
                        isDense: true,
                        style: TextStyle(
                          color: scheme.textPuzzlePanel,
                          fontSize: bodyFontSize,
                        ),
                        dropdownColor: scheme.backgroundPuzzlePanel,
                        value: localProvider.value.languageCode,
                        onChanged: (selected) {
                          context.changeLanguage(selected!);
                          context.settingsBloc.add(WriteSettingEvent(name: KnownSettingsNames.settingLocale, value: selected));
                        },
                        items: Constants.locales.map<DropdownMenuItem<String>>((locale) {
                          return DropdownMenuItem<String>(
                            value: locale,
                            child: Text(
                              context.localizations.translate("app_lang_$locale"),
                              style: TextStyle(
                                fontSize: bodyFontSize,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ]

                    // Directionality(
                    //   textDirection: TextDirection.ltr,
                    //   child: SegmentedButton(
                    //     style: SegmentedButton.styleFrom(
                    //       foregroundColor: scheme.textPuzzlePanel,
                    //       backgroundColor: scheme.backgroundPuzzlePanel,
                    //       selectedForegroundColor: scheme.backgroundPuzzlePanel,
                    //       selectedBackgroundColor: scheme.textPuzzlePanel,
                    //     ),
                    //     showSelectedIcon: false,
                    //     segments: Constants.locales.map((locale) {
                    //       return ButtonSegment<String>(
                    //         label: Text(
                    //           context.localizations.translate("app_lang_$locale"),
                    //           style: TextStyle(
                    //             fontSize: bodyFontSize,
                    //           ),
                    //         ),
                    //         value: locale
                    //       );

                    //     }).toList(),
                    //     selected: <String>{localProvider.value.languageCode},
                    //     onSelectionChanged: (selected) {

                    //       context.changeLanguage(selected.first);
                    //       context.settingsBloc.add(WriteSettingEvent(name: KnownSettingsNames.settingLocale, value: selected.first));
                    //     },
                    //   ),
                    // )
                  ],
                ),
              ),
            );
          },
        );
      }
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
          schemeNotifier: schemeNotifier,
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
