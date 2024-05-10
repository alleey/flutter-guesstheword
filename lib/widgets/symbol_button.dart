import 'package:flutter/material.dart';

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
    this.buttonSize,
    this.foregroundColor = defaultColorForeground,
    this.backgroundColor = defaultColorBackground,
  });

  final String text;
  final Color foregroundColor;
  final Color backgroundColor;
  final Size? buttonSize;
  final SymbolPressCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return _wrapInSized(
      size: buttonSize,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          alignment: Alignment.center,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          onSelect.call(text);
          //FlipCardRequest().dispatch(context);
        },
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _wrapInSized({ required Widget child, Size? size }) {
    if (size != null) {
      return SizedBox(
        width: size.width,
        height: size.height,
        child: child,
      );
    }
    return child;
  }
}
