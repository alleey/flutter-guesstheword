import 'package:flutter/material.dart';

class AlternatingColorSquares extends StatelessWidget {
  final Color color1;
  final Color color2;
  final double squareSize;
  final Axis axis;

  const AlternatingColorSquares({
    super.key,
    required this.color1,
    required this.color2,
    required this.squareSize,
    this.axis = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: axis == Axis.horizontal ? Size(double.infinity, squareSize):Size(squareSize, double.infinity),
      painter: _AlternatingColorSquaresPainter(color1, color2, squareSize, axis),
    );
  }
}

class _AlternatingColorSquaresPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double squareSize;
  final Axis axis;

  _AlternatingColorSquaresPainter(this.color1, this.color2, this.squareSize, this.axis);

  @override
  void paint(Canvas canvas, Size size) {

    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final totalLength = axis == Axis.horizontal ? size.width:size.height;
    final dx = axis == Axis.horizontal ? 1.0:0;
    final dy = axis == Axis.horizontal ? 0:1.0;

    for (var i = 0.0; i < totalLength; i += squareSize) {
      canvas.drawRect(
        Rect.fromLTWH(dx * i, dy * i, squareSize, squareSize),
        (i % (squareSize * 2) == 0) ? paint1 : paint2
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}