import 'package:bit_array/bit_array.dart';
import 'package:flutter/material.dart';

import 'flip_card.dart';
import 'symbol_button.dart';

typedef SymbolSelectCallback = void Function(String, bool flipped);

class SymbolPad extends StatelessWidget {

  static const double defaultWhiteSpaceWidth = 20;
  static const double defaultButtonWidth = 25;
  static const double defaultButtonHeight = 25;
  static const Color defaultColorBackground = Color.fromARGB(0xff, 0x00, 0x20, 0x3F);
  static const Color defaultColorForeground = Color.fromARGB(0xff, 0xAD, 0xEF, 0xD1);

  SymbolPad({
    super.key,
    required this.frontSymbols,
    required this.backSymbols,
    this.flipped,
    this.whiteSpace,
    this.buttonSize,
    this.whiteSpaceWidth = defaultWhiteSpaceWidth,
    this.foregroundColor = defaultColorForeground,
    this.backgroundColor = defaultColorBackground,
    this.foregroundColorFlipped = defaultColorForeground,
    this.backgroundColorFlipped = defaultColorBackground,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.alignment = WrapAlignment.center,
    required this.onSelect
  }) :  assert(frontSymbols.length == backSymbols.length) {

    flipped = flipped ?? BitArray(frontSymbols.length);
    whiteSpace = whiteSpace ?? BitArray(frontSymbols.length);
  }

  final String frontSymbols;
  final String backSymbols;
  final Size? buttonSize;
  final double? whiteSpaceWidth;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color foregroundColorFlipped;
  final Color backgroundColorFlipped;
  final SymbolSelectCallback onSelect;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  late BitArray? flipped;
  late BitArray? whiteSpace;

  @override
  Widget build(BuildContext context) {
    return _buildPanel(context);
  }

  Widget _buildPanel(BuildContext context) {

    final symbolList = frontSymbols.split('').asMap();
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      children: Iterable<int>.generate(symbolList.length).map((index) {
        if (whiteSpace![index]) {
          return SizedBox(width: whiteSpaceWidth,);
        }
        return _buildCard(context, index);
      }).toList(),
    );
  }

  Widget _buildCard(BuildContext c, int index) {

    return FlipCard(
      showFront: !flipped![index],
      frontCard: SymbolButton(
          text: frontSymbols[index],
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          buttonSize: buttonSize,
          onSelect: (ch) {
            onSelect.call(ch, false);
          }),
      backCard: SymbolButton(
          text: backSymbols[index],
          foregroundColor: foregroundColorFlipped,
          backgroundColor: backgroundColorFlipped,
          buttonSize: buttonSize,
          onSelect: (ch) {
            onSelect.call(ch, true);
          }
      ),
    );
  }
}
