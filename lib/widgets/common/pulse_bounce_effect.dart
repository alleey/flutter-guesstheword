import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class PulseBounceEffect extends StatefulWidget {
  final Widget child;
  final double bounceHeight;
  final Duration speed;
  final Duration period;

  const PulseBounceEffect({
    super.key,
    required this.child,
    this.bounceHeight = 10,
    this.speed = const Duration(milliseconds: 250),
    this.period = const Duration(seconds: 5),
  });

  @override
  _PulseBounceEffectState createState() => _PulseBounceEffectState();
}

class _PulseBounceEffectState extends State<PulseBounceEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.speed,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: widget.bounceHeight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: widget.bounceHeight, end: 0.0), weight: 1),
    ]).animate(_controller);

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });

    _startRandomAnimation();
  }

  void _startRandomAnimation() {
    final random = Random();
    _timer = Timer.periodic(widget.period, (timer) {
      final randomInterval = Duration(
        seconds: random.nextInt(5)
      );
      Future.delayed(randomInterval, () {
        if (mounted) {
          _controller.forward(from: 0);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0.0, -_animation.value),
      child: widget.child,
    );
  }
}
