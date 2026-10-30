import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../../domain/models/live_gift.dart';
import '../../../../../domain/models/gift_display_type.dart';
import '../../../../live_feed/view_models/live_room_gifts_view_model.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../level_chip.dart';
import '../../../../core/themes/app_colors.dart';

/// 🧪 TESTE (Fase de validação Lottie): slugs que têm asset Lottie local
/// disponível em `assets/lottie_test/<slug>.json`. Fora desta lista, o
/// comportamento é IDENTICO ao anterior (Image.network do ícone PNG).
/// Isolado de propósito para não afetar nenhum outro presente existente.
const Map<String, String> _kLottieTestAssets = {
  'star': 'assets/lottie_test/estrela.json',
};

/// 🖼️ Mapa slug → tier, usado para localizar o PNG local em
/// `assets/images/gifts/<tier>/<slug>.png` (mesmo pacote de assets já
/// usado pela sacola de presentes em `GiftsOverlay`/`_GiftIcon`).
///
/// IMPORTANTE: o `icon_url` que vem do backend (`cdn.brawe.io/gifts/v1/...`)
/// atualmente retorna 404 — nenhum ícone de gift foi publicado no R2/DO
/// Spaces ainda. Por isso os PNGs locais são a fonte PRIMÁRIA e confiável;
/// a URL remota fica como fallback secundário (pra quando o CDN for
/// populado no futuro, sem precisar mudar código).
const Map<String, String> _kGiftSlugTier = {
  // FREE
  'clap': 'free', 'fire': 'free', 'heart': 'free',
  // BASIC
  'rose': 'basic', 'star': 'basic', 'kiss': 'basic', 'butterfly': 'basic',
  'headphones': 'basic', 'moon': 'basic', 'microphone': 'basic',
  'diamond': 'basic',
  // PREMIUM
  'energy': 'premium', 'rocket': 'premium', 'gamepad': 'premium',
  'mini-crown': 'premium', 'bear': 'premium', 'galaxy': 'premium',
  'coin-rain': 'premium',
  // LUXURY
  'crown': 'luxury', 'sports-car': 'luxury', 'yacht': 'luxury',
  'private-jet': 'luxury', 'titan': 'luxury', 'tsunami': 'luxury',
  // LEGENDARY
  'castle': 'legendary', 'dragon': 'legendary', 'lion': 'legendary',
  'phoenix': 'legendary', 'supernova': 'legendary', 'universe': 'legendary',
};

/// Widget central que decide o visual do gift, em ordem de prioridade:
/// 1. Lottie local (se o slug estiver mapeado em [_kLottieTestAssets])
/// 2. PNG local do asset pack (`assets/images/gifts/<tier>/<slug>.png`) —
///    fonte PRIMÁRIA confiável, já empacotada no app
/// 3. `Image.network` do `icon_url` remoto (CDN) — fallback secundário
/// 4. Emoji/ícone genérico — fallback final
class _GiftVisual extends StatelessWidget {
  const _GiftVisual({
    required this.gift,
    required this.size,
    this.fallbackIcon,
  });

  final LiveGift gift;
  final double size;
  final Widget? fallbackIcon;

  /// 🚫 SVGA não é suportado na arquitetura da Brawe (ver
  /// SVGA_NOT_SUPPORTED.md). Se `animationType == "svga"` (ou qualquer
  /// formato não-Lottie), NUNCA tentamos carregar um player — pulamos
  /// direto para a cadeia de fallback estático (PNG local → PNG remoto →
  /// emoji). Isso é intencional e definitivo, não um "TODO".
  bool get _isUnsupportedAnimationFormat {
    final type = gift.animationType?.toLowerCase();
    return type == 'svga' || type == 'video' || type == 'particle';
  }

  @override
  Widget build(BuildContext context) {
    final slug = gift.giftSlug;
    final lottiePath = slug != null ? _kLottieTestAssets[slug] : null;

    // Lottie local de teste tem prioridade absoluta (independe do
    // animationType vindo do backend — é um asset já embutido no app).
    if (lottiePath != null) {
      return Lottie.asset(
        lottiePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        repeat: false,
        errorBuilder: (_, __, ___) => _networkOrFallback(),
      );
    }

    // 🚫 Formato incompatível (SVGA/VIDEO/PARTICLE) — NUNCA tenta nenhum
    // player para esses formatos. O PNG local por tier ainda é tentado
    // normalmente aqui embaixo (é um asset estático independente do
    // `animationType`), então esse gift ainda mostra corretamente sua
    // imagem — só a "animação" em si é que nunca é reproduzida.
    if (_isUnsupportedAnimationFormat) {
      // Log sanitizado (sem dados sensíveis) — ajuda a identificar
      // presentes que precisam ser migrados para LOTTIE no catálogo.
      debugPrint(
        '⚠️ [GIFT-FORMAT] slug=$slug tem animation_type incompatível '
        '(${gift.animationType}) — usando fallback estático. '
        'Ver SVGA_NOT_SUPPORTED.md.',
      );
    }

    final tier = slug != null ? _kGiftSlugTier[slug] : null;
    if (tier != null) {
      return Image.asset(
        'assets/images/gifts/$tier/$slug.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _networkOrFallback(),
      );
    }

    return _networkOrFallback();
  }

  Widget _networkOrFallback() {
    if (gift.giftIconUrl != null) {
      return Image.network(
        gift.giftIconUrl!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _iconFallback(),
      );
    }
    return _iconFallback();
  }

  Widget _iconFallback() =>
      fallbackIcon ?? const Icon(Icons.workspace_premium, color: Colors.white);
}

/// 🎁 Overlay de animações de presente.
///
/// - Presentes comuns: toast animado no canto inferior esquerdo (estilo TikTok).
/// - Presentes premium (value >= 100): burst fullscreen com efeito de luz.
class GiftAnimationOverlay extends ConsumerStatefulWidget {
  final String roomId;

  const GiftAnimationOverlay({super.key, required this.roomId});

  @override
  ConsumerState<GiftAnimationOverlay> createState() =>
      _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends ConsumerState<GiftAnimationOverlay> {
  // 🔒 Dedup por `transaction_id` (vem do backend, único por gift).
  // Antes usávamos `senderId::giftId::quantity` — e como rosa+rosa fora da
  // janela de combo voltavam ambos com `quantity=1`, a 2ª rosa era
  // descartada silenciosamente (bug "às vezes aparece, às vezes não").
  // Também limpamos o set quando passa do limite, para não vazar memória
  // numa live longa.
  static const int _kDedupCap = 300;
  final Set<String> _shownVisual = <String>{};

  void _rememberShown(String id) {
    _shownVisual.add(id);
    if (_shownVisual.length > _kDedupCap) {
      // FIFO trim — remove o(s) mais antigo(s) (Set mantém ordem de inserção).
      final overflow = _shownVisual.length - _kDedupCap;
      final toRemove = _shownVisual.take(overflow).toList(growable: false);
      _shownVisual.removeAll(toRemove);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<LiveGift>>(liveRoomGiftsViewModelProvider(widget.roomId), (
      prev,
      next,
    ) {
      for (final g in next) {
        final displayType = g.resolvedDisplayType;

        // 🎯 Presentes tipo `chat` NUNCA disparam overlay — vão só pro chat
        // (Fase 6/11). Não ocupam espaço visual desnecessário na tela.
        if (!displayType.entersVisualQueue) continue;

        // 🎬 O ViewModel (`LiveRoomGiftsViewModel`) já controla A FILA e
        // A PRIORIDADE — só marca `isAnimating=true` quando chegou a vez
        // deste item animar (nunca dois ao mesmo tempo, sempre respeitando
        // prioridade). O overlay só precisa REAGIR a essa borda de subida.
        if (!g.isAnimating) continue;

        // Chave única do gift (transaction_id). Em combos, o view-model
        // mantém o mesmo `id` e só incrementa `quantity` → não re-dispara
        // a animação (correto: TikTok-style, mostra 1x e fica visível).
        final dedupKey = g.id;
        if (_shownVisual.contains(dedupKey)) continue;
        _rememberShown(dedupKey);

        switch (displayType) {
          case GiftDisplayType.centerSmall:
            _showCenterSmall(g);
          case GiftDisplayType.centerLarge:
            _showCenterLarge(g);
          case GiftDisplayType.fullscreen:
            _showFullscreen(g);
          case GiftDisplayType.chat:
            break; // inalcançável (filtrado acima), mantém exaustividade
        }
      }
    });

    return const SizedBox.shrink();
  }

  void _showCenterSmall(LiveGift gift) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final lane =
        ref
            .read(liveRoomGiftsViewModelProvider(widget.roomId).notifier)
            .laneOf(gift.id) ??
        0;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _GiftToast(
        gift: gift,
        roomId: widget.roomId,
        lane: lane,
        onDone: () {
          try {
            entry.remove();
          } catch (_) {}
        },
      ),
    );
    overlay.insert(entry);
  }

  void _showCenterLarge(LiveGift gift) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CenterLargeBurst(
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

  void _showFullscreen(LiveGift gift) {
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

/// Aviso de presente pequeno (centerSmall) — estilo TikTok.
///
/// Fica em uma de 2 faixas ([lane] 0 = de baixo, 1 = de cima) e permanece na
/// tela enquanto o `LiveRoomGiftsViewModel` mantiver o presente ativo
/// (`isAnimating`). Combos do mesmo remetente+presente atualizam o "xN"
/// AQUI, com um "pulo", e prorrogam o tempo do aviso.
class _GiftToast extends ConsumerStatefulWidget {
  const _GiftToast({
    required this.gift,
    required this.roomId,
    required this.lane,
    required this.onDone,
  });
  final LiveGift gift;
  final String roomId;
  final int lane;
  final VoidCallback onDone;

  /// Distância vertical entre as 2 faixas.
  static const double laneSpacing = 62;

  @override
  ConsumerState<_GiftToast> createState() => _GiftToastState();
}

class _GiftToastState extends ConsumerState<_GiftToast>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl; // entrada
  late final AnimationController _exitCtrl; // saída
  late final AnimationController _pulseCtrl; // "pulo" do xN no combo
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final Animation<double> _pulse;
  late final Listenable _anim;
  Timer? _safetyTimer;
  bool _exiting = false;
  int _lastQuantity = 0;

  /// `true` quando o toast deve aparecer no lado direito da tela (lado B
  /// da batalha). Calculado uma vez aqui pra os 2 animations + Positioned
  /// concordarem em direção (entra do mesmo lado em que ancora).
  bool get _isRightSide => widget.gift.battleSide == 'b';

  @override
  void initState() {
    super.initState();
    _lastQuantity = widget.gift.quantity;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    // 🎯 Entra deslizando do lado em que vai ancorar:
    //   - solo / lado A → entra da esquerda (-1.2 → 0)
    //   - lado B → entra da direita (+1.2 → 0)
    final beginOffset = _isRightSide
        ? const Offset(1.2, 0)
        : const Offset(-1.2, 0);
    _slide = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
    _pulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 1),
    ]).animate(_pulseCtrl);
    _anim = Listenable.merge([_ctrl, _exitCtrl, _pulseCtrl]);
    _ctrl.forward();
    // Garantia: nunca fica preso na tela se o estado se perder.
    _safetyTimer = Timer(const Duration(seconds: 30), _exit);
  }

  void _exit() {
    if (_exiting || !mounted) return;
    _exiting = true;
    _safetyTimer?.cancel();
    _exitCtrl.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _ctrl.dispose();
    _exitCtrl.dispose();
    _pulseCtrl.dispose();
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
    if (n.contains('butterfly') || n.contains('borboleta')) return '🦋';
    if (n.contains('phone') || n.contains('fone')) return '🎧';
    if (n.contains('moon') || n.contains('lua')) return '🌙';
    if (n.contains('gamepad') || n.contains('game')) return '🎮';
    return '🎁';
  }

  @override
  Widget build(BuildContext context) {
    // 📐 Posicionamento RESPONSIVO (Fase 12) — substitui o antigo valor
    // fixo `bottom: 390`, que não respondia a tamanho de tela, notch,
    // SafeArea, tablets ou landscape.
    //
    // Cálculo: ChatTicker ocupa uma faixa fixa de 240px de altura, ancorada
    // em `bottom: 120` (ver live_player_screen.dart) + a SafeArea inferior
    // do dispositivo (gestos/home indicator no iOS, barra de navegação no
    // Android). O toast fica sempre ACIMA dessa faixa, com um respiro
    // proporcional à altura da tela (nunca um pixel fixo arbitrário) —
    // garante leitura confortável em iPhone SE até tablets em landscape.
    // Leituras granulares (sizeOf/paddingOf/viewInsetsOf): o toast só
    // reconstrói quando a dimensão que ele usa muda.
    // Estado atual deste presente no ViewModel (quantidade do combo e se
    // ainda deve ficar na tela).
    final live = ref.watch(
      liveRoomGiftsViewModelProvider(widget.roomId).select((list) {
        for (final g in list) {
          if (g.id == widget.gift.id) return g;
        }
        return null;
      }),
    );
    if (live == null || !live.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _exit());
    }
    final gift = live ?? widget.gift;
    if (gift.quantity > _lastQuantity) {
      _lastQuantity = gift.quantity;
      _pulseCtrl.forward(from: 0);
    }

    const chatTickerHeight = 240.0;
    const chatTickerBottomAnchor = 120.0;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    // ⌨️ Com o teclado aberto o chat sobe junto e o toast colidiria com
    // ele / com o top bar. Escondemos o toast enquanto o usuário digita —
    // o presente continua aparecendo na linha do chat (GiftChatLine).
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    // Respiro proporcional: 3% da altura da tela, com piso de 16px e teto
    // de 40px — evita colar (telas pequenas) ou flutuar longe demais
    // (tablets/telas grandes).
    final breathingRoom = (screenHeight * 0.03).clamp(16.0, 40.0);
    final responsiveBottom =
        chatTickerBottomAnchor +
        chatTickerHeight +
        breathingRoom +
        safeAreaBottom +
        widget.lane * _GiftToast.laneSpacing;

    // ⚠️ OverlayEntry NÃO tem ancestor Material/Directionality por padrão.
    // Qualquer Text descendente ganha a "linha amarela double underline" do
    // default textStyle de erro do Flutter. Por isso embrulhamos o conteúdo
    // em Directionality + Material(transparency) + DefaultTextStyle DENTRO
    // do Positioned (o Positioned precisa ser filho direto do Overlay Stack).
    return Positioned(
      bottom: responsiveBottom,
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
              child: Offstage(
                offstage: keyboardOpen,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => SlideTransition(
                    position: _slide,
                    child: FadeTransition(
                      opacity: _fade,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 1) Avatar circular
                            _AvatarCircle(
                              url: gift.senderAvatarUrl,
                              fallback: gift.senderName,
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
                                    // Chip de nível (💎 Lv34) estilo TikTok —
                                    // altura reduzida (era o default 18px,
                                    // grande o suficiente pra roubar a
                                    // atenção do nome do remetente). 15px
                                    // mantém legibilidade com discrição,
                                    // combinando com o restante do toast.
                                    LevelChip(
                                      level: gift.gifterLevel,
                                      badge: gift.gifterBadge,
                                      colorHex: gift.gifterColor,
                                      imageUrl: gift.gifterImageUrl,
                                      height: 15,
                                    ),
                                    const SizedBox(width: 6),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 160,
                                      ),
                                      child: Text(
                                        gift.senderName,
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
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 11,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 120,
                                      ),
                                      child: Text(
                                        gift.giftName,
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
                            // 3) Ícone/animação do gift (à direita) — usa Lottie
                            // local se disponível para o slug (ver
                            // `_kLottieTestAssets`), senão mantém o PNG remoto.
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _GiftVisual(
                                gift: gift,
                                size: 36,
                                fallbackIcon: Text(
                                  _giftEmoji(gift.giftName),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                            // 4) Multiplicador xN
                            if (gift.quantity > 1) ...[
                              const SizedBox(width: 4),
                              ScaleTransition(
                                scale: _pulse,
                                child: Text(
                                  'x${gift.quantity}',
                                  style: const TextStyle(
                                    color: AppColors.braweEmber,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    decoration: TextDecoration.none,
                                  ),
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
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// FULLSCREEN burst — presentes épicos (dragão, universo, etc.)
// Duração dinâmica: 6000-12000ms, vinda do backend via
// `resolvedDurationMs` (clampada nos limites seguros do tipo fullscreen).
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
    // 🎯 Duração dinâmica (Fase 7) — não mais hardcoded 2600ms. Vem do
    // backend, já clampada nos limites de FULLSCREEN (6000-12000ms), e
    // reclampada aqui como defesa em profundidade.
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.gift.resolvedDurationMs),
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
                                Color(0x66FF6A09),
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
                                    colors: [
                                      Color(0xFFFFD166),
                                      AppColors.braweEmber,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      blurRadius: 60,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                                // Ícone/animação central — usa Lottie local
                                // se disponível para o slug (ver
                                // `_kLottieTestAssets`), senão mantém o PNG
                                // remoto + fallback de sempre.
                                child: _GiftVisual(
                                  gift: widget.gift,
                                  size: 120,
                                  fallbackIcon: const Icon(
                                    Icons.workspace_premium,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFFFFD166),
                                    width: 1.5,
                                  ),
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
// CENTER_LARGE burst — presentes premium de maior impacto (foguete, urso,
// galáxia, chuva de moedas, etc.). Fica entre o toast pequeno (CENTER_SMALL)
// e o burst fullscreen: ocupa uma área central maior (~55% da largura),
// mostra remetente com destaque, mas NÃO cobre a tela inteira nem bloqueia
// interação — chat e controles continuam parcialmente visíveis.
// Duração dinâmica: 4000-7000ms, vinda do backend via `resolvedDurationMs`.
// ────────────────────────────────────────────────────────────────────────

class _CenterLargeBurst extends StatefulWidget {
  const _CenterLargeBurst({required this.gift, required this.onDone});
  final LiveGift gift;
  final VoidCallback onDone;

  @override
  State<_CenterLargeBurst> createState() => _CenterLargeBurstState();
}

class _CenterLargeBurstState extends State<_CenterLargeBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.gift.resolvedDurationMs),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.6,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 15),
    ]).animate(_ctrl);
    _fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 73),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(_ctrl);
    _ctrl.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    // 📐 Responsivo (Fase 12): ~55% da largura da tela, com piso/teto
    // seguros pra não ficar minúsculo em telas pequenas nem gigante em
    // tablets — atende a faixa conceitual de 40%-75% pedida na
    // especificação (usamos o meio da faixa como valor confortável).
    final screenWidth = MediaQuery.of(context).size.width;
    final visualSize = (screenWidth * 0.55).clamp(220.0, 420.0);

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
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return Center(
                  // Levemente acima do centro geométrico — deixa a metade
                  // inferior da tela (chat, controles) mais livre, como
                  // pedido na Fase 5 (TIPO 3): "controles críticos
                  // continuam acima" / "chat parcialmente visível".
                  heightFactor: 0.75,
                  child: Opacity(
                    opacity: _fade.value,
                    child: Transform.scale(
                      scale: _scale.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: visualSize,
                            height: visualSize,
                            child: _GiftVisual(
                              gift: widget.gift,
                              size: visualSize,
                              fallbackIcon: Icon(
                                Icons.auto_awesome,
                                size: visualSize * 0.6,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.braweSky,
                                width: 1.2,
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: widget.gift.senderName,
                                    style: const TextStyle(
                                      color: AppColors.braweSky,
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
                                        color: AppColors.braweSky,
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
    final initial = fallback.trim().isNotEmpty
        ? fallback.trim()[0].toUpperCase()
        : '?';
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.braweEmber, Color(0xFFFFD166)],
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

