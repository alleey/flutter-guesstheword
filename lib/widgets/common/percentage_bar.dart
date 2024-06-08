import 'package:flutter/material.dart';

class PercentageBar extends StatelessWidget {

  const PercentageBar({
    super.key,
    required this.value,
    this.height = 20,
    this.backgroundColor = Colors.black,
    this.foregroundColor = Colors.white,
    this.borderColor,
    this.borderWidth = 0.0,
    this.textStyle,
    this.inverted = false,
    this.showLabel = true,
  });

  final double value;
  final double height;
  final bool inverted;
  final bool showLabel;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor; // Optional border color
  final double borderWidth; // Optional border width
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return _buildRectangularIndicator(context, value, Colors.blue);
  }

  Widget _buildRectangularIndicator(BuildContext context, double value, Color color) {
    return Stack(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: 1 - value,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: inverted ? backgroundColor:backgroundColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: borderColor ?? Colors.transparent, width: borderWidth),
              ),
            ),
          ),
        ),
        if (value > 0)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FractionallySizedBox(
              widthFactor: value,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: inverted ? backgroundColor.withOpacity(0.3):backgroundColor,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: borderColor ?? Colors.transparent, width: borderWidth),
                ),
              ),
            ),
          ),
        if (showLabel)
          Positioned.fill(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "${(value * 100).toStringAsFixed(1)}%",
                  textScaler: const TextScaler.linear(0.9),
                  style: textStyle ?? TextStyle(
                    color: foregroundColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
