import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../widgets/common/responsive_layout.dart';
import '../../blocs/settings_bloc.dart';
import '../../common/constants.dart';
import '../../common/layout_constants.dart';
import '../../localizations/app_localizations.dart';
import '../../models/app_settings.dart';
import '../color_scheme_picker.dart';
import '../settings_aware_builder.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}


class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return  SettingsAwareBuilder(
      builder: (context, settingsNotifier) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder(
          valueListenable: settingsNotifier,
          builder: (context, settings, child) =>  _buildPage(context, settings)
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, AppSettings settings) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        _buildColorSchemeSettings(context, settings),
          const SizedBox(height: 2),
        _buildAudioSettings(context, settings),

        if (Constants.locales.length > 1)
          ...[
            const SizedBox(height: 2),
            _buildLocaleSettings(context, settings)
          ],

      ],
    );
  }

  Widget _buildColorSchemeSettings(BuildContext context, AppSettings settings) {

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
    final scheme = settings.currentScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          child: Text.rich(
            textAlign: TextAlign.start,
            TextSpan(
              style: TextStyle(
                color: scheme.textPuzzlePanel,
                fontSize: titleFontSize,
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
          selectedTheme: settings.theme,
          onSelect: (newTheme) {
            context.settingsBloc.add(WriteSettingsBlocEvent(
              settings: settings.copyWith(theme: newTheme),
              reload: true
            ));
          }
        ),
      ],
    );
  }

  Widget _buildAudioSettings(BuildContext context, AppSettings settings) {

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
    final scheme = settings.currentScheme;

    return Row(
      children: [
        Semantics(
          container: true,
          child: Text(
            context.localizations.translate("dlg_settings_sound"),
            style: TextStyle(
                color: scheme.textPuzzlePanel,
              fontSize: titleFontSize,
            ),
          ),
        ),
        const Spacer(),
        SegmentedButton(
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            foregroundColor: scheme.textPuzzlePanel,
            backgroundColor: scheme.backgroundPuzzlePanel,
            selectedForegroundColor: scheme.backgroundPuzzlePanel,
            selectedBackgroundColor: scheme.textPuzzlePanel,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            )
          ),
          segments: [
            ButtonSegment<bool>(
              label: Text(
                context.localizations.translate("dlg_settings_sound_enable"),
                style: TextStyle(
                  fontSize: bodyFontSize,
                ),
              ),
              value: true
            ),
            ButtonSegment<bool>(
              label: Text(
                context.localizations.translate("dlg_settings_sound_disable"),
                style: TextStyle(
                  fontSize: bodyFontSize,
                ),
              ),
              value: false
            )
          ],
          selected: <bool>{settings.playSounds},
          onSelectionChanged: (selected) {
            context.settingsBloc.add(WriteSettingsBlocEvent(
              settings: settings.copyWith(playSounds: selected.first),
              reload: true
            ));
          },
        ),
      ]
    );
  }

  Widget _buildLocaleSettings(BuildContext context, AppSettings settings) {

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
    final scheme = settings.currentScheme;

    return Row(
      children: [
        Semantics(
          container: true,
          child: Text.rich(
            textAlign: TextAlign.start,
            TextSpan(
              style: TextStyle(
                color: scheme.textPuzzlePanel,
                fontSize: titleFontSize,
              ),
              children: [
                TextSpan(
                  text: context.localizations.translate("dlg_settings_chooselanguage"),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        DropdownButton<String>(
          style: TextStyle(
            color: scheme.textPuzzlePanel,
            fontSize: bodyFontSize,
          ),
          dropdownColor: scheme.backgroundPuzzlePanel,
          value: settings.locale,
          onChanged: (selected) {
            log("locale new value $selected");
            context.settingsBloc.add(WriteSettingsBlocEvent(
              settings: settings.copyWith(locale: selected),
              reload: true
            ));
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
      ],
    );
  }
}
