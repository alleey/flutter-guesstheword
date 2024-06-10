import 'package:flutter/material.dart';

class BlinkEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BlinkEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<BlinkEffect> createState() => _BlinkEffectState();
}

class _BlinkEffectState extends State<BlinkEffect> with SingleTickerProviderStateMixin {

  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    lowerBound: 0.6,
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }
}
