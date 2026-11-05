import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/live_dio_provider.dart';
import '../../domain/models/battle_candidate.dart';
import '../../domain/models/link_state.dart';
import 'battle_service.dart';

final linkServiceProvider = Provider<LinkService>(
  (ref) => LinkService(ref.watch(liveDioProvider)),
);

/// Conexão entre criadores (`/live/link`, BATTLE_V2_CONTRACT §8.2).
class LinkService {
  LinkService(this._dio);
  final Dio _dio;

  Map<String, dynamic> _map(dynamic d) {
    if (d is Map) {
      final m = Map<String, dynamic>.from(d);
      return m['data'] is Map ? Map<String, dynamic>.from(m['data'] as Map) : m;
    }
    return {};
  }

  /// Também serve de sonda: 503 = tempo real desligado (esconder "Conectar").
  Future<(List<BattleCandidate>, String?)> getCandidates({
    String? query,
    String? cursor,
    int limit = 20,
  }) async {
    final r = await _dio.get(
      '/live/link/candidates',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    final data = _map(r.data);
    final items = (data['items'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => BattleCandidate.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.roomId.isNotEmpty)
        .toList();
    final next = data['next_cursor']?.toString();
    return (items, next == null || next.isEmpty ? null : next);
  }

  Future<Map<String, dynamic>> invite({
    required String opponentRoomId,
    bool withBattle = false,
    int? durationSeconds,
  }) async {
    final r = await _dio.post(
      '/live/link/invite',
      data: {
        'opponent_room_id': opponentRoomId,
        'with_battle': withBattle,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
      },
    );
    return _map(r.data);
  }

  Future<void> accept(String linkId) => _dio.post('/live/link/$linkId/accept');
  Future<void> decline(String linkId) => _dio.post('/live/link/$linkId/decline');
  Future<void> cancel(String linkId) => _dio.post('/live/link/$linkId/cancel');
  Future<void> end(String linkId) => _dio.post(
    '/live/link/$linkId/end',
    options: Options(receiveTimeout: const Duration(seconds: 8)),
  );

  Future<BattleRtcCredentials> getRtc(String linkId) async {
    final r = await _dio.get(
      '/live/link/$linkId/rtc',
      options: Options(receiveTimeout: const Duration(seconds: 6)),
    );
    return BattleRtcCredentials.fromJson(_map(r.data));
  }

  Future<({bool a, bool b})?> setMute(String linkId, bool muted) async {
    final r = await _dio.post('/live/link/$linkId/mute', data: {'muted': muted});
    final m = _map(r.data)['muted'];
    return m is Map ? (a: m['a'] == true, b: m['b'] == true) : null;
  }

  /// Conexão ativa da sala (404 = nenhuma).
  Future<LinkState?> getActive(String roomId) async {
    final r = await _dio.get('/live/link/active', queryParameters: {'room_id': roomId});
    return LinkState.tryParse(r.data);
  }
}
