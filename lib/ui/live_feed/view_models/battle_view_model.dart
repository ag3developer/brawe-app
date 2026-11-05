import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/services/battle_service.dart';
import '../../../data/services/socket_service.dart';
import '../../../domain/models/battle_state.dart';

part 'battle_view_model.g.dart';

/// Sala em que o app está vendo a batalha (por `battle_id`). O REST filtra
/// pelo lado dessa sala (`?room_id=`, lado fechado): preenchido pelas telas
/// ANTES de assistir ao provider.
class BattleRoomScope {
  BattleRoomScope._();
  static final Map<String, String> _rooms = {};
  static void set(String battleId, String? roomId) {
    if (roomId == null || roomId.isEmpty) return;
    _rooms[battleId] = roomId;
  }

  static String? of(String battleId) => _rooms[battleId];
}

/// Drives all battle-related UI state: scores, timer, phase transitions.
///
/// Single source of truth for both battle overlays — `ViewerBattleHud`
/// (sobreposto à live do espectador) and `StreamerBattleHud` (HUD do
/// transmissor). Both receive the same socket events — only widget
/// rendering differs.
///
/// Batalha v2 (BATTLE_V2_CONTRACT):
/// - Cronômetro pelo relógio do servidor: `offset = server_now − agora local`
///   e `restante = ends_at − (agora + offset)`, recalculado a cada tick e
///   ressincronizado ao voltar do background e ao reconectar o socket.
/// - Contagem 3·2·1 dirigida por `connect:battle:countdown`.
/// - `seq` descarta `score_update` fora de ordem; `connect:battle:mute`,
///   `rtc_fallback` atualizam o modo de transmissão.
/// - Tolerante a backend antigo (campos novos ausentes).
@riverpod
class BattleViewModel extends _$BattleViewModel {
  Timer? _tickTimer;
  Timer? _countdownClear;
  Timer? _localCountdown;
  Timer? _hudLateTimer;
  AppLifecycleListener? _lifecycle;
  // Cached socket reference — used in _unsubscribeFromSocket so we never
  // call ref.read after the provider has been disposed (which would throw).
  SocketService? _cachedSocket;
  bool _disposed = false;

  /// `server_now − agora local` (UTC). Zero até o servidor informar.
  Duration _serverOffset = Duration.zero;
  Map<String, dynamic>? _pendingCountdown;
  int _localGiftSeq = 0;
  DateTime? _zeroSince;
  bool _resyncing = false;

  @override
  AsyncValue<BattleState> build(String battleId) {
    ref.onDispose(_dispose);
    try {
      _lifecycle = AppLifecycleListener(
        onResume: () => unawaited(resync()),
      );
    } catch (_) {
      // Sem binding (testes de unidade): segue sem resync ao voltar.
    }
    // Kick off: fetch initial state then subscribe to socket events.
    Future.microtask(_init);
    return const AsyncValue.loading();
  }

  /// Agora no relógio do servidor (UTC).
  DateTime get serverNow => DateTime.now().toUtc().add(_serverOffset);

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<({Map<String, dynamic> live, Map<String, dynamic> detail})>
  _fetchSnapshot() async {
    final svc = ref.read(battleServiceProvider);
    final results = await Future.wait<Map<String, dynamic>?>([
      svc.getLiveScores(battleId, roomId: BattleRoomScope.of(battleId)).then<Map<String, dynamic>?>((v) => v).catchError(
        (_) => null,
      ),
      svc.getBattle(battleId, roomId: BattleRoomScope.of(battleId)).then<Map<String, dynamic>?>((v) => v).catchError(
        (_) => null,
      ),
    ]);
    final live = results[0];
    final detail = results[1];
    if (live == null && detail == null) {
      throw StateError('battle snapshot unavailable');
    }
    return (live: _unwrap(live ?? {}), detail: _unwrap(detail ?? {}));
  }

  Future<void> _init() async {
    try {
      final snap = await _fetchSnapshot();
      if (_disposed) return;
      final initial = _buildState(null, snap.detail, snap.live);
      state = AsyncValue.data(initial);
      _subscribeToSocket();
      _startLocalTick();
      final pending = _pendingCountdown;
      if (pending != null) {
        _pendingCountdown = null;
        _applyCountdown(pending);
      }
    } catch (e, st) {
      if (_disposed) return;
      state = AsyncValue.error(e, st);
    }
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> raw) {
    final data = raw['data'];
    return data is Map ? Map<String, dynamic>.from(data) : raw;
  }

  /// Monta/atualiza o estado a partir do REST (`/{id}` + `/live-scores`).
  /// [prev] `null` = estado inicial. Campos ausentes preservam o anterior.
  BattleState _buildState(
    BattleState? prev,
    Map<String, dynamic> detail,
    Map<String, dynamic> live,
  ) {
    dynamic pick(String key) => live[key] ?? detail[key];
    Map<String, dynamic> nested(String key) {
      final v = detail[key] ?? live[key];
      return v is Map ? Map<String, dynamic>.from(v) : const {};
    }

    final nestedA = nested('streamer_a');
    final nestedB = nested('streamer_b');

    _syncClock(live);
    _syncClock(detail);

    double? score(String flat, Map<String, dynamic> n) =>
        (live[flat] as num?)?.toDouble() ??
        (n['score'] as num?)?.toDouble() ??
        (detail[flat] as num?)?.toDouble();
    int? gifts(String flat, Map<String, dynamic> n) =>
        _int(live[flat]) ?? _int(n['gifts_count']) ?? _int(detail[flat]);

    final status = (pick('status') as String?) ?? '';
    final phase = status.isEmpty
        ? (prev?.phase ?? BattlePhase.waiting)
        : _phaseFromStatus(status);

    final durationSeconds = _int(pick('duration_seconds')) ?? prev?.durationSeconds;
    var endsAt = _parseTs(pick('ends_at')) ?? prev?.endsAt;
    final remainingSeconds =
        _int(live['time_remaining_seconds']) ??
        _int(detail['time_remaining_seconds']);
    // Backend antigo (sem ends_at): sintetiza a partir do tempo restante.
    if (_parseTs(pick('ends_at')) == null &&
        remainingSeconds != null &&
        phase == BattlePhase.active) {
      endsAt = serverNow.add(Duration(seconds: remainingSeconds));
    }

    Duration remaining;
    if (phase == BattlePhase.finished || phase == BattlePhase.cancelled) {
      remaining = Duration.zero;
    } else if (endsAt != null && phase == BattlePhase.active) {
      remaining = _remainingFrom(endsAt);
    } else if (remainingSeconds != null) {
      remaining = Duration(seconds: remainingSeconds);
    } else if (prev != null && prev.phase == phase) {
      remaining = prev.timeRemaining;
    } else {
      // Ainda não começou: mostra a duração configurada (300 s só como
      // último recurso para batalhas que NÃO acabaram).
      remaining = Duration(seconds: durationSeconds ?? 300);
    }

    final muted = pick('muted');
    final mutedMap = muted is Map ? muted : const {};

    final streamUrlA = _nonEmpty(pick('stream_url_a')) ?? _nonEmpty(nestedA['stream_url']);
    final streamUrlB = _nonEmpty(pick('stream_url_b')) ?? _nonEmpty(nestedB['stream_url']);

    return BattleState(
      battleId: battleId,
      scoreA: score('score_a', nestedA) ?? prev?.scoreA ?? 0,
      scoreB: score('score_b', nestedB) ?? prev?.scoreB ?? 0,
      giftsCountA: gifts('gifts_count_a', nestedA) ?? prev?.giftsCountA ?? 0,
      giftsCountB: gifts('gifts_count_b', nestedB) ?? prev?.giftsCountB ?? 0,
      timeRemaining: remaining,
      endsAt: endsAt,
      durationSeconds: durationSeconds,
      streamerAId:
          _str(detail['streamer_a_id']) ??
          _str(nestedA['id']) ??
          prev?.streamerAId ??
          '',
      streamerBId:
          _str(detail['streamer_b_id']) ??
          _str(nestedB['id']) ??
          prev?.streamerBId ??
          '',
      streamerAName:
          _str(detail['streamer_a_name']) ??
          _str(nestedA['name']) ??
          prev?.streamerAName ??
          '',
      streamerBName:
          _str(detail['streamer_b_name']) ??
          _str(nestedB['name']) ??
          prev?.streamerBName ??
          '',
      streamerAAvatarUrl:
          _nonEmpty(nestedA['avatar_url']) ??
          _nonEmpty(detail['streamer_a_avatar']) ??
          _nonEmpty(nestedA['avatar']) ??
          prev?.streamerAAvatarUrl,
      streamerBAvatarUrl:
          _nonEmpty(nestedB['avatar_url']) ??
          _nonEmpty(detail['streamer_b_avatar']) ??
          _nonEmpty(nestedB['avatar']) ??
          prev?.streamerBAvatarUrl,
      roomAId:
          _str(detail['room_a_id']) ?? _str(nestedA['room_id']) ?? prev?.roomAId,
      roomBId:
          _str(detail['room_b_id']) ?? _str(nestedB['room_id']) ?? prev?.roomBId,
      flash: (live.containsKey('flash') || detail.containsKey('flash'))
          ? _flashFrom(pick('flash'))
          : _stillValid(prev?.flash),
      winStreakA: _int(nestedA['win_streak']) ?? _int(detail['streamer_a_win_streak']) ?? prev?.winStreakA,
      winStreakB: _int(nestedB['win_streak']) ?? _int(detail['streamer_b_win_streak']) ?? prev?.winStreakB,
      roomSlugA: _str(nestedA['room_slug']) ?? prev?.roomSlugA,
      roomSlugB: _str(nestedB['room_slug']) ?? prev?.roomSlugB,
      mvp: _mvpFrom(pick('mvp')) ?? prev?.mvp,
      mvpSide: _str((pick('mvp') is Map) ? (pick('mvp') as Map)['side'] : null) ?? prev?.mvpSide,
      streamUrlA: streamUrlA ?? prev?.streamUrlA,
      streamUrlB: streamUrlB ?? prev?.streamUrlB,
      playbackIdA:
          _nonEmpty(pick('playback_id_a')) ??
          _nonEmpty(nestedA['playback_id']) ??
          prev?.playbackIdA,
      playbackIdB:
          _nonEmpty(pick('playback_id_b')) ??
          _nonEmpty(nestedB['playback_id']) ??
          prev?.playbackIdB,
      phase: phase,
      rtcMode: _str(pick('rtc_mode')) ?? prev?.rtcMode ?? 'dual_hls',
      powerMoment: pick('power_moment') as bool? ?? prev?.powerMoment ?? false,
      multiplier:
          (pick('power_multiplier') as num?)?.toDouble() ??
          prev?.multiplier ??
          1.0,
      powerWindowSeconds:
          _int(pick('power_window_seconds')) ?? prev?.powerWindowSeconds ?? 30,
      topGifterA: _parseGifter(live['top_gifter_a']) ?? prev?.topGifterA,
      topGifterB: _parseGifter(live['top_gifter_b']) ?? prev?.topGifterB,
      topGiftersA: _giftersFrom(live, detail, 'top_gifters_a') ??
          prev?.topGiftersA ??
          const [],
      topGiftersB: _giftersFrom(live, detail, 'top_gifters_b') ??
          prev?.topGiftersB ??
          const [],
      mutedA: mutedMap.isNotEmpty ? mutedMap['a'] == true : (prev?.mutedA ?? false),
      mutedB: mutedMap.isNotEmpty ? mutedMap['b'] == true : (prev?.mutedB ?? false),
      winner: _str(pick('winner')) ?? prev?.winner,
      winnerId: _str(pick('winner_id')) ?? prev?.winnerId,
      winnerName: _str(pick('winner_name')) ?? prev?.winnerName,
      endReason: _str(pick('end_reason')) ?? prev?.endReason,
      forfeitBy: _str(pick('ended_by')) ?? _str(pick('forfeit_by')) ?? prev?.forfeitBy,
      countdown: prev?.countdown,
      lastGift: prev?.lastGift,
      lastSeq: prev?.lastSeq ?? 0,
    );
  }

  BattleGifter? _mvpFrom(dynamic raw) {
    if (raw is Map) return BattleGifter.fromJson(Map<String, dynamic>.from(raw));
    return null;
  }

  List<BattleGifter>? _giftersFrom(
    Map<String, dynamic> live,
    Map<String, dynamic> detail,
    String key,
  ) {
    if (live.containsKey(key)) return BattleGifter.listFrom(live[key]);
    if (detail.containsKey(key)) return BattleGifter.listFrom(detail[key]);
    return null;
  }

  // ── Socket subscriptions ──────────────────────────────────────────────────

  void _subscribeToSocket() {
    final socket = ref.read(socketServiceProvider);
    // Guardar referência para poder des-registrar no dispose sem usar ref
    _cachedSocket = socket;
    _attachHandlers();
    // 🔁 O socket interno é recriado em reconexões — re-anexa os handlers
    // e ressincroniza o placar/fase/relógio via REST.
    socket.addReconnectCallback(_onReconnect);
  }

  void _attachHandlers() {
    final socket = _cachedSocket;
    if (socket == null) return;
    _detachHandlers();
    socket.on(AppConstants.eventBattleStarted, _onStarted);
    socket.on(AppConstants.eventBattleCountdown, _onCountdown);
    socket.on(AppConstants.eventBattleScoreUpdate, _onScoreUpdate);
    socket.on(AppConstants.eventBattleEnded, _onEnded);
    socket.on(AppConstants.eventBattleCancelled, _onCancelled);
    socket.on(AppConstants.eventBattleMute, _onMute);
    socket.on(AppConstants.eventBattleRtcFallback, _onRtcFallback);
    socket.on(AppConstants.eventBattleFlash, _onFlash);
  }

  /// ⚠️ Sempre `off(evento, handler)`: `off(evento)` sem handler removia
  /// os listeners das telas (BroadcasterScreen/LivePlayerScreen) também —
  /// depois da 1ª batalha, a 2ª nunca aparecia.
  void _detachHandlers() {
    final socket = _cachedSocket;
    if (socket == null) return;
    socket.off(AppConstants.eventBattleStarted, _onStarted);
    socket.off(AppConstants.eventBattleCountdown, _onCountdown);
    socket.off(AppConstants.eventBattleScoreUpdate, _onScoreUpdate);
    socket.off(AppConstants.eventBattleEnded, _onEnded);
    socket.off(AppConstants.eventBattleCancelled, _onCancelled);
    socket.off(AppConstants.eventBattleMute, _onMute);
    socket.off(AppConstants.eventBattleRtcFallback, _onRtcFallback);
    socket.off(AppConstants.eventBattleFlash, _onFlash);
  }

  void _onReconnect() {
    _attachHandlers();
    unawaited(resync());
  }

  /// Ressincroniza placar/fase/relógio via REST (eventos perdidos offline,
  /// volta do background, reconexão do socket).
  Future<void> resync() async {
    if (_disposed || _resyncing || !state.hasValue) return;
    _resyncing = true;
    try {
      final snap = await _fetchSnapshot();
      if (_disposed) return;
      final cur = state.value;
      if (cur == null) return;
      // Já terminou localmente: não deixa um snapshot atrasado "ressuscitar".
      if (cur.isOver || cur.isCancelled) return;
      state = AsyncValue.data(_buildState(cur, snap.detail, snap.live));
      _startLocalTick();
    } catch (_) {
    } finally {
      _resyncing = false;
    }
  }

  void _unsubscribeFromSocket() {
    // Usa a referência cacheada — ref pode já estar inválida no dispose
    _detachHandlers();
    _cachedSocket?.removeReconnectCallback(_onReconnect);
    _cachedSocket = null;
  }

  // ── Event handlers ────────────────────────────────────────────────────────

  void _onStarted(dynamic raw) {
    final json = _parse(raw);
    if (json == null || json['battle_id'] != battleId) return;
    _syncClock(json);
    _localCountdown?.cancel();
    _countdownClear?.cancel();
    final duration = _int(json['duration_seconds']);
    _update((s) {
      var endsAt = _parseTs(json['ends_at']);
      endsAt ??= serverNow.add(
        Duration(seconds: duration ?? s.durationSeconds ?? 300),
      );
      final muted = json['muted'];
      return s.copyWith(
        phase: BattlePhase.active,
        countdown: null,
        endsAt: endsAt,
        durationSeconds: duration ?? s.durationSeconds,
        timeRemaining: _remainingFrom(endsAt),
        rtcMode: _str(json['rtc_mode']) ?? s.rtcMode,
        mutedA: muted is Map ? muted['a'] == true : s.mutedA,
        mutedB: muted is Map ? muted['b'] == true : s.mutedB,
        // 🎬 Atualiza URLs do split-screen — fallback caso o REST inicial
        // tenha sido feito quando a sala ainda não tinha stream provisionado.
        streamUrlA: _nonEmpty(json['stream_url_a']) ?? s.streamUrlA,
        streamUrlB: _nonEmpty(json['stream_url_b']) ?? s.streamUrlB,
        playbackIdA: _nonEmpty(json['playback_id_a']) ?? s.playbackIdA,
        playbackIdB: _nonEmpty(json['playback_id_b']) ?? s.playbackIdB,
        roomAId: _nonEmpty(json['room_a_id']) ?? s.roomAId,
        roomBId: _nonEmpty(json['room_b_id']) ?? s.roomBId,
      );
    });
    _startLocalTick();
  }

  void _onCountdown(dynamic raw) {
    final json = _parse(raw);
    if (json == null || json['battle_id'] != battleId) return;
    if (!state.hasValue) {
      // Estado ainda carregando (espectador criou o VM por causa deste
      // evento): aplica assim que o snapshot chegar.
      _pendingCountdown = json;
      return;
    }
    _applyCountdown(json);
  }

  /// Aplica um evento de contagem recebido antes de o VM existir (o HUD do
  /// espectador entrega o payload que originou a criação dele).
  void handleCountdown(Map<String, dynamic> json) {
    if (!state.hasValue) {
      _pendingCountdown = json;
      return;
    }
    _applyCountdown(json);
  }

  void _applyCountdown(Map<String, dynamic> json) {
    _syncClock(json);
    final startsAt = _parseTs(json['starts_at']);
    int? value;
    for (final k in const ['count', 'value', 'seconds', 'n', 'countdown', 'remaining']) {
      value = _int(json[k]);
      if (value != null) break;
    }
    // Sem número no payload: deriva de starts_at − server_now.
    if (value == null && startsAt != null) {
      final ms = startsAt.difference(serverNow).inMilliseconds;
      value = (ms / 1000).ceil();
    }
    final hasNumber = value != null;
    if (hasNumber) value = value.clamp(0, 5);
    final rtc = _str(json['rtc_mode']);
    _update(
      (s) => s.copyWith(
        phase: s.phase == BattlePhase.active ? s.phase : BattlePhase.countdown,
        rtcMode: rtc ?? s.rtcMode,
        countdown: hasNumber ? (value! > 0 ? value : null) : 3,
      ),
    );
    _countdownClear?.cancel();
    _localCountdown?.cancel();
    if (hasNumber) {
      // Um evento por segundo: se o próximo não vier, apaga depois de 1,6 s.
      _countdownClear = Timer(const Duration(milliseconds: 1600), () {
        if (_disposed) return;
        _update((s) => s.copyWith(countdown: null));
      });
    } else {
      // Backend antigo (um único evento): 3·2·1 local.
      var n = 3;
      _localCountdown = Timer.periodic(const Duration(seconds: 1), (t) {
        n--;
        if (_disposed) {
          t.cancel();
          return;
        }
        if (n <= 0) {
          t.cancel();
          _update((s) => s.copyWith(countdown: null));
        } else {
          _update((s) => s.copyWith(countdown: n));
        }
      });
    }
  }

  void _onScoreUpdate(dynamic raw) {
    final json = _parse(raw);
    if (json == null || json['battle_id'] != battleId) return;
    _syncClock(json);
    _update((s) {
      if (s.isOver || s.isCancelled) return s;
      final seq = _int(json['seq']);
      // Evento fora de ordem / repetido: ignora por completo.
      if (seq != null && seq <= s.lastSeq) return s;

      final endsAtNew = _parseTs(json['ends_at']);
      final legacyRemaining = _int(json['time_remaining']);
      DateTime? endsAt = endsAtNew ?? s.endsAt;
      if (endsAtNew == null && legacyRemaining != null) {
        endsAt = serverNow.add(Duration(seconds: legacyRemaining));
      }

      // Presente que pontuou: `last_gift` (v2) ou campos planos (legado).
      BattleGiftEvent? gift = s.lastGift;
      final lg = json['last_gift'];
      if (lg is Map) {
        final side = _str(lg['side']) ?? _str(json['updated_side']) ?? 'a';
        gift = BattleGiftEvent(
          seq: seq ?? ++_localGiftSeq + 1000000,
          side: side == 'b' ? 'b' : 'a',
          senderName: _str(lg['sender_name']) ?? '',
          giftName: _str(lg['gift_name']) ?? '',
          senderAvatar: _nonEmpty(lg['sender_avatar']),
          iconUrl: _nonEmpty(lg['icon_url']),
          quantity: _int(lg['quantity']) ?? 1,
        );
      } else if (json['last_gift_sender'] is String &&
          json['last_gift_name'] is String) {
        final side = _str(json['updated_side']) ?? 'a';
        gift = BattleGiftEvent(
          seq: seq ?? ++_localGiftSeq + 1000000,
          side: side == 'b' ? 'b' : 'a',
          senderName: json['last_gift_sender'] as String,
          giftName: json['last_gift_name'] as String,
        );
      }

      final activeNow = s.phase == BattlePhase.active || endsAt != null;
      return s.copyWith(
        scoreA: (json['score_a'] as num?)?.toDouble() ?? s.scoreA,
        scoreB: (json['score_b'] as num?)?.toDouble() ?? s.scoreB,
        giftsCountA: _int(json['gifts_count_a']) ?? s.giftsCountA,
        giftsCountB: _int(json['gifts_count_b']) ?? s.giftsCountB,
        endsAt: endsAt,
        timeRemaining: endsAt != null && activeNow
            ? _remainingFrom(endsAt)
            : s.timeRemaining,
        lastSeq: seq ?? s.lastSeq,
        lastGift: gift,
        lastGiftSender: _str(json['last_gift_sender']) ?? s.lastGiftSender,
        lastGiftName: _str(json['last_gift_name']) ?? s.lastGiftName,
        lastUpdatedSide: _str(json['updated_side']) ?? s.lastUpdatedSide,
        // 🔥 Power Moment + 🏅 MVP (campos enriquecidos pelo backend).
        multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
        powerMoment: json['power_moment'] as bool? ?? false,
        powerWindowSeconds:
            _int(json['power_window_seconds']) ?? s.powerWindowSeconds,
        topGifterA: json.containsKey('top_gifter_a')
            ? _parseGifter(json['top_gifter_a'])
            : s.topGifterA,
        topGifterB: json.containsKey('top_gifter_b')
            ? _parseGifter(json['top_gifter_b'])
            : s.topGifterB,
        topGiftersA: json.containsKey('top_gifters_a')
            ? BattleGifter.listFrom(json['top_gifters_a'])
            : null,
        topGiftersB: json.containsKey('top_gifters_b')
            ? BattleGifter.listFrom(json['top_gifters_b'])
            : null,
      );
    });
  }

  /// Converte o sub-objeto `top_gifter_*` do payload em [BattleGifter].
  /// Retorna `null` quando ausente (lado sem doações).
  BattleGifter? _parseGifter(dynamic raw) {
    if (raw is Map) {
      return BattleGifter.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  void _onEnded(dynamic raw) {
    final json = _parse(raw);
    if (json == null || json['battle_id'] != battleId) return;
    _tickTimer?.cancel();
    _countdownClear?.cancel();
    _localCountdown?.cancel();
    _update(
      (s) => s.copyWith(
        phase: BattlePhase.finished,
        countdown: null,
        scoreA: (json['score_a'] as num?)?.toDouble() ?? s.scoreA,
        scoreB: (json['score_b'] as num?)?.toDouble() ?? s.scoreB,
        winnerId: _str(json['winner_id']) ?? s.winnerId,
        winnerName: _str(json['winner_name']) ?? s.winnerName,
        winner: _str(json['winner']) ?? s.winner,
        endReason: _str(json['end_reason']) ?? s.endReason,
        forfeitBy: _str(json['ended_by']) ?? _str(json['forfeit_by']),
        mvp: _mvpFrom(json['mvp']) ?? s.mvp,
        mvpSide: _str((json['mvp'] is Map) ? (json['mvp'] as Map)['side'] : null) ?? s.mvpSide,
        powerMoment: false,
        topGifterA: json.containsKey('top_gifter_a')
            ? _parseGifter(json['top_gifter_a'])
            : s.topGifterA,
        topGifterB: json.containsKey('top_gifter_b')
            ? _parseGifter(json['top_gifter_b'])
            : s.topGifterB,
        topGiftersA: json.containsKey('top_gifters_a')
            ? BattleGifter.listFrom(json['top_gifters_a'])
            : null,
        topGiftersB: json.containsKey('top_gifters_b')
            ? BattleGifter.listFrom(json['top_gifters_b'])
            : null,
        timeRemaining: Duration.zero,
      ),
    );
  }

  void _onCancelled(dynamic raw) {
    final json = _parse(raw);
    if (json == null || json['battle_id'] != battleId) return;
    _tickTimer?.cancel();
    _countdownClear?.cancel();
    _localCountdown?.cancel();
    _update(
      (s) => s.copyWith(
        phase: BattlePhase.cancelled,
        countdown: null,
        timeRemaining: Duration.zero,
      ),
    );
  }

  void _onMute(dynamic raw) {
    final json = _parse(raw);
    if (json == null || json['battle_id'] != battleId) return;
    final m = json['muted'];
    if (m is! Map) return;
    _update((s) => s.copyWith(mutedA: m['a'] == true, mutedB: m['b'] == true));
  }

  void _onRtcFallback(dynamic raw) {
    final json = _parse(raw);
    if (json == null || json['battle_id'] != battleId) return;
    _update((s) => s.copyWith(rtcMode: _str(json['rtc_mode']) ?? 'dual_hls'));
  }

  /// Mantém o desafio anterior só enquanto o prazo dele não passou.
  BattleFlash? _stillValid(BattleFlash? f) {
    if (f == null) return null;
    final end = f.isBoost ? f.boostEndsAt : f.challengeEndsAt;
    if (end == null || end.isBefore(DateTime.now())) return null;
    return f;
  }

  BattleFlash? _flashFrom(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final phase = _str(m['phase']);
    if (phase != 'challenge' && phase != 'boost') return null;
    _syncClock(m);
    final gift = m['gift'] is Map ? Map<String, dynamic>.from(m['gift'] as Map) : const <String, dynamic>{};
    // Prazos do servidor → relógio local (offset = server_now − agora).
    DateTime? local(dynamic v) => _parseTs(v)?.subtract(_serverOffset).toLocal();
    return BattleFlash(
      phase: phase!,
      giftName: _str(gift['name']) ?? '',
      giftSlug: _str(gift['slug']) ?? '',
      iconUrl: _nonEmpty(gift['icon_url']),
      target: _int(m['target_count']) ?? 0,
      progress: _int(m['progress']) ?? 0,
      challengeEndsAt: local(m['challenge_ends_at']),
      boostEndsAt: local(m['boost_ends_at']),
      multiplier: (m['multiplier'] as num?)?.toDouble() ?? 2.0,
    );
  }

  void _onFlash(dynamic raw) {
    final json = _parse(raw);
    if (json == null || json['battle_id'] != battleId) return;
    // phase "ended" (ou inválida) → remove a pílula.
    final f = _flashFrom(json);
    _update((s) => s.copyWith(flash: f));
  }

  /// Atualização otimista do mute (resposta do POST /mute).
  void applyMute({required bool a, required bool b}) {
    _update((s) => s.copyWith(mutedA: a, mutedB: b));
  }

  // ── Relógio do servidor ───────────────────────────────────────────────────

  void _syncClock(Map<String, dynamic> json) {
    final sn = _parseTs(json['server_now']);
    if (sn != null) {
      _serverOffset = sn.difference(DateTime.now().toUtc());
    }
  }

  Duration _remainingFrom(DateTime endsAt) {
    final ms = endsAt.difference(serverNow).inMilliseconds;
    if (ms <= 0) return Duration.zero;
    return Duration(seconds: (ms / 1000).ceil());
  }

  /// Tick de 500 ms: recalcula o restante a partir de `ends_at` (nunca
  /// decrementa 1 s por tick, então não acumula deriva) e só emite estado
  /// quando o segundo exibido muda.
  void _startLocalTick() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final s = state.value;
      if (s == null || _disposed) return;
      if (s.phase != BattlePhase.active) {
        if (s.isOver || s.isCancelled) _tickTimer?.cancel();
        return;
      }
      final endsAt = s.endsAt;
      if (endsAt == null) return;
      final remaining = _remainingFrom(endsAt);
      if (remaining.inSeconds != s.timeRemaining.inSeconds) {
        state = AsyncValue.data(s.copyWith(timeRemaining: remaining));
      }
      // Passou do fim e o `ended` não chegou: busca o resultado no REST.
      if (remaining == Duration.zero) {
        _zeroSince ??= DateTime.now();
        if (DateTime.now().difference(_zeroSince!) >
            const Duration(seconds: 6)) {
          _zeroSince = DateTime.now();
          unawaited(_resyncEnded());
        }
      } else {
        _zeroSince = null;
      }
    });
  }

  Future<void> _resyncEnded() async {
    try {
      final snap = await _fetchSnapshot();
      if (_disposed) return;
      final cur = state.value;
      if (cur == null || cur.isOver) return;
      final next = _buildState(cur, snap.detail, snap.live);
      state = AsyncValue.data(next);
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _update(BattleState Function(BattleState) updater) {
    final s = state.value;
    if (s == null || _disposed) return;
    state = AsyncValue.data(updater(s));
  }

  Map<String, dynamic>? _parse(dynamic raw) {
    try {
      if (raw is Map<String, dynamic>) return raw;
      if (raw is Map) return Map<String, dynamic>.from(raw);
      if (raw is String) {
        final d = jsonDecode(raw);
        if (d is Map) return Map<String, dynamic>.from(d);
      }
      return null;
    } catch (e) {
      debugPrint('BattleViewModel: parse error $e');
      return null;
    }
  }

  BattlePhase _phaseFromStatus(String status) {
    switch (status) {
      case 'active':
        return BattlePhase.active;
      case 'countdown':
        return BattlePhase.countdown;
      case 'finished':
      case 'draw':
        return BattlePhase.finished;
      case 'cancelled':
        return BattlePhase.cancelled;
      default:
        return BattlePhase.waiting;
    }
  }

  void _dispose() {
    _disposed = true;
    _tickTimer?.cancel();
    _countdownClear?.cancel();
    _localCountdown?.cancel();
    _hudLateTimer?.cancel();
    _lifecycle?.dispose();
    _lifecycle = null;
    _unsubscribeFromSocket();
  }
}

/// Converte valores opcionais em `String?` tratando strings vazias como `null`
/// (o backend devolve `""` quando a sala não tem playback URL ainda).
String? _nonEmpty(dynamic value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

/// `num`/`String` → `int?` (o JSON pode trazer `300.0`, e `as int?` quebra).
int? _int(dynamic v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// Timestamp ISO-8601 → UTC. Sem fuso explícito, assume UTC.
DateTime? _parseTs(dynamic v) {
  if (v is! String || v.isEmpty) return null;
  var s = v;
  final hasTz = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(s);
  if (!hasTz) s = '${s}Z';
  return DateTime.tryParse(s)?.toUtc();
}
