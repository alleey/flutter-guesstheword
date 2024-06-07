

import 'dart:math';

import 'package:flutter/material.dart';

import 'simple_particle_system.dart';

class BumpEffect extends StatelessWidget {

  final Color particleColor;
  final Duration duration;
  final ParticleSystemBuilder builder;
  final int numberOfParticles;
  final VoidCallback? onComplete;
  late bool _autostart;

  BumpEffect({
    super.key,
    required this.particleColor,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.numberOfParticles = 15,
    bool autostart = true,
    this.onComplete,
  }) : _autostart = autostart;

  @override
  Widget build(BuildContext context) {

    return SimpleParticleSystem(
      builder: (context, fire) {
        final child = builder(context, fire);
        if (_autostart) {
          _autostart = false;
          WidgetsBinding.instance.addPostFrameCallback((d) {
            fire();
          });
        }
        return child;
      },
      generator: _createParticles,
      duration: duration,
      onComplete: onComplete,
    );
  }

  Iterable<Particle> _createParticles() {

    const velocityMagnitude = 4.0;
    final angleStep = 2 * pi / numberOfParticles;
    const size = 2.0;
    const position = Offset(0, 0);

    final newParticles = List<Particle>.generate(numberOfParticles, (index) {

      final angle = angleStep * index;
      final velocity = Offset(
        velocityMagnitude * cos(angle),
        velocityMagnitude * sin(angle),
      );

      return Particle(
        position: position,
        velocity: velocity,
        color: particleColor,
        size: size,
        lifespan: 1,
        decay: 0.05,
      );
    });

    return newParticles;
  }
}
