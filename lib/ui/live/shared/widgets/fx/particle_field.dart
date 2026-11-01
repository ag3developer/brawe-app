import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../domain/models/combo_tier.dart';

/// Matemática pura do motor de partículas (testável sem widgets).
class ParticleMath {
  ParticleMath._();

  /// Quantidade de partículas do [preset]; menos em aparelho fraco.
  static int countFor(ParticlePreset preset, {bool lowPerformance = false}) {
    final base = switch (preset) {
      ParticlePreset.petals => 46,
      ParticlePreset.hearts => 28,
      ParticlePreset.confetti => 90,
      ParticlePreset.sparks => 56,
      ParticlePreset.stars => 34,
      ParticlePreset.coins => 36,
      ParticlePreset.bubbles => 30,
      ParticlePreset.embers => 54,
    };
    return lowPerformance ? (base * 0.4).round() : base;
  }

  /// Heurística de "aparelho fraco" a partir do que o [MediaQuery] expõe
  /// (não há flag de desempenho): tela pequena ou de baixa densidade.
  static bool isLowPerformance(Size size, double devicePixelRatio) =>
      size.shortestSide < 340 || devicePixelRatio < 2.0;

  /// Paleta base do preset; [tint] (cor do presente) entra misturado.
  static List<Color> palette(ParticlePreset preset, {Color? tint}) {
    final base = switch (preset) {
      ParticlePreset.petals => const [
        Color(0xFFFFB7C5), Color(0xFFFF8FA3), Color(0xFFFFD6E0),
      ],
      ParticlePreset.hearts => const [
        Color(0xFFFF4D6D), Color(0xFFFF758F), Color(0xFFFFB3C1),
      ],
      ParticlePreset.confetti => const [
        Color(0xFFFF595E), Color(0xFFFFCA3A), Color(0xFF8AC926),
        Color(0xFF1982C4), Color(0xFF6A4C93),
      ],
      ParticlePreset.sparks => const [
        Color(0xFFFFF3B0), Color(0xFFFFC857), Color(0xFFFFFFFF),
      ],
      ParticlePreset.stars => const [
        Color(0xFFFFE066), Color(0xFFFFFFFF), Color(0xFFFFC107),
      ],
      ParticlePreset.coins => const [
        Color(0xFFFFD700), Color(0xFFFFB300), Color(0xFFFFE57F),
      ],
      ParticlePreset.bubbles => const [
        Color(0xFFB3E5FC), Color(0xFFE1F5FE), Color(0xFFCE93D8),
      ],
      ParticlePreset.embers => const [
        Color(0xFFFF6D00), Color(0xFFFFAB00), Color(0xFFFF3D00),
      ],
    };
    if (tint == null) return base;
    return [for (final c in base) Color.lerp(c, tint, 0.35)!];
  }
}

/// Parâmetros fixos de cada partícula (gerados uma vez, sem alocar por quadro).
class _Seeds {
  _Seeds(int n, int seed)
    : x = List.filled(n, 0),
      speed = List.filled(n, 0),
      phase = List.filled(n, 0),
      size = List.filled(n, 0),
      rot = List.filled(n, 0),
      sway = List.filled(n, 0),
      color = List.filled(n, 0) {
    final r = math.Random(seed);
    for (var i = 0; i < n; i++) {
      x[i] = r.nextDouble();
      speed[i] = 0.55 + r.nextDouble() * 0.9;
      phase[i] = r.nextDouble();
      size[i] = 0.6 + r.nextDouble() * 0.8;
      rot[i] = r.nextDouble() * math.pi * 2;
      sway[i] = 0.5 + r.nextDouble();
      color[i] = r.nextInt(1 << 16);
    }
  }
  final List<double> x, speed, phase, size, rot, sway;
  final List<int> color;
}

/// Campo de partículas: um único [CustomPainter] guiado por um ticker.
///
/// O quadro só repinta o próprio painter (`repaint:`) — nenhum `setState`
/// por quadro nos pais. Com `MediaQuery.disableAnimations` (reduzir
/// movimento) mostra só um brilho que aparece e some. Quem controla o ciclo
/// de vida (entrada/espera/saída) é o [GiftStage] que o hospeda; ao sair da
/// árvore o controlador é descartado.
class ParticleField extends StatefulWidget {
  const ParticleField({
    super.key,
    required this.preset,
    this.tint,
    this.lowPerformance,
  });

  final ParticlePreset preset;
  final Color? tint;

  /// Força o modo leve; `null` decide por [ParticleMath.isLowPerformance].
  final bool? lowPerformance;

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final ValueNotifier<double> _quality = ValueNotifier<double>(1.0);
  _Seeds? _seeds;
  int _seedCount = 0;
  Duration _lastTick = Duration.zero;
  double _avgMs = 16;
  int _frames = 0;

  @override
  void initState() {
    super.initState();
    // Relógio contínuo (segundos); o painter faz o módulo por partícula.
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3600),
    )..forward();
    _ctrl.addListener(_watchFrameTime);
  }

  /// Se os quadros estão lentos (média > 24 ms), reduz as partículas
  /// desenhadas pela metade — adaptação em tempo de execução.
  void _watchFrameTime() {
    final now = _ctrl.lastElapsedDuration ?? Duration.zero;
    final dt = (now - _lastTick).inMicroseconds / 1000.0;
    _lastTick = now;
    if (dt <= 0 || dt > 200) return;
    _avgMs = _avgMs * 0.9 + dt * 0.1;
    _frames++;
    if (_frames == 30 && _avgMs > 24 && _quality.value > 0.5) {
      _quality.value = 0.5;
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_watchFrameTime);
    _ctrl.dispose();
    _quality.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final colors = ParticleMath.palette(widget.preset, tint: widget.tint);

    if (mq.disableAnimations) {
      // Reduzir movimento: só um brilho suave com a cor do efeito.
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              colors.first.withValues(alpha: 0.35),
              colors.first.withValues(alpha: 0),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      );
    }

    final low =
        widget.lowPerformance ??
        ParticleMath.isLowPerformance(mq.size, mq.devicePixelRatio);
    final count = ParticleMath.countFor(widget.preset, lowPerformance: low);
    if (_seeds == null || _seedCount != count) {
      _seeds = _Seeds(count, widget.preset.index * 7919 + 13);
      _seedCount = count;
    }
    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        painter: _ParticlePainter(
          preset: widget.preset,
          seeds: _seeds!,
          colors: colors,
          clock: _ctrl,
          quality: _quality,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.preset,
    required this.seeds,
    required this.colors,
    required this.clock,
    required this.quality,
  }) : super(repaint: Listenable.merge([clock, quality]));

  final ParticlePreset preset;
  final _Seeds seeds;
  final List<Color> colors;
  final AnimationController clock;
  final ValueNotifier<double> quality;

  final Paint _paint = Paint()..isAntiAlias = true;

  static final Path _heart = () {
    // Coração unitário centrado na origem (largura ~1).
    final p = Path()
      ..moveTo(0, 0.35)
      ..cubicTo(-0.65, -0.1, -0.35, -0.6, 0, -0.25)
      ..cubicTo(0.35, -0.6, 0.65, -0.1, 0, 0.35)
      ..close();
    return p;
  }();

  static final Path _star = () {
    final p = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final r = i.isEven ? 0.5 : 0.15;
      final x = math.cos(a) * r, y = math.sin(a) * r;
      i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
    }
    return p..close();
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.lastElapsedDuration?.inMicroseconds ?? 0;
    final sec = t / 1e6;
    final n = (seeds.x.length * quality.value).round();
    final base = size.shortestSide / 360 * 14; // tamanho-base responsivo

    for (var i = 0; i < n; i++) {
      final life = (sec * 0.32 * seeds.speed[i] + seeds.phase[i]) % 1.0;
      final c = colors[seeds.color[i] % colors.length];
      final s = base * seeds.size[i];
      final fadeIn = (life / 0.1).clamp(0.0, 1.0);
      final fadeOut = ((1 - life) / 0.2).clamp(0.0, 1.0);
      final alpha = fadeIn * fadeOut;
      if (alpha <= 0) continue;
      _paint.color = c.withValues(alpha: alpha * 0.95);
      final sway = math.sin(life * math.pi * 2 * seeds.sway[i] + seeds.rot[i]);
      final w = size.width, h = size.height;

      switch (preset) {
        case ParticlePreset.petals:
          final x = seeds.x[i] * w + sway * w * 0.07;
          final y = -s + life * (h + 2 * s);
          _oval(canvas, x, y, s * 0.9, s * 0.5, seeds.rot[i] + life * 6 * sway);
        case ParticlePreset.hearts:
          final x = seeds.x[i] * w + sway * w * 0.05;
          final y = h + s - life * (h + 2 * s);
          _shape(canvas, _heart, x, y, s * 1.6, sway * 0.4);
        case ParticlePreset.confetti:
          final x = seeds.x[i] * w + sway * w * 0.04;
          final y = -s + life * (h + 2 * s);
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(seeds.rot[i] + life * 14);
          // Giro 3D simulado achatando a largura.
          canvas.scale(1, (0.25 + 0.75 * math.cos(life * 20 + seeds.rot[i]).abs()));
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: s * 0.7, height: s * 0.4),
            _paint,
          );
          canvas.restore();
        case ParticlePreset.sparks:
          // Faíscas saindo da base e abrindo em leque.
          final ang = -math.pi / 2 + (seeds.x[i] - 0.5) * math.pi * 0.9;
          final dist = life * h * 0.55 * seeds.speed[i];
          final ox = w / 2 + (seeds.x[i] - 0.5) * w * 0.3;
          final x = ox + math.cos(ang) * dist;
          final y = h * 0.8 + math.sin(ang) * dist;
          _paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.18
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(
            Offset(x, y),
            Offset(x - math.cos(ang) * s * 1.2, y - math.sin(ang) * s * 1.2),
            _paint,
          );
          _paint.style = PaintingStyle.fill;
        case ParticlePreset.stars:
          final x = seeds.x[i] * w;
          final y = (seeds.phase[i] * 0.9 + 0.05) * h;
          final tw = 0.5 + 0.5 * math.sin(sec * 3 * seeds.speed[i] + seeds.rot[i]);
          _paint.color = c.withValues(alpha: alpha * (0.35 + 0.65 * tw));
          _shape(canvas, _star, x, y, s * (1.2 + tw), seeds.rot[i] * 0.2);
        case ParticlePreset.coins:
          final x = seeds.x[i] * w + sway * w * 0.03;
          final y = -s + life * (h + 2 * s);
          final squash = math.cos(life * 18 + seeds.rot[i]).abs();
          _oval(canvas, x, y, s * 0.6 * (0.2 + 0.8 * squash), s * 0.6, 0);
        case ParticlePreset.bubbles:
          final x = seeds.x[i] * w + sway * w * 0.04;
          final y = h + s - life * (h + 2 * s);
          _paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6;
          canvas.drawCircle(Offset(x, y), s * 0.9, _paint);
          _paint
            ..style = PaintingStyle.fill
            ..color = c.withValues(alpha: alpha * 0.18);
          canvas.drawCircle(Offset(x, y), s * 0.9, _paint);
        case ParticlePreset.embers:
          final x = seeds.x[i] * w + sway * w * 0.05;
          final y = h + s - life * (h * 0.9 + 2 * s);
          _paint.color = c.withValues(alpha: alpha);
          canvas.drawCircle(Offset(x, y), s * 0.22 * (1.2 - life * 0.6), _paint);
      }
    }
  }

  void _oval(Canvas canvas, double x, double y, double rx, double ry, double rot) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rot);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
      _paint,
    );
    canvas.restore();
  }

  void _shape(Canvas canvas, Path path, double x, double y, double scale, double rot) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rot);
    canvas.scale(scale);
    canvas.drawPath(path, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.preset != preset || old.seeds != seeds || old.colors != colors;
}
