import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/settings_bloc.dart';
import '../../common/constants.dart';
import '../../common/game_color_scheme.dart';
import '../../services/app_data_service.dart';
import '../alternating_color_squares.dart';

class OkDialog extends StatefulWidget {

  const OkDialog({
    super.key,
    required this.title,
    required this.content,
    required this.colorScheme,
    this.onClose,
    this.okLabel = "Continue",
    this.width,
    this.height,
    this.padding = DialogConstants.padding,
    this.insetPadding = DialogConstants.insetPadding,
  });

  final GameColorScheme colorScheme;
  final String title;
  final Widget content;
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
              activeColorScheme = GameColorSchemes.scheme(s.value);
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
              child: _buildContents(context, scheme),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FittedBox(
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
                    fontSize: 24,
                  )
                ),
              ],
            ),
          ),
        ),
        widget.content,
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.backgroundPuzzleSymbols,
            foregroundColor: scheme.textPuzzleSymbols,
            alignment: Alignment.bottomCenter,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            widget.onClose?.call();
          },
          child: Center(
            child: Text(
              widget.okLabel,
              style: const TextStyle(
              ),
            ),
          ),
        )
      ],
    );
  }
}
