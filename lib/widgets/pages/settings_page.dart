import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../widgets/common/responsive_layout.dart';
import '../../blocs/settings_bloc.dart';
import '../../common/app_color_scheme.dart';
import '../../common/constants.dart';
import '../../common/layout_constants.dart';
import '../../localizations/app_localizations.dart';
import '../../localizations/locale_provider.dart';
import '../../services/app_data_service.dart';
import '../color_scheme_picker.dart';

class SettingsPage extends StatelessWidget {

  SettingsPage({
    super.key,
    required this.colorScheme,
  });

  final AppColorScheme colorScheme;
  final themeChangeNotifier  = ValueNotifier<String>(AppColorSchemes.defaultSchemeName);

  @override
  Widget build(BuildContext context) {

    final layout = context.layout;
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

    return Consumer<LocaleProvider>(
      builder: (context, localProvider, child) => BlocListener<SettingsBloc, SettingsBlocState>(
        listener: (BuildContext context, state) async {
          if(state is SettingsReadBlocState) {
            if (state.name == KnownSettingsNames.settingTheme) {
              themeChangeNotifier.value = state.value!;
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildPage(bodyFontSize, context, localProvider),
        ),
      ),
    );
  }

  Widget _buildPage(double bodyFontSize, BuildContext context, LocaleProvider localProvider) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            child: Text.rich(
              textAlign: TextAlign.start,
              TextSpan(
                style: TextStyle(
                  color: colorScheme.textPuzzlePanel,
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
          ValueListenableBuilder(
            valueListenable: themeChangeNotifier,
            builder: (context, selectedTheme, child) =>  ColorSchemePicker(
              alignment: WrapAlignment.start,
              selectedTheme: selectedTheme,
              onSelect: (newTheme) {
                context.settingsBloc.add(WriteSettingEvent(name: KnownSettingsNames.settingTheme, value: newTheme, reload: true));
              }
            ),
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
                    color: colorScheme.textPuzzlePanel,
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
                color: colorScheme.textPuzzlePanel,
                fontSize: bodyFontSize,
              ),
              dropdownColor: colorScheme.backgroundPuzzlePanel,
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
      );
  }
}
