import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class AuthBackground extends StatefulWidget {
  const AuthBackground({super.key});

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fundo sólido escuro — sem gradiente colorido
        const ColoredBox(color: Color(0xFF080810)),
        // Um único orb sutil no topo — não polui
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _SingleOrbPainter(_controller.value),
            );
          },
        ),
      ],
    );
  }
}

class _SingleOrbPainter extends CustomPainter {
  _SingleOrbPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * (0.5 + 0.04 * math.sin(t * 2 * math.pi));
    final cy = size.height * (0.0 - 0.02 * math.cos(t * 2 * math.pi));
    final radius = size.width * 0.72;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.electricPurple.withValues(alpha: 0.18),
          AppColors.electricPurple.withValues(alpha: 0.0),
        ],
      ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _SingleOrbPainter old) => old.t != t;
}