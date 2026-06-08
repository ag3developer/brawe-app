import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/services/battle_service.dart';
import '../../../data/services/socket_service.dart';
import '../../../domain/models/battle_state.dart';

part 'battle_view_model.g.dart';

/// Drives all battle-related UI state: scores, timer, phase transitions.
///
/// Single source of truth for both battle overlays — `ViewerBattleHud`
/// (sobreposto à live do espectador) and `StreamerBattleHud` (HUD do
/// transmissor). Both receive the same socket events — only widget
/// rendering differs.
@riverpod
class BattleViewModel extends _$BattleViewModel {
  Timer? _tickTimer;
  // Cached socket reference — used in _unsubscribeFromSocket so we never
  // call ref.read after the provider has been disposed (which would throw).
  SocketService? _cachedSocket;

  @override
  AsyncValue<BattleState> build(String battleId) {
    ref.onDispose(_dispose);
    // Kick off: fetch initial state then subscribe to socket events.
    Future.microtask(() => _init());
    return const AsyncValue.loading();
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    try {
      final json = await ref.read(battleServiceProvider).getLiveScores(battleId);
      final data = (json['data'] as Map<String, dynamic>?) ?? json;

      // Buscar detalhes completos (campos planos de streamer + room ids)
      Map<String, dynamic> battleDetail = {};
      try {
        final raw = await ref.read(battleServiceProvider).getBattle(battleId);
        battleDetail = (raw['data'] as Map<String, dynamic>?) ?? raw;
      } catch (_) {}

      // O endpoint DB devolve campos planos (streamer_a_id, streamer_a_name, …)
      // e também objetos aninhados (streamer_a.score, streamer_b.score).
      // Priorizamos campos planos; fazemos fallback para aninhados quando ausentes.
      final nestedA = (battleDetail['streamer_a'] as Map?)?.cast<String, dynamic>() ?? {};
      final nestedB = (battleDetail['streamer_b'] as Map?)?.cast<String, dynamic>() ?? {};

      // Scores iniciais: prefere dados frescos do Redis (data), senão usa DB.
      final scoreA = (data['score_a'] as num?)?.toDouble()
          ?? (nestedA['score'] as num?)?.toDouble()
          ?? 0.0;
      final scoreB = (data['score_b'] as num?)?.toDouble()
          ?? (nestedB['score'] as num?)?.toDouble()
          ?? 0.0;

      final initial = BattleState(
        battleId: battleId,
        scoreA: scoreA,
        scoreB: scoreB,
        giftsCountA: (data['gifts_count_a'] as int?)
            ?? (nestedA['gifts_count'] as int?)
            ?? 0,
        giftsCountB: (data['gifts_count_b'] as int?)
            ?? (nestedB['gifts_count'] as int?)
            ?? 0,
        timeRemaining: Duration(
          seconds: (data['time_remaining_seconds'] as int?) ?? 300,
        ),
        streamerAId: battleDetail['streamer_a_id'] as String?
            ?? nestedA['id'] as String? ?? '',
        streamerAName: battleDetail['streamer_a_name'] as String?
            ?? nestedA['name'] as String? ?? '',
        streamerBId: battleDetail['streamer_b_id'] as String?
            ?? nestedB['id'] as String? ?? '',
        streamerBName: battleDetail['streamer_b_name'] as String?
            ?? nestedB['name'] as String? ?? '',
        streamerAAvatarUrl: battleDetail['streamer_a_avatar'] as String?
            ?? nestedA['avatar'] as String?,
        streamerBAvatarUrl: battleDetail['streamer_b_avatar'] as String?
            ?? nestedB['avatar'] as String?,
        roomAId: battleDetail['room_a_id'] as String?,
        roomBId: battleDetail['room_b_id'] as String?,
        phase: _phaseFromStatus(data['status'] as String? ?? ''),
        // 🔥/🏅 Sincroniza Power Moment + MVP ao entrar mid-battle.
        powerMoment: data['power_moment'] as bool? ?? false,
        multiplier: (data['power_multiplier'] as num?)?.toDouble() ?? 1.0,
        topGifterA: _parseGifter(data['top_gifter_a']),
        topGifterB: _parseGifter(data['top_gifter_b']),
      );

      state = AsyncValue.data(initial);
      _subscribeToSocket();
      if (initial.phase == BattlePhase.active) _startLocalTick();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ── Socket subscriptions ──────────────────────────────────────────────────

  void _subscribeToSocket() {
    final socket = ref.read(socketServiceProvider);

    socket.on(AppConstants.eventBattleStarted, _onStarted);
    socket.on(AppConstants.eventBattleCountdown, _onCountdown);
    socket.on(AppConstants.eventBattleScoreUpdate, _onScoreUpdate);
    socket.on(AppConstants.eventBattleEnded, _onEnded);

    // Guardar referência para poder des-registrar no dispose sem usar ref
    _cachedSocket = socket;
  }

  void _unsubscribeFromSocket() {
    // Usa a referência cacheada — ref pode já estar inválida no dispose
    _cachedSocket?.off(AppConstants.eventBattleStarted);
    _cachedSocket?.off(AppConstants.eventBattleCountdown);
    _cachedSocket?.off(AppConstants.eventBattleScoreUpdate);
    _cachedSocket?.off(AppConstants.eventBattleEnded);
    _cachedSocket = null;
  }

  void _onStarted(dynamic raw) {
    final json = _parse(raw);
    if (json == null || json['battle_id'] != battleId) return;
    _update((s) => s.copyWith(
      phase: BattlePhase.active,
      timeRemaining: Duration(
        seconds: json['duration_seconds'] as int? ?? 300,
      ),
    ));
    _startLocalTick();
  }

  void _onCountdown(dynamic raw) {
    final json = _parse(raw);
    if (json == null || json['battle_id'] != battleId) return;
    _update((s) => s.copyWith(phase: BattlePhase.countdown));
  }

  void _onScoreUpdate(dynamic raw) {
    final json = _parse(raw);
    if (json == null || json['battle_id'] != battleId) return;
    _update((s) => s.copyWith(
      scoreA: (json['score_a'] as num?)?.toDouble() ?? s.scoreA,
      scoreB: (json['score_b'] as num?)?.toDouble() ?? s.scoreB,
      giftsCountA: json['gifts_count_a'] as int? ?? s.giftsCountA,
      giftsCountB: json['gifts_count_b'] as int? ?? s.giftsCountB,
      timeRemaining: Duration(seconds: json['time_remaining'] as int? ?? s.timeRemaining.inSeconds),
      lastGiftSender: json['last_gift_sender'] as String?,
      lastGiftName: json['last_gift_name'] as String?,
      lastUpdatedSide: json['updated_side'] as String?,
      // 🔥 Power Moment + 🏅 MVP (campos enriquecidos pelo backend).
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      powerMoment: json['power_moment'] as bool? ?? false,
      topGifterA: _parseGifter(json['top_gifter_a']),
      topGifterB: _parseGifter(json['top_gifter_b']),
    ));
  }

  /// Converte o sub-objeto `top_gifter_*` do payload em [BattleGifter].
  /// Retorna `null` quando ausente (lado sem doações).
  BattleGifter? _parseGifter(dynamic raw) {
    if (raw is Map<String, dynamic>) return BattleGifter.fromJson(raw);
    return null;
  }

  void _onEnded(dynamic raw) {
    final json = _parse(raw);
    if (json == null || json['battle_id'] != battleId) return;
    _tickTimer?.cancel();
    _update((s) => s.copyWith(
      phase: BattlePhase.finished,
      scoreA: (json['score_a'] as num?)?.toDouble() ?? s.scoreA,
      scoreB: (json['score_b'] as num?)?.toDouble() ?? s.scoreB,
      winnerId: json['winner_id'] as String?,
      winnerName: json['winner_name'] as String?,
      timeRemaining: Duration.zero,
    ));
  }

  // ── Local countdown tick ──────────────────────────────────────────────────

  void _startLocalTick() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state.whenData((s) {
        if (s.phase != BattlePhase.active) {
          _tickTimer?.cancel();
          return;
        }
        final remaining = s.timeRemaining - const Duration(seconds: 1);
        if (remaining <= Duration.zero) {
          _tickTimer?.cancel();
          _update((s) => s.copyWith(timeRemaining: Duration.zero));
        } else {
          _update((s) => s.copyWith(timeRemaining: remaining));
        }
      });
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _update(BattleState Function(BattleState) updater) {
    state.whenData((s) {
      state = AsyncValue.data(updater(s));
    });
  }

  Map<String, dynamic>? _parse(dynamic raw) {
    try {
      if (raw is Map<String, dynamic>) return raw;
      if (raw is String) return jsonDecode(raw) as Map<String, dynamic>;
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
      case 'finished':
      case 'draw':
        return BattlePhase.finished;
      default:
        return BattlePhase.waiting;
    }
  }

  void _dispose() {
    _tickTimer?.cancel();
    _unsubscribeFromSocket();
  }
}
