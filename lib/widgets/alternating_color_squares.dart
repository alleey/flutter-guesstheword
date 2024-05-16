import 'package:flutter/material.dart';

class AlternatingColorSquaresPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double squareSize;

  AlternatingColorSquaresPainter(this.color1, this.color2, this.squareSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;

    for (double i = 0; i < size.width; i += squareSize) {
      if (i % (squareSize * 2) == 0) {
        canvas.drawRect(Rect.fromLTWH(i, 0, squareSize, squareSize), paint1);
      } else {
        canvas.drawRect(Rect.fromLTWH(i, 0, squareSize, squareSize), paint2);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class AlternatingColorSquares extends StatelessWidget {
  final Color color1;
  final Color color2;
  final double squareSize;

  const AlternatingColorSquares({
    super.key,
    required this.color1,
    required this.color2,
    required this.squareSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, squareSize),
      painter: AlternatingColorSquaresPainter(color1, color2, squareSize),
    );
  }
}
