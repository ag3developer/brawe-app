// ignore_for_file: unused_element_parameter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/models/live_gift.dart';
import '../../../../live_feed/view_models/live_room_gifts_view_model.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../level_chip.dart';

/// Limiar (em créditos) acima do qual o presente vira "premium" —
/// dispara animação fullscreen com efeito de luz/blur.
const int _kPremiumThreshold = 100;

/// 🎁 Overlay de animações de presente.
///
/// - Presentes comuns: toast animado no canto inferior esquerdo (estilo TikTok).
/// - Presentes premium (value >= 100): burst fullscreen com efeito de luz.
class GiftAnimationOverlay extends ConsumerStatefulWidget {
  final String roomId;

  const GiftAnimationOverlay({super.key, required this.roomId});

  @override
  ConsumerState<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends ConsumerState<GiftAnimationOverlay> {
  // 🔒 Dedup por `transaction_id` (vem do backend, único por gift).
  // Antes usávamos `senderId::giftId::quantity` — e como rosa+rosa fora da
  // janela de combo voltavam ambos com `quantity=1`, a 2ª rosa era
  // descartada silenciosamente (bug "às vezes aparece, às vezes não").
  // Também limpamos o set quando passa do limite, para não vazar memória
  // numa live longa.
  static const int _kDedupCap = 300;
  final Set<String> _shownPremium = <String>{};
  final Set<String> _shownToast = <String>{};
  // ignore: unused_field
  final List<LiveGift> _activeToasts = [];

  void _rememberShown(Set<String> bag, String id) {
    bag.add(id);
    if (bag.length > _kDedupCap) {
      // FIFO trim — remove o(s) mais antigo(s) (Set mantém ordem de inserção).
      final overflow = bag.length - _kDedupCap;
      final toRemove = bag.take(overflow).toList(growable: false);
      bag.removeAll(toRemove);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<LiveGift>>(
      liveRoomGiftsViewModelProvider(widget.roomId),
      (prev, next) {
        for (final g in next) {
          final isPremium =
              g.quantity * (g.value > 0 ? g.value : 1) >= _kPremiumThreshold ||
                  g.value >= _kPremiumThreshold;

          // Chave única do gift (transaction_id). Em combos, o view-model
          // mantém o mesmo `id` e só incrementa `quantity` → não re-dispara
          // a animação (correto: TikTok-style, mostra 1x e fica visível).
          final dedupKey = g.id;

          if (isPremium) {
            if (_shownPremium.contains(dedupKey)) continue;
            _rememberShown(_shownPremium, dedupKey);
            _showPremiumBurst(g);
          } else {
            if (_shownToast.contains(dedupKey)) continue;
            _rememberShown(_shownToast, dedupKey);
            _showGiftToast(g);
          }
        }
      },
    );

    return const SizedBox.shrink();
  }

  void _showGiftToast(LiveGift gift) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _GiftToast(
        gift: gift,
        onDone: () {
          try { entry.remove(); } catch (_) {}
        },
      ),
    );
    overlay.insert(entry);
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
// Small gift toast (bottom-left, 3s)
// ────────────────────────────────────────────────────────────────────────

class _GiftToast extends StatefulWidget {
  const _GiftToast({required this.gift, required this.onDone});
  final LiveGift gift;
  final VoidCallback onDone;

  @override
  State<_GiftToast> createState() => _GiftToastState();
}

class _GiftToastState extends State<_GiftToast> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  /// `true` quando o toast deve aparecer no lado direito da tela (lado B
  /// da batalha). Calculado uma vez aqui pra os 2 animations + Positioned
  /// concordarem em direção (entra do mesmo lado em que ancora).
  bool get _isRightSide => widget.gift.battleSide == 'b';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    // 🎯 Entra deslizando do lado em que vai ancorar:
    //   - solo / lado A → entra da esquerda (-1.2 → 0)
    //   - lado B → entra da direita (+1.2 → 0)
    // Sem isso o toast do lado B faria "swoosh atravessando a tela",
    // chamando atenção em cima do streamer A — quebra a leitura.
    final beginOffset = _isRightSide
        ? const Offset(1.2, 0)
        : const Offset(-1.2, 0);
    _slide = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    ));
    _fade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );
    _ctrl.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _giftEmoji(String giftName) {
    final n = giftName.toLowerCase();
    if (n.contains('rose') || n.contains('rosa')) return '🌹';
    if (n.contains('heart') || n.contains('coração')) return '❤️';
    if (n.contains('star') || n.contains('estrela')) return '⭐';
    if (n.contains('fire') || n.contains('fogo')) return '🔥';
    if (n.contains('crown') || n.contains('coroa')) return '👑';
    if (n.contains('diamond') || n.contains('diamante')) return '💎';
    if (n.contains('kiss') || n.contains('beijo')) return '💋';
    if (n.contains('money') || n.contains('dinheiro')) return '💰';
    if (n.contains('unicorn') || n.contains('unicórnio')) return '🦄';
    if (n.contains('rocket') || n.contains('foguete')) return '🚀';
    if (n.contains('bomb') || n.contains('bomba')) return '💣';
    return '🎁';
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ OverlayEntry NÃO tem ancestor Material/Directionality por padrão.
    // Qualquer Text descendente ganha a "linha amarela double underline" do
    // default textStyle de erro do Flutter. Por isso embrulhamos o conteúdo
    // em Directionality + Material(transparency) + DefaultTextStyle DENTRO
    // do Positioned (o Positioned precisa ser filho direto do Overlay Stack).
    return Positioned(
      // ⬆️ Subimos para 220px (antes 200) para o toast NUNCA cobrir o
      // LiveActionBar do broadcaster (Pausar/Batalha/Co-host/Mais/Encerrar).
      // O action bar fica em bottom:16 + SafeArea + altura ~120 = ~180-200px,
      // então 220 garante folga.
      bottom: 220,
      // 🎯 TikTok-style PK: o toast ancora no lado do streamer que recebeu
      // o gift. Sem isso (live solo) cai no canto esquerdo histórico.
      // Em batalha lado B mirror pra direita; lado A mantém esquerda.
      left: _isRightSide ? null : 12,
      right: _isRightSide ? 12 : null,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          type: MaterialType.transparency,
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              decoration: TextDecoration.none,
              decorationColor: Colors.transparent,
              decorationThickness: 0,
            ),
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1) Avatar circular
                          _AvatarCircle(
                            url: widget.gift.senderAvatarUrl,
                            fallback: widget.gift.senderName,
                          ),
                          const SizedBox(width: 8),
                          // 2) Nome + chip de level + "enviou {gift}"
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Chip de nível (💎 Lv34) estilo TikTok
                                  LevelChip(
                                    level: widget.gift.gifterLevel,
                                    badge: widget.gift.gifterBadge,
                                    colorHex: widget.gift.gifterColor,
                                    imageUrl: widget.gift.gifterImageUrl,
                                  ),
                                  const SizedBox(width: 6),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 160),
                                    child: Text(
                                      widget.gift.senderName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'enviou ',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 11,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 120),
                                    child: Text(
                                      widget.gift.giftName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFFFFD166),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          // 3) Ícone do gift (à direita)
                          if (widget.gift.giftIconUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.gift.giftIconUrl!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Text(
                                  _giftEmoji(widget.gift.giftName),
                                  style: const TextStyle(fontSize: 28, decoration: TextDecoration.none),
                                ),
                              ),
                            )
                          else
                            Text(
                              _giftEmoji(widget.gift.giftName),
                              style: const TextStyle(fontSize: 28, decoration: TextDecoration.none),
                            ),
                          // 4) Multiplicador xN
                          if (widget.gift.quantity > 1) ...[
                            const SizedBox(width: 4),
                            Text(
                              'x${widget.gift.quantity}',
                              style: const TextStyle(
                                color: Color(0xFFFF4D8B),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
      // 🛡️ Wrap em Directionality + Material + DefaultTextStyle: OverlayEntry
      // não fornece ancestor Material/Directionality, então Text widgets sem
      // estilo explícito renderizam com `decoration: double-underline yellow`
      // (warning style) — exatamente as linhas amarelas que apareciam embaixo
      // do nome do presenteador.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          type: MaterialType.transparency,
          child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
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
        ),
      ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// TikTok-style helpers — avatar + level chip
// ────────────────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.url, required this.fallback});
  final String? url;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    const double size = 36;
    final initial = fallback.trim().isNotEmpty ? fallback.trim()[0].toUpperCase() : '?';
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4D8B), Color(0xFFFFD166)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          decoration: TextDecoration.none,
        ),
      ),
    );

    if (url == null || url!.trim().isEmpty) return placeholder;
    return ClipOval(
      child: Image.network(
        url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (ctx, child, p) => p == null ? child : placeholder,
      ),
    );
  }
}

// ignore: unused_element
class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level, this.badge, this.colorHex, this.imageUrl});
  final int level;
  final String? badge;
  final String? colorHex;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) =>
      LevelChip(level: level, badge: badge, colorHex: colorHex, imageUrl: imageUrl);
}
