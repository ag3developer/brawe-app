import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/live_gift.dart';
import '../view_models/live_room_gifts_view_model.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Limiar (em créditos) acima do qual o presente vira "premium" —
/// dispara animação fullscreen com efeito de luz/blur.
const int _kPremiumThreshold = 100;

/// 🎁 Overlay de animações de presente — apenas premium burst fullscreen.
///
/// Os combos comuns agora são renderizados inline no ticker de chat
/// (estilo TikTok), no [_ChatTicker] de `live_player_screen.dart`.
/// Aqui só permanece o efeito fullscreen disparado quando chega um
/// presente premium (`value >= 100`).
class GiftAnimationOverlay extends ConsumerStatefulWidget {
  final String roomId;

  const GiftAnimationOverlay({super.key, required this.roomId});

  @override
  ConsumerState<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends ConsumerState<GiftAnimationOverlay> {
  final Set<String> _shownPremium = {};

  @override
  Widget build(BuildContext context) {
    ref.listen<List<LiveGift>>(
      liveRoomGiftsViewModelProvider(widget.roomId),
      (prev, next) {
        // Detecta novos combos premium (cruzaram o threshold após combo).
        for (final g in next) {
          if (g.quantity * (g.value > 0 ? g.value : 1) >= _kPremiumThreshold ||
              g.value >= _kPremiumThreshold) {
            final key = '${g.senderId}::${g.giftId}::${g.quantity}';
            if (_shownPremium.contains(key)) continue;
            _shownPremium.add(key);
            _showPremiumBurst(g);
          }
        }
      },
    );

    final gifts = ref.watch(liveRoomGiftsViewModelProvider(widget.roomId));
    if (gifts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Combos comuns são renderizados no chat ticker (estilo TikTok).
    // Aqui só observamos a lista para disparar o premium burst quando aplicável.
    return const SizedBox.shrink();
  }

  void _showPremiumBurst(LiveGift gift) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _PremiumGiftBurst(
        gift: gift,
        onDone: () {
          try {
            entry.remove();
          } catch (_) {}
        },
      ),
    );
    overlay.insert(entry);
  }
}

// ────────────────────────────────────────────────────────────────────────
// Premium burst (fullscreen, ~2.5s)
// ────────────────────────────────────────────────────────────────────────

class _PremiumGiftBurst extends StatefulWidget {
  const _PremiumGiftBurst({required this.gift, required this.onDone});
  final LiveGift gift;
  final VoidCallback onDone;

  @override
  State<_PremiumGiftBurst> createState() => _PremiumGiftBurstState();
}

class _PremiumGiftBurstState extends State<_PremiumGiftBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          // Phase 1 (0..0.5) — light beam expands + icon scales up
          // Phase 2 (0.5..0.85) — hold
          // Phase 3 (0.85..1) — fade out
          final opacity = t < 0.15
              ? (t / 0.15)
              : t > 0.85
                  ? ((1 - t) / 0.15).clamp(0.0, 1.0)
                  : 1.0;
          final scale = t < 0.4
              ? Curves.elasticOut.transform((t / 0.4).clamp(0.0, 1.0))
              : 1.0;
          final beam = (t < 0.7 ? (t / 0.7) : 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              // Backdrop dimmer (subtle)
              Opacity(
                opacity: opacity * 0.45,
                child: Container(color: Colors.black),
              ),
              // Radial light beam
              Center(
                child: Opacity(
                  opacity: opacity * 0.85,
                  child: Container(
                    width: 600 * beam,
                    height: 600 * beam,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFFFFE08A),
                          Color(0x66FF4D8B),
                          Color(0x00000000),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              // Center icon + label
              Center(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD166), Color(0xFFFF4D8B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.6),
                                blurRadius: 60,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: widget.gift.giftIconUrl != null
                              ? Image.network(
                                  widget.gift.giftIconUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.workspace_premium,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.workspace_premium,
                                  size: 100,
                                  color: Colors.white,
                                ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: const Color(0xFFFFD166), width: 1.5),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: widget.gift.senderName,
                                  style: const TextStyle(
                                    color: Color(0xFFFFD166),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: s.livePlayerGiftSentVerb.trim(),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: widget.gift.giftName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (widget.gift.quantity > 1)
                                  TextSpan(
                                    text: ' x${widget.gift.quantity}',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD166),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
