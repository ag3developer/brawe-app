import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/services/feedback_service.dart';
import '../../../../domain/models/conversation.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../../data/services/gift_effect_cache.dart';
import '../../../../domain/models/live_gift.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../../live/shared/widgets/overlays/gift_animation_overlay.dart';
import '../../../live_feed/view_models/gift_catalog_view_model.dart';

/// Bolhas "ricas" do chat: interação com story, cofre de presente,
/// localização e arquivo. O conteúdo vem em `message.payload` (JSON).

// ─────────────────────────────────────────────────────────────────────────────
// Encaminhada

class ForwardedLabel extends StatelessWidget {
  const ForwardedLabel({super.key, required this.isMe});
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final c = isMe ? Colors.white70 : context.colors.textTertiary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.forward, size: 12, color: c),
          const SizedBox(width: 4),
          Text(
            S.of(context).chatForwarded,
            style: TextStyle(
              color: c,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reação / resposta a story

class StoryInteractionBubble extends StatelessWidget {
  const StoryInteractionBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = message.payload ?? const {};
    final isReply = message.messageType == 'story_reply';
    final media = p['story_media_url']?.toString();
    final expires = DateTime.tryParse(p['story_expires_at']?.toString() ?? '');
    final expired = expires != null && expires.isBefore(DateTime.now());
    final fg = isMe ? Colors.white : context.colors.textPrimary;
    final sub = isMe ? Colors.white70 : context.colors.textSecondary;

    final label = isReply
        ? (isMe ? s.chatStoryRepliedMine : s.chatStoryReplied)
        : (isMe ? s.chatStoryReactedMine : s.chatStoryReacted);

    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 64,
        height: 100,
        child: (media == null || media.isEmpty || expired)
            ? Container(
                color: Colors.black26,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                child: Text(
                  s.chatStoryUnavailable,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: sub, fontSize: 9.5),
                ),
              )
            : CachedNetworkImage(
                imageUrl: media,
                fit: BoxFit.cover,
                memCacheWidth: 192,
                errorWidget: (_, _, _) => Container(color: Colors.black26),
              ),
      ),
    );

    final emoji = p['emoji']?.toString() ?? '❤️';
    final text = p['text']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: sub, fontSize: 11.5)),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            thumb,
            const SizedBox(width: 10),
            Flexible(
              child: isReply
                  ? Text(
                      text,
                      style: TextStyle(color: fg, fontSize: 14, height: 1.3),
                    )
                  : Text(emoji, style: const TextStyle(fontSize: 40)),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cofre (presente recebido no story)

Color vaultTierColor(String? tier) => switch (tier) {
  'legendary' => const Color(0xFFF59E0B),
  'epic' => const Color(0xFFA855F7),
  'rare' => const Color(0xFF3B82F6),
  _ => const Color(0xFF94A3B8),
};

String vaultTierName(S s, String? tier) => switch (tier) {
  'legendary' => s.chatVaultTierLegendary,
  'epic' => s.chatVaultTierEpic,
  'rare' => s.chatVaultTierRare,
  _ => s.chatVaultTierCommon,
};

/// Desenho do cofre (porta redonda com segredo e travas), na cor da raridade.
class VaultArt extends StatelessWidget {
  const VaultArt({
    super.key,
    required this.size,
    required this.tint,
    this.dialTurns = 0,
    this.doorOpen = 0,
  });

  final double size;
  final Color tint;

  /// Giro do segredo (em voltas).
  final double dialTurns;

  /// 0 = fechado … 1 = porta aberta.
  final double doorOpen;

  @override
  Widget build(BuildContext context) {
    final steelHi = Color.lerp(const Color(0xFFE5E7EB), tint, 0.25)!;
    final steel = Color.lerp(const Color(0xFF6B7280), tint, 0.35)!;
    final steelLo = Color.lerp(const Color(0xFF1F2937), tint, 0.25)!;

    Widget bolt(Alignment a) => Align(
      alignment: a,
      child: Container(
        width: size * 0.07,
        height: size * 0.07,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [steelHi, steelLo]),
        ),
      ),
    );

    final door = Container(
      width: size * 0.7,
      height: size * 0.7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [steelHi, steel, steelLo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: steelLo, width: size * 0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: size * 0.06,
            offset: Offset(0, size * 0.02),
          ),
        ],
      ),
      child: Center(
        child: Transform.rotate(
          angle: dialTurns * 2 * math.pi,
          child: SizedBox(
            width: size * 0.42,
            height: size * 0.42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (var i = 0; i < 6; i++)
                  Transform.rotate(
                    angle: i * math.pi / 3,
                    child: Container(
                      width: size * 0.05,
                      height: size * 0.42,
                      decoration: BoxDecoration(
                        color: steelLo,
                        borderRadius: BorderRadius.circular(size * 0.03),
                      ),
                    ),
                  ),
                Container(
                  width: size * 0.18,
                  height: size * 0.18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [tint, steelLo]),
                    border: Border.all(color: steelHi, width: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.18),
          gradient: LinearGradient(
            colors: [steel, steelLo],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: steelHi.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: tint.withValues(alpha: 0.45),
              blurRadius: size * 0.2,
            ),
          ],
        ),
        child: Stack(
          children: [
            bolt(const Alignment(-0.82, -0.82)),
            bolt(const Alignment(0.82, -0.82)),
            bolt(const Alignment(-0.82, 0.82)),
            bolt(const Alignment(0.82, 0.82)),
            Center(
              child: Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateY(-doorOpen * 1.7),
                child: door,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Busca o presente no catálogo (animação, tipo, som, tela cheia) e monta
/// um [LiveGift] para tocar o MESMO efeito da live. `null` = sem efeito.
Future<LiveGift?> vaultGiftEffect(WidgetRef ref, Map<String, dynamic> p) async {
  String? animUrl = p['animation_url']?.toString();
  String? animType = p['animation_type']?.toString();
  String? soundUrl;
  var fullscreen = false;
  var durationMs = 0;
  String? icon = p['gift_image_url']?.toString();
  try {
    final tiers = await ref.read(giftCatalogViewModelProvider.future);
    final id = p['gift_id']?.toString();
    final slug = p['gift_slug']?.toString();
    for (final t in tiers) {
      for (final g in t.gifts) {
        if (g.id == id || (slug != null && g.slug == slug)) {
          animUrl = g.animationUrl ?? animUrl;
          animType = g.animationType;
          soundUrl = g.soundUrl;
          fullscreen = g.isFullscreen;
          durationMs = g.animationDurationMs;
          icon ??= g.iconUrl;
        }
      }
    }
  } catch (_) {}
  if (animUrl == null || animUrl.isEmpty) return null;
  // Sem tipo do catálogo: deduz pela extensão.
  if (animType == null || (animType != 'vap' && animType != 'lottie')) {
    final u = animUrl.toLowerCase();
    animType = u.endsWith('.mp4')
        ? 'vap'
        : (u.endsWith('.json') || u.endsWith('.lottie') ? 'lottie' : animType);
  }
  if (animType != 'vap' && animType != 'lottie') return null;
  return LiveGift(
    id: 'vault-${DateTime.now().microsecondsSinceEpoch}',
    senderId: '',
    senderName: '',
    giftId: p['gift_id']?.toString() ?? '',
    giftName: p['gift_name']?.toString() ?? '',
    giftSlug: p['gift_slug']?.toString(),
    giftIconUrl: icon,
    animationUrl: animUrl,
    animationType: animType,
    isFullscreen: fullscreen || animType == 'vap',
    quantity: (p['quantity'] as num?)?.toInt() ?? 1,
    timestamp: DateTime.now(),
    soundEnabled: true,
    soundUrl: soundUrl,
    animationDurationMs: durationMs > 0 ? durationMs : null,
  );
}

/// Imagem do presente (URL) ou emoji.
class _GiftImage extends StatelessWidget {
  const _GiftImage({required this.payload, required this.size});
  final Map<String, dynamic> payload;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = payload['gift_image_url']?.toString();
    final emoji = payload['gift_emoji']?.toString();
    final fallback = Text(
      (emoji == null || emoji.isEmpty) ? '🎁' : emoji,
      style: TextStyle(fontSize: size * 0.8),
    );
    if (url == null || url.isEmpty) return fallback;
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorWidget: (_, _, _) => fallback,
    );
  }
}

class GiftVaultBubble extends ConsumerStatefulWidget {
  const GiftVaultBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onOpen,
  });

  final ChatMessage message;
  final bool isMe;

  /// Chama o servidor para abrir; devolve a mensagem atualizada (ou null).
  final Future<ChatMessage?> Function() onOpen;

  @override
  ConsumerState<GiftVaultBubble> createState() => _GiftVaultBubbleState();
}

class _GiftVaultBubbleState extends ConsumerState<GiftVaultBubble> {
  bool _loadingFx = false;

  ChatMessage get message => widget.message;
  bool get isMe => widget.isMe;
  Future<ChatMessage?> Function() get onOpen => widget.onOpen;

  @override
  void initState() {
    super.initState();
    // Baixa o efeito já: abrir o cofre não espera o download.
    final p = widget.message.payload;
    if (p != null) {
      vaultGiftEffect(ref, p).then((g) {
        final url = g?.animationUrl;
        if (url != null) GiftEffectCache.instance.fetch(url);
      });
    }
  }

  Future<void> _replay(Map<String, dynamic> p) async {
    if (_loadingFx) return;
    HapticFeedback.selectionClick();
    setState(() => _loadingFx = true);
    try {
      final g = await vaultGiftEffect(ref, p);
      var played = false;
      if (g != null && mounted) {
        played = await playGiftEffectStandalone(context, g);
      }
      // Sem efeito (ou não tocou): animação de reserva com o presente.
      if (!played && mounted) await showGiftPop(context, p);
    } finally {
      if (mounted) setState(() => _loadingFx = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = message.payload ?? const {};
    final opened = p['opened'] == true;
    final tier = p['tier']?.toString();
    final tint = vaultTierColor(tier);
    final fg = isMe ? Colors.white : context.colors.textPrimary;
    final sub = isMe ? Colors.white70 : context.colors.textSecondary;
    final giftName = p['gift_name']?.toString() ?? '';
    final qty = (p['quantity'] as num?)?.toInt() ?? 1;

    final String title;
    final String subtitle;
    if (isMe) {
      title = s.chatVaultSentMine;
      subtitle = opened ? s.chatVaultOpenedBy : s.chatVaultWaiting;
    } else if (opened) {
      title = qty > 1 ? '$giftName ×$qty' : giftName;
      subtitle = s.chatVaultOpenedBy;
    } else {
      title = s.chatVaultReceived;
      subtitle = s.chatVaultTapToOpen;
    }

    final canOpen = !isMe && !opened && !message.isPending;
    // Já aberto: tocar repete o efeito do presente.
    final canReplay = opened && !message.isPending;

    Widget art = opened && !isMe
        ? SizedBox(
            width: 64,
            height: 64,
            child: Center(child: _GiftImage(payload: p, size: 54)),
          )
        : VaultArt(size: 64, tint: tint, doorOpen: opened ? 0.6 : 0);
    if (canOpen) art = _Wiggle(child: art);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canOpen
          ? () => showVaultReveal(context, payload: p, onOpen: onOpen)
          : canReplay
          ? () => _replay(p)
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          art,
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: isMe ? 0.35 : 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vaultTierName(s, tier).toUpperCase(),
                    style: TextStyle(
                      color: isMe ? Colors.white : tint,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(subtitle, style: TextStyle(color: sub, fontSize: 12)),
                if (canReplay)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _loadingFx
                            ? SizedBox(
                                width: 11,
                                height: 11,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.6,
                                  color: isMe ? Colors.white : tint,
                                ),
                              )
                            : Icon(
                                LucideIcons.rotateCcw,
                                size: 12,
                                color: isMe ? Colors.white : tint,
                              ),
                        const SizedBox(width: 4),
                        Text(
                          s.chatVaultReplay,
                          style: TextStyle(
                            color: isMe ? Colors.white : tint,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Balança de leve, chamando para tocar.
class _Wiggle extends StatefulWidget {
  const _Wiggle({required this.child});
  final Widget child;
  @override
  State<_Wiggle> createState() => _WiggleState();
}

class _WiggleState extends State<_Wiggle> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
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
      builder: (_, child) {
        // Balança só nos primeiros 30% do ciclo.
        final t = _c.value;
        final a = t < 0.3 ? math.sin(t / 0.3 * math.pi * 4) * 0.08 : 0.0;
        return Transform.rotate(angle: a, child: child);
      },
      child: widget.child,
    );
  }
}

/// Tela cheia de revelação: toque no cofre → treme → gira o segredo →
/// porta abre com luz e confete → mostra o presente e quanto entrou nas
/// recompensas de criador.
Future<void> showVaultReveal(
  BuildContext context, {
  required Map<String, dynamic> payload,
  required Future<ChatMessage?> Function() onOpen,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, _, _) => _VaultReveal(payload: payload, onOpen: onOpen),
    transitionBuilder: (_, a, _, child) =>
        FadeTransition(opacity: a, child: child),
  );
}

class _VaultReveal extends ConsumerStatefulWidget {
  const _VaultReveal({required this.payload, required this.onOpen});
  final Map<String, dynamic> payload;
  final Future<ChatMessage?> Function() onOpen;

  @override
  ConsumerState<_VaultReveal> createState() => _VaultRevealState();
}

enum _Phase { idle, unlocking, revealed }

class _VaultRevealState extends ConsumerState<_VaultReveal>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.idle;

  /// Efeito do presente tocando: esconde o cofre para o efeito aparecer
  /// limpo por cima.
  bool _playingEffect = false;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final AnimationController _unlock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _shake.dispose();
    _unlock.dispose();
    _burst.dispose();
    _idle.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_phase != _Phase.idle) return;
    setState(() => _phase = _Phase.unlocking);
    final fb = ref.read(feedbackServiceProvider);
    HapticFeedback.mediumImpact();
    fb.questTap();
    // Servidor, efeito do presente e animação do cofre em paralelo.
    final server = widget.onOpen();
    final effect = vaultGiftEffect(ref, widget.payload);
    await _shake.forward(from: 0);
    HapticFeedback.heavyImpact();
    final unlocking = _unlock.forward(from: 0);
    final result = await server;
    await unlocking;
    if (!mounted) return;
    if (result == null) {
      Navigator.of(context).pop();
      return;
    }
    // Porta aberta: toca o efeito real do presente (VAP em tela cheia ou
    // Lottie no centro), igual à live. Depois mostra o que ganhou.
    final gift = await effect;
    if (gift != null && mounted) {
      setState(() => _playingEffect = true);
      await playGiftEffectStandalone(context, gift);
      if (!mounted) return;
      _playingEffect = false;
    }
    HapticFeedback.heavyImpact();
    fb.questBadge();
    setState(() => _phase = _Phase.revealed);
    _burst.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = widget.payload;
    final tier = p['tier']?.toString();
    final tint = vaultTierColor(tier);
    final giftName = p['gift_name']?.toString() ?? '';
    final qty = (p['quantity'] as num?)?.toInt() ?? 1;
    final earnings = (p['earnings_usdt'] as num?)?.toDouble() ?? 0;
    final money = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
      name: 'USD',
    ).format(earnings);

    return Material(
      color: Colors.transparent,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _playingEffect ? 0 : 1,
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Raios de luz girando atrás (aparecem ao abrir).
              AnimatedBuilder(
                animation: Listenable.merge([_unlock, _burst]),
                builder: (_, _) {
                  final o = _phase == _Phase.revealed
                      ? 1.0
                      : (_unlock.value - 0.6).clamp(0.0, 0.4) / 0.4;
                  return Opacity(
                    opacity: o,
                    child: Transform.rotate(
                      angle: _burst.value * math.pi / 2,
                      child: CustomPaint(
                        size: const Size(420, 420),
                        painter: _RaysPainter(tint),
                      ),
                    ),
                  );
                },
              ),
              if (_phase == _Phase.revealed)
                IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _burst,
                    builder: (_, _) => CustomPaint(
                      size: MediaQuery.sizeOf(context),
                      painter: _ConfettiPainter(_burst.value, tint),
                    ),
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tint.withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      vaultTierName(s, tier).toUpperCase(),
                      style: TextStyle(
                        color: tint,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: _phase == _Phase.revealed
                        ? AnimatedBuilder(
                            animation: _burst,
                            builder: (_, _) {
                              final t = Curves.elasticOut.transform(
                                (_burst.value * 2.2).clamp(0, 1),
                              );
                              return Transform.scale(
                                scale: 0.3 + 0.7 * t,
                                child: Center(
                                  child: _GiftImage(payload: p, size: 170),
                                ),
                              );
                            },
                          )
                        : GestureDetector(
                            onTap: _start,
                            child: AnimatedBuilder(
                              animation: Listenable.merge([
                                _shake,
                                _unlock,
                                _idle,
                              ]),
                              builder: (_, _) {
                                final shake =
                                    math.sin(_shake.value * math.pi * 8) *
                                    (1 - _shake.value) *
                                    0.12;
                                final breathe = _phase == _Phase.idle
                                    ? 1 + _idle.value * 0.04
                                    : 1.0;
                                final dial = Curves.easeInOut.transform(
                                  (_unlock.value / 0.6).clamp(0, 1),
                                );
                                final door = Curves.easeOutBack.transform(
                                  ((_unlock.value - 0.6) / 0.4).clamp(0, 1),
                                );
                                return Transform.rotate(
                                  angle: shake,
                                  child: Transform.scale(
                                    scale: breathe,
                                    child: VaultArt(
                                      size: 200,
                                      tint: tint,
                                      dialTurns: dial * 1.5,
                                      doorOpen: door,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _phase == _Phase.revealed
                        ? Column(
                            key: const ValueKey('rev'),
                            children: [
                              Text(
                                s.chatVaultYouGot,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                qty > 1 ? '$giftName ×$qty' : giftName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (earnings > 0) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    s.chatVaultEarnings(money),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 28),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (earnings > 0) ...[
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: Colors.white38,
                                        ),
                                        shape: const StadiumBorder(),
                                      ),
                                      onPressed: () {
                                        final router = GoRouter.of(context);
                                        Navigator.of(context).pop();
                                        router.push('/earnings');
                                      },
                                      child: Text(s.chatVaultSeeRewards),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: tint,
                                      foregroundColor: Colors.white,
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(s.chatVaultCollect),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Text(
                            key: const ValueKey('hint'),
                            _phase == _Phase.idle ? s.chatVaultTapHint : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ],
              ),
              if (_phase == _Phase.idle)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  _RaysPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + r * math.cos(a - 0.12), c.dy + r * math.sin(a - 0.12))
        ..lineTo(c.dx + r * math.cos(a + 0.12), c.dy + r * math.sin(a + 0.12))
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RaysPainter old) => old.color != color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t, this.tint);
  final double t;
  final Color tint;

  static final _rnd = List.generate(60, (i) {
    final r = math.Random(i * 7919);
    return (r.nextDouble(), r.nextDouble(), r.nextDouble(), r.nextInt(5));
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      tint,
      const Color(0xFFFFD166),
      const Color(0xFF34D399),
      const Color(0xFF60A5FA),
      const Color(0xFFF472B6),
    ];
    final c = Offset(size.width / 2, size.height * 0.42);
    for (final (a, sp, rot, ci) in _rnd) {
      final angle = a * 2 * math.pi;
      final dist = (120 + sp * 260) * Curves.easeOut.transform(t);
      final fall = t * t * 260;
      final pos =
          c + Offset(math.cos(angle) * dist, math.sin(angle) * dist + fall);
      final paint = Paint()
        ..color = colors[ci].withValues(alpha: (1 - t).clamp(0, 1));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(rot * 6 + t * 10);
      canvas.drawRect(const Rect.fromLTWH(-4, -2, 8, 4), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Localização

class LocationBubble extends StatelessWidget {
  const LocationBubble({super.key, required this.message, required this.isMe});
  final ChatMessage message;
  final bool isMe;

  Future<void> _open() async {
    final p = message.payload ?? const {};
    final lat = (p['lat'] as num?)?.toDouble();
    final lng = (p['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return;
    final uri = Platform.isIOS
        ? Uri.parse('https://maps.apple.com/?ll=$lat,$lng&q=$lat,$lng')
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
          );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = message.payload ?? const {};
    final name = p['name']?.toString();
    final lat = (p['lat'] as num?)?.toDouble();
    final lng = (p['lng'] as num?)?.toDouble();
    final fg = isMe ? Colors.white : context.colors.textPrimary;
    final sub = isMe ? Colors.white70 : context.colors.textSecondary;

    return GestureDetector(
      onTap: message.isPending ? null : _open,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Mapa" estilizado (sem SDK de mapas).
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 220,
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD1FAE5), Color(0xFFBFDBFE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  CustomPaint(painter: _MapGridPainter()),
                  const Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 40,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  if (message.isPending)
                    const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            (name == null || name.isEmpty) ? s.chatLocationTitle : name,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          if (lat != null && lng != null)
            Text(
              '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
              style: TextStyle(color: sub, fontSize: 11.5),
            ),
          const SizedBox(height: 2),
          Text(
            s.chatLocationOpen,
            style: TextStyle(
              color: isMe ? Colors.white : context.colors.accentPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 5;
    final minor = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, size.height * 0.62),
      Offset(size.width, size.height * 0.38),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.42, size.height),
      road,
    );
    for (var x = 0.0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x + 12, size.height), minor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Arquivo

class FileBubble extends StatelessWidget {
  const FileBubble({super.key, required this.message, required this.isMe});
  final ChatMessage message;
  final bool isMe;

  static String _size(num? bytes) {
    if (bytes == null || bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = message.payload ?? const {};
    final name = p['name']?.toString() ?? 'arquivo';
    final url = p['url']?.toString() ?? '';
    final ext = name.contains('.') ? name.split('.').last.toUpperCase() : '';
    final fg = isMe ? Colors.white : context.colors.textPrimary;
    final sub = isMe ? Colors.white70 : context.colors.textSecondary;
    final color = switch (ext) {
      'PDF' => const Color(0xFFEF4444),
      'DOC' || 'DOCX' => const Color(0xFF3B82F6),
      'XLS' || 'XLSX' || 'CSV' => const Color(0xFF10B981),
      'PPT' || 'PPTX' => const Color(0xFFF97316),
      'ZIP' || 'RAR' => const Color(0xFF8B5CF6),
      _ => const Color(0xFF64748B),
    };
    final info = [
      ext,
      _size(p['size'] as num?),
    ].where((e) => e.isNotEmpty).join(' · ');

    return GestureDetector(
      onTap: (url.isEmpty || message.isPending)
          ? null
          : () =>
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: message.isPending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    ext.isEmpty
                        ? '•'
                        : (ext.length > 4 ? ext.substring(0, 4) : ext),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info.isEmpty ? s.chatFileOpen : '$info · ${s.chatFileOpen}',
                  style: TextStyle(color: sub, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/// Animação de reserva: o presente "salta" no centro com raios e brilho.
/// Usada quando o presente não tem efeito ou o efeito não pôde tocar.
Future<void> showGiftPop(BuildContext context, Map<String, dynamic> p) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'gift',
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, _, _) => _GiftPop(payload: p),
  );
}

class _GiftPop extends StatefulWidget {
  const _GiftPop({required this.payload});
  final Map<String, dynamic> payload;
  @override
  State<_GiftPop> createState() => _GiftPopState();
}

class _GiftPopState extends State<_GiftPop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..forward().whenComplete(() {
      if (mounted) Navigator.of(context).maybePop();
    });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tint = vaultTierColor(widget.payload['tier']?.toString());
    final name = widget.payload['gift_name']?.toString() ?? '';
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) {
            final t = _c.value;
            final pop = Curves.elasticOut.transform((t * 2).clamp(0, 1));
            final fade = t > 0.8 ? (1 - (t - 0.8) / 0.2) : 1.0;
            return Opacity(
              opacity: fade.clamp(0, 1),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: t * math.pi / 3,
                    child: CustomPaint(
                      size: const Size(380, 380),
                      painter: _RaysPainter(tint),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: 0.2 + 0.8 * pop,
                        child: _GiftImage(payload: widget.payload, size: 180),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
