import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../domain/models/gift_presentation.dart';
import '../../layout/live_dock_metrics.dart';

/// Visual de um presente numa [GiftStage]: recebe a área em que deve caber.
typedef GiftStageContentBuilder = Widget Function(BuildContext context, Size size);

/// Quanto cada barra de cinema cobre (fração da altura).
const double kCurtainBarFraction = 0.11;

/// Resultado de uma transição num instante: opacidade, deslocamento (em
/// frações da área) e escala do presente.
class GiftFx {
  const GiftFx(this.opacity, this.dx, this.dy, this.scale);
  final double opacity;
  final double dx;
  final double dy;
  final double scale;
}

/// Matemática pura das transições (testável, sem widgets).
///
/// [p] é a "presença" do presente: 0 = escondido, 1 = em cena. Na entrada
/// vale a curva de entrada; na saída, `1 - curva(x)`.
class GiftStageMath {
  GiftStageMath._();

  /// Progresso da fase de entrada/saída a partir do valor do controlador
  /// (0..2): entrada = 0..1, saída = 1..2.
  static double enterProgress(double v) => v.clamp(0.0, 1.0);
  static double exitProgress(double v) => (v - 1.0).clamp(0.0, 1.0);

  /// Presença do presente para [type] no progresso [t] (já 0..1, onde 1 é
  /// "em cena" na entrada e "saindo por completo" na saída).
  static GiftFx fx(GiftTransition type, double p, {bool entering = true}) {
    p = p.clamp(0.0, 1.0);
    switch (type) {
      case GiftTransition.none:
        return GiftFx(p >= 1 ? 1 : 0, 0, 0, 1);
      case GiftTransition.fade:
        return GiftFx(p, 0, 0, 1);
      case GiftTransition.zoom:
        return GiftFx(p, 0, 0, 0.6 + 0.4 * p);
      case GiftTransition.rise:
        return GiftFx(p, 0, (1 - p) * 0.6, 1);
      case GiftTransition.drop:
        return GiftFx(p, 0, -(1 - p) * 0.6, 1);
      case GiftTransition.slideLeft:
        return GiftFx((p * 3).clamp(0.0, 1.0), -(1 - p), 0, 1);
      case GiftTransition.slideRight:
        return GiftFx((p * 3).clamp(0.0, 1.0), (1 - p), 0, 1);
      case GiftTransition.dawn:
        // Entrada: o fundo escurece primeiro (40%); o presente só aparece depois.
        // Saída: espelho (o presente some nos primeiros 60%; o resto é o entardecer).
        // Entrada: tela escurece primeiro; presente nos últimos 65%.
        // Saída: o presente some junto com o escurecimento (linear).
        final q = entering ? ((p - 0.35) / 0.65).clamp(0.0, 1.0) : p;
        return GiftFx(q, 0, 0, 0.85 + 0.15 * q);
      case GiftTransition.curtain:
        final q = ((p - 0.3) / 0.7).clamp(0.0, 1.0);
        return GiftFx(q, 0, 0, 0.85 + 0.15 * q);
    }
  }

  /// Efeito do presente no valor [v] (0..2) do controlador.
  static GiftFx giftFx(GiftPresentation pr, double v) {
    if (v <= 1.0) {
      final e = Curves.easeOutCubic.transform(enterProgress(v));
      return fx(pr.enter.type, e);
    }
    final x = Curves.easeInCubic.transform(exitProgress(v));
    // Na saída, `fx` recebe a presença que vai de 1 a 0.
    // Para dawn/curtain o "p" de saída é o progresso 1-x.
    return fx(pr.exit.type, 1 - x, entering: false);
  }

  /// Altura (fração 0..1 do tamanho cheio) das barras de cinema em [v].
  static double curtainBars(GiftPresentation pr, double v) {
    if (pr.enter.type != GiftTransition.curtain) return 0;
    final e = Curves.easeOutCubic.transform(enterProgress(v));
    final x = Curves.easeInCubic.transform(exitProgress(v));
    final inP = (e / 0.4).clamp(0.0, 1.0);
    return inP * (1 - x);
  }

  static const Color warm = Color(0xFFFFC77A);

  /// Cores sobrepostas ao fundo em [v]: [0] = estático (darken/lighten),
  /// [1] = amanhecer/entardecer.
  static List<Color> backdrop(GiftPresentation pr, double v) {
    final e = enterProgress(v);
    final x = exitProgress(v);
    final presence = e * (1 - x);
    final op = pr.backdropOpacity;

    Color fixed = const Color(0x00000000);
    switch (pr.backdrop) {
      case GiftBackdrop.darken:
        fixed = Colors.black.withValues(alpha: op * presence);
      case GiftBackdrop.lighten:
        fixed = warm.withValues(alpha: op * 0.6 * presence);
      case GiftBackdrop.none:
      case GiftBackdrop.dawn:
        break;
    }

    final modeDawn = pr.backdrop == GiftBackdrop.dawn;
    final enterDawn = modeDawn || pr.enter.type == GiftTransition.dawn;
    final exitDawn = modeDawn || pr.exit.type == GiftTransition.dawn;
    Color dawn = const Color(0x00000000);
    if (enterDawn || exitDawn) {
      final dOp = pr.backdrop == GiftBackdrop.none ? 0.5 : op;
      // Em cena (e=1, x=0): brilho quente só no modo dawn.
      final rest = modeDawn ? dOp * 0.6 : 0.0;
      Color c;
      double a;
      if (x > 0) {
        if (exitDawn) {
          // Entardecer: a tela escurece até ~60% enquanto o presente some.
          c = Color.lerp(rest > 0 ? warm : Colors.black, Colors.black, x)!;
          a = rest + (0.6 - rest) * x;
        } else {
          c = warm;
          a = rest * (1 - x);
        }
      } else if (enterDawn) {
        if (e < 0.4) {
          c = Colors.black;
          a = dOp * (e / 0.4);
        } else {
          final t = (e - 0.4) / 0.6;
          c = Color.lerp(Colors.black, warm, t)!;
          a = dOp + (rest - dOp) * t;
        }
      } else {
        c = warm;
        a = rest * e;
      }
      dawn = c.withValues(alpha: a.clamp(0.0, 1.0));
    }
    return [fixed, dawn];
  }
}

/// Motor de encenação de presentes (contrato v1).
///
/// Um único [AnimationController] (0..2: entrada 0→1, saída 1→2) guia
/// transição de entrada/saída, fundo e barras de cinema; só as camadas
/// animadas reconstroem a cada quadro — o conteúdo (vídeo/Lottie/imagem) é
/// criado uma vez e passado como `child`.
class GiftStage extends StatefulWidget {
  const GiftStage({
    super.key,
    required this.presentation,
    required this.builder,
    required this.onDone,
    this.holdMs,
  });

  final GiftPresentation presentation;
  final GiftStageContentBuilder builder;

  /// Tempo em cena entre entrada e saída. `null` = espera [GiftStageState.requestExit]
  /// (ex.: fim do vídeo VAP).
  final int? holdMs;

  /// Chamado uma única vez, ao fim da saída.
  final VoidCallback onDone;

  @override
  State<GiftStage> createState() => GiftStageState();
}

class GiftStageState extends State<GiftStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Timer? _holdTimer;
  Timer? _safety;
  bool _entered = false;
  bool _exiting = false;
  bool _exitRequested = false;
  bool _done = false;
  bool _focused = false;

  GiftPresentation get _pr => widget.presentation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 2,
    );
    if (_pr.layer == GiftLayer.overChat) {
      LiveStageFocus.enter();
      _focused = true;
    }
    _fireHaptic();
    final hold = widget.holdMs;
    if (hold != null) {
      _safety = Timer(
        Duration(
          milliseconds: _pr.enter.effectiveMs + hold + _pr.exit.effectiveMs + 3000,
        ),
        _finish,
      );
    }
    _ctrl
        .animateTo(1, duration: Duration(milliseconds: _pr.enter.effectiveMs))
        .then((_) => _onEntered());
  }

  void _fireHaptic() {
    try {
      switch (_pr.haptic) {
        case GiftHaptic.none:
          break;
        case GiftHaptic.light:
          HapticFeedback.lightImpact();
        case GiftHaptic.medium:
          HapticFeedback.mediumImpact();
        case GiftHaptic.heavy:
          HapticFeedback.heavyImpact();
      }
    } catch (_) {}
  }

  void _onEntered() {
    if (!mounted || _done) return;
    _entered = true;
    if (_exitRequested) {
      _startExit();
      return;
    }
    final hold = widget.holdMs;
    if (hold != null) {
      _holdTimer = Timer(Duration(milliseconds: hold), _startExit);
    }
  }

  /// Inicia a saída (idempotente). Se a entrada ainda corre, espera ela acabar.
  void requestExit() {
    if (_done || _exiting) return;
    _exitRequested = true;
    if (_entered) _startExit();
  }

  void _startExit() {
    if (_exiting || _done || !mounted) return;
    _exiting = true;
    _holdTimer?.cancel();
    _ctrl
        .animateTo(2, duration: Duration(milliseconds: _pr.exit.effectiveMs))
        .then((_) => _finish());
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _holdTimer?.cancel();
    _safety?.cancel();
    widget.onDone();
  }

  @override
  void dispose() {
    _done = true;
    _holdTimer?.cancel();
    _safety?.cancel();
    if (_focused) LiveStageFocus.leave();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pr = _pr;
    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    Widget area(double? dockTop) {
      // Limite inferior da área do presente (em Y global).
      var bottomLimit = screen.height;
      if (pr.layer == GiftLayer.underChat) {
        bottomLimit = dockTop != null
            ? dockTop - 6
            : screen.height * 0.55;
      }
      bottomLimit = bottomLimit.clamp(screen.height * 0.25, screen.height).toDouble();
      final areaSize = Size(screen.width, bottomLimit);
      final isFull = pr.position == GiftPosition.full;
      final side = isFull
          ? 0.0
          : (screen.width * pr.scale).clamp(0.0, 560.0).clamp(0.0, areaSize.height).toDouble();
      final contentSize = isFull ? areaSize : Size(side, side);

      final content = RepaintBoundary(
        child: SizedBox(
          width: contentSize.width,
          height: contentSize.height,
          child: widget.builder(context, contentSize),
        ),
      );

      final alignment = switch (pr.position) {
        GiftPosition.top => Alignment.topCenter,
        GiftPosition.bottom => Alignment.bottomCenter,
        _ => Alignment.center,
      };
      final edgePadding = pr.layer == GiftLayer.overChat
          ? EdgeInsets.only(
              top: padding.top + 56,
              bottom: padding.bottom + 24,
            )
          : EdgeInsets.only(top: padding.top + 56, bottom: 8);

      return Positioned(
        left: 0,
        top: 0,
        right: 0,
        height: bottomLimit,
        child: Padding(
          padding: isFull ? EdgeInsets.zero : edgePadding,
          child: Align(
            alignment: alignment,
            child: AnimatedBuilder(
              animation: _ctrl,
              child: content,
              builder: (_, child) {
                final f = GiftStageMath.giftFx(pr, _ctrl.value);
                if (f.opacity <= 0) return const SizedBox.shrink();
                return Opacity(
                  opacity: f.opacity,
                  child: Transform.translate(
                    offset: Offset(f.dx * areaSize.width, f.dy * areaSize.height),
                    child: Transform.scale(scale: f.scale, child: child),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    final needsBackdrop = pr.backdrop != GiftBackdrop.none ||
        pr.enter.type == GiftTransition.dawn ||
        pr.exit.type == GiftTransition.dawn;
    final needsBars = pr.enter.type == GiftTransition.curtain;

    final dockLayer = pr.layer == GiftLayer.underChat
        ? ValueListenableBuilder<double?>(
            valueListenable: LiveDockMetrics.top,
            builder: (_, dock, _) => Stack(
              fit: StackFit.expand,
              children: [area(dock)],
            ),
          )
        : Stack(fit: StackFit.expand, children: [area(null)]);

    return IgnorePointer(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          type: MaterialType.transparency,
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (needsBackdrop)
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, _) {
                      final c = GiftStageMath.backdrop(pr, _ctrl.value);
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ColoredBox(color: c[0]),
                          ColoredBox(color: c[1]),
                        ],
                      );
                    },
                  ),
                dockLayer,
                if (needsBars)
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, _) {
                      final h = GiftStageMath.curtainBars(pr, _ctrl.value) *
                          kCurtainBarFraction *
                          screen.height;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            height: h,
                            child: const ColoredBox(color: Colors.black),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: h,
                            child: const ColoredBox(color: Colors.black),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
