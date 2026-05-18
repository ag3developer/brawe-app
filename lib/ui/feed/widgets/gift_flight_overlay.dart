// =============================================================================
// 🎁 GIFT FLIGHT OVERLAY — Brawe Pulse
// =============================================================================
// Animação curta (~1.4s) que faz um gift "voar" de um ponto de origem
// (centro da tela / botão de envio) até a posição do avatar do creator,
// com escala, rotação, glow electricPurple e fade out no final.
// =============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';

class GiftFlightOverlay {
  /// Mostra a animação. [endKey] aponta pro widget do avatar do creator;
  /// se for null ou inválido, o gift sobe pra ~30% top-left.
  static void play(
    BuildContext context, {
    required String label,
    String? emoji,
    String? iconUrl,
    int? quantity,
    GlobalKey? endKey,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final screen = MediaQuery.of(context).size;

    // Origem: bottom-center (acima da barra de reply)
    final Offset start = Offset(screen.width / 2, screen.height * 0.78);

    // Destino: posição do avatar (top-left header) ou fallback
    Offset end = Offset(screen.width * 0.18, screen.height * 0.10);
    if (endKey?.currentContext != null) {
      final box = endKey!.currentContext!.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final pos = box.localToGlobal(Offset.zero);
        end = pos + Offset(box.size.width / 2, box.size.height / 2);
      }
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _GiftFlight(
        start: start,
        end: end,
        label: label,
        emoji: emoji,
        iconUrl: iconUrl,
        quantity: quantity,
        onDone: () {
          entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _GiftFlight extends StatefulWidget {
  const _GiftFlight({
    required this.start,
    required this.end,
    required this.label,
    required this.onDone,
    this.emoji,
    this.iconUrl,
    this.quantity,
  });

  final Offset start;
  final Offset end;
  final String label;
  final String? emoji;
  final String? iconUrl;
  final int? quantity;
  final VoidCallback onDone;

  @override
  State<_GiftFlight> createState() => _GiftFlightState();
}

class _GiftFlightState extends State<_GiftFlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      });
    _t = CurvedAnimation(parent: _c, curve: Curves.easeInOutCubic);
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Curva em arco — usa bezier quadrática com ponto de controle pra cima.
  Offset _bezier(double t) {
    final s = widget.start;
    final e = widget.end;
    // Control point: meio do caminho, deslocado pra cima
    final ctrl = Offset(
      (s.dx + e.dx) / 2 + (e.dx - s.dx) * 0.15,
      math.min(s.dy, e.dy) - 80,
    );
    final x = math.pow(1 - t, 2) * s.dx +
        2 * (1 - t) * t * ctrl.dx +
        math.pow(t, 2) * e.dx;
    final y = math.pow(1 - t, 2) * s.dy +
        2 * (1 - t) * t * ctrl.dy +
        math.pow(t, 2) * e.dy;
    return Offset(x.toDouble(), y.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _t,
        builder: (_, _) {
          final t = _t.value;
          final pos = _bezier(t);

          // Escala: 0.6 → 1.4 (50%) → 0.5 (final)
          double scale;
          if (t < 0.5) {
            scale = 0.6 + (t * 2) * 0.8;
          } else {
            scale = 1.4 - ((t - 0.5) * 2) * 0.9;
          }

          // Opacity: fade-in rápido, fade-out final
          double opacity;
          if (t < 0.1) {
            opacity = t / 0.1;
          } else if (t > 0.85) {
            opacity = (1 - t) / 0.15;
          } else {
            opacity = 1;
          }

          final rotation = math.sin(t * math.pi * 2) * 0.18;

          return Stack(
            children: [
              Positioned(
                left: pos.dx - 36,
                top: pos.dy - 36,
                child: Opacity(
                  opacity: opacity.clamp(0, 1),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: scale,
                      child: _GiftBubble(
                        emoji: widget.emoji,
                        iconUrl: widget.iconUrl,
                        quantity: widget.quantity,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GiftBubble extends StatelessWidget {
  const _GiftBubble({this.emoji, this.iconUrl, this.quantity});
  final String? emoji;
  final String? iconUrl;
  final int? quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.electricPurple.withValues(alpha: 0.55),
            AppColors.electricPurple.withValues(alpha: 0.0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricPurple.withValues(alpha: 0.55),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (iconUrl != null && iconUrl!.isNotEmpty)
            SizedBox(
              width: 50,
              height: 50,
              child: Image.network(
                iconUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => _fallbackEmoji(),
              ),
            )
          else
            _fallbackEmoji(),
          if (quantity != null && quantity! > 1)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.coolCyan,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coolCyan.withValues(alpha: 0.55),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  'x$quantity',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallbackEmoji() {
    return Text(
      (emoji != null && emoji!.isNotEmpty) ? emoji! : '��',
      style: const TextStyle(fontSize: 38),
    );
  }
}
