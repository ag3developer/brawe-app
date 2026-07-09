import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../view_models/live_room_comments_view_model.dart';
import '../view_models/live_room_gifts_view_model.dart';
import '../../core/view_models/follow_view_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../data/services/battle_service.dart';
import '../../../data/services/socket_service.dart';
import '../../../domain/models/live_room.dart';
import '../../../domain/models/live_reaction_event.dart';
import '../../../domain/models/user.dart';
import '../../live/shared/widgets/actions/actions.dart';
import '../../live/shared/widgets/chat/chat.dart';
import '../../live/shared/widgets/commerce/commerce.dart';
import '../../live/shared/widgets/hud/hud.dart';
import '../../live/shared/widgets/overlays/overlays.dart';
import '../../live/shared/widgets/video/live_gradients.dart';
import 'viewer_battle_hud.dart';
import 'dual_hls_player.dart';
import '../view_models/battle_view_model.dart';
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

  // 🌹 Rose batching — igual às reactions, agrega taps em 400ms e envia
  // 1 request com quantity=N. Evita estouro do rate limit (30/min) quando
  // o usuário clica em combo rápido (TikTok-style).
  Timer? _roseFlushTimer;
  Timer? _battleCheckDebounce;
  int _pendingRoses = 0;

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
    // ⚡ Se o room já veio com battleId (live_type=battle + dados enriquecidos
    // pelo backend), seta o HUD imediatamente — sem nenhum roundtrip extra.
    // Isso elimina a tela de loading dupla ao entrar em live de batalha.
    if (widget.room.liveType == 'battle' &&
        widget.room.battleId != null &&
        widget.room.battleId!.isNotEmpty) {
      _activeBattleId = widget.room.battleId;
    }
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
    _roseFlushTimer?.cancel();
    _flushRoses(force: true);
    _reactionSub?.cancel();
    _battleCheckDebounce?.cancel();
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
    // 🔁 Re-anexar handler em reconexões (idêntico ao broadcaster).
    socket.addReconnectCallback(_reattachBattleHandlers);
    // Verifica se a live já está em batalha (viewer entrou mid-battle)
    _checkActiveBattle();
  }

  void _reattachBattleHandlers() {
    if (!mounted) return; // widget pode ter sido descartado antes do callback
    final socket = ref.read(socketServiceProvider);
    socket.off(AppConstants.eventBattleStarted);
    socket.on(AppConstants.eventBattleStarted, _onBattleStarted);
    // Após reconectar, valida via REST se uma batalha começou durante
    // a queda de conexão — com debounce de 5s para evitar spam em
    // reconexões rápidas (ex: restart do servidor durante deploy).
    _debouncedCheckActiveBattle();
  }

  void _unsubscribeFromBattleEvents() {
    try {
      final socket = ref.read(socketServiceProvider);
      socket.off(AppConstants.eventBattleStarted);
      socket.removeReconnectCallback(_reattachBattleHandlers);
    } catch (_) {}
  }

  /// Debounce de 5s para evitar spam de chamadas ao /battle/active em
  /// reconexões rápidas (ex: restart do servidor durante deploy).
  void _debouncedCheckActiveBattle() {
    _battleCheckDebounce?.cancel();
    _battleCheckDebounce = Timer(
      const Duration(seconds: 5),
      _checkActiveBattle,
    );
  }

  /// Consulta o backend para saber se já existe uma batalha ativa nesta sala.
  /// Necessário quando o viewer entra na live depois da batalha já ter começado
  /// (o evento `connect:battle:started` já foi emitido antes da entrada).
  /// SKIP: se o room já veio com battleId (enriquecido pelo backend), não há
  /// necessidade de roundtrip — o battleId foi setado no initState.
  Future<void> _checkActiveBattle() async {
    if (!mounted) return;
    // Se o battleId já foi carregado via room detail (backend enriched), skip.
    if (_activeBattleId != null && _activeBattleId!.isNotEmpty) return;
    try {
      final result = await ref
          .read(battleServiceProvider)
          .getActiveBattleForRoom(widget.room.id);
      final battleId = result['battle_id'] as String?;
      if (battleId != null && battleId.isNotEmpty && mounted) {
        // Overlay (não navega): a batalha vira uma camada por cima desta
        // live — vídeo, chat, rosa e presentes continuam vivos atrás.
        setState(() => _activeBattleId = battleId);
      }
    } catch (_) {
      // 404 = sem batalha ativa — silencioso.
    }
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
    // 🛡️ Parse defensivo: o socket pode entregar Map OU String JSON
    // (depende de transport/encoding). Sem isso, eventos válidos eram
    // descartados silenciosamente.
    final data = _parseSocketPayload(raw);
    if (data == null) return;
    final battleId = data['battle_id'] as String?;
    if (battleId == null || battleId.isEmpty) return;
    // Overlay (não navega): mostra o HUD de batalha por cima da live atual.
    setState(() => _activeBattleId = battleId);
  }

  /// Converte o payload bruto do socket em Map.
  /// O `socket_io_client` às vezes entrega o evento já decodificado (`Map`)
  /// e às vezes como `String` JSON — depende do transport (websocket vs polling)
  /// e do middleware no servidor. Tratamos os 2 casos.
  Map<String, dynamic>? _parseSocketPayload(dynamic raw) {
    try {
      if (raw is Map<String, dynamic>) return raw;
      if (raw is Map) return Map<String, dynamic>.from(raw);
      if (raw is String && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      debugPrint('LivePlayer: socket payload parse error: $e (raw=$raw)');
    }
    return null;
  }

  Future<void> _initializePlayer() async {
    if (_controller != null) return;
    final streamUrl = widget.room.streamUrl;
    if (streamUrl == null || streamUrl.isEmpty) return;
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(streamUrl),
      videoPlayerOptions: VideoPlayerOptions(
        // Permite que SFX/gifts toquem junto com o áudio da live.
        mixWithOthers: true,
        // ⭐ Mantém o áudio rolando em segundo plano (avFoundation) quando o
        // app perde foco momentâneo (notificação, alarme). Reduz cortes.
        allowBackgroundPlayback: false,
      ),
      // Cabeçalhos para o HLS da Mux — User-Agent identifica o app no
      // analytics e ajuda em CDN-edge caching.
      httpHeaders: const {'User-Agent': 'BraweApp/1.0 (HLS-Live)'},
    );
    try {
      await _controller!.initialize();
      if (!mounted) return;

      // Seek para o live edge (último segmento disponível) logo após inicializar.
      // Sem isso, o player pode começar a reproduzir de um ponto anterior no
      // buffer HLS, aumentando o delay percebido pelo espectador.
      final duration = _controller!.value.duration;
      if (duration > Duration.zero) {
        await _controller!.seekTo(duration);
      }

      setState(() => _isInitialized = true);
      _controller!
        ..play()
        // Live HLS NÃO faz loop — é stream contínuo.
        ..setLooping(false)
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
    HapticFeedback.lightImpact();
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
    _reactionFlushTimer = Timer(
      const Duration(milliseconds: 250),
      _flushReactions,
    );
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
      // Em batalha, o presente pontua no placar (mesmo caminho da rosa).
      battleId: _activeBattleId,
    );
  }

  /// Abre o quick sheet do streamer (mesmo usado ao tocar no avatar do topo).
  /// Single source of truth do fluxo de follow.
  void _openStreamerSheet() {
    final room = widget.room;
    final rawName = room.streamerName.trim();
    final looksGeneric =
        rawName.isEmpty ||
        rawName.toLowerCase() == 'streamer' ||
        RegExp(
          r'^streamer-?[0-9a-f]{0,8}$',
          caseSensitive: false,
        ).hasMatch(rawName);
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

  /// 🌹 Atalho rápido — envia 1 rosa direto, sem abrir o catálogo.
  ///
  /// **Batch TikTok-style**: agrega taps em 400ms e envia 1 request
  /// com `quantity=N`. Isso elimina o 429 (rate limit 30/min) quando o
  /// usuário clica em combo rápido — antes cada tap era 1 request.
  ///
  /// Animação: o spawn local do coração é IMEDIATO (sem esperar o flush).
  /// O backend confirma via socket `gift_received` após o batch.
  void _sendRose() {
    HapticFeedback.lightImpact();
    _heartsKey.currentState?.spawn(1); // feedback visual imediato
    _pendingRoses += 1;
    _roseFlushTimer?.cancel();
    _roseFlushTimer = Timer(const Duration(milliseconds: 400), _flushRoses);
  }

  void _flushRoses({bool force = false}) {
    if (_pendingRoses <= 0) return;
    final qty = _pendingRoses;
    _pendingRoses = 0;
    unawaited(_fireRoseRequest(quantity: qty));
  }

  Future<void> _fireRoseRequest({int quantity = 1}) async {
    // Captura o repository ANTES do await — ref não pode ser lido
    // depois que o widget foi disposed.
    final repo = ref.read(giftRepositoryProvider);
    try {
      await repo.sendGift(
        roomId: widget.room.id,
        giftId: 'rose',
        receiverId: widget.room.streamerId,
        quantity: quantity,
        battleId: _activeBattleId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao enviar rosa: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    }
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
    final commentsState = ref.watch(
      liveRoomCommentsViewModelProvider(widget.room.id),
    );
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
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: LiveTopBar(
                  room: widget.room,
                  viewerCount: commentsState.viewerCount,
                  likesCount: _likesCount,
                  roomId: widget.room.id,
                  onBack: () => context.pop(),
                  onShare: _onTapShare,
                  recentViewerAvatars: commentsState.recentViewerAvatars,
                  gifterRanking: commentsState.gifterRanking,
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
            left: 12,
            right: 12,
            bottom: 160,
            child: IgnorePointer(
              child: ChatTicker(comments: commentsState.comments, gifts: gifts),
            ),
          ),

          // ── 6.5. Pinned product (event-driven, slide-in quando streamer pinar) ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 250,
            child: PinnedProductBar(roomId: widget.room.id),
          ),

          // ── 7. Bottom bar: chat input + ações inline (TikTok Live style) ──
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
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

          // ── 8. Battle HUD (overlay) — só aparece em batalha ──
          // Camada LEVE por cima da live: placar dos 2 participantes + timer
          // + toasts de gift no topo. NÃO substitui a tela: vídeo, chat,
          // rosa e presentes continuam vivos atrás. Mesmo padrão do streamer
          // (BroadcasterScreen → StreamerBattleHud).
          if (_activeBattleId != null)
            Positioned.fill(
              child: ViewerBattleHud(
                battleId: _activeBattleId!,
                onClose: () {
                  if (mounted) setState(() => _activeBattleId = null);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoLayer() {
    // 🎬 BATTLE MODE — renderiza split-screen 50/50 numa faixa central,
    // exatamente como TikTok/Bigo PK: fundo preto total, vídeos entre o
    // top bar e o chat (NÃO de fora a fora).
    if (_activeBattleId != null) {
      final asyncBattle = ref.watch(battleViewModelProvider(_activeBattleId!));
      final battle = asyncBattle.value;
      if (battle != null &&
          (battle.streamUrlA != null || battle.streamUrlB != null)) {
        // Pausar o single-controller pra não competir por áudio/CPU.
        if (_controller?.value.isInitialized == true &&
            _controller!.value.isPlaying) {
          _controller!.pause();
          _controller!.setVolume(0.0);
        }

        // TikTok PK layout: fundo preto ocupa 100% da tela; o DualHlsPlayer
        // fica numa faixa vertical restrita entre o top bar e o bottom bar.
        //
        //  ┌─────────────────────────────────┐  ← topo da tela
        //  │  SafeArea.top + LiveTopBar ~80px │  (preto / gradiente)
        //  ├─────────────────────────────────┤
        //  │  ← DualHlsPlayer (split 50/50)  │  ← videoH = ~55% da tela
        //  ├─────────────────────────────────┤
        //  │  Chat + ações  ~140px + bottom  │  (preto)
        //  └─────────────────────────────────┘
        final mq = MediaQuery.of(context);
        const kTopBarH =
            80.0; // altura estimada do LiveTopBar (abaixo SafeArea)
        const kBottomBarH = 140.0; // LiveBottomBar + padding inferior
        final topOffset = mq.padding.top + kTopBarH;
        final bottomOffset = mq.padding.bottom + kBottomBarH;
        final videoH = (mq.size.height - topOffset - bottomOffset).clamp(
          200.0,
          mq.size.height * 0.62,
        );

        return Container(
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: topOffset),
              SizedBox(
                height: videoH,
                child: DualHlsPlayer(
                  streamUrlA: battle.streamUrlA,
                  streamUrlB: battle.streamUrlB,
                  streamerAName: battle.streamerAName,
                  streamerBName: battle.streamerBName,
                ),
              ),
              // Espaço restante fica preto — chat e ações vivem aqui como
              // overlay (camadas superiores do Stack pai).
            ],
          ),
        );
      }
      // Fallback: batalha ativa mas URLs ainda não chegaram (raríssimo —
      // backend já envia tudo no `started`). Cai pro single-controller
      // do streamer dono dessa sala enquanto o REST/socket sincroniza.
    } else {
      // Voltou pro modo solo: garantir que o single-controller esteja
      // tocando com áudio (caso tenha sido pausado durante a batalha).
      if (_controller?.value.isInitialized == true &&
          !_controller!.value.isPlaying) {
        _controller!.play();
        _controller!.setVolume(1.0);
      }
    }

    // ── Modo SOLO (default) ──
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

// ⚠️ _TopBar migrado para lib/ui/live/shared/widgets/hud/live_top_bar.dart
//    (renomeado para LiveTopBar público).

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

// ⚠️ _PinnedProduct + _PinnedProductBar migrados para
//    lib/ui/live/shared/widgets/commerce/pinned_product_bar.dart
//    (renomeados para PinnedProduct/PinnedProductBar públicos).
