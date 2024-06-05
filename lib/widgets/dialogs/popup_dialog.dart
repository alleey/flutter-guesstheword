import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/settings_bloc.dart';
import '../../common/game_color_scheme.dart';
import '../../common/layout_constants.dart';
import '../../services/app_data_service.dart';
import '../common/alternating_color_squares.dart';
import '../common/responsive_layout.dart';
import 'common.dart';

class PopupDialog extends StatefulWidget {

  const PopupDialog({
    super.key,
    required this.title,
    required this.builder,
    required this.colorScheme,
    this.width,
    this.height,
    this.padding = DialogLayoutConstants.padding,
    this.insetPadding = DialogLayoutConstants.insetPadding,
  });

  final GameColorScheme colorScheme;
  final String title;
  final ContentBuilder builder;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final EdgeInsets insetPadding;

  @override
  State<PopupDialog> createState() => _PopupDialogState();
}

class _PopupDialogState extends State<PopupDialog> {

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
      ],
    );
  }
}
