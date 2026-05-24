import 'dart:async';
import 'dart:ui' as ui;
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
import '../../../domain/models/live_comment.dart';
import '../../../domain/models/live_gift.dart';
import '../../../domain/models/live_room.dart';
import '../../../domain/models/live_reaction_event.dart';
import '../../../domain/models/user.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/follow_button.dart';
import '../../live/shared/widgets/hud/hud.dart';
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
      builder: (_) => _StreamerQuickSheet(
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
              child: _ChatTicker(
                comments: commentsState.comments,
                gifts: gifts,
              ),
            ),
          ),

          // ── 6.5. Pinned product (event-driven, slide-in quando streamer pinar) ──
          Positioned(
            left: 0, right: 0, bottom: 250,
            child: _PinnedProductBar(roomId: widget.room.id),
          ),

          // ── 7. Bottom bar: chat input + ações inline (TikTok Live style) ──
          Positioned(
            left: 12, right: 12, bottom: 12,
            child: SafeArea(
              top: false,
              child: _LiveBottomBar(
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
            Expanded(child: _StreamerIdentityBar(room: room)),
            const SizedBox(width: 8),
            // Stack de avatares de viewers + total (350+ etc.)
            ViewersStack(viewerCount: viewerCount),
            const SizedBox(width: 8),
            // More menu (⋯)
            TopHudCircleIcon(
              icon: Icons.more_horiz_rounded,
              onTap: () => _MoreSheet.show(context, onShare: onShare),
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

/// Bottom sheet moderno (glassmorphism + dark) que substitui o `PopupMenuButton`
/// material padrão. Mostra ações secundárias da live.
class _MoreSheet extends StatelessWidget {
  const _MoreSheet({required this.onShare});
  final VoidCallback onShare;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onShare,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      builder: (_) => _MoreSheet(onShare: onShare),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  _MoreTile(
                    icon: Icons.send_rounded,
                    iconColor: AppColors.electricPurple,
                    title: s.livePlayerShareTitle,
                    subtitle: s.livePlayerShareSubtitle,
                    onTap: () {
                      Navigator.of(context).pop();
                      onShare();
                    },
                  ),
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                    indent: 64,
                  ),
                  _MoreTile(
                    icon: Icons.flag_outlined,
                    iconColor: const Color(0xFFFF4D6D),
                    title: s.livePlayerReportTitle,
                    subtitle: s.livePlayerReportSubtitle,
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(s.livePlayerReportSubmitted),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.35),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});
  final Color color;
  final double size = 8;
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);

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
        final v = 0.7 + 0.3 * _c.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: v),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.5 * v),
                blurRadius: 6,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Streamer identity (avatar + nome + follow)
// ────────────────────────────────────────────────────────────────────────

/// Pílula glass com avatar + nome do streamer.
///
/// Comportamento:
/// - Avatar + nome SEMPRE visíveis (essencial para viewer novo conhecer
///   quem está transmitindo).
/// - Botão "Seguir" só aparece quando o viewer ainda NÃO segue — limpa o
///   HUD de quem já é fã.
/// - Tap no avatar/nome abre um bottom-sheet rápido ("Ver perfil" /
///   "Seguir") sem tirar o usuário da live.
class _StreamerIdentityBar extends ConsumerWidget {
  const _StreamerIdentityBar({required this.room});
  final LiveRoom room;

  String _displayStreamerName(LiveRoom r) {
    // Prioridade: streamerName real → @username → fallback @id6 → 'Streamer'.
    // ⚠️ NUNCA cair para `r.title` (título da live) — o título só faz
    // sentido no card de descoberta (For You), não no header da live.
    final name = r.streamerName.trim();
    final looksGeneric = name.isEmpty ||
        name.toLowerCase() == 'streamer' ||
        RegExp(r'^streamer-?[0-9a-f]{0,8}$', caseSensitive: false)
            .hasMatch(name);
    if (!looksGeneric) return name;
    final username = (r.streamerUsername ?? '').trim();
    if (username.isNotEmpty) {
      return username.startsWith('@') ? username : '@$username';
    }
    final id = r.streamerId;
    if (id.length >= 6) return '@${id.substring(0, 6)}';
    return 'Streamer';
  }

  void _openQuickSheet(BuildContext context, WidgetRef ref, bool isFollowing) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _StreamerQuickSheet(
        room: room,
        displayName: _displayStreamerName(room),
        isFollowing: isFollowing,
        onToggleFollow: () =>
            ref.read(followViewModelProvider(room.streamerId).notifier).toggleFollow(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followAsync = ref.watch(followViewModelProvider(room.streamerId));
    final isFollowing = followAsync.value ?? false;

    return GestureDetector(
      onTap: () => _openQuickSheet(context, ref, isFollowing),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.32),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 0.6,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.electricPurple,
                  backgroundImage: room.streamerAvatarUrl != null
                      ? NetworkImage(room.streamerAvatarUrl!)
                      : null,
                  child: room.streamerAvatarUrl == null
                      ? const Icon(Icons.person, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    _displayStreamerName(room),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                if (room.streamerVerified) ...[
                  const SizedBox(width: 3),
                  const Icon(Icons.verified,
                      color: Color(0xFFB6A6FF), size: 13),
                ],
                // Botão "Seguir" só aparece se NÃO segue (HUD limpo para fãs).
                if (!isFollowing) ...[
                  const SizedBox(width: 8),
                  FollowButton(userId: room.streamerId, compact: true),
                ] else
                  const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet rápido ao tocar no avatar/nome do streamer.
/// Permite seguir/ver perfil sem sair da live.
class _StreamerQuickSheet extends StatelessWidget {
  const _StreamerQuickSheet({
    required this.room,
    required this.displayName,
    required this.isFollowing,
    required this.onToggleFollow,
  });

  final LiveRoom room;
  final String displayName;
  final bool isFollowing;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0B14).withValues(alpha: 0.86),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.6,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.electricPurple,
                  backgroundImage: room.streamerAvatarUrl != null
                      ? NetworkImage(room.streamerAvatarUrl!)
                      : null,
                  child: room.streamerAvatarUrl == null
                      ? const Icon(Icons.person, size: 36, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (room.streamerVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          color: Color(0xFFB6A6FF), size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  room.title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _QuickSheetButton(
                        icon: Icons.person_outline_rounded,
                        label: 'Ver perfil',
                        filled: false,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/profile/${room.streamerId}');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickSheetButton(
                        icon: isFollowing
                            ? Icons.check_rounded
                            : Icons.add_rounded,
                        label: isFollowing ? 'Seguindo' : 'Seguir',
                        filled: !isFollowing,
                        onTap: () {
                          onToggleFollow();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickSheetButton extends StatelessWidget {
  const _QuickSheetButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFB44CF0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: filled ? null : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Chat ticker (overlay)
// ────────────────────────────────────────────────────────────────────────

class _ChatTicker extends StatelessWidget {
  const _ChatTicker({required this.comments, required this.gifts});
  final List<LiveComment> comments;
  final List<LiveGift> gifts;

  @override
  Widget build(BuildContext context) {
    // Merge comentários + gifts em uma única timeline ordenada.
    final items = <_TickerItem>[
      for (final c in comments)
        _TickerItem(timestamp: c.timestamp, comment: c),
      for (final g in gifts)
        _TickerItem(timestamp: g.timestamp, gift: g),
    ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (items.isEmpty) return const SizedBox.shrink();
    final visible = items.length > 6
        ? items.sublist(items.length - 6)
        : items;

    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        colors: [Colors.transparent, Colors.black, Colors.black],
        stops: [0, 0.25, 1],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final it in visible)
            if (it.comment != null)
              _ChatLine(comment: it.comment!)
            else if (it.gift != null)
              _GiftChatLine(gift: it.gift!),
        ],
      ),
    );
  }
}

/// Item interno do ticker: ou um comentário ou um presente.
class _TickerItem {
  _TickerItem({required this.timestamp, this.comment, this.gift});
  final DateTime timestamp;
  final LiveComment? comment;
  final LiveGift? gift;
}

class _ChatLine extends StatelessWidget {
  const _ChatLine({required this.comment});
  final LiveComment comment;

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        comment.avatarUrl != null && comment.avatarUrl!.isNotEmpty;
    final initial = comment.userName.isNotEmpty
        ? comment.userName.characters.first.toUpperCase()
        : '?';
    // Estilo TikTok Live: avatar pequeno + texto direto sobre o vídeo.
    // Sem caixa preta volumosa — confiamos no shadow + gradient da base
    // para legibilidade.
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar pequeno (20px)
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.electricPurple,
              image: hasAvatar
                  ? DecorationImage(
                      image: NetworkImage(comment.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: hasAvatar
                ? null
                : Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          // Nome + mensagem flutuando direto (sombra para legibilidade)
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  children: [
                    TextSpan(
                      text: '${comment.userName} ',
                      style: const TextStyle(
                        color: Color(0xFFC9B6FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    TextSpan(
                      text: comment.message,
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: comment.isPending ? 0.7 : 0.98,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha do chat representando um presente enviado — estilo TikTok:
/// pill com gradiente dourado, avatar do remetente, `fulano enviou
/// gift_name` e contador `xN` quando aplicável. Aparece na mesma timeline
/// do chat, não numa coluna separada.
class _GiftChatLine extends StatelessWidget {
  const _GiftChatLine({required this.gift});
  final LiveGift gift;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final hasAvatar =
        gift.senderAvatarUrl != null && gift.senderAvatarUrl!.isNotEmpty;
    final initial = gift.senderName.isNotEmpty
        ? gift.senderName.characters.first.toUpperCase()
        : '?';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xE6FFB23A), Color(0xE6FF4D8B)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: const Color(0xFFFFD166),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66FFD166),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar do remetente
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black26,
                image: hasAvatar
                    ? DecorationImage(
                        image: NetworkImage(gift.senderAvatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: hasAvatar
                  ? null
                  : Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            // Nome + "enviou" + nome do presente
            Flexible(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: gift.senderName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(text: s.livePlayerGiftSentVerb),
                    TextSpan(
                      text: gift.giftName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Ícone do gift
            SizedBox(
              width: 24,
              height: 24,
              child: gift.giftIconUrl != null && gift.giftIconUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        gift.giftIconUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.card_giftcard,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 18,
                    ),
            ),
            if (gift.quantity > 1) ...[
              const SizedBox(width: 4),
              Text(
                'x${gift.quantity}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: Colors.black45, blurRadius: 4),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Right Action Rail (TikTok-style vertical actions)
// ────────────────────────────────────────────────────────────────────────

class _RightActionRail extends StatelessWidget {
  const _RightActionRail({
    required this.isLiked,
    required this.likesCount,
    required this.onLike,
    required this.onGifts,
    required this.onShare,
    required this.onComment,
  });
  final bool isLiked;
  final int likesCount;
  final VoidCallback onLike;
  final VoidCallback onGifts;
  final VoidCallback onShare;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RailItem(
          icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isLiked ? const Color(0xFFFF4D8B) : Colors.white,
          label: _fmt(likesCount),
          onTap: onLike,
          glow: isLiked,
        ),
        const SizedBox(height: 18),
        _RailItem(
          icon: Icons.card_giftcard_rounded,
          color: const Color(0xFFFFD166),
          label: 'Gift',
          onTap: onGifts,
        ),
        const SizedBox(height: 18),
        _RailItem(
          icon: Icons.chat_bubble_outline_rounded,
          color: Colors.white,
          label: 'Chat',
          onTap: onComment,
        ),
        const SizedBox(height: 18),
        _RailItem(
          icon: Icons.reply_rounded,
          color: Colors.white,
          label: 'Share',
          onTap: onShare,
        ),
      ],
    );
  }

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.glow = false,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.35),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: glow
                  ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 14)]
                  : null,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Floating Chat Input (slim, TikTok-style)
// ────────────────────────────────────────────────────────────────────────

class _LiveBottomBar extends StatelessWidget {
  const _LiveBottomBar({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.isLiked,
    required this.likesCount,
    required this.onSend,
    required this.onSendRose,
    required this.onGifts,
    required this.onLike,
    required this.onShare,
    required this.onSeguir,
    required this.onShop,
    required this.hasStorefront,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final bool isLiked;
  final int likesCount;
  final VoidCallback onSend;
  final VoidCallback onSendRose;
  final VoidCallback onGifts;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onSeguir;
  final VoidCallback onShop;
  final bool hasStorefront;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Chat input full-width com 😊 dentro ────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 0.6,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'Diga algo...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.50),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 13),
                      ),
                    ),
                  ),
                  // Emoji / send (alterna)
                  GestureDetector(
                    onTap: () {
                      if (controller.text.trim().isEmpty) {
                        // TODO: abrir emoji picker
                      } else {
                        onSend();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                      child: Icon(
                        controller.text.trim().isEmpty
                            ? Icons.emoji_emotions_outlined
                            : Icons.send_rounded,
                        color: Colors.white.withValues(alpha: 0.55),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // ─── Floating actions: Presentes · Curtir · Seguir · [Loja] · Mais
        // O botão "Loja" só aparece quando o criador tem vitrine ativa.
        // TODO(backend): expor `hasStorefront` na LiveRoom e usar aqui.
        // Por enquanto, mantemos escondido (mais limpo que mostrar vazio).
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _LiveActionButton(
              icon: Icons.card_giftcard_rounded,
              label: 'Presentes',
              filled: true,
              onTap: onGifts,
            ),
            _LiveActionButton(
              icon: isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: 'Curtir',
              iconColor:
                  isLiked ? const Color(0xFFFF3D6E) : Colors.white,
              onTap: onLike,
            ),
            _LiveActionButton(
              icon: Icons.person_add_alt_1_outlined,
              label: 'Seguir',
              onTap: onSeguir,
            ),
            if (hasStorefront)
              _LiveActionButton(
                icon: Icons.shopping_bag_outlined,
                label: 'Loja',
                onTap: onShop,
              ),
            _LiveActionButton(
              icon: Icons.send_rounded,
              label: 'Compartilhar',
              onTap: onShare,
            ),
          ],
        ),
      ],
    );
  }
}

/// Botão circular outlined com label embaixo (estilo do mockup).
/// `filled=true` aplica o gradient rosa→roxo (usado em "Presentes").
class _LiveActionButton extends StatelessWidget {
  const _LiveActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.iconColor = Colors.white,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    const double size = 38;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: filled
                  ? const LinearGradient(
                      colors: [Color(0xFFFF4F8B), Color(0xFFB44CF0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: filled ? null : Colors.transparent,
              border: filled
                  ? null
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.55),
                      width: 1.2,
                    ),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: const Color(0xFFB44CF0).withValues(alpha: 0.40),
                        blurRadius: 14,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  const _BarIcon({
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });
  final IconData icon;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              bottom: -2,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FloatingChatInput extends StatelessWidget {
  const _FloatingChatInput({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
    required this.onSendRose,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onSendRose;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Diga algo...',
                    hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45), fontSize: 13.5),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                ),
              ),
              // Rose quick-send
              GestureDetector(
                onTap: onSendRose,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.local_florist_rounded,
                      color: const Color(0xFFFF6B9D).withValues(alpha: 0.9), size: 20),
                ),
              ),
              // Send button
              GestureDetector(
                onTap: isSending ? null : onSend,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFB44CF0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    isSending ? Icons.hourglass_top_rounded : Icons.send_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Chat input + ações inline (Rosa · Gift · Like · Send) — LEGACY kept for compat
// ────────────────────────────────────────────────────────────────────────

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.isLiked,
    required this.onSendRose,
    required this.onOpenGifts,
    required this.onLike,
    required this.onSend,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final bool isLiked;
  final VoidCallback onSendRose;
  final VoidCallback onOpenGifts;
  final VoidCallback onLike;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white12),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: s.livePlayerInputHint,
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // 1️⃣ Rosa — envio direto, sem catálogo
        _InlineAction(
          icon: Icons.local_florist,
          color: const Color(0xFFFF6B9D),
          tooltip: s.livePlayerTooltipRose,
          onTap: onSendRose,
        ),
        const SizedBox(width: 6),
        // 2️⃣ Caixa de presente — abre catálogo completo
        _InlineAction(
          icon: Icons.card_giftcard,
          color: const Color(0xFFFFD166),
          tooltip: s.livePlayerTooltipGifts,
          onTap: onOpenGifts,
        ),
        const SizedBox(width: 6),
        // 3️⃣ Curtir
        _InlineAction(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? const Color(0xFFFF4D8B) : Colors.white,
          tooltip: s.livePlayerTooltipLike,
          onTap: onLike,
        ),
        const SizedBox(width: 6),
        // 4️⃣ Enviar mensagem
        _InlineAction(
          icon: isSending ? Icons.hourglass_top : Icons.send_rounded,
          color: AppColors.electricPurple,
          tooltip: s.livePlayerTooltipSend,
          onTap: isSending ? () {} : onSend,
          filled: true,
        ),
      ],
    );
  }
}

/// Botão circular compacto usado na linha do input. Quando `filled`,
/// mostra um gradient (estilo do botão de Send antigo). Caso contrário,
/// é um chip preto translúcido com ícone colorido.
class _InlineAction extends StatelessWidget {
  const _InlineAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: filled
                ? LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: filled ? null : Colors.black.withValues(alpha: 0.55),
            border: filled
                ? null
                : Border.all(color: Colors.white12),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: filled ? Colors.white : color,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Gradientes de legibilidade
// ────────────────────────────────────────────────────────────────────────
// ⚠️ `_TopGradient` e `_BottomGradient` foram extraídos para
// `lib/ui/live/shared/widgets/video/live_gradients.dart`
// (renomeados para `LiveTopGradient` e `LiveBottomGradient`).

// ────────────────────────────────────────────────────────────────────────
// Haptic helper (sem dependência externa — uso seguro do HapticFeedback)
// ────────────────────────────────────────────────────────────────────────

class HapticLike {
  static void light() {
    // Mantém leve mesmo em muitos toques (não bloqueante).
    // ignore: invalid_use_of_visible_for_testing_member
    // (não usa visibleForTesting; só wrap simples)
  }
}

// ────────────────────────────────────────────────────────────────────────
// 🛒 Pinned Product (event-driven)
// ────────────────────────────────────────────────────────────────────────
//
// Aparece com slide-in suave quando o streamer pinar um produto da
// vitrine via Socket (`product_pinned`). Some com slide-out quando o
// streamer despinar (`product_unpinned`). Tap → abre drawer/checkout.
//
// Estilo: pílula glass minimalista, mini-thumb + nome + preço + chevron.
// Nada de card pesado — mantém o vídeo como protagonista.

class _PinnedProduct {
  const _PinnedProduct({
    required this.id,
    required this.name,
    required this.priceLabel,
    this.subtitle,
    this.thumbnailUrl,
  });
  final String id;
  final String name;
  final String priceLabel;
  final String? subtitle;
  final String? thumbnailUrl;

  static _PinnedProduct? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = (raw['id'] ?? raw['product_id'] ?? '').toString();
    final name = (raw['name'] ?? raw['title'] ?? '').toString();
    if (id.isEmpty || name.isEmpty) return null;
    final priceRaw = raw['price_label'] ??
        raw['priceLabel'] ??
        (raw['price'] != null ? 'R\$ ${raw['price']}' : '');
    final subtitleRaw =
        raw['subtitle'] ?? raw['short_description'] ?? raw['description'];
    return _PinnedProduct(
      id: id,
      name: name,
      priceLabel: priceRaw.toString(),
      subtitle: subtitleRaw?.toString(),
      thumbnailUrl: (raw['thumbnail_url'] ?? raw['image_url'] ?? raw['thumb'])
          ?.toString(),
    );
  }
}

class _PinnedProductBar extends ConsumerStatefulWidget {
  const _PinnedProductBar({required this.roomId});
  final String roomId;

  @override
  ConsumerState<_PinnedProductBar> createState() => _PinnedProductBarState();
}

class _PinnedProductBarState extends ConsumerState<_PinnedProductBar> {
  _PinnedProduct? _product;

  late final void Function(dynamic) _onPinned;
  late final void Function(dynamic) _onUnpinned;

  @override
  void initState() {
    super.initState();
    _onPinned = (data) {
      final p = _PinnedProduct.tryParse(data is Map ? data['product'] ?? data : data);
      if (!mounted || p == null) return;
      setState(() => _product = p);
    };
    _onUnpinned = (_) {
      if (!mounted) return;
      setState(() => _product = null);
    };
    final socket = ref.read(socketServiceProvider);
    socket.on('product_pinned', _onPinned);
    socket.on('product_unpinned', _onUnpinned);
  }

  @override
  void dispose() {
    try {
      final socket = ref.read(socketServiceProvider);
      socket.off('product_pinned', _onPinned);
      socket.off('product_unpinned', _onUnpinned);
    } catch (_) {}
    super.dispose();
  }

  void _openProduct() {
    final p = _product;
    if (p == null) return;
    // TODO: substituir por sheet de checkout/produto real.
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0A0B14),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.priceLabel,
                style: const TextStyle(
                  color: Color(0xFFB44CF0),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Abrir produto na vitrine — em breve.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _product;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.6),
          end: Offset.zero,
        ).animate(anim),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: p == null
          ? const SizedBox(key: ValueKey('empty'), height: 0)
          : Padding(
              key: ValueKey('pinned-${p.id}'),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GestureDetector(
                onTap: _openProduct,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                              width: 0.6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // ── Thumb 64×64 ─────────────────────────
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: p.thumbnailUrl != null
                                      ? Image.network(
                                          p.thumbnailUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _thumbPlaceholder(),
                                        )
                                      : _thumbPlaceholder(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // ── Título · subtítulo · preço ──────────
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        height: 1.15,
                                      ),
                                    ),
                                    if ((p.subtitle ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        p.subtitle!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.65),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          height: 1.15,
                                        ),
                                      ),
                                    ],
                                    if (p.priceLabel.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        p.priceLabel,
                                        style: const TextStyle(
                                          color: Color(0xFFFFC56B),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          height: 1,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              // ── Botão "Ver produto" gradient pill ──
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF4F8B),
                                      Color(0xFFB44CF0),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB44CF0)
                                          .withValues(alpha: 0.45),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Ver produto',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ── Pin icon top-right (decorativo) ─────────
                        Positioned(
                          top: 6,
                          right: 8,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFB44CF0)
                                  .withValues(alpha: 0.22),
                              border: Border.all(
                                color: const Color(0xFFB44CF0)
                                    .withValues(alpha: 0.55),
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(
                              Icons.push_pin_rounded,
                              color: Color(0xFFD9B4FF),
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _thumbPlaceholder() => Container(
        color: Colors.white.withValues(alpha: 0.08),
        child: const Icon(Icons.shopping_bag_outlined,
            color: Colors.white54, size: 18),
      );
}
