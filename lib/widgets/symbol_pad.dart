import 'package:bit_array/bit_array.dart';
import 'package:flutter/material.dart';

import '../common/constants.dart';
import 'flip_card.dart';
import 'symbol_button.dart';

typedef SymbolSelectCallback = void Function(String, bool flipped);

class SymbolPad extends StatefulWidget {

  SymbolPad({
    super.key,
    required this.frontSymbols,
    required this.backSymbols,
    this.flipped,
    this.whiteSpace,
    this.foregroundColor = Constants.colorForeground,
    this.backgroundColor = Constants.colorBackground,
    this.foregroundColorFlipped = Constants.colorForeground,
    this.backgroundColorFlipped = Constants.colorBackground,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    required this.onSelect
  }) :  assert(frontSymbols.length == backSymbols.length) {

    flipped = flipped ?? BitArray(frontSymbols.length);
    whiteSpace = whiteSpace ?? BitArray(frontSymbols.length);
  }

  final String frontSymbols;
  final String backSymbols;
  late BitArray? flipped;
  late BitArray? whiteSpace;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color foregroundColorFlipped;
  final Color backgroundColorFlipped;
  final SymbolSelectCallback onSelect;
  final double spacing;
  final double runSpacing;

  @override
  State<SymbolPad> createState() => _SymbolPadState();
}

class _SymbolPadState extends State<SymbolPad> {

  @override
  Widget build(BuildContext context) {
    return _buildPanel(context);
  }

  Widget _buildPanel(BuildContext context) {

    final symbolList = widget.frontSymbols.split('').asMap();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
        spacing: widget.spacing,
        runSpacing: widget.runSpacing,
        alignment: WrapAlignment.center,
        children: Iterable<int>.generate(symbolList.length)
          .map((index) {
            if (widget.whiteSpace![index]) {
              return const SizedBox(width: 20,);
            }
            return _buildCard(context, index);
          })
          .toList(),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext c, int index) {

    return FlipCard(
      showFront: !widget.flipped![index],
      frontCard: SymbolButton(
          text: widget.frontSymbols[index],
          foregroundColor: widget.foregroundColor,
          backgroundColor: widget.backgroundColor,
          onSelect: (ch) {
            widget.onSelect.call(ch, false);
          }),
      backCard: SymbolButton(
          text: widget.backSymbols[index],
          foregroundColor: widget.foregroundColorFlipped,
          backgroundColor: widget.backgroundColorFlipped,
          onSelect: (ch) {
            widget.onSelect.call(ch, true);
          }
      ),
    );
  }
}
