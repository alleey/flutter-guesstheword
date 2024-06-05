import 'package:flutter/material.dart';
import 'dart:math';

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double lifespan;
  double decay;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifespan,
    required this.decay,
  });
}

typedef ParticleGenerator = Iterable<Particle> Function();
typedef ParticleSystemBuilder = Widget Function(BuildContext, VoidCallback);

class SimpleParticleSystem extends StatefulWidget {
  final ParticleGenerator generator;
  final ParticleSystemBuilder builder;
  final Duration duration;

  // ignore: use_key_in_widget_constructors
  const SimpleParticleSystem({
    required this.builder,
    required this.generator,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  _SimpleParticleSystemState createState() => _SimpleParticleSystemState();
}

class _SimpleParticleSystemState extends State<SimpleParticleSystem> with SingleTickerProviderStateMixin {
  List<Particle> particles = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addListener(() {
      _updateParticles();
    })..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          particles = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void fire() {
    final newParticles = widget.generator();
    setState(() {
      particles.addAll(newParticles);
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      //clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        widget.builder(context, fire),
        CustomPaint(
          painter: _ParticlePainter(particles),
          child: const SizedBox(),
        )
      ],
    );
  }

  void _updateParticles() {
    setState(() {
      for (final particle in particles) {
        particle.position += particle.velocity;
        particle.lifespan -= particle.decay;
      }
      particles.removeWhere((particle) => particle.lifespan <= 0);
    });
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
