import 'dart:async';
import 'dart:convert';
import 'dart:math' show max;
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
import '../../../domain/models/failure.dart';
import '../../../domain/models/live_comment.dart';
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
import '../../wallet/widgets/top_up_coins_sheet.dart';
import '../../core/themes/app_colors.dart';

// ── Qualidade de stream ───────────────────────────────────────────────────────

enum StreamQuality {
  auto('Auto', null),
  p480('480p', '480p'),
  p720('720p HD', '720p'),
  p1080('1080p Full HD', '1080p');

  const StreamQuality(this.label, this.maxResolution);

  /// Label exibido para o usuário.
  final String label;

  /// Valor do parâmetro `max_resolution` para a Mux CDN. null = sem restrição.
  final String? maxResolution;

  /// Constrói a URL HLS com o parâmetro correto.
  String buildUrl(String playbackId) {
    final base = 'https://stream.mux.com/$playbackId.m3u8';
    if (maxResolution == null) return base; // auto: sem restrição
    return '$base?max_resolution=$maxResolution';
  }
}

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

  /// Qualidade selecionada pelo usuário. Padrão: Auto.
  StreamQuality _quality = StreamQuality.auto;

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

  /// Pausa do criador (overlay "Já voltamos" / "Voltando…").
  _StreamerPauseState _pauseState = _StreamerPauseState.none;
  Timer? _resumeOverlayTimer;

  /// Último modo aplicado ao player solo (null = ainda não aplicado).
  bool? _soloPlaying;

  // Floating hearts overlay key (para spawn local imediato)
  final GlobalKey<FloatingHeartsOverlayState> _heartsKey =
      GlobalKey<FloatingHeartsOverlayState>();

  /// Capturado no initState (ver `_fireRoseRequest`).
  late final GiftRepository _giftRepo;
  late final LiveRepository _liveRepo;

  // Chat input
  final TextEditingController _chatCtrl = TextEditingController();
  final FocusNode _chatFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Fullscreen imersivo: esconde status bar e nav bar durante a live
    // (vídeo ocupa 100% da tela, igual Stories/TikTok Live). Restaurado no
    // dispose. Ver ANDROID_EDGE_TO_EDGE_AUDIT.md, Fase E.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _likesCount = widget.room.totalLikes;
    _giftRepo = ref.read(giftRepositoryProvider);
    _liveRepo = ref.read(liveRepositoryProvider);
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
    _resumeOverlayTimer?.cancel();
    _chatCtrl.dispose();
    _chatFocus.dispose();
    _controller?.dispose();
    _unsubscribeFromBattleEvents();
    WakelockPlus.disable();
    // Restaura as barras do sistema ao sair da live.
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  // ── Battle events ──────────────────────────────────────────────────────────

  // ⚠️ Sempre `off(evento, handler)`: `off(evento)` sem handler remove os
  // listeners de TODAS as telas/view models (ex.: o BattleViewModel) e a
  // 2ª batalha deixava de aparecer.
  void _subscribeToBattleEvents() {
    final socket = ref.read(socketServiceProvider);
    socket.on(AppConstants.eventBattleStarted, _onBattleStarted);
    socket.on(AppConstants.eventBattleCancelled, _onBattleCancelled);
    socket.on(AppConstants.eventLivePaused, _onLivePaused);
    socket.on(AppConstants.eventLiveResumed, _onLiveResumed);
    // 🔁 Re-anexar handler em reconexões (idêntico ao broadcaster).
    socket.addReconnectCallback(_reattachBattleHandlers);
    // Verifica se a live já está em batalha (viewer entrou mid-battle)
    _checkActiveBattle();
  }

  void _reattachBattleHandlers() {
    if (!mounted) return; // widget pode ter sido descartado antes do callback
    final socket = ref.read(socketServiceProvider);
    socket.off(AppConstants.eventBattleStarted, _onBattleStarted);
    socket.off(AppConstants.eventBattleCancelled, _onBattleCancelled);
    socket.off(AppConstants.eventLivePaused, _onLivePaused);
    socket.off(AppConstants.eventLiveResumed, _onLiveResumed);
    socket.on(AppConstants.eventBattleStarted, _onBattleStarted);
    socket.on(AppConstants.eventBattleCancelled, _onBattleCancelled);
    socket.on(AppConstants.eventLivePaused, _onLivePaused);
    socket.on(AppConstants.eventLiveResumed, _onLiveResumed);
    // Após reconectar, valida via REST se uma batalha começou durante
    // a queda de conexão — com debounce de 5s para evitar spam em
    // reconexões rápidas (ex: restart do servidor durante deploy).
    _debouncedCheckActiveBattle();
  }

  void _unsubscribeFromBattleEvents() {
    try {
      final socket = ref.read(socketServiceProvider);
      socket.off(AppConstants.eventBattleStarted, _onBattleStarted);
      socket.off(AppConstants.eventBattleCancelled, _onBattleCancelled);
      socket.off(AppConstants.eventLivePaused, _onLivePaused);
      socket.off(AppConstants.eventLiveResumed, _onLiveResumed);
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
    if (!_isEventForThisRoom(data)) return;
    // Overlay (não navega): mostra o HUD de batalha por cima da live atual.
    setState(() => _activeBattleId = battleId);
  }

  /// Batalha cancelada (ex.: streamer encerrou a live durante a contagem).
  void _onBattleCancelled(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null || data['battle_id'] != _activeBattleId) return;
    setState(() => _activeBattleId = null);
  }

  // ── Pausa do criador ("Já voltamos") ─────────────────────────────────
  //
  // O socket avisa na hora; o vídeo HLS só reflete a pausa/retomada
  // 12-20s depois (latência "reduced" do Mux). Por isso, ao retomar,
  // mostramos "Voltando…" por esse intervalo em vez de sumir com o aviso
  // enquanto o slate ainda está na tela.

  void _onLivePaused(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null || data['room_id'] != widget.room.id) return;
    _resumeOverlayTimer?.cancel();
    _dismissKeyboard();
    setState(() => _pauseState = _StreamerPauseState.paused);
  }

  void _onLiveResumed(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null || data['room_id'] != widget.room.id) return;
    if (_pauseState == _StreamerPauseState.none) return;
    setState(() => _pauseState = _StreamerPauseState.resuming);
    _resumeOverlayTimer?.cancel();
    _resumeOverlayTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) setState(() => _pauseState = _StreamerPauseState.none);
    });
  }

  /// O socket pode entregar eventos de batalha de outra sala (ex.: viewer
  /// que trocou de live no feed). Só aceita se esta sala participa.
  /// Payload sem room ids (backend antigo) → aceita, por compat.
  bool _isEventForThisRoom(Map<String, dynamic> data) {
    final roomA = data['room_a_id'] as String?;
    final roomB = data['room_b_id'] as String?;
    if (roomA == null && roomB == null) return true;
    return roomA == widget.room.id || roomB == widget.room.id;
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

  Future<void> _initializePlayer({StreamQuality? quality}) async {
    if (_controller != null && quality == null) return;
    final playbackId = widget.room.playbackId;
    final q = quality ?? _quality;

    // Determinar URL com base na qualidade selecionada.
    // Se temos o playbackId, construímos a URL com o parâmetro correto.
    // Caso contrário, usamos a streamUrl que já vem do DTO.
    final String? streamUrl = playbackId != null
        ? q.buildUrl(playbackId)
        : widget.room.streamUrl;

    if (streamUrl == null || streamUrl.isEmpty) return;

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(streamUrl),
      videoPlayerOptions: VideoPlayerOptions(
        // Permite que SFX/gifts toquem junto com o áudio da live.
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
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

      _soloPlaying = null;
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

  // ────────────────────── Quality control ──────────────────────

  /// Troca a qualidade do stream ao vivo.
  /// Descarta o controller atual, cria um novo com a URL correta e reinicia.
  Future<void> _changeQuality(StreamQuality q) async {
    if (q == _quality) return;
    setState(() {
      _quality = q;
      _isInitialized = false;
    });
    final old = _controller;
    _controller = null;
    old?.dispose();
    await _initializePlayer(quality: q);
  }

  void _showQualitySelector() {
    _dismissKeyboard();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _QualitySheet(
        current: _quality,
        onSelect: (q) {
          Navigator.pop(context);
          _changeQuality(q);
        },
      ),
    );
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
    // `_liveRepo` (capturado no initState): também roda no dispose.
    unawaited(
      _liveRepo.sendReaction(widget.room.id, count: count).catchError((_) {}),
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
    _dismissKeyboard();
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
    _dismissKeyboard();
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
  /// Animação: o presente em si (toast/overlay da rosa) já é disparado
  /// pelo `liveRoomGiftsViewModelProvider` ao receber o evento de socket
  /// `gift_received` — não precisamos (e não devemos) spawnar corações
  /// aqui. `_heartsKey.spawn()` é EXCLUSIVO do botão de curtir
  /// (`_onTapLike`); usá-lo aqui também causava o bug reportado onde um
  /// coração flutuante aparecia junto de toda rosa enviada, mesmo sem o
  /// usuário ter tocado em "Curtir".
  void _sendRose() {
    HapticFeedback.lightImpact();
    _pendingRoses += 1;
    // Teto do backend por request (quantity ≤ 99): envia já ao atingir —
    // antes, toques contínuos passavam de 99 e o lote inteiro era recusado.
    if (_pendingRoses >= _maxRosesPerRequest) {
      _roseFlushTimer?.cancel();
      _flushRoses();
      return;
    }
    // Throttle: o 1º toque abre a janela de 400ms; toques seguintes entram
    // no mesmo lote (antes cada toque reiniciava o timer e nada era
    // enviado enquanto o usuário continuasse tocando).
    _roseFlushTimer ??= Timer(const Duration(milliseconds: 400), _flushRoses);
  }

  static const _maxRosesPerRequest = 99;

  void _flushRoses({bool force = false}) {
    _roseFlushTimer?.cancel();
    _roseFlushTimer = null;
    if (_pendingRoses <= 0) return;
    final qty = _pendingRoses;
    _pendingRoses = 0;
    unawaited(_fireRoseRequest(quantity: qty));
  }

  Future<void> _fireRoseRequest({int quantity = 1}) async {
    // Repository capturado no initState: este método também roda a partir
    // do dispose (flush das rosas pendentes ao sair), quando `ref` já não
    // pode ser usado.
    final repo = _giftRepo;
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
      final message = e is Failure
          ? e.toDisplayMessage()
          : 'Não foi possível enviar a rosa';
      final isBalance =
          message.toLowerCase().contains('saldo') ||
          message.toLowerCase().contains('insuficiente');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
            action: isBalance
                ? SnackBarAction(
                    label: 'Recarregar',
                    onPressed: () => TopUpCoinsSheet.show(
                      context,
                      reason: _activeBattleId != null ? 'battle' : 'gift',
                    ),
                  )
                : null,
          ),
        );
    }
  }

  /// Envia o comentário: limpa o input e fecha o teclado na hora (a
  /// mensagem aparece imediatamente no chat via eco otimista). Se o envio
  /// falhar, devolve o texto ao input para o usuário não perder o que
  /// digitou.
  Future<void> _sendComment() async {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;
    _chatCtrl.clear();
    _chatFocus.unfocus();
    final sent = await ref
        .read(liveRoomCommentsViewModelProvider(widget.room.id).notifier)
        .sendComment(text);
    if (!sent && mounted && _chatCtrl.text.isEmpty) {
      _chatCtrl.text = text;
      _chatCtrl.selection = TextSelection.collapsed(offset: text.length);
    }
  }

  /// Toque numa mensagem do chat → cartão do autor. "Responder" insere a
  /// @menção no input e abre o teclado (TikTok).
  Future<void> _onCommentTap(LiveComment comment) async {
    final action = await ChatUserSheet.show(context, comment);
    if (!mounted || action == null) return;
    switch (action) {
      case ChatUserAction.reply:
        ChatUserSheet.insertMention(_chatCtrl, comment);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _chatFocus.requestFocus();
        });
      case ChatUserAction.viewProfile:
        if (comment.userId.isNotEmpty) {
          context.push('/profile/${comment.userId}');
        }
    }
  }

  /// Fecha o teclado antes de abrir sheets — sem isso o Flutter devolve o
  /// foco ao input quando o sheet fecha e o teclado reabre sozinho.
  void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  // ────────────────────── Build ──────────────────────

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(
      liveRoomCommentsViewModelProvider(widget.room.id),
    );
    // Mantém a fila de animações viva (o overlay lê o mesmo provider).
    ref.watch(liveRoomGiftsViewModelProvider(widget.room.id));

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
      // ⌨️ O vídeo NUNCA redimensiona com o teclado (antes o body inteiro
      // encolhia → vídeo dava zoom/pulo e o split da batalha estourava).
      // Só o `_ViewerChatDock` sobe acompanhando o teclado.
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Video / thumbnail background ──
          _buildVideoLayer(),

          // ── 1.5 Criador pausou a live ──
          if (_pauseState != _StreamerPauseState.none)
            Positioned.fill(
              child: _StreamerPausedOverlay(
                streamerName: widget.room.streamerName,
                resuming: _pauseState == _StreamerPauseState.resuming,
              ),
            ),

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
                  likesCount: max(_likesCount, commentsState.likeCount),
                  roomId: widget.room.id,
                  onBack: () => context.pop(),
                  onShare: _onTapShare,
                  recentViewerAvatars: commentsState.recentViewerAvatars,
                  gifterRanking: commentsState.gifterRanking,
                  qualityLabel: _quality.label,
                  onQualityTap: _showQualitySelector,
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

          // ── 6. Dock inferior: produto fixado + chat + input/ações ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ViewerChatDock(
              pinnedProduct: PinnedProductBar(roomId: widget.room.id),
              tickerBuilder: (maxHeight) => ChatTicker(
                comments: commentsState.comments,
                gifts: commentsState.chatGifts,
                hostUserId: widget.room.streamerId,
                myUserId: ref.watch(authStateProvider).value?.id,
                myUsername: commentsState.myUsername,
                onCommentTap: _onCommentTap,
                maxHeight: maxHeight,
              ),
              bottomBar: LiveBottomBar(
                controller: _chatCtrl,
                focusNode: _chatFocus,
                isSending: commentsState.isSending,
                isLiked: _isLiked,
                likesCount: max(_likesCount, commentsState.likeCount),
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
        _scheduleSoloPlayback(playing: false);

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
        //
        // sizeOf/paddingOf: não reconstrói a cada frame do teclado, e como
        // o Scaffold não redimensiona mais, a altura é sempre a da tela.
        final screenH = MediaQuery.sizeOf(context).height;
        final padding = MediaQuery.paddingOf(context);
        const kTopBarH =
            80.0; // altura estimada do LiveTopBar (abaixo SafeArea)
        const kBottomBarH = 140.0; // LiveBottomBar + padding inferior
        final topOffset = padding.top + kTopBarH;
        final bottomOffset = padding.bottom + kBottomBarH;
        final videoH = (screenH - topOffset - bottomOffset).clamp(
          200.0,
          screenH * 0.62,
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
    }
    // Solo (ou fallback): garantir que o single-controller esteja tocando
    // com áudio (caso tenha sido pausado durante a batalha).
    _scheduleSoloPlayback(playing: true);

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

  /// Pausa/retoma o player solo FORA do build (efeitos colaterais no
  /// build rodavam a cada rebuild — inclusive a cada frame do teclado).
  /// Só age quando o modo muda.
  void _scheduleSoloPlayback({required bool playing}) {
    if (_soloPlaying == playing) return;
    _soloPlaying = playing;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = _controller;
      if (!mounted || c == null || !c.value.isInitialized) {
        _soloPlaying = null; // reavalia no próximo build
        return;
      }
      if (playing) {
        c
          ..play()
          ..setVolume(1.0);
      } else {
        c
          ..pause()
          ..setVolume(0.0);
      }
    });
  }

  Widget _placeholder() => Container(
    color: const Color(0xFF1B2B6B),
    child: const Center(
      child: Icon(Icons.live_tv, color: Colors.white24, size: 64),
    ),
  );
}

enum _StreamerPauseState { none, paused, resuming }

/// Aviso ao espectador quando o criador pausa a live — aparece na hora
/// (via socket), antes mesmo do slate "Já voltamos" chegar pelo vídeo.
class _StreamerPausedOverlay extends StatelessWidget {
  const _StreamerPausedOverlay({
    required this.streamerName,
    required this.resuming,
  });

  final String streamerName;
  final bool resuming;

  @override
  Widget build(BuildContext context) {
    final name = streamerName.trim().isEmpty ? 'O criador' : streamerName;
    return ColoredBox(
      color: const Color(0xE60B0F1A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              resuming
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.coffee_rounded,
                      color: Colors.white,
                      size: 46,
                    ),
              const SizedBox(height: 16),
              Text(
                resuming ? 'Voltando…' : 'Já voltamos!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                resuming
                    ? '$name retomou a live. O vídeo aparece em instantes.'
                    : '$name pausou a live por alguns minutos. Fique por aqui!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ⌨️ Dock inferior do espectador: produto fixado + chat + input/ações.
///
/// Único widget que lê `viewInsets` — só ele reconstrói durante a animação
/// do teclado (vídeo, top bar e overlays ficam parados). Com o teclado
/// aberto:
/// - o dock sobe junto, colado no teclado;
/// - a altura do chat encolhe para caber entre o top bar e o input;
/// - o produto fixado some (fica montado, só escondido, para não perder
///   o estado do pin).
class _ViewerChatDock extends StatelessWidget {
  const _ViewerChatDock({
    required this.pinnedProduct,
    required this.tickerBuilder,
    required this.bottomBar,
  });

  final Widget pinnedProduct;
  final Widget Function(double maxHeight) tickerBuilder;
  final Widget bottomBar;

  /// Altura reservada no topo (status bar + LiveTopBar + identidade).
  static const _topReserved = 130.0;

  /// Altura aproximada da barra de input/ações + espaçamentos.
  static const _bottomBarH = 64.0;

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final padding = MediaQuery.paddingOf(context);
    final size = MediaQuery.sizeOf(context);
    final typing = keyboard > 0;

    final bottomInset = typing ? keyboard + 8 : padding.bottom + 12;
    final free =
        size.height - padding.top - _topReserved - _bottomBarH - bottomInset;
    final tickerMax = typing
        ? (free * 0.75).clamp(60.0, 220.0)
        : free.clamp(80.0, 240.0);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Offstage(offstage: typing, child: pinnedProduct),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.bottomLeft,
              // Chat ocupa ~78% da largura: a faixa direita fica livre
              // para os corações e toques no vídeo.
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: size.width * 0.78),
                child: tickerBuilder(tickerMax),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: bottomBar,
          ),
        ],
      ),
    );
  }
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

// ── Seletor de qualidade de stream ───────────────────────────────────────────

/// Bottom sheet para selecionar qualidade do stream.
class _QualitySheet extends StatelessWidget {
  final StreamQuality current;
  final ValueChanged<StreamQuality> onSelect;

  const _QualitySheet({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.hd, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Qualidade do vídeo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Nota sobre FPS
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'FPS: definido pelo streamer (geralmente 30fps)',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
              ),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          ...StreamQuality.values.map(
            (q) => _QualityTile(
              quality: q,
              isSelected: q == current,
              onTap: () => onSelect(q),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _QualityTile extends StatelessWidget {
  final StreamQuality quality;
  final bool isSelected;
  final VoidCallback onTap;

  const _QualityTile({
    required this.quality,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Ícone de qualidade
            Icon(
              _iconFor(quality),
              color: isSelected ? AppColors.braweBlueLight : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quality.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  Text(
                    _descriptionFor(quality),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.braweBlueLight,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(StreamQuality q) => switch (q) {
    StreamQuality.auto => Icons.auto_awesome,
    StreamQuality.p480 => Icons.sd,
    StreamQuality.p720 => Icons.hd,
    StreamQuality.p1080 => Icons.high_quality,
  };

  String _descriptionFor(StreamQuality q) => switch (q) {
    StreamQuality.auto => 'Ajusta automaticamente conforme sua conexão',
    StreamQuality.p480 => 'Menor consumo de dados',
    StreamQuality.p720 => 'Boa qualidade, recomendado',
    StreamQuality.p1080 => 'Máxima qualidade, requer boa internet',
  };
}
