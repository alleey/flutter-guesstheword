
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/settings_bloc.dart';
import '../../common/app_color_scheme.dart';
import '../../common/layout_constants.dart';
import '../../common/utils.dart';
import '../../services/app_data_service.dart';
import '../common/alternating_color_squares.dart';
import '../common/responsive_layout.dart';
import 'common.dart';

class AppDialog extends StatefulWidget {

  const AppDialog({
    super.key,
    required this.title,
    required this.contents,
    required this.colorScheme,
    required this.actions,
    this.width,
    this.height,
    this.padding,
    this.insetPadding,
  });

  final AppColorScheme colorScheme;
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

  late ValueNotifier<AppColorScheme> activeColorScheme;

  @override
  void initState() {
    super.initState();
    activeColorScheme = ValueNotifier<AppColorScheme>(widget.colorScheme);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsBlocState>(
      listener: (BuildContext context, state) {
        switch(state) {
          case final SettingsReadBlocState s:
            if (state.name == KnownSettingsNames.settingTheme) {
              activeColorScheme.value = AppColorSchemes.fromName(state.value);
            }
          break;
        }
      },
      child: _buildDialog(context),
    );
  }

  Widget _buildDialog(BuildContext context) {

    final layout = context.layout;
    final screenCoverPct = layout.get<Size>(DialogLayoutConstants.screenCoverPctKey);
    final padding = layout.get<EdgeInsets>(DialogLayoutConstants.paddingKey);
    final insetPadding = layout.get<EdgeInsets>(DialogLayoutConstants.insetPaddingKey);

    return ValueListenableBuilder<AppColorScheme>(
      valueListenable: activeColorScheme,
      builder: (context, scheme, child) {
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
                    child: _buildContents(context)
                  ),
                ),
                Positioned(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AlternatingColorSquares(
                      color1: scheme.backgroundInputPanel,
                      color2: scheme.backgroundPuzzlePanel,
                      squareSize: 4,
                    )
                  )
                ),
                Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AlternatingColorSquares(
                      color1: scheme.backgroundPuzzlePanel,
                      color2: scheme.backgroundInputPanel,
                      squareSize: 4,
                    )
                  )
                ),
              ],
            ),
          )
        );
      },
    );
  }

  Widget _buildContents(BuildContext context) {

    final layout = context.layout;

    return ValueListenableBuilder<AppColorScheme>(
      valueListenable: activeColorScheme,
      builder: (context, scheme, child) {

        final buttons = widget.actions(layout, activeColorScheme);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
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
                      child: widget.title(layout, activeColorScheme)
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: widget.contents(layout, activeColorScheme)
            ),

            if (buttons.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttons.mapIndexed((index, action) {

                  return Padding(
                    padding: EdgeInsets.only(left: index > 0 ? 10:0),
                    child: action,
                  );

                }).toList(),
              ),
          ],
        );
      },
    );
  }
}

class ButtonDialogAction extends DialogAction {
  const ButtonDialogAction({
    super.key,
    required super.schemeNotifier,
    required super.builder,
    required this.isDefault,
    required this.onAction,
  }) : super();

  final bool isDefault;
  final void Function(CloseWithResult close) onAction;

  @override
  Widget build(BuildContext context) {

    final layout = context.layout;
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);
    final scheme = schemeNotifier.value;
    final foregroundColor = isDefault ? scheme.textPuzzleSymbolsFlipped : scheme.textPuzzleSymbols;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDefault ? scheme.backgroundPuzzleSymbolsFlipped : scheme.backgroundPuzzleSymbols,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
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
        child: builder(layout, schemeNotifier),
      ),
    );
  }
}