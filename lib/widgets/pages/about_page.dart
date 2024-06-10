import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/common/responsive_layout.dart';
import '../../common/custom_traversal_policy.dart';
import '../../common/layout_constants.dart';
import '../../localizations/app_localizations.dart';
import '../../models/app_settings.dart';
import '../../services/data_service.dart';
import '../common/focus_highlight.dart';
import '../dialogs/app_dialog.dart';
import '../localized_text.dart';
import '../settings_aware_builder.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return  SettingsAwareBuilder(
      builder: (context, settingsNotifier) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder(
          valueListenable: settingsNotifier,
          builder: (context, settings, child) =>  _buildContents(context, settings)
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context, AppSettings settings) {

    final scheme = settings.currentScheme;
    final layout = context.layout;
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
    final metadata = DataService().metaData;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Align(
            alignment: AlignmentDirectional.center,
            child: Semantics(
              label: "Game version is ${metadata.version}",
              container: true,
              excludeSemantics: true,
              child: FocusHighlight(
                canRequestFocus: true,
                focusColor: scheme.backgroundPuzzlePanel,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text.rich(
                    textAlign: TextAlign.center,
                    textScaler: const TextScaler.linear(0.9),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: context.localizations.translate("dlg_about_version", placeholders: {"version": metadata.version}),
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
            ),
          ),

          const SizedBox(height: 2),

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
                    text: context.localizations.translate("dlg_about_intro"),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 2),
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
                    text: context.localizations.translate("dlg_about_intro2"),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 2),
          FocusTraversalOrder(
            order: const GroupFocusOrder(GroupFocusOrder.groupDialog, 2),
            child: Semantics(
              label: "Give Feedback",
              button: true,
              excludeSemantics: true,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: ButtonDialogAction(
                  isDefault: true,
                  onAction: (close) async {
                    final link = Uri.tryParse(metadata.linkFeedback);
                    if (link != null) {
                      await launchUrl(link, mode: LaunchMode.inAppBrowserView);
                    }
                  },
                  builder: (_,__) => const  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rate_review),
                      SizedBox(width: 5),
                      LocalizedText(textId: "dlg_about_feedback"),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 2),
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
                    text: context.localizations.translate("dlg_about_intro3"),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 2),
          FocusTraversalOrder(
            order: const GroupFocusOrder(GroupFocusOrder.groupDialog, 3),
            child: Semantics(
              label: "Donate",
              button: true,
              excludeSemantics: true,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: ButtonDialogAction(
                  onAction: (close) async {
                    final link = Uri.tryParse(metadata.linkDonation);
                    if (link != null) {
                      await launchUrl(link, mode: LaunchMode.inAppBrowserView);
                    }
                  },
                  builder: (_,__) => const  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.free_breakfast),
                      SizedBox(width: 5),
                      LocalizedText(textId: "dlg_about_donate"),
                    ],
                  ),
                ),
              ),
            ),
          ),

      ]),
    );
  }
}
