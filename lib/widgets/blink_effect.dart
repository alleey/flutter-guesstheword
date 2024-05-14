import 'package:flutter/material.dart';

class BlinkEffect extends StatefulWidget {
  final Widget child;

  const BlinkEffect({
    super.key,
    required this.child,
  });

  @override
  State<BlinkEffect> createState() => _BlinkEffectState();
}

class _BlinkEffectState extends State<BlinkEffect> with SingleTickerProviderStateMixin {

  late final AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 1500),
    lowerBound: 0.7,
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> animation = CurvedAnimation(
    parent: controller,
    curve: Curves.easeIn,
  );

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: animation, child: widget.child);
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }
}
