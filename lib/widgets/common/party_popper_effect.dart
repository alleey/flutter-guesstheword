import 'dart:math' as math;

import 'package:flutter/material.dart';

class PartyPopperEffect extends StatefulWidget {

  const PartyPopperEffect({
    super.key,
    this.duration = const Duration(milliseconds: 1500),
    this.maxRibbons = 100,
    this.autostart = true,
  });

  final Duration duration;
  final int maxRibbons;
  final bool autostart;

  @override
  _PartyPopperEffectState createState() => _PartyPopperEffectState();
}

class _PartyPopperEffectState extends State<PartyPopperEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_Ribbon> _ribbons = [];
  late Size _size;
  late bool _showOver = false;
  late bool _autostart;

  @override
  void initState() {
    super.initState();
    _autostart = widget.autostart;
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )
    ..addListener(() {
      setState(() {});
    })
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showOver = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showOver ? const SizedBox() : LayoutBuilder(
      builder: (context, constraints) {
        _size = Size(constraints.maxWidth, constraints.maxHeight);

        if (_autostart) {
          _autostart = false;
          WidgetsBinding.instance.addPostFrameCallback((d) {
            fire();
          });
        }

        return CustomPaint(
          painter: _RibbonPainter(_ribbons, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }

  void fire() {
    if (_ribbons.isEmpty) {
      _initializeRibbons();
    }
    _controller.forward(from: 0);
  }

  void _initializeRibbons() {
    final random = math.Random();
    _ribbons = List.generate(widget.maxRibbons, (index) => _Ribbon(
      color: Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ),
      x: random.nextDouble() * _size.width,
      y: random.nextDouble() * -_size.height,
      speedY: random.nextDouble() * 2 + 2,
      speedX: random.nextDouble() * 2 - 1,
      width: random.nextDouble() * 10 + 2,
      height: random.nextDouble() * 20 + 10,
    ));
  }
}

class _Ribbon {
  Color color;
  double x;
  double y;
  double speedY;
  double speedX;
  double width;
  double height;

  _Ribbon({
    required this.color,
    required this.x,
    required this.y,
    required this.speedY,
    required this.speedX,
    required this.width,
    required this.height,
  });

  void update(double progress) {
    y += speedY * progress * 10;
    x += speedX * progress * 10;
  }
}

class _RibbonPainter extends CustomPainter {
  List<_Ribbon> ribbons;
  double progress;

  _RibbonPainter(this.ribbons, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var ribbon in ribbons) {
      ribbon.update(progress);
      paint.color = ribbon.color;
      canvas.drawRect(
        Rect.fromLTWH(ribbon.x, ribbon.y, ribbon.width, ribbon.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

