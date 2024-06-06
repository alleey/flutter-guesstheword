
import 'package:flutter/material.dart';

import '../common/utils.dart';

typedef SymbolPressCallback = void Function(String);

class SymbolButton extends StatelessWidget {

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
  Widget build(BuildContext context) => _buildKey(text);

  Widget _buildKey(String text) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: SizedBox(
        width: buttonSize.width,
        height: buttonSize.height,
        child: ElevatedButton(
          autofocus: autofocus,
          style: ElevatedButton.styleFrom(
            alignment: Alignment.center,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ).copyWith(
            overlayColor: StateDependentColor(foregroundColor),
          ),
          onPressed: () {
            onSelect.call(text);
          },
          child: Text(
            text,
            style: TextStyle(
              color: foregroundColor,
            ),
          ),
        )
      )
    );
  }
}
