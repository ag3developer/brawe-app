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

  // ─── Séries completas (data + previous + summary) ──────────────────

  /// Devolve o corpo inteiro de uma rota de série temporal:
  /// `{ data: [...], previous: [...], summary: {...} }`.
  /// [path]: "earnings" | "viewers" | "followers" | "lives-series"
  Future<Map<String, dynamic>> getSeries(
    String path, {
    String period = '30d',
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/analytics/$path',
      queryParameters: {'period': period},
    );
    return r.data ?? {};
  }

  /// Top gifts de um período (null = todo o histórico).
  /// Cada item: gift_name, gift_slug, gift_tier, icon_url, count, quantity,
  /// total_usdt, earnings_usdt, share_pct.
  Future<List<Map<String, dynamic>>> getTopGiftsByPeriod({
    String? period,
    int limit = 10,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/analytics/top-gifts',
      queryParameters: {'limit': limit, 'period': ?period},
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

  // ─── Replay on-demand ───────────────────────────────────────────────

  /// Busca a URL HLS de replay de uma live pelo room_id.
  ///
  /// Retorna:
  ///   { success, data: { recording_url, thumbnail_url, duration_seconds } }
  ///   ou { success: false, error: "replay_expired" | "replay_not_available" }
  Future<Map<String, dynamic>> getLiveReplay(String roomId) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/analytics/live-history/$roomId/replay',
    );
    return r.data ?? {};
  }

  // ─── Download MP4 ───────────────────────────────────────────────────

  /// Retorna URL de download MP4 de uma live gravada.
  ///
  /// [quality]: "high" (1080p) | "medium" (720p) | "low" (480p)
  ///
  /// Retorna:
  ///   { success, data: { download_url, filename, resolution } }
  Future<Map<String, dynamic>> getLiveDownload(
    String roomId, {
    String quality = 'high',
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/analytics/live-history/$roomId/download',
      queryParameters: {'quality': quality},
      // 202 = MP4 ainda sendo preparado pelo Mux. Não é erro de rede;
      // deixamos passar para tratar como "processando" no chamador.
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    // Propaga o status para o chamador diferenciar 202 (processando)
    // de 200 (pronto) e 4xx (indisponível).
    final data = r.data ?? <String, dynamic>{};
    return {...data, '_statusCode': r.statusCode};
  }

  /// Baixa o MP4 da live diretamente para [savePath], reportando o
  /// progresso via [onProgress] (0.0 → 1.0).
  ///
  /// Fluxo:
  ///   1. Resolve a `download_url` via [getLiveDownload].
  ///   2. Faz o streaming do arquivo com `dio.download` (chunked),
  ///      emitindo o percentual recebido enquanto baixa.
  ///
  /// A URL retornada pelo backend aponta para um MP4 remoto (Mux) já
  /// legível pela maioria dos players — a conversão para um formato
  /// 100% compatível com o dispositivo é feita depois, na etapa de
  /// edição/recorte nativa (video_trimmer).
  ///
  /// Retorna `{ filename, resolution, url }` em caso de sucesso.
  /// Lança [Exception] se a URL não estiver disponível.
  Future<Map<String, dynamic>> downloadLiveFile(
    String roomId, {
    String quality = 'high',
    required String savePath,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final meta = await getLiveDownload(roomId, quality: quality);
    final statusCode = meta['_statusCode'] as int?;

    // 202 → o MP4 ainda está sendo gerado pelo Mux (a solicitação de
    // geração já foi disparada no backend). Sinaliza "processando".
    if (statusCode == 202) {
      throw Exception('download_processing');
    }

    final success = meta['success'] == true;
    final data = meta['data'] as Map<String, dynamic>?;
    final url = data?['download_url']?.toString() ?? '';

    if (!success || url.isEmpty) {
      throw Exception('download_unavailable');
    }

    // Baixa a URL externa (Mux) com uma instância Dio LIMPA — sem os
    // interceptors da API interna, que injetavam o header Authorization
    // Bearer (indevido para um CDN externo) em todas as requisições.
    final plainDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
        followRedirects: true,
      ),
    );

    try {
      await plainDio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );
    } finally {
      plainDio.close();
    }

    return {
      'filename': data?['filename']?.toString() ?? 'live_$roomId.mp4',
      'resolution': data?['resolution']?.toString() ?? quality,
      'url': url,
    };
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
