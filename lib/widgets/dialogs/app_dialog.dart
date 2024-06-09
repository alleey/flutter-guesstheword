
import 'package:flutter/material.dart';

import '../../common/layout_constants.dart';
import '../../common/utils.dart';
import '../../models/app_settings.dart';
import '../common/alternating_color_squares.dart';
import '../common/responsive_layout.dart';
import '../settings_aware_builder.dart';
import 'common.dart';

class AppDialog extends StatefulWidget {

  const AppDialog({
    super.key,
    required this.title,
    required this.contents,
    required this.actions,
    this.width,
    this.height,
    this.padding,
    this.insetPadding,
  });

  final ContentBuilder title;
  final ContentBuilder contents;
  final ActionBuilder actions;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? insetPadding;

  @override
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog> {

  @override
  Widget build(BuildContext context) {
    return SettingsAwareBuilder(
      builder: (context, settingsProvider){
        return ValueListenableBuilder(
          valueListenable: settingsProvider,
          builder: (context, settings, child) {
            return _buildDialog(context, settingsProvider);
          }
        );
      },
    );
  }

  Widget _buildDialog(BuildContext context, ValueNotifier<AppSettings> settings) {

    final layout = context.layout;
    final screenCoverPct = layout.get<Size>(DialogLayoutConstants.screenCoverPctKey);
    final padding = layout.get<EdgeInsets>(DialogLayoutConstants.paddingKey);
    final insetPadding = layout.get<EdgeInsets>(DialogLayoutConstants.insetPaddingKey);
    final scheme = settings.value.currentScheme;

    return Dialog(
      insetPadding: widget.insetPadding ?? insetPadding,
      surfaceTintColor: scheme.backgroundInputPanel,
      child: Container(
        width: widget.width ?? (MediaQuery.of(context).size.width * screenCoverPct.width),
        height: widget.height ?? (MediaQuery.of(context).size.height * screenCoverPct.height),
        color: scheme.backgroundPuzzlePanel,
        child: Stack(
          children: [
            Padding(
              padding: widget.padding ?? padding,
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: _buildContents(context, settings)
              ),
            ),
            Positioned(
              child: Align(
                alignment: AlignmentDirectional.topCenter,
                child: AlternatingColorSquares(
                  color1: scheme.backgroundInputPanel,
                  color2: scheme.backgroundPuzzlePanel,
                  squareSize: 4,
                )
              )
            ),
          ],
        ),
      )
    );
  }

  Widget _buildContents(BuildContext context, ValueNotifier<AppSettings> settingsProvider) {

    final buttons = widget.actions(context, settingsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.title(context, settingsProvider),
        Expanded(
          child: widget.contents(context, settingsProvider)
        ),
        if (buttons.isNotEmpty)
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buttons.toList(),
            ),
          ),
      ],
    );
  }
}

class DefaultDialogTitle extends StatelessWidget {
  const DefaultDialogTitle({
    super.key,
    required this.builder,
  });

  final ContentBuilder builder;

  @override
  Widget build(BuildContext context) => SettingsAwareBuilder(
      builder: (context, settingsProvider)=> _buildTitle(context, settingsProvider),
    );

  Widget _buildTitle(BuildContext context, ValueNotifier<AppSettings> settingsProvider) {
    final scheme = settingsProvider.value.currentScheme;
    return Semantics(
      header: true,
      container: true,
      child: Container(
        color: scheme.textPuzzleSymbolsFlipped.withOpacity(0.3),
        padding: const EdgeInsets.only(bottom: 4, top: 10),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text.rich(
            textAlign: TextAlign.center,
            WidgetSpan(
              child: builder(context, settingsProvider)
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonDialogAction extends DialogAction {
  const ButtonDialogAction({
    super.key,
    required super.builder,
    required this.onAction,
    this.isDefault = false,
  }) : super();

  final bool isDefault;
  final void Function(CloseWithResult close) onAction;

  @override
  Widget build(BuildContext context) => SettingsAwareBuilder(
      builder: (context, settingsProvider)=> _buildButton(context, settingsProvider),
    );

  Widget _buildButton(BuildContext context, ValueNotifier<AppSettings> settingsProvider) {

    final layout = context.layout;
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
    final scheme = settingsProvider.value.currentScheme;
    final foregroundColor = isDefault ? scheme.textPuzzleSymbolsFlipped : scheme.textPuzzleSymbols;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDefault ? scheme.backgroundPuzzleSymbolsFlipped : scheme.backgroundPuzzleSymbols,
        foregroundColor: foregroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        padding: EdgeInsets.zero,
      ).copyWith(
        overlayColor: StateDependentColor(foregroundColor),
      ),
      onPressed: () {
        onAction((result) => Navigator.of(context, rootNavigator: true).pop(result));
      },
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: bodyFontSize,
          color: foregroundColor,
        ),
        child: builder(context, settingsProvider),
      ),
    );
  }
}