import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/settings_bloc.dart';
import '../../common/game_color_scheme.dart';
import '../../common/layout_constants.dart';
import '../../services/app_data_service.dart';
import '../common/alternating_color_squares.dart';
import '../common/responsive_layout.dart';

class YesNoDialog extends StatefulWidget {

  const YesNoDialog({
    super.key,
    required this.title,
    required this.content,
    required this.colorScheme,
    required this.onAccept,
    this.onReject,
    this.yesLabel = "Yes",
    this.noLabel = "No",
    this.width,
    this.height,
    this.padding = DialogLayoutConstants.padding,
    this.insetPadding = DialogLayoutConstants.insetPadding,
  });

  final GameColorScheme colorScheme;
  final String title;
  final Widget content;
  final String yesLabel;
  final String noLabel;
  final double? width;
  final double? height;
  final VoidCallback onAccept;
  final VoidCallback? onReject;
  final EdgeInsets padding;
  final EdgeInsets insetPadding;

  @override
  State<YesNoDialog> createState() => _YesNoDialogState();
}

class _YesNoDialogState extends State<YesNoDialog> {
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

    final layout = ResponsiveLayoutProvider.layout(context);
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);
    final bodyFontSize = layout.get<double>(AppLayoutConstants.bodyFontSizeKey);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          container: true,
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
        widget.content,
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.backgroundPuzzleSymbols,
                foregroundColor: scheme.textPuzzleSymbols,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                widget.onAccept();
              },
              // Is there any good method on planet earth to vertically center text inside elevated button
              // without a padding hack?
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  widget.yesLabel,
                  style: TextStyle(
                    fontSize: bodyFontSize
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.backgroundPuzzleSymbolsFlipped,
                foregroundColor: scheme.textPuzzleSymbolsFlipped,
                alignment: Alignment.bottomCenter,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                widget.onReject?.call();
              },
              // Is there any good method on planet earth to vertically center text inside elevated button
              // without a padding hack?
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  widget.noLabel,
                  style: TextStyle(
                    fontSize: bodyFontSize
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
