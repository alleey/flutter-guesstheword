import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class PulseSquashEffect extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration speed;
  final Duration period;

  const PulseSquashEffect({
    super.key,
    required this.child,
    this.scale = 0.8,
    this.speed = const Duration(milliseconds: 300),
    this.period = const Duration(seconds: 5),
  });

  @override
  _PulseSquashEffectState createState() => _PulseSquashEffectState();
}

class _PulseSquashEffectState extends State<PulseSquashEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.speed,
      reverseDuration: const Duration(milliseconds: 200),
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: widget.scale), weight: 1),
      TweenSequenceItem(tween: Tween(begin: widget.scale, end: 1.0), weight: 1),
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
    return Transform.scale(
      scale: _animation.value,
      child: widget.child,
    );
  }
}
