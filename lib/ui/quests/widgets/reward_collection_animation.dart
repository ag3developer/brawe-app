import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Controla a animação premium de coleta de recompensa.
///
/// Responsável por:
/// - Coordenar transição visual do card
/// - Animar partículas saindo do card
/// - Animar movimento para indicadores (XP, coins)
/// - Atualizar contadores com animação suave
/// - Animar avanço de barra de XP
/// - Disparar celebração de level up se necessário
/// - Respeitar redução de movimento
class RewardCollectionController extends ChangeNotifier {
  late AnimationController _particleCtrl;
  late AnimationController _counterCtrl;
  late AnimationController _xpBarCtrl;
  late AnimationController _celebrationCtrl;

  final TickerProvider vsync;
  final MediaQueryData mediaQuery;

  // Estado da animação
  bool isAnimating = false;
  bool isLevelUp = false;
  int displayXp = 0;
  int displayCoins = 0;
  double xpBarProgress = 0;

  // Partículas geradas
  final List<_AnimatingParticle> particles = [];

  // Callbacks
  VoidCallback? onAnimationComplete;

  RewardCollectionController({required this.vsync, required this.mediaQuery}) {
    _particleCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 900),
    );

    _counterCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 800),
    );

    _xpBarCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1200),
    );

    _celebrationCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 2000),
    );

    _particleCtrl.addListener(_notifyListeners);
    _counterCtrl.addListener(_notifyListeners);
    _xpBarCtrl.addListener(_notifyListeners);
    _celebrationCtrl.addListener(_notifyListeners);
  }

  void _notifyListeners() => notifyListeners();

  /// Inicia a animação de coleta de recompensa.
  ///
  /// Fluxo:
  /// 1. Gera partículas saindo do card (700ms)
  /// 2. Anima contadores em paralelo (800ms)
  /// 3. Anima barra de XP (1200ms)
  /// 4. Se level up: dispara celebração (até 2000ms)
  Future<void> play({
    required int xpEarned,
    required int coinsEarned,
    required double xpProgression,
    required bool levelUp,
    VoidCallback? onComplete,
  }) async {
    if (isAnimating) return;

    isAnimating = true;
    isLevelUp = levelUp;
    onAnimationComplete = onComplete;
    displayXp = 0;
    displayCoins = 0;
    xpBarProgress = 0;

    // Gerar partículas se redução de movimento não está ativa
    if (!mediaQuery.disableAnimations) {
      _generateParticles();
    }

    // Haptic feedback leve
    await HapticFeedback.lightImpact();

    // Iniciar animações em paralelo
    _particleCtrl.forward();
    _counterCtrl.forward();
    _xpBarCtrl.forward();

    // Animar contadores com easing
    final xpTween = Tween<int>(begin: 0, end: xpEarned);
    final coinsTween = Tween<int>(begin: 0, end: coinsEarned);

    _counterCtrl.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        displayXp = xpTween.evaluate(
          CurvedAnimation(parent: _counterCtrl, curve: Curves.easeOut),
        );
        displayCoins = coinsTween.evaluate(
          CurvedAnimation(parent: _counterCtrl, curve: Curves.easeOut),
        );
      }
    });

    _xpBarCtrl.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        xpBarProgress = Tween<double>(begin: 0, end: xpProgression).evaluate(
          CurvedAnimation(parent: _xpBarCtrl, curve: Curves.easeInOut),
        );
      }
    });

    // Aguardar conclusão das animações principais
    await Future.wait([
      _particleCtrl.forward(),
      _counterCtrl.forward(),
      _xpBarCtrl.forward(),
    ]);

    // Se level up, disparar celebração
    if (levelUp && !mediaQuery.disableAnimations) {
      await _celebrationCtrl.forward();
    }

    isAnimating = false;
    onAnimationComplete?.call();
  }

  /// Gera partículas aleatórias com trajetórias em direções diferentes.
  void _generateParticles() {
    particles.clear();
    const particleCount = 8;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = 80 + math.Random().nextDouble() * 60;

      particles.add(
        _AnimatingParticle(
          id: i,
          angle: angle,
          distance: distance,
          delay: math.Random().nextDouble() * 100,
          opacity: 0.6 + math.Random().nextDouble() * 0.4,
          scale: 0.4 + math.Random().nextDouble() * 0.6,
        ),
      );
    }
  }

  /// Calcula a posição de uma partícula em um determinado momento.
  Offset getParticlePosition(int id, Offset cardCenter) {
    if (particles.isEmpty || id >= particles.length) return cardCenter;

    final particle = particles[id];
    final delayFraction =
        (particle.delay / _particleCtrl.duration!.inMilliseconds).clamp(
          0.0,
          1.0,
        );
    final progress = (_particleCtrl.value - delayFraction).clamp(0.0, 1.0);

    if (progress <= 0) return cardCenter;

    // Easing para movimento mais natural (ease-out)
    final eased = Curves.easeOut.transform(progress);
    final dx = math.cos(particle.angle) * particle.distance * eased;
    final dy = math.sin(particle.angle) * particle.distance * eased;

    return Offset(cardCenter.dx + dx, cardCenter.dy + dy);
  }

  /// Obtém a opacidade de uma partícula.
  double getParticleOpacity(int id) {
    if (particles.isEmpty || id >= particles.length) return 0;

    final particle = particles[id];
    final delayFraction =
        (particle.delay / _particleCtrl.duration!.inMilliseconds).clamp(
          0.0,
          1.0,
        );
    final progress = (_particleCtrl.value - delayFraction).clamp(0.0, 1.0);

    if (progress <= 0) return 0;
    if (progress >= 0.8) return 1.0 - (progress - 0.8) * 5;

    return progress * particle.opacity;
  }

  /// Obtém escala de uma partícula.
  double getParticleScale(int id) {
    if (particles.isEmpty || id >= particles.length) return 0;

    final particle = particles[id];
    final delayFraction =
        (particle.delay / _particleCtrl.duration!.inMilliseconds).clamp(
          0.0,
          1.0,
        );
    final progress = (_particleCtrl.value - delayFraction).clamp(0.0, 1.0);

    if (progress <= 0) return particle.scale * 0.8;
    return particle.scale;
  }

  /// Obtém valor de glow para level up.
  double getCelebrationGlow() => _celebrationCtrl.value;

  /// Obtém escala do badge durante level up.
  double getCelebrationScale() {
    const curve = Curves.elasticOut;
    return 1.0 + curve.transform(_celebrationCtrl.value) * 0.3;
  }

  @override
  void dispose() {
    _particleCtrl.dispose();
    _counterCtrl.dispose();
    _xpBarCtrl.dispose();
    _celebrationCtrl.dispose();
    super.dispose();
  }
}

/// Partícula individual em movimento.
class _AnimatingParticle {
  final int id;
  final double angle;
  final double distance;
  final double delay;
  final double opacity;
  final double scale;

  _AnimatingParticle({
    required this.id,
    required this.angle,
    required this.distance,
    required this.delay,
    required this.opacity,
    required this.scale,
  });
}

/// Overlay que renderiza as partículas animadas e feedback visual.
class RewardCollectionOverlay extends StatefulWidget {
  final RewardCollectionController controller;
  final Offset cardCenter;
  final Color accentColor;

  const RewardCollectionOverlay({
    super.key,
    required this.controller,
    required this.cardCenter,
    required this.accentColor,
  });

  @override
  State<RewardCollectionOverlay> createState() =>
      _RewardCollectionOverlayState();
}

class _RewardCollectionOverlayState extends State<RewardCollectionOverlay> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isAnimating) return const SizedBox.shrink();

    return Stack(
      children: [
        // Partículas
        if (!MediaQuery.of(context).disableAnimations)
          CustomPaint(
            painter: _ParticlePainter(
              particles: widget.controller.particles,
              cardCenter: widget.cardCenter,
              controller: widget.controller,
              accentColor: widget.accentColor,
            ),
            size: Size.infinite,
          ),

        // Level up celebration (se aplicável)
        if (widget.controller.isLevelUp &&
            !MediaQuery.of(context).disableAnimations)
          _LevelUpFeedback(
            controller: widget.controller,
            accentColor: widget.accentColor,
          ),
      ],
    );
  }
}

/// Renderizador de partículas customizado.
class _ParticlePainter extends CustomPainter {
  final List<_AnimatingParticle> particles;
  final Offset cardCenter;
  final RewardCollectionController controller;
  final Color accentColor;

  const _ParticlePainter({
    required this.particles,
    required this.cardCenter,
    required this.controller,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final pos = controller.getParticlePosition(particle.id, cardCenter);
      final opacity = controller.getParticleOpacity(particle.id);
      final scale = controller.getParticleScale(particle.id);

      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = accentColor.withValues(alpha: opacity * 0.7)
        ..style = PaintingStyle.fill;

      final radius = 4.0 * scale;

      // Desenhar partícula com glow sutil
      canvas.drawCircle(pos, radius, paint);

      // Glow externo
      final glowPaint = Paint()
        ..color = accentColor.withValues(alpha: opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;

      canvas.drawCircle(pos, radius * 1.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

/// Feedback visual de level up (glow + pulsação).
class _LevelUpFeedback extends StatelessWidget {
  final RewardCollectionController controller;
  final Color accentColor;

  const _LevelUpFeedback({required this.controller, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final glow = controller.getCelebrationGlow();

    return IgnorePointer(
      child: Center(
        child: Container(
          width: 120 * controller.getCelebrationScale(),
          height: 120 * controller.getCelebrationScale(),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: glow * 0.6),
                blurRadius: 40 * glow,
                spreadRadius: 20 * glow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


