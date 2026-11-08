import 'dart:async';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'dart:io';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vap_player/flutter_vap_player.dart';
import 'package:lottie/lottie.dart';

import '../../../../../data/repositories/gift_repository.dart';
import '../../../../../data/services/gift_effect_cache.dart';
import '../../../../../data/services/sfx_player.dart';
import '../../../../../domain/models/combo_tier.dart';

import '../../../../../domain/models/live_gift.dart';
import '../../../../../domain/models/gift_display_type.dart';
import '../../../../../domain/models/gift_presentation.dart';
import '../../../../live_feed/view_models/live_room_gifts_view_model.dart';
import '../../layout/live_dock_metrics.dart';
import '../../../../live_feed/battle/battle_layout.dart';
import '../award_badge.dart';
import '../level_chip.dart';
import 'gift_stage.dart';
import '../../../../core/themes/app_colors.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

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

    // 🎬 Lottie do servidor (subido no painel) — prioridade máxima: do arquivo já baixado (prefetch ao entrar na
    // live) ou, se ainda não chegou, direto da rede.
    final remoteLottie = gift.animationType?.toLowerCase() == 'lottie'
        ? gift.animationUrl
        : null;
    if (remoteLottie != null && remoteLottie.isNotEmpty) {
      final file = GiftEffectCache.instance.cachedFile(remoteLottie);
      return file != null
          ? Lottie.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.contain,
              repeat: false,
              errorBuilder: (_, _, _) => _networkOrFallback(context),
            )
          : Lottie.network(
              remoteLottie,
              width: size,
              height: size,
              fit: BoxFit.contain,
              repeat: false,
              errorBuilder: (_, _, _) => _networkOrFallback(context),
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

    // 🖼️ Imagem subida no painel (URL absoluta do CDN) vence o PNG antigo
    // embutido no app — senão trocar a imagem no painel não mudava nada.
    final icon = gift.giftIconUrl?.trim() ?? '';
    if (icon.startsWith('http') && !icon.contains('/gifts/v1/')) {
      return Image.network(
        icon,
        cacheWidth: context.decodePx(size),
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _assetOrFallback(context, slug),
      );
    }
    return _assetOrFallback(context, slug);
  }

  Widget _assetOrFallback(BuildContext context, String? slug) {
    final tier = slug != null ? _kGiftSlugTier[slug] : null;
    if (tier != null) {
      return Image.asset(
        'assets/images/gifts/$tier/$slug.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _networkOrFallback(context),
      );
    }

    return _networkOrFallback(context);
  }

  Widget _networkOrFallback(BuildContext context) {
    if (gift.giftIconUrl != null) {
      return Image.network(
        cacheWidth: context.decodePx(size),
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
      fallbackIcon ?? const Icon(LucideIcons.crown, color: Colors.white);
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

  @override
  void initState() {
    super.initState();
    _prefetchEffects();
  }

  /// Baixa os vídeos VAP / Lottie / sons do catálogo ao entrar na live, pra
  /// que o efeito toque na hora em que o presente chegar.
  Future<void> _prefetchEffects() async {
    try {
      final tiers = await ref.read(giftRepositoryProvider).getGiftCatalog();
      // Os vídeos dos presentes mais caros primeiro (são os maiores e os que
      // mais impressionam); depois Lottie e sons. Antes era a ordem do
      // catálogo — o Lendário chegava antes do próprio vídeo e caía no ícone.
      final gifts = [for (final t in tiers.reversed) ...t.gifts];
      final urls = <String?>[
        for (final g in gifts)
          if (g.animationType == 'vap') g.animationUrl,
        for (final g in gifts)
          if (g.animationType == 'lottie') g.animationUrl,
        for (final g in gifts) g.soundUrl,
      ];
      await GiftEffectCache.instance.prefetch(urls);
    } catch (e) {
      debugPrint('[GIFT-FX] prefetch falhou: $e');
    }
  }

  /// Tela dupla (conexão/batalha), segundo o `display_type` do presente:
  /// - center_large: ancorada EMBAIXO, largura total, até ~70% da altura da
  ///   tela (por cima do chat e da parte de baixo dos vídeos);
  /// - fullscreen: 100% da tela, inclusive os vídeos (igual à live solo);
  /// - center_small: só o combo no canto da metade de quem recebeu.
  /// Live solo (sem regiões publicadas): nada muda.
  Widget _inReceiverHalf(BuildContext ctx, LiveGift gift, Widget effect) {
    if (BattleGiftRegions.current.value == null) return effect;
    if (gift.resolvedDisplayType != GiftDisplayType.centerLarge) return effect;
    final size = MediaQuery.sizeOf(ctx);
    final h = size.height * 0.7;
    return battleRegionWrap(
      ctx,
      Rect.fromLTWH(0, size.height - h, size.width, h),
      effect,
    );
  }

  /// Vídeo VAP (transparente, com som) por cima da live. Só toca se o
  /// arquivo já estiver no aparelho; senão baixa pra próxima vez e o
  /// presente usa o efeito padrão.
  Future<bool> _tryShowVap(LiveGift gift) async {
    final url = gift.animationUrl;
    if (gift.animationType?.toLowerCase() != 'vap' || url == null) {
      return false;
    }
    var file = GiftEffectCache.instance.cachedFile(url);
    if (file == null) {
      // Ainda baixando: espera um pouco — o vídeo uns segundos depois vale
      // mais que o ícone na hora. Se não chegar, efeito padrão (e o download
      // segue para o próximo presente).
      debugPrint('[GIFT-FX] VAP ainda não baixado — aguardando $url');
      file = await GiftEffectCache.instance
          .fetch(url)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (!mounted) return true;
      if (file == null) {
        debugPrint('[GIFT-FX] VAP não chegou a tempo — efeito padrão');
        return false;
      }
    }
    final vapFile = file;
    debugPrint('[GIFT-FX] tocando VAP ${vapFile.path}');
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _inReceiverHalf(
        ctx,
        gift,
        _VapGiftEffect(
          file: vapFile,
          gift: gift,
          onDone: () {
            try {
              entry.remove();
            } catch (_) {}
          },
        ),
      ),
    );
    overlay.insert(entry);
    return true;
  }

  /// Som do efeito padrão/Lottie (o VAP toca o próprio áudio).
  void _playSound(LiveGift gift) {
    final url = gift.soundUrl;
    if (!gift.soundEnabled || url == null || url.isEmpty) return;
    // Baixa latência (flutter_soloud) com reserva no just_audio.
    SfxPlayer.instance.play(url);
  }

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
        debugPrint(
          '[GIFT-FX] overlay dispara ${g.giftName} (${displayType.name})',
        );

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

  Future<void> _showCenterLarge(LiveGift gift) async {
    if (await _tryShowVap(gift) || !mounted) return;
    _playSound(gift);
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _inReceiverHalf(
        ctx,
        gift,
        _CenterLargeBurst(
          gift: gift,
          onDone: () {
            try {
              entry.remove();
            } catch (_) {}
          },
        ),
      ),
    );
    overlay.insert(entry);
  }

  Future<void> _showFullscreen(LiveGift gift) async {
    if (await _tryShowVap(gift) || !mounted) return;
    _playSound(gift);
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _inReceiverHalf(
        ctx,
        gift,
        _PremiumGiftBurst(
          gift: gift,
          onDone: () {
            try {
              entry.remove();
            } catch (_) {}
          },
        ),
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
  // Combo que evolui: último degrau mirado e o anterior (base da barra).
  int? _lastNextAt;
  int _prevTierAt = 0;
  late final AnimationController _tierCtrl; // pulso ao cruzar um degrau

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
    _tierCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _anim = Listenable.merge([_ctrl, _exitCtrl, _pulseCtrl, _tierCtrl]);
    _ctrl.forward();
    LiveDockMetrics.top.addListener(_onDockMoved);
    // Garantia: nunca fica preso na tela se o estado se perder.
    _safetyTimer = Timer(const Duration(seconds: 30), _exit);
  }

  void _onDockMoved() {
    if (mounted) setState(() {});
  }

  void _exit() {
    if (_exiting || !mounted) return;
    _exiting = true;
    _safetyTimer?.cancel();
    _exitCtrl.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    LiveDockMetrics.top.removeListener(_onDockMoved);
    _safetyTimer?.cancel();
    _ctrl.dispose();
    _exitCtrl.dispose();
    _pulseCtrl.dispose();
    _tierCtrl.dispose();
    super.dispose();
  }

  /// 0..1..0 durante o pulso de cruzar um degrau.
  double _tierBump() {
    final v = _tierCtrl.value;
    return v <= 0 || v >= 1 ? 0 : (v < 0.4 ? v / 0.4 : (1 - v) / 0.6);
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
    // 🔥 Contagem do servidor (igual para todos); sem ela, a local.
    final count = ComboMath.displayCount(
      serverCount: gift.comboCount,
      localCount: gift.quantity,
    );
    final nextAt = gift.comboNextAt;
    final prevNext = _lastNextAt;
    if (prevNext != null && count >= prevNext && nextAt != prevNext) {
      // Cruzou o degrau: o contador "estoura" e a barra recomeça dali.
      _prevTierAt = prevNext;
      _tierCtrl.forward(from: 0);
    }
    _lastNextAt = nextAt;
    final showBar = nextAt != null && nextAt > count;

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
    // Sem dock medida (tela do criador): reserva o painel de avisos.
    const noticeLaneReserve = 56.0;
    final responsiveBottom =
        chatTickerBottomAnchor +
        chatTickerHeight +
        noticeLaneReserve +
        breathingRoom +
        safeAreaBottom +
        widget.lane * _GiftToast.laneSpacing;
    // Tela com a coluna de baixo medida (espectador): encaixa logo acima
    // dela — painel de avisos e chat nunca ficam por baixo do combo.
    final dockTop = LiveDockMetrics.top.value;
    final bottom = dockTop == null
        ? responsiveBottom
        : screenHeight - dockTop + 6 + widget.lane * _GiftToast.laneSpacing;

    // ⚠️ OverlayEntry NÃO tem ancestor Material/Directionality por padrão.
    // Qualquer Text descendente ganha a "linha amarela double underline" do
    // default textStyle de erro do Flutter. Por isso embrulhamos o conteúdo
    // em Directionality + Material(transparency) + DefaultTextStyle DENTRO
    // do Positioned (o Positioned precisa ser filho direto do Overlay Stack).
    // ⚔ Batalha: o combo fica na BASE da metade de quem recebeu (A esquerda,
    // B direita), encolhido para caber na metade — nunca sobre os rostos.
    final half = BattleGiftRegions.current.value?.half(widget.gift.battleSide);
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Positioned(
      bottom: half != null
          ? screenHeight -
                half.bottom +
                6 +
                widget.lane * _GiftToast.laneSpacing
          : bottom,
      // 🎯 TikTok-style PK: o toast ancora no lado do streamer que recebeu
      // o gift. Sem isso (live solo) cai no canto esquerdo histórico.
      // Em batalha lado B mirror pra direita; lado A mantém esquerda.
      left: half != null ? half.left + 6 : (_isRightSide ? null : 12),
      width: half != null ? half.width - 12 : null,
      right: half != null ? null : (_isRightSide ? 12 : null),
      child: _BattleHalfFit(
        enabled: half != null && screenWidth > 0,
        alignEnd: _isRightSide,
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
                          child: IntrinsicWidth(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            if (gift.senderAward != null) ...[
                                              const SizedBox(width: 4),
                                              AwardBadge(
                                                award: gift.senderAward!,
                                                height: 15,
                                              ),
                                            ],
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
                                                  decoration:
                                                      TextDecoration.none,
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
                                              '${S.of(context).livexSentVerb} ',
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
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    // 3) Presente à direita: Lottie do painel → imagem do
                                    // painel → PNG do app (ver `_GiftVisual`).
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _GiftVisual(
                                        gift: gift,
                                        size: 46,
                                        fallbackIcon: Text(
                                          _giftEmoji(gift.giftName),
                                          style: const TextStyle(
                                            fontSize: 28,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // 4) Multiplicador xN (contagem do servidor quando há)
                                    if (count > 1) ...[
                                      const SizedBox(width: 4),
                                      ScaleTransition(
                                        scale: _pulse,
                                        child: Transform.scale(
                                          scale: 1 + 0.5 * _tierBump(),
                                          child: Text(
                                            'x$count',
                                            style: TextStyle(
                                              color: Color.lerp(
                                                AppColors.braweEmber,
                                                const Color(0xFFFFD166),
                                                _tierBump(),
                                              ),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                // 5) Barra até o próximo degrau: "×37 · faltam 13"
                                if (showBar) ...[
                                  const SizedBox(height: 5),
                                  _ComboBar(
                                    count: count,
                                    nextAt: nextAt,
                                    prevAt: _prevTierAt,
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
        ),
      ),
    );
  }
}

/// Encolhe o combo para a largura da metade da batalha (quando [enabled]).
class _BattleHalfFit extends StatelessWidget {
  const _BattleHalfFit({
    required this.enabled,
    required this.alignEnd,
    required this.child,
  });
  final bool enabled;
  final bool alignEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Align(
      alignment: alignEnd ? Alignment.bottomRight : Alignment.bottomLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignEnd ? Alignment.bottomRight : Alignment.bottomLeft,
        child: child,
      ),
    );
  }
}

/// Barra de progresso do combo até o próximo degrau.
class _ComboBar extends StatelessWidget {
  const _ComboBar({
    required this.count,
    required this.nextAt,
    required this.prevAt,
  });
  final int count;
  final int nextAt;
  final int prevAt;

  @override
  Widget build(BuildContext context) {
    final p = ComboMath.progress(count, nextAt, prevAt: prevAt);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: Colors.white.withValues(alpha: 0.18)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: p,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.braweEmber, Color(0xFFFFD166)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          ComboMath.progressText(count, nextAt),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// FULLSCREEN burst — presentes épicos (dragão, universo, etc.)
// Duração dinâmica: 6000-12000ms, vinda do backend via
// `resolvedDurationMs` (clampada nos limites seguros do tipo fullscreen).
// ────────────────────────────────────────────────────────────────────────

class _PremiumGiftBurst extends StatelessWidget {
  const _PremiumGiftBurst({required this.gift, required this.onDone});
  final LiveGift gift;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    // 🎭 Entrada/saída, fundo, camada e háptico vêm da encenação do presente
    // (padrão: fade 300/400 + escurecer 0.25, tela cheia). O tempo em cena é
    // `hold_ms` ou a duração dinâmica do backend (6000-12000ms).
    return GiftStage(
      presentation: gift.resolvedPresentation,
      holdMs: gift.resolvedPresentation.holdMs ?? gift.resolvedDurationMs,
      onDone: onDone,
      builder: (context, size) {
        final unit = size.shortestSide.clamp(0.0, 420.0).toDouble();
        final disc = unit * 0.4;
        final beam = unit * 1.5;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: beam,
              height: beam,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xD9FFE08A),
                    Color(0x66FF6A09),
                    Color(0x00000000),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Container(
              width: disc,
              height: disc,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD166), AppColors.braweEmber],
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
              padding: EdgeInsets.all(disc * 0.125),
              // Lottie do painel → imagem do painel → PNG do app.
              child: _GiftVisual(
                gift: gift,
                size: disc * 0.75,
                fallbackIcon: Icon(
                  LucideIcons.crown,
                  size: disc * 0.6,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
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

class _CenterLargeBurst extends StatelessWidget {
  const _CenterLargeBurst({required this.gift, required this.onDone});
  final LiveGift gift;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    // 🎭 Padrão: zoom 450 / fade 350, centro, 70% da largura, sobre o chat.
    // Tempo em cena = `hold_ms` ou duração dinâmica do backend (4000-7000ms).
    final pr = gift.resolvedPresentation;
    return GiftStage(
      presentation: pr,
      holdMs: pr.holdMs ?? gift.resolvedDurationMs,
      onDone: onDone,
      builder: (context, size) => _GiftVisual(
        gift: gift,
        size: size.shortestSide,
        fallbackIcon: Icon(
          LucideIcons.sparkles,
          size: size.shortestSide * 0.6,
          color: Colors.white,
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
        cacheWidth: context.decodePx(size),
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

// ────────────────────────────────────────────────────────────────────────
// VAP — vídeo com transparência e som (carro chegando, dragão, iate...).
// Ocupa a tela toda por cima da live, com o nome de quem enviou no topo.
// Some ao terminar o vídeo, se der erro, ou pela trava de segurança.
// ────────────────────────────────────────────────────────────────────────

class _VapGiftEffect extends StatefulWidget {
  const _VapGiftEffect({
    required this.file,
    required this.gift,
    required this.onDone,
    this.onStartFailed,
  });

  final File file;
  final LiveGift gift;
  final VoidCallback onDone;

  /// Chamado se o vídeo não começar a tocar (ex.: simulador do iOS, onde o
  /// VAP se recusa: "playHWDMP4 not allowed in Simulator").
  final VoidCallback? onStartFailed;

  @override
  State<_VapGiftEffect> createState() => _VapGiftEffectState();
}

class _VapGiftEffectState extends State<_VapGiftEffect> {
  late final VapPlayerController _ctrl;
  late final GiftPresentation _pr;
  final GlobalKey<GiftStageState> _stageKey = GlobalKey<GiftStageState>();
  StreamSubscription<VapEvent>? _events;
  Timer? _safety;
  Timer? _startWatchdog;
  bool _started = false;
  bool _ready = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _pr = widget.gift.resolvedPresentation;
    _ctrl = VapPlayerController.file(
      widget.file,
      options: VapPlayerOptions(
        mute: !widget.gift.soundEnabled,
        scaleType: VapScaleType.fitCenter,
      ),
    );
    _events = _ctrl.events.listen(
      (e) {
        if (e is VapStartedEvent || e is VapFrameEvent) {
          _started = true;
          _startWatchdog?.cancel();
        }
        if (e is VapCompletedEvent) {
          _endOfVideo();
        } else if (e is VapErrorEvent) {
          debugPrint('[GIFT-FX] VAP erro: $e');
          _finish();
        }
      },
      onError: (Object err) {
        debugPrint('[GIFT-FX] VAP erro no stream: $err');
        _finish();
      },
    );
    // Trava de segurança: duração do backend (ou hold_ms) + transições.
    final hold = _pr.holdMs ?? widget.gift.resolvedDurationMs;
    _safety = Timer(
      Duration(
        milliseconds:
            hold + _pr.enter.effectiveMs + _pr.exit.effectiveMs + 3000,
      ),
      _finish,
    );
    // Cão de guarda: sem começar em 2,5 s, desiste (não trava a tela).
    _startWatchdog = Timer(const Duration(milliseconds: 2500), () {
      if (_started || _done) return;
      debugPrint('[GIFT-FX] VAP não começou — desistindo');
      widget.onStartFailed?.call();
      _finish();
    });
    _start();
  }

  Future<void> _start() async {
    try {
      await _ctrl.initialize();
      if (!mounted || _done) return;
      setState(() => _ready = true);
      await _ctrl.play();
    } catch (e) {
      debugPrint('[GIFT-FX] VAP falhou: $e');
      _finish();
    }
  }

  /// O vídeo acabou: sai com a transição de saída da encenação.
  void _endOfVideo() {
    final stage = _stageKey.currentState;
    if (stage == null) {
      _finish();
    } else {
      stage.requestExit();
    }
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _safety?.cancel();
    _startWatchdog?.cancel();
    widget.onDone();
  }

  @override
  void dispose() {
    _events?.cancel();
    _safety?.cancel();
    _startWatchdog?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Só o efeito: quem enviou aparece na faixa de notícia (ao lado das
    // metas) e no chat — nada por cima do presente. A cena só começa quando
    // o vídeo está pronto, para a entrada não se perder na inicialização.
    // Sem `hold_ms` o presente fica até o vídeo terminar, depois sai.
    if (!_ready) return const SizedBox.shrink();
    return GiftStage(
      key: _stageKey,
      presentation: _pr,
      holdMs: _pr.holdMs,
      onDone: _finish,
      builder: (context, size) => VapPlayer(_ctrl),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Efeito do presente FORA da live (ex.: cofre de presente de story no chat)

/// Toca o efeito real de um presente por cima de tudo (overlay raiz):
/// - VAP (vídeo com transparência e som) → tela cheia, igual à live;
/// - Lottie → animação grande no centro, com o som do presente.
/// Completa quando o efeito termina. Se o presente não tem efeito (ou o
/// arquivo não baixou a tempo), completa na hora com `false`.
Future<bool> playGiftEffectStandalone(
  BuildContext context,
  LiveGift gift,
) async {
  // O efeito precisa de um contexto ainda montado depois do download.
  final overlayState = Overlay.of(context, rootOverlay: true);
  final type = gift.animationType?.toLowerCase();
  final url = gift.animationUrl;
  debugPrint('[GIFT-FX] standalone: type=$type url=$url');
  if (url == null || url.isEmpty || (type != 'vap' && type != 'lottie')) {
    debugPrint('[GIFT-FX] standalone: sem efeito suportado');
    return false;
  }
  final overlay = overlayState;
  final done = Completer<bool>();
  late OverlayEntry entry;
  var played = true;
  void finish() {
    try {
      entry.remove();
    } catch (_) {}
    if (!done.isCompleted) done.complete(played);
  }

  if (type == 'vap') {
    var file = GiftEffectCache.instance.cachedFile(url);
    debugPrint('[GIFT-FX] standalone: em cache=${file != null}');
    // Vídeos de tela cheia podem ter vários MB: espera mais que na live
    // (aqui a pessoa pediu para ver; não há fila de presentes atrás).
    file ??= await GiftEffectCache.instance
        .fetch(url)
        .timeout(const Duration(seconds: 30), onTimeout: () => null);
    if (file == null) {
      debugPrint('[GIFT-FX] standalone: download falhou/expirou');
      return false;
    }
    if (!context.mounted) return false;
    debugPrint(
      '[GIFT-FX] standalone: tocando VAP ${file.path} '
      '(${file.lengthSync()} bytes)',
    );
    final vapFile = file;
    entry = OverlayEntry(
      builder: (_) => _VapGiftEffect(
        file: vapFile,
        gift: gift,
        onDone: finish,
        onStartFailed: () => played = false,
      ),
    );
  } else {
    final sound = gift.soundUrl;
    if (gift.soundEnabled && sound != null && sound.isNotEmpty) {
      SfxPlayer.instance.play(sound);
    }
    entry = OverlayEntry(
      builder: (_) => _StandaloneLottie(url: url, gift: gift, onDone: finish),
    );
  }
  overlay.insert(entry);
  return done.future;
}

class _StandaloneLottie extends StatefulWidget {
  const _StandaloneLottie({
    required this.url,
    required this.gift,
    required this.onDone,
  });
  final String url;
  final LiveGift gift;
  final VoidCallback onDone;

  @override
  State<_StandaloneLottie> createState() => _StandaloneLottieState();
}

class _StandaloneLottieState extends State<_StandaloneLottie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  Timer? _safety;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    // Trava de segurança caso o arquivo não carregue.
    _safety = Timer(
      Duration(milliseconds: widget.gift.resolvedDurationMs + 6000),
      _close,
    );
  }

  void _close() {
    if (_closing) return;
    _closing = true;
    _safety?.cancel();
    widget.onDone();
  }

  @override
  void dispose() {
    _safety?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final full = widget.gift.resolvedDisplayType == GiftDisplayType.fullscreen;
    final file = GiftEffectCache.instance.cachedFile(widget.url);
    final side = full ? size.width : size.width * 0.8;
    void onLoaded(LottieComposition comp) {
      _c
        ..duration = comp.duration
        ..forward().whenComplete(_close);
    }

    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: side,
          height: full ? size.height : side,
          child: file != null
              ? Lottie.file(
                  file,
                  controller: _c,
                  fit: BoxFit.contain,
                  onLoaded: onLoaded,
                  errorBuilder: (_, _, _) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _close(),
                    );
                    return const SizedBox.shrink();
                  },
                )
              : Lottie.network(
                  widget.url,
                  controller: _c,
                  fit: BoxFit.contain,
                  onLoaded: onLoaded,
                  errorBuilder: (_, _, _) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _close(),
                    );
                    return const SizedBox.shrink();
                  },
                ),
        ),
      ),
    );
  }
}
