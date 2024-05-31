import 'dart:developer';

import 'package:bit_array/bit_array.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'common/flip_card.dart';
import 'symbol_button.dart';

typedef SymbolSelectCallback = void Function(String, bool flipped);
typedef DecoratorFunction = Widget Function(Widget widget, int index, bool isFront, String frontLabel, String backLabel);

class FocusedButton extends StatefulWidget {
  final Widget child;

  const FocusedButton({super.key, required this.child});

  @override
  _FocusedButtonState createState() => _FocusedButtonState();
}

class _FocusedButtonState extends State<FocusedButton> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        setState(() {});
      },
      child: widget.child,
    );
  }
}

class SymbolPad extends StatefulWidget {

  static const double defaultWhiteSpaceWidth = 20;
  static const double defaultButtonWidth = 25;
  static const double defaultButtonHeight = 25;
  static const Color defaultColorBackground = Color.fromARGB(0xff, 0x00, 0x20, 0x3F);
  static const Color defaultColorForeground = Color.fromARGB(0xff, 0xAD, 0xEF, 0xD1);

  SymbolPad({
    super.key,
    this.autofocus = false,
    required this.frontSymbols,
    required this.backSymbols,
    required this.buttonSize,
    BitArray? flipped,
    BitArray? whiteSpace,
    this.whiteSpaceWidth = defaultWhiteSpaceWidth,
    this.foregroundColor = defaultColorForeground,
    this.backgroundColor = defaultColorBackground,
    this.foregroundColorFlipped = defaultColorForeground,
    this.backgroundColorFlipped = defaultColorBackground,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.alignment = WrapAlignment.center,
    required this.onSelect,
    DecoratorFunction? symbolDecorator,
  }):
    assert(frontSymbols.length == backSymbols.length),
    symbolDecorator = symbolDecorator ?? ((widget,_, __,___,____) => widget),
    flippedMask = flipped ?? BitArray(frontSymbols.length),
    whiteSpaceMask = whiteSpace ?? BitArray(frontSymbols.length);

  final bool autofocus;
  final String frontSymbols;
  final String backSymbols;
  final Size buttonSize;
  final double? whiteSpaceWidth;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color foregroundColorFlipped;
  final Color backgroundColorFlipped;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final BitArray flippedMask;
  final BitArray whiteSpaceMask;
  final SymbolSelectCallback onSelect;
  final DecoratorFunction symbolDecorator;

  @override
  State<SymbolPad> createState() => _SymbolPadState();
}

class _SymbolPadState extends State<SymbolPad> {
  @override
  Widget build(BuildContext context) {
    return _buildPanel(context);
  }

  Widget _buildPanel(BuildContext context) {

    final symbolList = widget.frontSymbols.split('');
    final firstUnset = widget.flippedMask.asIntIterable(false).first;

    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      alignment: widget.alignment,
      children: symbolList.mapIndexed((index, sym) {

        if (widget.whiteSpaceMask[index]) {
          return SizedBox(width: widget.whiteSpaceWidth,);
        }
        return _buildCard(context, index, autofocus: widget.autofocus && index == firstUnset);
      }).toList(),
    );
  }

  Widget _buildCard(BuildContext c, int index, {bool autofocus = false}) {

    Widget frontFace = SymbolButton(
      autofocus: autofocus,
      text: widget.frontSymbols[index],
      foregroundColor: widget.foregroundColor,
      backgroundColor: widget.backgroundColor,
      buttonSize: widget.buttonSize,
      onSelect: (ch) {
        widget.onSelect.call(ch, false);
      }
    );

    Widget backFace = SymbolButton(
      text: widget.backSymbols[index],
      foregroundColor: widget.foregroundColorFlipped,
      backgroundColor: widget.backgroundColorFlipped,
      buttonSize: widget.buttonSize,
      onSelect: (ch) {
        widget.onSelect.call(ch, true);
      }
    );

    return FlipCard(
      showFront: !widget.flippedMask[index],
      frontCard: widget.symbolDecorator(frontFace, index, true, widget.frontSymbols[index], widget.backSymbols[index]),
      backCard: widget.symbolDecorator(backFace, index, false, widget.frontSymbols[index], widget.backSymbols[index]),
    );
  }
}
