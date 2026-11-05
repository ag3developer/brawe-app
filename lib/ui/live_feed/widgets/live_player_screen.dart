import 'dart:async';
import '../../core/view_models/hidden_users_view_model.dart';
import 'dart:convert';
import 'package:dio/dio.dart' show DioException;
import 'dart:ui' show ImageFilter;
import 'dart:math' show max, min;
import 'package:flutter/material.dart';
import '../../../core/remote_config/remote_flags.dart';
import '../../live/shared/widgets/overlays/combo_tier_layer.dart';
import '../../live/shared/widgets/overlays/entrance_effect_layer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brawe_app/config/feature_flags.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../view_models/live_room_comments_view_model.dart';
import '../view_models/live_room_gifts_view_model.dart';
import '../../core/view_models/follow_view_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../data/services/battle_service.dart';
import '../../../data/services/link_service.dart';
import '../../../domain/models/link_state.dart';
import '../battle/link_hud.dart';
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
import '../../live/shared/widgets/sheets/sheets.dart';
import '../../live/shared/widgets/sheets/event_page_sheet.dart';
import '../../live/shared/layout/live_dock_metrics.dart';
import 'live_notice_lane.dart';
import 'viewer_gamification_layer.dart';
import '../../live/shared/widgets/goal/live_goals.dart';
import '../../live/shared/widgets/hud/live_gift_ticker.dart';
import '../../live/shared/widgets/hud/live_event_chip.dart';
import 'live_ended_view.dart';
import 'dual_hls_player.dart';
import '../battle/battle_hud.dart';
import '../battle/battle_layout.dart';
import '../battle/battle_hud_parts.dart';
import '../view_models/battle_view_model.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../wallet/widgets/top_up_coins_sheet.dart';
import '../../core/themes/app_colors.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// Extrai o playbackId de `https://stream.mux.com/<id>.m3u8` (ignora query).
/// Retorna `null` para qualquer outra URL.
String? muxPlaybackIdOf(String? url) {
  if (url == null) return null;
  final m = RegExp(
    r'^https://stream\.mux\.com/([A-Za-z0-9]+)\.m3u8(?:\?.*)?$',
  ).firstMatch(url.trim());
  return m?.group(1);
}

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

  /// Conexão entre criadores ativa nesta sala (tela dupla, §8).
  LinkState? _link;

  /// Tela dividida: batalha OU conexão.
  bool get _split => _activeBattleId != null || _link != null;

  /// Payload do `connect:battle:countdown` que abriu a batalha (o VM é criado
  /// depois dele; o HUD reaplica para não perder o "3").
  Map<String, dynamic>? _countdownPayload;

  /// Pausa do criador (overlay "Já voltamos" / "Voltando…").
  _StreamerPauseState _pauseState = _StreamerPauseState.none;

  /// Limite da pausa (paused_at + max_pause) para o "Volta em até m:ss".
  DateTime? _pauseDeadline;
  static const Duration _defaultMaxPause = Duration(minutes: 5);

  /// Live encerrada (aviso `live_ended` ou sala já encerrada ao abrir).
  bool _ended = false;
  bool _endedLate = false;
  int? _endedDurationSeconds;
  Timer? _resumeOverlayTimer;

  // Reconexão do vídeo: no começo da live o HLS ainda não existe, e a rede
  // oscila — sem nova tentativa a tela ficava presa na capa para sempre.
  Timer? _playerRetryTimer;

  /// Vigia de vídeo parado: ao entrar/sair da conexão o criador troca a
  /// origem do vídeo (RTMP ↔ montagem do servidor) e o HLS do Mux pode só
  /// "estagnar" sem erro — o espectador ficaria no último quadro.
  Timer? _stallTimer;
  Duration _stallLastPos = Duration.zero;
  int _stallTicks = 0;
  int _playerAttempts = 0;
  String? _freshPlaybackId;
  String? _freshStreamUrl;

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
    // Notificação antiga / link de uma live que já acabou: mostra direto
    // "Live encerrada" em vez de um player vazio.
    if (widget.room.isPaused && widget.room.status != 'ended') {
      _pauseState = _StreamerPauseState.paused;
      final at = widget.room.pausedAt;
      _pauseDeadline = at != null ? at.add(_defaultMaxPause) : null;
    }
    if (widget.room.status == 'ended') {
      _ended = true;
      _endedLate = true;
    } else {
      _initializePlayer();
    }
    // Refresh follow state on entry (avoids stale cache from previous session)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(followViewModelProvider(widget.room.streamerId));
      if (_ended) return;
      _subscribeToBattleEvents();
      _subscribeToReactions();
      _confirmStillLive();
    });
  }

  /// Se a live era a rota atual no último `didChangeDependencies`.
  bool _routeWasCurrent = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ao voltar de uma tela empilhada por cima (ex.: perfil, que restaura as
    // barras do sistema), reaplica o modo imersivo da live. Idempotente —
    // fechar um sheet por cima também passa aqui, sem efeito visível.
    final isCurrent = ModalRoute.isCurrentOf(context) ?? true;
    if (isCurrent && !_routeWasCurrent) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    _routeWasCurrent = isCurrent;
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
    _playerRetryTimer?.cancel();
    _stallTimer?.cancel();
    _chatCtrl.dispose();
    _chatFocus.dispose();
    _controller?.removeListener(_watchPlayerHealth);
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
    socket.on(AppConstants.eventBattleCountdown, _onBattleCountdown);
    socket.on(AppConstants.eventBattleStarted, _onBattleStarted);
    socket.on(AppConstants.eventBattleCancelled, _onBattleCancelled);
    socket.on(AppConstants.eventLinkStarted, _onLinkStarted);
    socket.on(AppConstants.eventLinkEnded, _onLinkEnded);
    socket.on(AppConstants.eventLinkMute, _onLinkMute);
    socket.on(AppConstants.eventLinkMedia, _onLinkMedia);
    socket.on(AppConstants.eventLivePaused, _onLivePaused);
    socket.on(AppConstants.eventLiveResumed, _onLiveResumed);
    socket.on(AppConstants.eventLiveEnded, _onLiveEnded);
    // 🔁 Re-anexar handler em reconexões (idêntico ao broadcaster).
    socket.addReconnectCallback(_reattachBattleHandlers);
    // Verifica se a live já está em batalha (viewer entrou mid-battle)
    _checkActiveBattle();
    _checkActiveLink();
  }

  void _reattachBattleHandlers() {
    if (!mounted) return; // widget pode ter sido descartado antes do callback
    final socket = ref.read(socketServiceProvider);
    socket.off(AppConstants.eventBattleCountdown, _onBattleCountdown);
    socket.off(AppConstants.eventBattleStarted, _onBattleStarted);
    socket.off(AppConstants.eventBattleCancelled, _onBattleCancelled);
    socket.off(AppConstants.eventLinkStarted, _onLinkStarted);
    socket.off(AppConstants.eventLinkEnded, _onLinkEnded);
    socket.off(AppConstants.eventLinkMute, _onLinkMute);
    socket.off(AppConstants.eventLinkMedia, _onLinkMedia);
    socket.off(AppConstants.eventLivePaused, _onLivePaused);
    socket.off(AppConstants.eventLiveResumed, _onLiveResumed);
    socket.off(AppConstants.eventLiveEnded, _onLiveEnded);
    socket.on(AppConstants.eventBattleCountdown, _onBattleCountdown);
    socket.on(AppConstants.eventBattleStarted, _onBattleStarted);
    socket.on(AppConstants.eventBattleCancelled, _onBattleCancelled);
    socket.on(AppConstants.eventLinkStarted, _onLinkStarted);
    socket.on(AppConstants.eventLinkEnded, _onLinkEnded);
    socket.on(AppConstants.eventLinkMute, _onLinkMute);
    socket.on(AppConstants.eventLinkMedia, _onLinkMedia);
    socket.on(AppConstants.eventLivePaused, _onLivePaused);
    socket.on(AppConstants.eventLiveResumed, _onLiveResumed);
    socket.on(AppConstants.eventLiveEnded, _onLiveEnded);
    // A live pode ter acabado durante a queda de conexão.
    _confirmStillLive();
    // Conexão (tela dupla) pode ter começado/terminado enquanto offline.
    unawaited(_checkActiveLink());
    // Após reconectar, valida via REST se uma batalha começou durante
    // a queda de conexão — com debounce de 5s para evitar spam em
    // reconexões rápidas (ex: restart do servidor durante deploy).
    _debouncedCheckActiveBattle();
  }

  void _unsubscribeFromBattleEvents() {
    try {
      final socket = ref.read(socketServiceProvider);
      socket.off(AppConstants.eventBattleCountdown, _onBattleCountdown);
      socket.off(AppConstants.eventBattleStarted, _onBattleStarted);
      socket.off(AppConstants.eventBattleCancelled, _onBattleCancelled);
      socket.off(AppConstants.eventLinkStarted, _onLinkStarted);
      socket.off(AppConstants.eventLinkEnded, _onLinkEnded);
      socket.off(AppConstants.eventLinkMute, _onLinkMute);
      socket.off(AppConstants.eventLinkMedia, _onLinkMedia);
    socket.off(AppConstants.eventLinkMedia, _onLinkMedia);
      socket.off(AppConstants.eventLivePaused, _onLivePaused);
      socket.off(AppConstants.eventLiveResumed, _onLiveResumed);
      socket.off(AppConstants.eventLiveEnded, _onLiveEnded);
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

  // ── Conexão entre criadores (tela dupla sem batalha) ─────────────────────

  bool _linkIsMine(LinkState l) =>
      l.a.roomId == widget.room.id || l.b.roomId == widget.room.id;

  void _onLinkStarted(dynamic raw) {
    if (!mounted) return;
    final l = LinkState.tryParse(_parseSocketPayload(raw));
    if (l == null || !_linkIsMine(l)) return;
    final wasLinked = _link != null;
    final before = _llUrl;
    setState(() => _link = l);
    // §18.2: já veio a URL de baixa latência → troca na hora (a retentativa
    // cobre o 404 dos primeiros segundos). Senão, recarrega o HLS normal.
    if (_llUrl != null && _llUrl != before) {
      _restartPlayer();
    } else if (!wasLinked) {
      _reloadAfterSourceSwitch();
    }
  }

  /// `connect:link:media`: as streams LL ficaram prontas (ou mudaram).
  void _onLinkMedia(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    final cur = _link;
    if (data == null || cur == null || data['link_id'] != cur.linkId) return;
    final pb = LinkState.parsePlayback(data['playback']);
    final before = _llUrl;
    setState(() => _link = cur.withPlayback(pb.$1, pb.$2));
    if (_llUrl != before) _restartPlayer();
  }

  void _onLinkEnded(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null || data['link_id'] != _link?.linkId) return;
    final hadLl = _llUrl != null;
    setState(() => _link = null);
    // Streams LL apagadas no fim da conexão: volta já para a URL da sala.
    if (hadLl) _restartPlayer();
    _reloadAfterSourceSwitch();
  }

  void _onLinkMute(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    final cur = _link;
    if (data == null || cur == null || data['link_id'] != cur.linkId) return;
    final m = data['muted'];
    if (m is! Map) return;
    setState(
      () =>
          _link = cur.copyWith(mutedA: m['a'] == true, mutedB: m['b'] == true),
    );
  }

  /// Conexão já em curso quando o espectador entra.
  Future<void> _checkActiveLink() async {
    try {
      final l = await ref.read(linkServiceProvider).getActive(widget.room.id);
      if (l != null && l.isActive && mounted) {
        final before = _llUrl;
        setState(() => _link = l);
        if (_llUrl != null && _llUrl != before && _controller != null) {
          _restartPlayer();
        }
      }
    } on DioException catch (e) {
      // 404: a conexão acabou enquanto estávamos offline → sai da tela dupla.
      if (e.response?.statusCode == 404 && mounted && _link != null) {
        setState(() => _link = null);
      }
    } catch (_) {
      // 503: tempo real desligado.
    }
  }

  /// Contagem 3·2·1 (um evento por segundo): abre o HUD já na contagem
  /// (o VM da batalha nasce aqui, não só no `started`).
  void _onBattleCountdown(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null) return;
    final battleId = data['battle_id'] as String?;
    if (battleId == null || battleId.isEmpty) return;
    if (!_isEventForThisRoom(data)) return;
    if (_activeBattleId == battleId) {
      // VM já existe e escuta o evento sozinho.
      return;
    }
    setState(() {
      _activeBattleId = battleId;
      _countdownPayload = data;
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
    if (_activeBattleId == battleId) return;
    setState(() => _activeBattleId = battleId);
  }

  /// Batalha cancelada (ex.: streamer encerrou a live durante a contagem).
  void _onBattleCancelled(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null || data['battle_id'] != _activeBattleId) return;
    setState(() {
      _activeBattleId = null;
      _countdownPayload = null;
    });
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
    final pausedAt = DateTime.tryParse(
      data['paused_at']?.toString() ?? '',
    )?.toLocal();
    final maxSecs = (data['max_pause_seconds'] as num?)?.toInt();
    setState(() {
      _pauseState = _StreamerPauseState.paused;
      _pauseDeadline = (pausedAt ?? DateTime.now()).add(
        maxSecs != null ? Duration(seconds: maxSecs) : _defaultMaxPause,
      );
    });
  }

  void _onLiveEnded(dynamic raw) {
    if (!mounted || _ended) return;
    final data = _parseSocketPayload(raw);
    if (data == null || data['room_id'] != widget.room.id) return;
    _showEnded(durationSeconds: (data['duration_seconds'] as num?)?.toInt());
  }

  /// Confere no servidor se a sala ainda está no ar (entrada pelo feed com
  /// dado antigo, ou reconexão depois de a live acabar).
  Future<void> _confirmStillLive() async {
    try {
      final fresh = await _liveRepo.getRoom(widget.room.id);
      if (!mounted || _ended) return;
      if (fresh != null && fresh.status == 'ended') _showEnded(late: true);
    } catch (_) {}
  }

  void _showEnded({bool late = false, int? durationSeconds}) {
    _dismissKeyboard();
    _resumeOverlayTimer?.cancel();
    _controller?.pause();
    setState(() {
      _ended = true;
      _endedLate = late;
      _endedDurationSeconds = durationSeconds;
      _pauseState = _StreamerPauseState.none;
    });
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

  /// URL de baixa latência do lado desta sala na conexão ativa (§18.2).
  String? get _llUrl {
    final l = _link;
    if (l == null || !l.isActive) return null;
    final side = l.sideOf(roomId: widget.room.id);
    return side == null ? null : l.playbackOf(side);
  }

  /// Lado (A/B) da sala assistida: é o que fica à esquerda, em azul (§18.1).
  /// Só espelha quando o servidor sinaliza `owner_left` (senão A à esquerda,
  /// igual ao vídeo do app antigo).
  String get _ownSide {
    final id = _activeBattleId;
    if (id != null) {
      final b = ref.read(battleViewModelProvider(id)).value;
      final s = b?.sideOf(roomId: widget.room.id);
      if (b != null && s != null) return b.ownerLeft ? s : 'a';
    }
    final l = _link;
    if (l != null && l.ownerLeft) {
      return l.sideOf(roomId: widget.room.id) ?? 'a';
    }
    return 'a';
  }

  BattleLayout _layout() => battleLayoutOf(context, ownSide: _ownSide);

  /// URL a tocar: LL da conexão (se houver) ou a normal da sala, com a
  /// qualidade escolhida quando for Mux.
  String? _resolveStreamUrl(StreamQuality q) {
    // Se a LL falha várias vezes (não existe mais), cai na URL normal.
    final ll = _playerAttempts >= 6 ? null : _llUrl;
    final base = ll ?? _freshStreamUrl ?? widget.room.streamUrl;
    final id = ll != null
        ? muxPlaybackIdOf(ll)
        : (_freshPlaybackId ?? widget.room.playbackId ?? muxPlaybackIdOf(base));
    if (id != null) return q.buildUrl(id);
    return base;
  }

  Future<void> _initializePlayer({StreamQuality? quality}) async {
    if (_controller != null && quality == null) return;
    _playerRetryTimer?.cancel();
    final q = quality ?? _quality;

    // URL conforme a qualidade escolhida. O servidor só manda a URL do Mux
    // (sem playback_id): o id é extraído dela; URLs fora do Mux ficam como estão.
    final String? streamUrl = _resolveStreamUrl(q);

    if (streamUrl == null || streamUrl.isEmpty) {
      // Sala vinda de uma lista sem o endereço do vídeo: busca de novo.
      await _refreshPlaybackSource();
      _schedulePlayerRetry();
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(streamUrl),
      videoPlayerOptions: VideoPlayerOptions(
        // Permite que SFX/gifts toquem junto com o áudio da live.
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
      httpHeaders: const {'User-Agent': 'BraweApp/1.0 (HLS-Live)'},
    );
    _controller = controller;
    try {
      // Sem limite, o player pode esperar para sempre por um HLS que
      // ainda não existe.
      await controller.initialize().timeout(const Duration(seconds: 12));
      if (!mounted || _controller != controller) {
        if (_controller != controller) controller.dispose();
        return;
      }

      // Seek para o live edge (último segmento disponível) logo após inicializar.
      // Sem isso, o player pode começar a reproduzir de um ponto anterior no
      // buffer HLS, aumentando o delay percebido pelo espectador.
      final duration = controller.value.duration;
      if (duration > Duration.zero) {
        await controller.seekTo(duration);
      }

      _playerAttempts = 0;
      _soloPlaying = null;
      setState(() => _isInitialized = true);
      controller
        ..addListener(_watchPlayerHealth)
        ..play()
        // Live HLS NÃO faz loop — é stream contínuo.
        ..setLooping(false)
        ..setVolume(1.0);
      WakelockPlus.enable();
      _startStallWatch();
    } catch (e) {
      debugPrint(
        'LivePlayer: video init error (tentativa ${_playerAttempts + 1}): $e',
      );
      if (_controller == controller) _controller = null;
      controller.dispose();
      if (_playerAttempts >= 2) await _refreshPlaybackSource();
      _schedulePlayerRetry();
    }
  }

  /// Nova tentativa com espera crescente (1s, 2s, 4s, depois a cada 6s)
  /// (teto vem do Remote Config `video_retry_max_s`, padrão 6s) enquanto a
  /// tela estiver aberta e a live não tiver acabado.
  void _schedulePlayerRetry() {
    if (!mounted || _ended) return;
    final seconds = min(
      RemoteFlags.current.videoRetryMaxS,
      1 << min(_playerAttempts, 3),
    );
    // setState: a mensagem de "sem sinal" depende do número de tentativas.
    setState(() => _playerAttempts++);
    _playerRetryTimer?.cancel();
    _playerRetryTimer = Timer(Duration(seconds: seconds), () {
      if (mounted && !_ended && _controller == null) _initializePlayer();
    });
  }

  /// Erro no meio da live (rede caiu, streamer reconectou): descarta o
  /// player e reconecta em vez de congelar no último quadro.
  void _watchPlayerHealth() {
    final c = _controller;
    if (c == null || !c.value.hasError || _ended) return;
    debugPrint(
      'LivePlayer: erro durante a reprodução: ${c.value.errorDescription}',
    );
    c.removeListener(_watchPlayerHealth);
    _controller = null;
    if (mounted) setState(() => _isInitialized = false);
    // Fora do listener: não descartar o controller dentro do próprio aviso.
    Future.microtask(c.dispose);
    _schedulePlayerRetry();
  }

  /// Verifica a cada 2s se o vídeo avança. Parado por ~8s enquanto deveria
  /// tocar (solo ou tela dividida montada) → recria o player.
  void _startStallWatch() {
    _stallTimer?.cancel();
    _stallTicks = 0;
    _stallLastPos = _controller?.value.position ?? Duration.zero;
    _stallTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final c = _controller;
      if (!mounted || _ended || _swapping) return;
      if (c == null || !c.value.isInitialized) return;
      // Pausado de propósito (dual_hls usa outros players; pausa do criador).
      if (_soloPlaying == false ||
          !c.value.isPlaying ||
          _pauseState == _StreamerPauseState.paused) {
        _stallTicks = 0;
        _stallLastPos = c.value.position;
        return;
      }
      final pos = c.value.position;
      if (pos != _stallLastPos) {
        _stallLastPos = pos;
        _stallTicks = 0;
        return;
      }
      _stallTicks++;
      // Carregando (esperando dados): quase sempre é o envio do criador que
      // atrasou — recarregar não ajuda e só apagava a tela. Espera ~30 s.
      // Parado SEM carregar: o player travou de verdade → troca em ~8 s.
      final limit = c.value.isBuffering ? 15 : 4;
      if (_stallTicks >= limit) {
        debugPrint(
          'LivePlayer: vídeo parado há ~${_stallTicks * 2}s '
          '(carregando=${c.value.isBuffering}) — trocando o player',
        );
        _stallTicks = 0;
        _restartPlayer();
      }
    });
  }

  /// Troca o player por um novo no ponto ao vivo SEM apagar a tela: o atual
  /// continua visível até o novo estar pronto (sem "sem conexão" piscando).
  /// Se o novo não abrir, mantém o atual.
  bool _swapping = false;
  int _swapRetries = 0;
  Future<void> _restartPlayer() async {
    final old = _controller;
    if (old == null || !old.value.isInitialized) {
      // Nada na tela: caminho normal (com retentativas).
      _soloPlaying = null;
      _playerAttempts = 0;
      _controller = null;
      if (old != null) {
        old.removeListener(_watchPlayerHealth);
        Future.microtask(old.dispose);
      }
      if (mounted) setState(() => _isInitialized = false);
      await _initializePlayer();
      return;
    }
    if (_swapping) return;
    _swapping = true;
    try {
      final url = _resolveStreamUrl(_quality);
      if (url == null || url.isEmpty) return;
      final next = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
        httpHeaders: const {'User-Agent': 'BraweApp/1.0 (HLS-Live)'},
      );
      try {
        await next.initialize().timeout(const Duration(seconds: 12));
        final d = next.value.duration;
        if (d > Duration.zero) await next.seekTo(d);
      } catch (e) {
        debugPrint('LivePlayer: troca do player falhou ($e) — mantém o atual');
        next.dispose();
        // Endereço novo (ex.: vídeo de baixa latência ainda subindo): tenta
        // de novo algumas vezes; depois `_resolveStreamUrl` cai na URL normal.
        if (url != old.dataSource && _swapRetries < 6) {
          _swapRetries++;
          _playerAttempts++;
          Timer(const Duration(seconds: 3), () {
            if (mounted && !_ended && _controller == old) _restartPlayer();
          });
        }
        return;
      }
      _swapRetries = 0;
      if (!mounted || _ended || _controller != old) {
        next.dispose();
        return;
      }
      old.removeListener(_watchPlayerHealth);
      _soloPlaying = null;
      setState(() {
        _controller = next;
        _isInitialized = true;
      });
      next
        ..addListener(_watchPlayerHealth)
        ..play()
        ..setLooping(false)
        ..setVolume(1.0);
      Future.delayed(const Duration(milliseconds: 300), old.dispose);
      _startStallWatch();
    } finally {
      _swapping = false;
    }
  }

  /// A origem do vídeo da sala muda (conexão/batalha começou ou acabou):
  /// dá alguns segundos para o Mux receber o novo sinal e recarrega.
  void _reloadAfterSourceSwitch() {
    Timer(const Duration(seconds: 6), () {
      if (mounted && !_ended) _restartPlayer();
    });
  }

  /// Busca a sala de novo para pegar o endereço do vídeo atualizado.
  Future<void> _refreshPlaybackSource() async {
    try {
      final fresh = await _liveRepo.getRoom(widget.room.id);
      if (!mounted || fresh == null) return;
      if (fresh.status == 'ended') {
        _showEnded(late: true);
        return;
      }
      _freshPlaybackId = fresh.playbackId ?? _freshPlaybackId;
      _freshStreamUrl = fresh.streamUrl ?? _freshStreamUrl;
    } catch (_) {}
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
    old?.removeListener(_watchPlayerHealth);
    old?.dispose();
    _playerAttempts = 0;
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
    // interno (mandar a live para amigos da Brawe) é exposto pelo "Mais".
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
        // UUID v4 por requisição de rosa (idempotência do backend).
        clientRequestId: const Uuid().v4(),
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
            action: isBalance && kCoinPurchaseEnabled
                ? SnackBarAction(
                    label: S.of(context).liveTopUpAction,
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
    final myId = ref.read(authStateProvider).value?.id;
    final access = chatModerationAccess(
      ref,
      roomId: widget.room.id,
      isHost: myId != null && myId == widget.room.streamerId,
    );
    final action = await ChatUserSheet.show(
      context,
      comment,
      // Não há ferramentas de moderação sobre o próprio criador.
      moderation: comment.userId == widget.room.streamerId ? null : access,
    );
    if (!mounted || action == null) return;
    if (action.isModeration) {
      await performChatModeration(
        context,
        ref,
        roomId: widget.room.id,
        comment: comment,
        action: action,
      );
      return;
    }
    switch (action) {
      case ChatUserAction.reply:
        ChatUserSheet.insertMention(_chatCtrl, comment);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _chatFocus.requestFocus();
        });
      case ChatUserAction.viewProfile:
        if (comment.userId.isNotEmpty) {
          context.push('/people/${comment.userId}');
        }
      default:
        break;
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

    final hidden =
        ref.watch(hiddenUsersProvider).value ?? const HiddenUsersState();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      // ⌨️ O vídeo NUNCA redimensiona com o teclado (antes o body inteiro
      // encolhia → vídeo dava zoom/pulo e o split da batalha estourava).
      // Só o `_ViewerChatDock` sobe acompanhando o teclado.
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Video / thumbnail background ──
          _buildVideoLayer(),

          // Tela dupla: a área do chat tem fundo escuro sólido, separado do vídeo.
          if (_split)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: _layout().chat.top,
              child: const ColoredBox(color: kBattleBg),
            ),

          // ── 1.5 Criador pausou a live ──
          if (_pauseState != _StreamerPauseState.none)
            Positioned.fill(
              child: _StreamerPausedOverlay(
                streamerName: widget.room.streamerName,
                resuming: _pauseState == _StreamerPauseState.resuming,
                deadline: _pauseDeadline,
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
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
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
          // Em batalha: confinados à coluna estreita da direita (embaixo).
          if (_split)
            battleRegionWrap(
              context,
              Rect.fromLTRB(
                MediaQuery.sizeOf(context).width - 64,
                _layout().chat.top,
                MediaQuery.sizeOf(context).width,
                MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).bottom -
                    84,
              ),
              IgnorePointer(
                child: FloatingHeartsOverlay(
                  key: _heartsKey,
                  roomId: widget.room.id,
                ),
              ),
            )
          else
            Positioned.fill(
              child: IgnorePointer(
                child: FloatingHeartsOverlay(
                  key: _heartsKey,
                  roomId: widget.room.id,
                ),
              ),
            ),

          // ── 4.5 Meta da live (barra fina sob o top bar) ──
          Positioned(
            top: MediaQuery.paddingOf(context).top + 70,
            left: 12,
            right: 12,
            // Metas do criador: pílula compacta; toque abre a sacola já
            // no presente da meta (ou a lista, se houver mais de uma).
            // Linha: metas à esquerda + faixa de notícia correndo ao lado.
            child: Row(
              children: [
                Flexible(
                  child: LiveEventChip(
                    expand: true,
                    roomId: widget.room.id,
                    initialEvent: widget.room.event,
                    onTap: (event) => EventPageSheet.show(
                      context,
                      roomId: widget.room.id,
                      streamerId: widget.room.streamerId,
                      event: event,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: LiveGoalsPill(
                    expand: true,
                    roomId: widget.room.id,
                    streamerId: widget.room.streamerId,
                    initialGoals: widget.room.goals,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LiveGiftTicker(
                    expand: true,
                    currentRoomId: widget.room.id,
                  ),
                ),
              ],
            ),
          ),

          // ── 4.6 Gamificação: "Fulano subiu de nível" vira linha no chat.
          // Entradas VIP, meu level-up, "passou você", novo #1 e marcos de
          // curtidas ficam no painel de avisos, acima do chat (dock abaixo).
          ViewerGamificationLayer(roomId: widget.room.id),

          // ── 5. Gift combos (canto inf. esq, acima do chat) ──
          GiftAnimationOverlay(roomId: widget.room.id),
          // ── 5.1 Efeito de entrada de viewer VIP (VAP/Lottie, fila própria)
          // Em batalha ambos ficam na região de baixo (não cobrem os rostos).
          if (_split) ...[
            battleRegionWrap(
              context,
              _layout().chat,
              EntranceEffectLayer(roomId: widget.room.id),
            ),
            // ── 5.2 Degraus do combo (partículas/Lottie/VAP, prioridade < presente)
            battleRegionWrap(
              context,
              _layout().chat,
              ComboTierLayer(roomId: widget.room.id),
            ),
          ] else ...[
            EntranceEffectLayer(roomId: widget.room.id),
            // ── 5.2 Degraus do combo (partículas/Lottie/VAP, prioridade < presente)
            ComboTierLayer(roomId: widget.room.id),
          ],

          // ── 6. Dock inferior: produto fixado + chat + input/ações ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: _split ? _layout().chat.top : null,
            child: _BattleDockClip(
              enabled: _split,
              child: _ViewerChatDock(
                battleChatTop: _split ? _layout().chat.top : null,
                // Produto fixado/loja: exclusivos da live solo (somem na conexão/batalha).
              pinnedProduct: _split
                  ? const SizedBox.shrink()
                  : PinnedProductBar(roomId: widget.room.id),
                notices: LiveNoticeLane(
                  roomId: widget.room.id,
                  streamerId: widget.room.streamerId,
                  battleIdGetter: () => _activeBattleId,
                ),
                tickerBuilder: (maxHeight) => PinnedAboveChat(
                  roomId: widget.room.id,
                  isHost:
                      ref.read(authStateProvider).value?.id ==
                      widget.room.streamerId,
                  child: ChatTicker(
                    giftParts: commentsState.chatGiftParts,
                    // Bloqueados (nos dois sentidos) não aparecem no chat da live.
                    comments: commentsState.comments
                        .where((c) => !hidden.isBlocked(c.userId))
                        .toList(),
                    gifts: commentsState.chatGifts
                        .where((g) => !hidden.isBlocked(g.senderId))
                        .toList(),
                    hostUserId: widget.room.streamerId,
                    myUserId: ref.watch(authStateProvider).value?.id,
                    myUsername: commentsState.myUsername,
                    onCommentTap: _onCommentTap,
                    maxHeight: maxHeight,
                  ),
                ),
                bottomBar: ChatErrorAbove(
                  roomId: widget.room.id,
                  child: LiveBottomBar(
                    roomId: widget.room.id,
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
                    onMore: () => MoreSheet.show(context, onShare: _onTapShare),
                  ),
                ),
              ),
            ),
          ),

          // ── 7.8 Tela dupla da conexão (sem batalha) ──
          if (_link != null && _activeBattleId == null)
            Positioned.fill(
              child: LinkHudOverlay(
                link: _link!,
                layout: _layout(),
                ownSide: _link!.sideOf(roomId: widget.room.id) ?? 'a',
                onOpenPartner: (id) => context.push('/live/$id'),
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
                key: ValueKey('viewer-hud-$_activeBattleId'),
                battleId: _activeBattleId!,
                initialCountdown: _countdownPayload,
                roomId: widget.room.id,
                streamerId: widget.room.streamerId,
                onClose: () {
                  if (mounted) {
                    setState(() {
                      _activeBattleId = null;
                      _countdownPayload = null;
                    });
                  }
                },
              ),
            ),

          // ── 9. Live encerrada — cobre tudo (criador, seguir, próxima live) ──
          if (_ended)
            Positioned.fill(
              child: LiveEndedView(
                room: widget.room,
                late: _endedLate,
                durationSeconds: _endedDurationSeconds,
              ),
            ),
        ],
      ),
    );
  }

  /// HLS único da sala (frame 720×1280 já com a tela dividida montada).
  Widget _compositeFrame(BattleLayout layout) {
    return ColoredBox(
      color: kBattleBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fromRect(
            rect: layout.frame,
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoLayer() {
    // Conexão entre criadores sem batalha: tela dupla no mesmo layout.
    if (_activeBattleId == null &&
        _link != null &&
        _isInitialized &&
        _controller != null) {
      _scheduleSoloPlayback(playing: true);
      return _compositeFrame(_layout());
    }
    // 🎬 BATTLE MODE — o layout vem de [BattleLayout] (contrato §1): faixa do
    // HUD no topo, faixa dividida (dono esq / parceiro dir, §18.1) e região do chat embaixo.
    if (_activeBattleId != null) {
      BattleRoomScope.set(_activeBattleId!, widget.room.id);
      final battle = ref.watch(battleViewModelProvider(_activeBattleId!)).value;
      if (battle != null) {
        final layout = _layout();
        // composite: a sala já entrega UM HLS com a tela dividida montada
        // (preenche o frame 720×1280). dual_hls (fallback): 2 players dentro
        // da mesma faixa dividida.
        final dual =
            !battle.isComposite &&
            (battle.streamUrlA != null || battle.streamUrlB != null);
        if (dual) {
          _scheduleSoloPlayback(playing: false);
          return ColoredBox(
            color: kBattleBg,
            child: DualHlsPlayer(
              layout: layout,
              streamUrlA: battle.streamUrlA,
              streamUrlB: battle.streamUrlB,
              streamerAName: battle.streamerAName,
              streamerBName: battle.streamerBName,
            ),
          );
        }
        if ((battle.isComposite || (_link != null && !dual)) &&
            _isInitialized &&
            _controller != null) {
          _scheduleSoloPlayback(playing: true);
          return _compositeFrame(layout);
        }
      }
      // Batalha dentro de uma conexão: o HLS já é a tela dividida montada
      // — não espera o estado da batalha carregar para mostrá-la.
      if (battle == null &&
          _link != null &&
          _isInitialized &&
          _controller != null) {
        _scheduleSoloPlayback(playing: true);
        return _compositeFrame(_layout());
      }
      // Fallback: batalha ativa mas ainda sem dados/vídeo — cai no
      // player solo enquanto o REST/socket sincroniza.
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
    // Carregando: capa desfocada + "Conectando…" — deixa claro que o vídeo
    // está vindo (antes era só a capa parada, parecia travado).
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.room.thumbnailUrl != null)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Image.network(
              widget.room.thumbnailUrl!,
              cacheWidth: context.decodePx(200),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(),
            ),
          )
        else
          _placeholder(),
        Container(color: Colors.black.withValues(alpha: 0.35)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                // Depois de algumas tentativas sem vídeo (ex.: HTTP 412 do
                // provedor = transmissão parada), diz o que está acontecendo.
                _playerAttempts >= 3
                    ? S.of(context).liveWaitingSignal
                    : S.of(context).liveConnecting,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

  Widget _placeholder() => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A1028), Color(0xFF05070F)],
      ),
    ),
  );
}

enum _StreamerPauseState { none, paused, resuming }

/// Aviso ao espectador quando o criador pausa a live — aparece na hora
/// (via socket), antes mesmo do slate "Já voltamos" chegar pelo vídeo.
/// Aviso de pausa para quem assiste — minimalista e no terço de cima, para
/// não brigar com o chat (que ocupa a metade de baixo). Mostra quanto falta
/// para o limite da pausa; ao retomar, "Voltando…" até o vídeo chegar.
class _StreamerPausedOverlay extends StatefulWidget {
  const _StreamerPausedOverlay({
    required this.streamerName,
    required this.resuming,
    this.deadline,
  });

  final String streamerName;
  final bool resuming;

  /// Fim do limite da pausa (paused_at + max_pause). Nulo = desconhecido.
  final DateTime? deadline;

  @override
  State<_StreamerPausedOverlay> createState() => _StreamerPausedOverlayState();
}

class _StreamerPausedOverlayState extends State<_StreamerPausedOverlay> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.deadline != null && !widget.resuming)
        setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final name = widget.streamerName.trim().isEmpty
        ? 'Streamer'
        : widget.streamerName.trim();
    String? left;
    final deadline = widget.deadline;
    if (deadline != null && !widget.resuming) {
      final secs = deadline.difference(DateTime.now()).inSeconds.clamp(0, 3600);
      left = '${secs ~/ 60}:${(secs % 60).toString().padLeft(2, '0')}';
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1028), Color(0xFF070B1A), Color(0xFF05070F)],
        ),
      ),
      child: Align(
        alignment: const Alignment(0, -0.42),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              ),
              child: widget.resuming
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.pause_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.resuming ? s.livePausedResuming : s.livePausedTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.resuming ? s.livePausedResumingHint : s.livePausedBy(name),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFB5BFD6), fontSize: 14),
            ),
            if (left != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  s.livePausedBackIn(left),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ],
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
    this.battleChatTop,
    required this.pinnedProduct,
    required this.notices,
    required this.tickerBuilder,
    required this.bottomBar,
  });

  /// Em batalha: Y (na tela) onde começa a região do chat. O dock nunca
  /// passa dali para cima — o chat não cobre o vídeo.
  final double? battleChatTop;

  final Widget pinnedProduct;

  /// Painel de avisos (entre o vídeo e o chat).
  final Widget notices;
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
    // Espaço reservado acima do chat: painel de avisos (~60) + 2 faixas de
    // combo de presente (~124). Sem isso, chat cheio em tela pequena
    // empurrava os combos para baixo do topo.
    const aboveChatReserve = 184.0;
    final battle = battleChatTop != null;
    // Em batalha: espaço entre o fim da faixa dividida e o input (menos ~56
    // reservados para o painel de avisos).
    final battleFree = battle
        ? size.height - battleChatTop! - _bottomBarH - bottomInset - 8 - 56
        : 0.0;
    final tickerMax = battle
        ? battleFree.clamp(0.0, 260.0)
        : typing
        ? (free * 0.75).clamp(60.0, 220.0)
        : (free - aboveChatReserve).clamp(80.0, 240.0);

    return LiveDockTopReporter(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Offstage(offstage: typing || battle, child: pinnedProduct),
            const SizedBox(height: 8),
            // Some enquanto digita: o teclado já ocupa a metade de baixo.
            Offstage(
              offstage: typing,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: size.width * (battle ? 0.78 : 0.86),
                    ),
                    child: notices,
                  ),
                ),
              ),
            ),
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

/// Em batalha, recorta o dock à região do chat (nada sobe sobre o vídeo).
class _BattleDockClip extends StatelessWidget {
  const _BattleDockClip({required this.enabled, required this.child});
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return ClipRect(
      child: Align(alignment: Alignment.bottomCenter, child: child),
    );
  }
}
