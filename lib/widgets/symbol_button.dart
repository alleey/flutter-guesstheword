import 'dart:developer';

import 'package:flutter/material.dart';

import '../common/utils.dart';

typedef SymbolPressCallback = void Function(String);

class SymbolButton extends StatefulWidget {

  static const double defaultWidth = 45;
  static const double defaultHeight = 25;
  static const Color defaultColorBackground = Color.fromARGB(0xff, 0x00, 0x20, 0x3F);
  static const Color defaultColorForeground = Color.fromARGB(0xff, 0xAD, 0xEF, 0xD1);

  const SymbolButton({
    super.key,
    required this.text,
    required this.onSelect,
    required this.buttonSize,
    this.autofocus = false,
    this.foregroundColor = defaultColorForeground,
    this.backgroundColor = defaultColorBackground,
  });

  final String text;
  final Color foregroundColor;
  final Color backgroundColor;
  final Size buttonSize;
  final bool autofocus;
  final SymbolPressCallback onSelect;

  @override
  State<SymbolButton> createState() => _SymbolButtonState();
}

class _SymbolButtonState extends State<SymbolButton> {
  @override
  Widget build(BuildContext context) => _buildKey(widget.text);

  Widget _buildKey(String text) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: SizedBox(
        width: widget.buttonSize.width,
        height: widget.buttonSize.height,
        child: ElevatedButton(
          autofocus: widget.autofocus,
          style: ElevatedButton.styleFrom(
            alignment: Alignment.center,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ).copyWith(
            overlayColor: StateDependentColor(widget.foregroundColor),
          ),
          onPressed: () {
            widget.onSelect.call(text);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              text,
              style: TextStyle(
                color: widget.foregroundColor,
              ),
            ),
          ),
        )
      )
    );
  }
}
