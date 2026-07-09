import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';

part 'analytics_service.g.dart';

@riverpod
AnalyticsService analyticsService(Ref ref) {
  return AnalyticsService(ref.watch(liveDioProvider));
}

/// Serviço HTTP para o módulo de Analytics do Creator Dashboard.
///
/// Base URL: /api/v1/analytics
///
/// Endpoints disponíveis:
///   GET /analytics/dashboard      → KPIs gerais (total lives, viewers, followers, earnings)
///   GET /analytics/earnings        → Histórico de ganhos por período
///   GET /analytics/viewers         → Histórico de audiência por período
///   GET /analytics/top-gifts       → Gifts mais recebidos
///   GET /analytics/live-history    → Histórico paginado de lives com métricas
///
/// Integrado com:
///   GET /social/stats/:userId      → followers_count, following_count, total_lives, total_viewers
///   GET /profile/:userId/lives     → lives paginadas com playback_url (Mux HLS)
class AnalyticsService {
  final Dio _dio;
  AnalyticsService(this._dio);

  // ─── Dashboard KPIs ─────────────────────────────────────────────────

  /// Retorna KPIs do streamer:
  /// total_lives, total_viewers, total_followers, total_earnings,
  /// total_gifts_received, total_products_sold, avg_viewers_per_live,
  /// avg_duration_minutes
  Future<Map<String, dynamic>> getDashboard() async {
    final r = await _dio.get<Map<String, dynamic>>('/analytics/dashboard');
    return _unwrap(r.data ?? {});
  }

  // ─── Earnings history ───────────────────────────────────────────────

  /// period: "7d" | "30d" | "90d" | "365d"
  /// Retorna lista de { date, earnings, gifts_count, platform_fee }
  Future<List<Map<String, dynamic>>> getEarnings({
    String period = '30d',
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/analytics/earnings',
      queryParameters: {'period': period},
    );
    final data = _unwrap(r.data ?? {});
    if (data is List) return List<Map<String, dynamic>>.from(data);
    return _toList(data);
  }

  // ─── Viewers history ────────────────────────────────────────────────

  /// period: "7d" | "30d" | "90d" | "365d"
  /// Retorna lista de { date, viewers, peak_viewers }
  Future<List<Map<String, dynamic>>> getViewersHistory({
    String period = '30d',
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/analytics/viewers',
      queryParameters: {'period': period},
    );
    final raw = r.data ?? {};
    final data = raw['data'] ?? raw;
    if (data is List) return List<Map<String, dynamic>>.from(data);
    return [];
  }

  // ─── Top gifts ──────────────────────────────────────────────────────

  /// Retorna lista de { gift_name, gift_slug, count, total_usdt }
  Future<List<Map<String, dynamic>>> getTopGifts({int limit = 10}) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/analytics/top-gifts',
      queryParameters: {'limit': limit},
    );
    final raw = r.data ?? {};
    final data = raw['data'] ?? raw;
    if (data is List) return List<Map<String, dynamic>>.from(data);
    return [];
  }

  // ─── Live history ───────────────────────────────────────────────────

  /// Histórico paginado de lives com métricas.
  /// Retorna { items, total } onde cada item tem:
  ///   id, title, category, viewer_count, peak_viewers,
  ///   gifts_value, products_sold, duration_minutes, started_at
  ///
  /// O playback_url (Mux HLS) fica em /profile/:userId/lives
  /// para streaming de replay (disponível por 30 dias).
  Future<({List<Map<String, dynamic>> items, int total})> getLiveHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/analytics/live-history',
      queryParameters: {'page': page, 'limit': limit},
    );
    final raw = r.data ?? {};
    final list = raw['data'] ?? raw['items'] ?? [];
    final total = (raw['total'] as num?)?.toInt() ?? 0;
    final items = list is List
        ? list.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    return (items: items, total: total);
  }

  // ─── Social stats (via /social/stats) ───────────────────────────────

  /// followers_count, following_count, total_lives, total_viewers
  Future<Map<String, dynamic>> getSocialStats(String userId) async {
    final r = await _dio.get<Map<String, dynamic>>('/social/stats/$userId');
    return (r.data?['data'] as Map<String, dynamic>?) ?? {};
  }

  // ─── Profile lives (com playback_url Mux) ───────────────────────────

  /// Lives do usuário com playback_url para replay.
  /// Mux retém os vídeos por 30 dias após o término.
  Future<List<Map<String, dynamic>>> getProfileLives(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/profile/$userId/lives',
      queryParameters: {'page': page, 'limit': limit},
    );
    final raw = r.data ?? {};
    final list = raw['data'] ?? raw['items'] ?? raw;
    if (list is List) return List<Map<String, dynamic>>.from(list);
    return [];
  }

  // ─── Helpers ────────────────────────────────────────────────────────

  static dynamic _unwrap(Map<String, dynamic> raw) {
    if (raw.containsKey('data')) return raw['data'];
    return raw;
  }

  static List<Map<String, dynamic>> _toList(dynamic data) {
    if (data is List) return List<Map<String, dynamic>>.from(data);
    return [];
  }
}
