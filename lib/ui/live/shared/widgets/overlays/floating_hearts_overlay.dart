import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/repositories/auth_state_provider.dart';
import '../../../../../data/repositories/live_repository.dart';

/// ❤️ Overlay de corações flutuantes em tempo real.
///
/// Escuta `liveRepository.watchReactions(roomId)` e, para cada evento
/// recebido (batch de N), cria N animações de coração subindo pela tela
/// com cor/jitter aleatórios. Cada coração é uma StatefulWidget filha
/// auto-removida ao fim da animação.
///
/// Também expõe um método estático [emit] para o próprio usuário disparar
/// hearts localmente (otimista) — o socket envia o batch e os outros viewers
/// recebem via `watchReactions`.
class FloatingHeartsOverlay extends ConsumerStatefulWidget {
  const FloatingHeartsOverlay({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<FloatingHeartsOverlay> createState() => FloatingHeartsOverlayState();
}

class FloatingHeartsOverlayState extends ConsumerState<FloatingHeartsOverlay> {
  static final _palette = <Color>[
    const Color(0xFFFF4D8B), // pink
    const Color(0xFFFF7AB6), // light pink
    const Color(0xFFB6A6FF), // purple
    const Color(0xFFFFD166), // gold (raro)
    const Color(0xFF7BE0FF), // cyan
  ];

  // 🎯 Paleta dedicada da batalha — alinhada com o `viewer_battle_hud`:
  //   lado A (esquerda) → roxo
  //   lado B (direita) → rosa
  // Sem palette aleatória aqui: a leitura visual é "purple sobe = lado A
  // está sendo torcido", "pink sobe = lado B". Ajuda o espectador a
  // entender quem está bombando sem precisar olhar o placar.
  static const Color _kBattleSideAColor = Color(0xFF8DB8FF); // brawe blue soft (lado A)
  static const Color _kBattleSideBColor = Color(0xFFFF4D8B); // pink

  final List<_HeartSpec> _hearts = [];
  final _rand = math.Random();
  int _seq = 0;
  StreamSubscription? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Subscribe to broadcast reactions (other viewers + own echo).
    _subscribe();
  }

  void _subscribe() {
    final repo = ref.read(liveRepositoryProvider);
    final myId = ref.read(authStateProvider).value?.id;
    _sub = repo.watchReactions(widget.roomId).listen((event) {
      // Eco do próprio usuário: o coração já foi desenhado localmente.
      if (myId != null && event.userId == myId) return;
      _spawn(
        event.count,
        color: _colorFromName(event.color),
        battleSide: event.battleSide,
      );
    });
  }

  Color? _colorFromName(String? name) {
    if (name == null) return null;
    switch (name.toLowerCase()) {
      case 'pink':
        return const Color(0xFFFF4D8B);
      case 'purple':
        return const Color(0xFFB6A6FF);
      case 'gold':
        return const Color(0xFFFFD166);
      case 'cyan':
        return const Color(0xFF7BE0FF);
      default:
        return null;
    }
  }

  /// Spawna [count] corações localmente. Usado tanto pelo handler do socket
  /// quanto pelo botão "like" (otimista).
  ///
  /// [battleSide] (opcional): quando definido (`'a'` ou `'b'`), os corações
  /// sobem na lateral correspondente do split-screen + cor fixa do lado.
  /// Sem isso (live solo), mantém o comportamento clássico: faixa direita,
  /// palette aleatória.
  void spawn(int count, {Color? color, String? battleSide}) =>
      _spawn(count, color: color, battleSide: battleSide);

  void _spawn(int count, {Color? color, String? battleSide}) {
    if (!mounted) return;
    final clamped = count.clamp(1, 50);

    // Resolve faixa horizontal e cor com base no lado da batalha (se houver).
    // - Lado A (esquerda): faixa 0.05..0.30 → corações sobem do lado do streamer A
    // - Lado B (direita): faixa 0.70..0.95 → corações sobem do lado do streamer B
    // - Live solo: faixa 0.80..0.95 (clássico) + palette aleatória
    final double startXBase;
    final double startXRange;
    final Color? sideColor;
    switch (battleSide) {
      case 'a':
        startXBase = 0.05;
        startXRange = 0.25;
        sideColor = _kBattleSideAColor;
        break;
      case 'b':
        startXBase = 0.70;
        startXRange = 0.25;
        sideColor = _kBattleSideBColor;
        break;
      default:
        startXBase = 0.80;
        startXRange = 0.15;
        sideColor = null;
    }

    setState(() {
      for (int i = 0; i < clamped; i++) {
        _hearts.add(_HeartSpec(
          id: _seq++,
          // Em batalha cada lado tem sua faixa; em solo, faixa direita.
          startX: startXBase + _rand.nextDouble() * startXRange,
          // Drift leve para a esquerda/direita, mas sem cruzar a tela.
          drift: (_rand.nextDouble() - 0.5) * 0.10,
          scale: 0.85 + _rand.nextDouble() * 0.55,
          // Prioridade: cor explícita do caller > cor do lado > palette aleatória.
          // (Em batalha, sideColor sempre vence — vira identidade visual do lado.)
          color: color ?? sideColor ?? _palette[_rand.nextInt(_palette.length)],
          duration: Duration(milliseconds: 2200 + _rand.nextInt(900)),
          delay: Duration(milliseconds: i * 60),
        ));
      }
    });
  }

  void _remove(int id) {
    if (!mounted) return;
    setState(() => _hearts.removeWhere((h) => h.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final h in _hearts)
            _FloatingHeart(
              key: ValueKey(h.id),
              spec: h,
              onDone: () => _remove(h.id),
            ),
        ],
      ),
    );
  }
}

class _HeartSpec {
  _HeartSpec({
    required this.id,
    required this.startX,
    required this.drift,
    required this.scale,
    required this.color,
    required this.duration,
    required this.delay,
  });
  final int id;
  final double startX; // 0..1 fraction of width (near right rail)
  final double drift; // horizontal drift fraction
  final double scale;
  final Color color;
  final Duration duration;
  final Duration delay;
}

class _FloatingHeart extends StatefulWidget {
  const _FloatingHeart({super.key, required this.spec, required this.onDone});
  final _HeartSpec spec;
  final VoidCallback onDone;

  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.spec.duration);
    Future.delayed(widget.spec.delay, () {
      if (!mounted) return;
      _ctrl.forward().then((_) {
        if (mounted) widget.onDone();
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value; // 0..1
        // Caminho em S leve — sin wave reduzido para manter na coluna direita
        final wave = math.sin(t * math.pi * 2.4) * 8;
        final xFrac = widget.spec.startX + widget.spec.drift * t;
        final dx = xFrac * size.width + wave;
        // Sobe do botão "Curtir" (bottom ~18%) até ~45% da tela (meio).
        // Não cruza o avatar do streamer no topo — visual mais limpo.
        final startY = 0.82;
        final endY = 0.42;
        final dy = size.height * (startY - (startY - endY) * t);
        // Fade-in rápido, fade-out no último terço (some no meio da tela)
        final opacity = t < 0.1
            ? (t / 0.1)
            : t > 0.65
                ? ((1 - t) / 0.35).clamp(0.0, 1.0)
                : 1.0;
        return Positioned(
          left: dx - 14,
          top: dy,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: widget.spec.scale * (0.85 + 0.25 * math.sin(t * math.pi)),
              child: Icon(
                Icons.favorite,
                size: 32,
                color: widget.spec.color,
                shadows: [
                  Shadow(
                    color: widget.spec.color.withValues(alpha: 0.6),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
