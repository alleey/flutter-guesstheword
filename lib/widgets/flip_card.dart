import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';

class FlipCard extends StatelessWidget {
  final bool showFront;
  final Widget frontCard;
  final Widget backCard;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final int durationMs;

  const FlipCard({
    required this.showFront,
    required this.frontCard,
    required this.backCard,
    this.durationMs = 800,
    this.transitionBuilder = null,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: durationMs),
      transitionBuilder: transitionBuilder ?? _transitionBuilder,
      layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
      switchInCurve: Curves.ease,
      switchOutCurve: Curves.ease.flipped,
      child: showFront
        ? SizedBox(key: const ValueKey('front'), child: frontCard)
        : SizedBox(key: const ValueKey('back'), child: backCard),
    );
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnimation = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnimation,
      child: widget,
      builder: (context, widget) {
        final isFront = ValueKey(showFront) == widget!.key;
        final rotationY = isFront ? rotateAnimation.value : min(rotateAnimation.value, pi * 0.5);
        return Transform(
          transform: Matrix4.rotationY(rotationY)..setEntry(3, 0, 0),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }
}

