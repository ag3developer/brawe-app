import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../view_models/live_room_comments_view_model.dart';
import '../view_models/live_room_gifts_view_model.dart';
import '../view_models/send_gift_view_model.dart';
import '../../core/view_models/follow_view_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../data/services/socket_service.dart';
import '../../../domain/models/live_room.dart';
import '../../../domain/models/live_reaction_event.dart';
import '../../../domain/models/user.dart';
import '../../live/shared/widgets/actions/actions.dart';
import '../../live/shared/widgets/chat/chat.dart';
import '../../live/shared/widgets/commerce/commerce.dart';
import '../../live/shared/widgets/hud/hud.dart';
import '../../live/shared/widgets/sheets/sheets.dart';
import '../../live/shared/widgets/video/live_gradients.dart';
import 'gifts_overlay.dart';
import 'gift_animation_overlay.dart';
import 'floating_hearts_overlay.dart';
import '../../../gen/l10n/app_localizations.dart';

/// 📺 Tela do espectador (live viewer).
///
/// Layout TikTok-style com:
/// - Vídeo fullscreen (HLS) com fit cover.
/// - Header compacto: voltar · LIVE • N viewers · top gifters · close button.
/// - Identidade do streamer + Follow (canto superior esquerdo).
/// - Comentários flutuando da base para o meio (overlay), tipo TikTok.
/// - Action rail à direita: Like (toque rápido = corações) · Gift · Share · Comment.
/// - Input de chat fixo na base.
/// - Overlays: corações flutuantes em tempo real · combos de gifts · burst premium.
class LivePlayerScreen extends ConsumerStatefulWidget {
  final LiveRoom room;

  const LivePlayerScreen({super.key, required this.room});

  @override
  ConsumerState<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends ConsumerState<LivePlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLiked = false;
  int _likesCount = 0;

  // Reaction batching (TikTok-style: agrega N toques em 250ms)
  Timer? _reactionFlushTimer;
  int _pendingReactions = 0;

  // Realtime reactions (corações de outros viewers + contador global)
  StreamSubscription<LiveReactionEvent>? _reactionSub;

  // Battle
  String? _activeBattleId;

  // Floating hearts overlay key (para spawn local imediato)
  final GlobalKey<FloatingHeartsOverlayState> _heartsKey =
      GlobalKey<FloatingHeartsOverlayState>();

  // Chat input
  final TextEditingController _chatCtrl = TextEditingController();
  final FocusNode _chatFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _likesCount = widget.room.totalLikes;
    _initializePlayer();
    // Refresh follow state on entry (avoids stale cache from previous session)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(followViewModelProvider(widget.room.streamerId));
      _subscribeToBattleEvents();
      _subscribeToReactions();
    });
  }

  @override
  void dispose() {
    _reactionFlushTimer?.cancel();
    _flushReactions(force: true);
    _reactionSub?.cancel();
    _chatCtrl.dispose();
    _chatFocus.dispose();
    _controller?.dispose();
    _unsubscribeFromBattleEvents();
    WakelockPlus.disable();
    super.dispose();
  }

  // ── Battle events ──────────────────────────────────────────────────────────

  void _subscribeToBattleEvents() {
    final socket = ref.read(socketServiceProvider);
    socket.on(AppConstants.eventBattleStarted, _onBattleStarted);
  }

  void _unsubscribeFromBattleEvents() {
    try {
      final socket = ref.read(socketServiceProvider);
      socket.off(AppConstants.eventBattleStarted);
    } catch (_) {}
  }

  // ── Realtime reactions ──────────────────────────────────────────────────
  //
  // Assinamos o stream global de reactions para:
  //   1. Incrementar o contador `_likesCount` em tempo real (curtidas de
  //      outros viewers aparecem no top bar).
  //   2. NÃO duplicar corações do próprio user — o `FloatingHeartsOverlay`
  //      já cuida do spawn visual (inclusive do eco do backend), então aqui
  //      apenas atualizamos o contador. Filtramos eventos do próprio user
  //      para evitar double-count (já incrementamos otimisticamente em
  //      `_onTapLike`).
  void _subscribeToReactions() {
    final repo = ref.read(liveRepositoryProvider);
    final authState = ref.read(authStateProvider);
    final currentUser = authState is AsyncData<User?> ? authState.value : null;
    final myId = currentUser?.id;
    _reactionSub = repo.watchReactions(widget.room.id).listen((event) {
      if (!mounted) return;
      // Skip eco do próprio user (já contado em _onTapLike).
      if (myId != null && event.userId == myId) return;
      setState(() => _likesCount += event.count);
    });
  }

  void _onBattleStarted(dynamic raw) {
    if (!mounted) return;
    Map<String, dynamic> data = {};
    if (raw is Map<String, dynamic>) data = raw;
    final battleId = data['battle_id'] as String?;
    if (battleId == null) return;
    // Navegar para a tela de batalha do viewer
    context.push('/live/battle/$battleId');
  }

  Future<void> _initializePlayer() async {
    if (_controller != null) return;
    final streamUrl = widget.room.streamUrl;
    if (streamUrl == null || streamUrl.isEmpty) return;
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(streamUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
      _controller!
        ..play()
        ..setLooping(true)
        ..setVolume(1.0);
      WakelockPlus.enable();
    } catch (e) {
      debugPrint('LivePlayer: video init error: $e');
    }
  }

  // ────────────────────── Interaction handlers ──────────────────────

  /// Toque rápido no botão de like — spawna 1 coração local + agrega
  /// para envio em batch ao backend.
  void _onTapLike() {
    HapticLike.light();
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _likesCount += 1;
      });
      // Toggle persistente (fire-and-forget)
      unawaited(
        ref
            .read(liveRepositoryProvider)
            .toggleLike(widget.room.id, false)
            .catchError((_) {}),
      );
    } else {
      setState(() => _likesCount += 1);
    }

    _heartsKey.currentState?.spawn(1);
    _pendingReactions += 1;
    _reactionFlushTimer?.cancel();
    _reactionFlushTimer = Timer(const Duration(milliseconds: 250), _flushReactions);
  }

  void _flushReactions({bool force = false}) {
    if (_pendingReactions <= 0) return;
    final count = _pendingReactions;
    _pendingReactions = 0;
    unawaited(
      ref
          .read(liveRepositoryProvider)
          .sendReaction(widget.room.id, count: count)
          .catchError((_) {}),
    );
  }

  Future<void> _onTapShare() async {
    // 🌍 Compartilhamento EXTERNO (sistema operacional): copia link/texto
    // para apps de mensagens, redes sociais, etc. O compartilhamento
    // interno (mandar a live para amigos do Brawe) é exposto pelo "Mais".
    final s = S.of(context);
    final url = 'https://brawe.app/live/${widget.room.slug}';
    final message = s.liveFeedShareMessage(widget.room.title, url);
    try {
      await SharePlus.instance.share(ShareParams(text: message));
    } catch (e) {
      debugPrint('LivePlayer: share error: $e');
    }
  }

  void _openGifts() {
    GiftsOverlay.show(
      context,
      widget.room.id,
      widget.room.streamerId,
    );
  }

  /// Abre o quick sheet do streamer (mesmo usado ao tocar no avatar do topo).
  /// Single source of truth do fluxo de follow.
  void _openStreamerSheet() {
    final room = widget.room;
    final rawName = room.streamerName.trim();
    final looksGeneric = rawName.isEmpty ||
        rawName.toLowerCase() == 'streamer' ||
        RegExp(r'^streamer-?[0-9a-f]{0,8}$', caseSensitive: false)
            .hasMatch(rawName);
    String displayName = rawName;
    if (looksGeneric) {
      final username = (room.streamerUsername ?? '').trim();
      if (username.isNotEmpty) {
        displayName = username.startsWith('@') ? username : '@$username';
      } else if (room.streamerId.length >= 6) {
        displayName = '@${room.streamerId.substring(0, 6)}';
      } else {
        displayName = 'Streamer';
      }
    }
    final isFollowing =
        ref.read(followViewModelProvider(room.streamerId)).value ?? false;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => StreamerQuickSheet(
        room: room,
        displayName: displayName,
        isFollowing: isFollowing,
        onToggleFollow: () => ref
            .read(followViewModelProvider(room.streamerId).notifier)
            .toggleFollow(),
      ),
    );
  }

  /// Envia 1 rosa direto, sem abrir o catálogo. Usa o slug 'rose' como
  /// padrão (gift mais barato/básico do catálogo). Fire-and-forget.
  void _sendRose() {
    unawaited(
      ref.read(sendGiftViewModelProvider.notifier).sendGift(
            roomId: widget.room.id,
            giftId: 'rose',
            receiverId: widget.room.streamerId,
            quantity: 1,
          ),
    );
  }

  void _sendComment() {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;
    ref
        .read(liveRoomCommentsViewModelProvider(widget.room.id).notifier)
        .sendComment(text);
    _chatCtrl.clear();
  }

  // ────────────────────── Build ──────────────────────

  @override
  Widget build(BuildContext context) {
    final commentsState =
        ref.watch(liveRoomCommentsViewModelProvider(widget.room.id));
    final gifts = ref.watch(liveRoomGiftsViewModelProvider(widget.room.id));

    ref.listen<LiveRoomCommentsState>(
      liveRoomCommentsViewModelProvider(widget.room.id),
      (previous, next) {
        final errorMessage = next.errorMessage;
        if (errorMessage == null || errorMessage == previous?.errorMessage) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorMessage)));
        ref
            .read(liveRoomCommentsViewModelProvider(widget.room.id).notifier)
            .clearError();
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Video / thumbnail background ──
          _buildVideoLayer(),

          // ── 2. Gradients para legibilidade ──
          const LiveTopGradient(),
          const LiveBottomGradient(),

          // ── 3. Top bar ──
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: _TopBar(
                  room: widget.room,
                  viewerCount: commentsState.viewerCount,
                  likesCount: _likesCount,
                  roomId: widget.room.id,
                  onBack: () => context.pop(),
                  onShare: _onTapShare,
                ),
              ),
            ),
          ),

          // ── 4. Floating hearts (fullscreen, mas o overlay já posiciona
          // os corações na faixa direita ~80-95% da largura, subindo do
          // bottom até o topo). IgnorePointer para não bloquear toques.
          Positioned.fill(
            child: IgnorePointer(
              child: FloatingHeartsOverlay(
                key: _heartsKey,
                roomId: widget.room.id,
              ),
            ),
          ),

          // ── 5. Gift combos (canto inf. esq, acima do chat) ──
          GiftAnimationOverlay(roomId: widget.room.id),

          // ── 6. Chat ticker (sobe da base, ACIMA do bottom bar) ──
          // bottom bar = chat input (52) + spacing (10) + actions (52) + safearea
          // ≈ 140px → ticker fica em 160 para sobrar respiro visual.
          Positioned(
            left: 12, right: 12, bottom: 160,
            child: IgnorePointer(
              child: ChatTicker(
                comments: commentsState.comments,
                gifts: gifts,
              ),
            ),
          ),

          // ── 6.5. Pinned product (event-driven, slide-in quando streamer pinar) ──
          Positioned(
            left: 0, right: 0, bottom: 250,
            child: PinnedProductBar(roomId: widget.room.id),
          ),

          // ── 7. Bottom bar: chat input + ações inline (TikTok Live style) ──
          Positioned(
            left: 12, right: 12, bottom: 12,
            child: SafeArea(
              top: false,
              child: LiveBottomBar(
                controller: _chatCtrl,
                focusNode: _chatFocus,
                isSending: commentsState.isSending,
                isLiked: _isLiked,
                likesCount: _likesCount,
                onSend: _sendComment,
                onSendRose: _sendRose,
                onGifts: _openGifts,
                onLike: _onTapLike,
                onShare: _onTapShare,
                onSeguir: _openStreamerSheet,
                onShop: () {
                  // TODO: navegar para vitrine do criador.
                },
                // ⚠️ MVP: enquanto o backend não expõe `hasStorefront`,
                // mantemos escondido — só quem tiver vitrine real verá o
                // botão "Loja" (espectador não vê vazio).
                hasStorefront: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoLayer() {
    if (_isInitialized && _controller != null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    }
    if (widget.room.thumbnailUrl != null) {
      return Image.network(
        widget.room.thumbnailUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF1B2B6B),
        child: const Center(
          child: Icon(Icons.live_tv, color: Colors.white24, size: 64),
        ),
      );
}

// ────────────────────────────────────────────────────────────────────────
// Top bar
// ────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.room,
    required this.viewerCount,
    required this.likesCount,
    required this.roomId,
    required this.onBack,
    required this.onShare,
  });
  final LiveRoom room;
  final int viewerCount;
  final int likesCount;
  final String roomId;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Linha 1: identidade + viewers stack + more ───────────────
        Row(
          children: [
            // X close
            GestureDetector(
              onTap: onBack,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.close_rounded,
                    color: Colors.white, size: 26),
              ),
            ),
            const SizedBox(width: 4),
            // Identity pill (avatar + nome + verified + estrela/score)
            Expanded(child: StreamerIdentityBar(room: room)),
            const SizedBox(width: 8),
            // Stack de avatares de viewers + total (350+ etc.)
            ViewersStack(viewerCount: viewerCount),
            const SizedBox(width: 8),
            // More menu (⋯)
            TopHudCircleIcon(
              icon: Icons.more_horiz_rounded,
              onTap: () => MoreSheet.show(context, onShare: onShare),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // ─── Linha 2: pílulas LIVE · views · likes ───────────────────
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Row(
            children: [
              LivePill(label: s.liveFeedBadgeLive),
              const SizedBox(width: 8),
              MetricPill(
                icon: Icons.visibility_rounded,
                value: _formatCount(viewerCount),
              ),
              const SizedBox(width: 8),
              _LiveLikesPill(roomId: roomId, initial: likesCount),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── Top HUD átomos ────────────────────────────────────────────────────
//
// `LivePill`, `MetricPill`, `ViewersStack` e `TopHudCircleIcon` foram
// extraídos para `lib/ui/live/shared/widgets/hud/` (barrel `hud.dart`).
// Aqui mantemos apenas o wrapper `_LiveLikesPill` que adiciona a cor
// rosa específica do contador de likes.

/// Pílula de likes (escuta o contador local que já é incrementado por
/// `_onTapLike` + eventos socket no `_LivePlayerScreenState`).
class _LiveLikesPill extends StatelessWidget {
  const _LiveLikesPill({required this.roomId, required this.initial});
  final String roomId;
  final int initial;

  @override
  Widget build(BuildContext context) {
    return MetricPill(
      icon: Icons.favorite_rounded,
      iconColor: const Color(0xFFFF3D6E),
      value: _format(initial),
    );
  }

  static String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

/// Stack horizontal de até 3 avatares + contador (ex.: "350+").
/// ⚠️ Migrado para `lib/ui/live/shared/widgets/hud/viewers_stack.dart`.

/// Círculo glass usado para botões soltos no topo (more menu).
/// ⚠️ Migrado para `lib/ui/live/shared/widgets/hud/top_hud_circle_icon.dart`.

// ⚠️ _MoreSheet + _MoreTile migrados para
//    lib/ui/live/shared/widgets/sheets/more_sheet.dart
// ⚠️ _StreamerIdentityBar, _StreamerQuickSheet, _QuickSheetButton migrados
//    para lib/ui/live/shared/widgets/hud/streamer_identity_bar.dart
//    (renomeados para StreamerIdentityBar/StreamerQuickSheet públicos;
//     _QuickSheetButton continua privado lá).
// ⚠️ _ChatTicker, _TickerItem, _ChatLine, _GiftChatLine migrados para
//    lib/ui/live/shared/widgets/chat/chat.dart

// Bottom bar (chat input + ações flutuantes — TikTok Live style)
// ⚠️ _LiveBottomBar + _LiveActionButton migrados para
//    lib/ui/live/shared/widgets/actions/live_bottom_bar.dart
//    (renomeado para LiveBottomBar; _LiveActionButton continua privado lá).


class HapticLike {
  static void light() {
    // Mantém leve mesmo em muitos toques (não bloqueante).
    // ignore: invalid_use_of_visible_for_testing_member
    // (não usa visibleForTesting; só wrap simples)
  }
}

// ⚠️ _PinnedProduct + _PinnedProductBar migrados para
//    lib/ui/live/shared/widgets/commerce/pinned_product_bar.dart
//    (renomeados para PinnedProduct/PinnedProductBar públicos).
