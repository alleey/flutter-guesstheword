import 'package:flutter/material.dart';

import '../common/constants.dart';

typedef SymbolPressCallback = void Function(String);

class SymbolButton extends StatelessWidget {
  const SymbolButton({
    super.key,
    required this.text,
    required this.onSelect,
    this.foregroundColor = Constants.colorForeground,
    this.backgroundColor = Constants.colorBackground,
  });

  final String text;
  final Color foregroundColor;
  final Color backgroundColor;
  final SymbolPressCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      onPressed: () {
        onSelect.call(text);
        //FlipCardRequest().dispatch(context);
      },
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
