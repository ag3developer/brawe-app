import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animação de celebração de level up.
///
/// Exibe:
/// - Badge de nível com escala elástica
/// - Glow sutil ao redor do badge
/// - Confete discreto caindo
/// - Texto de novo nível (localizado)
/// - Sem exageros, mantendo elegância
class LevelUpCelebration extends StatefulWidget {
  final int newLevel;
  final Color accentColor;
  final String levelUpText;
  final VoidCallback? onComplete;

  const LevelUpCelebration({
    super.key,
    required this.newLevel,
    required this.accentColor,
    required this.levelUpText,
    this.onComplete,
  });

  @override
  State<LevelUpCelebration> createState() => _LevelUpCelebrationState();
}

class _LevelUpCelebrationState extends State<LevelUpCelebration>
    with TickerProviderStateMixin {
  late AnimationController _badgeCtrl;
  late AnimationController _confettiCtrl;
  late Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();

    _badgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _badgeScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _badgeCtrl, curve: Curves.elasticOut));

    _badgeCtrl.forward().then((_) {
      _confettiCtrl.forward().then((_) {
        widget.onComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _badgeCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confete
        IgnorePointer(
          child: CustomPaint(
            painter: _ConfettiPainter(
              animation: _confettiCtrl,
              color: widget.accentColor,
            ),
            size: Size.infinite,
          ),
        ),

        // Badge principal com glow
        Center(
          child: IgnorePointer(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow externo
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.3).animate(
                    CurvedAnimation(
                      parent: _badgeCtrl,
                      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                  ),
                ),

                // Badge com nível
                ScaleTransition(
                  scale: _badgeScale,
                  child: _LevelBadge(
                    level: widget.newLevel,
                    color: widget.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Texto "Novo Nível"
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _badgeCtrl,
                curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
              ),
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1).animate(
                CurvedAnimation(
                  parent: _badgeCtrl,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                ),
              ),
              child: Text(
                widget.levelUpText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: widget.accentColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Badge visual do nível com gradiente.
class _LevelBadge extends StatelessWidget {
  final int level;
  final Color color;

  const _LevelBadge({required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          level.toString(),
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Renderizador de confete discreto.
class _ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _ConfettiPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const particleCount = 12;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = 200 + i * 20.0;

      // Trajetória: sai do centro, sobe um pouco, depois cai
      final progress = animation.value;
      final height = -size.height * 0.5 + progress * size.height * 0.8;
      final horizontal = centerX + math.cos(angle) * distance * progress * 0.3;

      final x = horizontal;
      final y = height + size.height * 0.3;

      if (y >= 0 && y <= size.height && x >= 0 && x <= size.width) {
        // Opacidade: fade out no final
        final opacity = math.max(0.0, (1 - progress).clamp(0, 1) * 0.3);

        final paint = Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.fill;

        // Pequenos retângulos rotacionados
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(progress * math.pi * 4);
        canvas.drawRect(const Rect.fromLTWH(-3, -6, 6, 12), paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
