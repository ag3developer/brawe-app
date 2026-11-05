import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/models/battle_assets.dart';
import 'battle_media.dart';
import 'battle_layout.dart' show BattleLayout;

/// Lado do encaixe de poder nas pontas da barra (etapa 2 coloca os poderes).
const double kBattleSlotSize = 28;

/// Estado de um gatilho de efeito da barra (lead_change, momentum,
/// multiplier, final_window, event).
@immutable
class BarTrigger {
  const BarTrigger({required this.startedAt, this.side, this.ongoing = true});

  final DateTime startedAt;

  /// Lado de dados ('a'/'b') que disparou; `null` = nenhum em especial.
  final String? side;

  /// A condição do gatilho ainda vale (usado quando `duration_ms == 0`).
  final bool ongoing;
}

/// Camada de efeitos desenhada sobre a barra de pontos (§19.1/19.2).
///
/// Tamanho = o da barra. Âncoras: `bar` (inteira), `side` (metade do time que
/// disparou), `seam` (costura) e `slot` (encaixe de cada ponta, logo abaixo
/// da barra). Os dois encaixes existem sempre, vazios, para os poderes.
class BattleBarEffectsLayer extends StatelessWidget {
  const BattleBarEffectsLayer({
    super.key,
    required this.effects,
    required this.triggers,
    required this.leftFraction,
    required this.layout,
    required this.barHeight,
  });

  final List<BattleBarEffect> effects;
  final Map<String, BarTrigger> triggers;

  /// Fração da barra ocupada pelo time da esquerda (posição da costura).
  final double leftFraction;
  final BattleLayout layout;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    final sorted = [...effects]..sort((a, b) => a.z.compareTo(b.z));
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (_, box) {
          final w = box.maxWidth;
          final seamX = w * leftFraction.clamp(0.04, 0.96);
          final children = <Widget>[
            // Encaixes vazios das pontas (poderes na etapa 2).
            Positioned(
              left: 2,
              top: barHeight + 2,
              width: kBattleSlotSize,
              height: kBattleSlotSize,
              child: const SizedBox(key: ValueKey('battle-slot-left')),
            ),
            Positioned(
              right: 2,
              top: barHeight + 2,
              width: kBattleSlotSize,
              height: kBattleSlotSize,
              child: const SizedBox(key: ValueKey('battle-slot-right')),
            ),
          ];
          for (final fx in sorted) {
            final t = triggers[fx.trigger];
            if (t == null) continue;
            if (fx.durationMs == 0 && !t.ongoing) continue;
            final remaining = fx.durationMs > 0
                ? Duration(milliseconds: fx.durationMs) -
                      DateTime.now().difference(t.startedAt)
                : null;
            if (remaining != null && remaining <= Duration.zero) continue;
            final leftSide = t.side == null ? null : layout.isLeft(t.side!);
            final spots = _spots(fx.anchor, w, seamX, leftSide);
            for (var i = 0; i < spots.length; i++) {
              final spot = spots[i];
              children.add(
                spot.place(
                  _TimedFx(
                    key: ValueKey(
                      'fx-${fx.id}-${t.startedAt.microsecondsSinceEpoch}-$i',
                    ),
                    effect: fx,
                    lifetime: remaining,
                    clip: spot.clip,
                  ),
                ),
              );
            }
          }
          return SizedBox(
            width: w,
            height: barHeight,
            child: Stack(clipBehavior: Clip.none, children: children),
          );
        },
      ),
    );
  }

  List<_Spot> _spots(String anchor, double w, double seamX, bool? leftSide) {
    final h = barHeight;
    switch (anchor) {
      case 'side':
        // Sem lado conhecido, cai na barra inteira.
        if (leftSide == null) return [_Spot.fill(w, h)];
        return leftSide
            ? [_Spot(0, 0, seamX, h, clip: true)]
            : [_Spot(seamX, 0, w - seamX, h, clip: true)];
      case 'seam':
        const s = 56.0;
        return [_Spot(seamX - s / 2, (h - s) / 2, s, s)];
      case 'slot':
        const s = kBattleSlotSize;
        final left = _Spot(2, h + 2, s, s);
        final right = _Spot(w - s - 2, h + 2, s, s);
        if (leftSide == null) return [left, right];
        return [leftSide ? left : right];
      case 'bar':
      default:
        return [_Spot.fill(w, h)];
    }
  }
}

class _Spot {
  const _Spot(this.left, this.top, this.width, this.height, {this.clip = false});
  factory _Spot.fill(double w, double h) => _Spot(0, 0, w, h, clip: true);

  final double left;
  final double top;
  final double width;
  final double height;
  final bool clip;

  Widget place(Widget child) => Positioned(
    left: left,
    top: top,
    width: width,
    height: height,
    child: child,
  );
}

/// Desenha um efeito e o remove ao fim da duração (se houver). Toca o som ao
/// aparecer. Efeito sem arquivo nenhum (ex.: "lead-shine") usa o brilho
/// embutido; com arquivos ainda não baixados não desenha nada.
class _TimedFx extends StatefulWidget {
  const _TimedFx({
    super.key,
    required this.effect,
    required this.lifetime,
    required this.clip,
  });

  final BattleBarEffect effect;
  final Duration? lifetime;
  final bool clip;

  @override
  State<_TimedFx> createState() => _TimedFxState();
}

class _TimedFxState extends State<_TimedFx> {
  Timer? _t;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    BattleMedia.play(widget.effect.soundUrl);
    final life = widget.lifetime;
    if (life != null) {
      _t = Timer(life, () {
        if (mounted) setState(() => _gone = true);
      });
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gone) return const SizedBox.shrink();
    final fx = widget.effect;
    Widget child;
    if (!fx.hasVisual) {
      child = const BattleBarShine();
    } else if (BattleMedia.hasVisual(fx.lottieUrl, fx.imageUrl)) {
      child = BattleMediaView(
        lottieUrl: fx.lottieUrl,
        imageUrl: fx.imageUrl,
        loop: fx.loop || fx.durationMs == 0,
        fit: widget.clip ? BoxFit.cover : BoxFit.contain,
      );
    } else {
      return const SizedBox.shrink();
    }
    return widget.clip ? ClipRect(child: child) : child;
  }
}

/// Brilho padrão (varredura de luz) para efeitos sem arquivo.
class BattleBarShine extends StatefulWidget {
  const BattleBarShine({super.key});

  @override
  State<BattleBarShine> createState() => _BattleBarShineState();
}

class _BattleBarShineState extends State<BattleBarShine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final x = -1.0 + 3 * _c.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(x - 0.5, 0),
              end: Alignment(x + 0.5, 0),
              colors: [
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: 0.55),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        );
      },
    );
  }
}
