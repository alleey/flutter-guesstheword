import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/settings_bloc.dart';
import '../../common/game_color_scheme.dart';
import '../../common/layout_constants.dart';
import '../../common/utils.dart';
import '../../services/app_data_service.dart';
import '../common/alternating_color_squares.dart';
import '../common/responsive_layout.dart';
import 'common.dart';

class OkDialog extends StatefulWidget {

  const OkDialog({
    super.key,
    required this.title,
    required this.builder,
    required this.colorScheme,
    this.onClose,
    this.okLabel = "Continue",
    this.width,
    this.height,
    this.padding = DialogLayoutConstants.padding,
    this.insetPadding = DialogLayoutConstants.insetPadding,
  });

  final GameColorScheme colorScheme;
  final String title;
  final ContentBuilder builder;
  final String okLabel;
  final double? width;
  final double? height;
  final VoidCallback? onClose;
  final EdgeInsets padding;
  final EdgeInsets insetPadding;

  @override
  State<OkDialog> createState() => _OkDialogState();
}

class _OkDialogState extends State<OkDialog> {

  late GameColorScheme activeColorScheme;

  @override
  void initState() {
    super.initState();
    activeColorScheme = widget.colorScheme;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsBlocState>(
      listener: (BuildContext context, state) {
        switch(state) {
          case final SettingsReadBlocState s:
          if (s.name == KnownSettingsNames.settingTheme) {
            setState(() {
              activeColorScheme = GameColorSchemes.fromName(s.value);
            });
          }
          break;
        }
      },
      child: _buildDialog(context, activeColorScheme),
    );
  }

  Widget _buildDialog(BuildContext context, GameColorScheme scheme) {
    return Dialog(
      insetPadding: widget.insetPadding,
      surfaceTintColor: scheme.backgroundInputPanel,
      child: Container(
        width: widget.width ?? MediaQuery.of(context).size.width,
        height: widget.height ?? MediaQuery.of(context).size.height,
        color: scheme.backgroundPuzzlePanel,
        child: Stack(
          children: [
            Padding(
              padding: widget.padding,
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: _buildContents(context, scheme)
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
  }

  Widget _buildContents(BuildContext context, GameColorScheme scheme) {

    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          container: true,
          child: Container(
            color: scheme.textPuzzleSymbolsFlipped.withOpacity(0.3),
            padding: const EdgeInsets.only(bottom: 4, top: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: widget.title,
                      style: TextStyle(
                        color: scheme.backgroundPuzzleSymbolsFlipped,
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: widget.builder(layout, widget.colorScheme)
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              autofocus: true,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.backgroundPuzzleSymbols,
                foregroundColor: scheme.textPuzzleSymbols,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ).copyWith(
                overlayColor: StateDependentColor(scheme.textPuzzleSymbols),
              ),
              onPressed: () {
                widget.onClose?.call();
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text(
                widget.okLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: bodyFontSize,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
