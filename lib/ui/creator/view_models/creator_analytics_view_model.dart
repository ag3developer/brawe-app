import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/analytics_service.dart';

part 'creator_analytics_view_model.g.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

/// KPIs principais do Creator Dashboard.
class CreatorDashboardKpis {
  final int totalLives;
  final int totalViewers;
  final int totalFollowers;
  final double totalEarnings;
  final int totalGiftsReceived;
  final int totalProductsSold;
  final double avgViewersPerLive;
  final double avgDurationMinutes;

  const CreatorDashboardKpis({
    this.totalLives = 0,
    this.totalViewers = 0,
    this.totalFollowers = 0,
    this.totalEarnings = 0,
    this.totalGiftsReceived = 0,
    this.totalProductsSold = 0,
    this.avgViewersPerLive = 0,
    this.avgDurationMinutes = 0,
  });

  factory CreatorDashboardKpis.fromJson(Map<String, dynamic> j) =>
      CreatorDashboardKpis(
        totalLives: (j['total_lives'] as num?)?.toInt() ?? 0,
        totalViewers: (j['total_viewers'] as num?)?.toInt() ?? 0,
        totalFollowers: (j['total_followers'] as num?)?.toInt() ?? 0,
        totalEarnings: (j['total_earnings'] as num?)?.toDouble() ?? 0.0,
        totalGiftsReceived: (j['total_gifts_received'] as num?)?.toInt() ?? 0,
        totalProductsSold: (j['total_products_sold'] as num?)?.toInt() ?? 0,
        avgViewersPerLive: (j['avg_viewers_per_live'] as num?)?.toDouble() ?? 0,
        avgDurationMinutes:
            (j['avg_duration_minutes'] as num?)?.toDouble() ?? 0,
      );
}

/// Ponto de dados de série temporal (viewers ou earnings por data).
class AnalyticsDataPoint {
  final DateTime date;
  final double value;
  final double? secondaryValue; // peak_viewers ou platform_fee

  const AnalyticsDataPoint({
    required this.date,
    required this.value,
    this.secondaryValue,
  });

  factory AnalyticsDataPoint.fromViewers(Map<String, dynamic> j) =>
      AnalyticsDataPoint(
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        value: (j['viewers'] as num?)?.toDouble() ?? 0,
        secondaryValue: (j['peak_viewers'] as num?)?.toDouble(),
      );

  factory AnalyticsDataPoint.fromEarnings(Map<String, dynamic> j) =>
      AnalyticsDataPoint(
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        value: (j['earnings'] as num?)?.toDouble() ?? 0,
        secondaryValue: (j['platform_fee'] as num?)?.toDouble(),
      );
}

/// Registro de uma live no histórico.
class LiveHistoryItem {
  final String id;
  final String title;
  final String? category;
  final int viewerCount;
  final int peakViewers;
  final double giftsValue;
  final int productsSold;
  final double durationMinutes;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? playbackUrl; // Mux HLS do merge analytics+profile
  final String? recordingUrl; // Mux HLS direto do campo recording_url
  final String? thumbnailUrl;
  final String? playbackId;

  const LiveHistoryItem({
    required this.id,
    required this.title,
    this.category,
    this.viewerCount = 0,
    this.peakViewers = 0,
    this.giftsValue = 0,
    this.productsSold = 0,
    this.durationMinutes = 0,
    this.startedAt,
    this.endedAt,
    this.playbackUrl,
    this.recordingUrl,
    this.thumbnailUrl,
    this.playbackId,
  });

  /// URL de replay disponível — prefere recordingUrl (vem direto do DB/Mux)
  String? get replayUrl => recordingUrl ?? playbackUrl;

  bool get hasReplay => replayUrl != null && replayUrl!.isNotEmpty;

  /// Replay disponível por 30 dias após o início.
  bool get isReplayAvailable {
    if (startedAt == null) return hasReplay;
    return DateTime.now().difference(startedAt!).inDays < 30;
  }

  /// A live pode ter replay (mesmo que ainda não tenha sido processado pelo Mux).
  bool get replayMayBePending {
    if (startedAt == null) return false;
    final age = DateTime.now().difference(startedAt!);
    // Mux processa VOD em ~2–5 min após o término da live
    return !hasReplay && age.inDays < 30;
  }

  factory LiveHistoryItem.fromJson(Map<String, dynamic> j) => LiveHistoryItem(
    id: (j['id'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    category: j['category']?.toString(),
    viewerCount: (j['viewer_count'] as num?)?.toInt() ?? 0,
    peakViewers: (j['peak_viewers'] as num?)?.toInt() ?? 0,
    giftsValue:
        (j['gifts_value'] as num?)?.toDouble() ??
        (j['total_gifts_value'] as num?)?.toDouble() ??
        0,
    productsSold: (j['products_sold'] as num?)?.toInt() ?? 0,
    durationMinutes:
        (j['duration_minutes'] as num?)?.toDouble() ??
        ((j['duration_seconds'] as num?)?.toDouble() ?? 0) / 60,
    startedAt: DateTime.tryParse(j['started_at']?.toString() ?? ''),
    endedAt: DateTime.tryParse(j['ended_at']?.toString() ?? ''),
    playbackUrl: j['playback_url']?.toString(),
    recordingUrl: j['recording_url']?.toString(),
    thumbnailUrl: j['thumbnail_url']?.toString(),
    playbackId: j['playback_id']?.toString(),
  );
}

// ─── Providers ────────────────────────────────────────────────────────────────

/// KPIs do Dashboard — carregados uma vez ao abrir a tela.
@riverpod
Future<CreatorDashboardKpis> creatorDashboardKpis(Ref ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final data = await service.getDashboard();
  return CreatorDashboardKpis.fromJson(data);
}

/// Seguidores totais via social stats (para o card de Crescimento).
@riverpod
Future<Map<String, dynamic>> creatorSocialStats(Ref ref) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.id ?? '';
  if (userId.isEmpty) return {};
  final service = ref.watch(analyticsServiceProvider);
  return service.getSocialStats(userId);
}

/// Série histórica de viewers por período.
@riverpod
Future<List<AnalyticsDataPoint>> viewersHistory(Ref ref, String period) async {
  final service = ref.watch(analyticsServiceProvider);
  final raw = await service.getViewersHistory(period: period);
  return raw.map(AnalyticsDataPoint.fromViewers).toList();
}

/// Histórico de lives paginado.
@riverpod
Future<({List<LiveHistoryItem> items, int total})> liveHistoryPage(
  Ref ref,
  int page,
) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.id ?? '';
  final service = ref.watch(analyticsServiceProvider);

  // Busca simultânea: analytics (métricas) + profile (playback_url Mux)
  final results = await Future.wait([
    service.getLiveHistory(page: page, limit: 20),
    if (userId.isNotEmpty)
      service.getProfileLives(userId, page: page, limit: 20)
    else
      Future.value(<Map<String, dynamic>>[]),
  ]);

  final analytics =
      results[0] as ({List<Map<String, dynamic>> items, int total});
  final profileLives = results[1] as List<Map<String, dynamic>>;

  // Merge: associar playback_url do profile à live analytics por ID
  final playbackByRoomId = <String, String>{};
  for (final l in profileLives) {
    final id = (l['id'] ?? l['room_id'] ?? '').toString();
    final url = l['playback_url']?.toString() ?? '';
    if (id.isNotEmpty && url.isNotEmpty) {
      playbackByRoomId[id] = url;
    }
  }

  final items = analytics.items.map((j) {
    final id = (j['id'] ?? '').toString();
    final enriched = Map<String, dynamic>.from(j);
    if (playbackByRoomId.containsKey(id)) {
      enriched['playback_url'] = playbackByRoomId[id];
    }
    return LiveHistoryItem.fromJson(enriched);
  }).toList();

  return (items: items, total: analytics.total);
}

/// Período selecionado para os gráficos (estado local da UI).
@riverpod
class AnalyticsPeriod extends _$AnalyticsPeriod {
  @override
  String build() => '30d';

  void set(String period) => state = period;
}

/// Histórico de ganhos por período (para Reach/Monetização).
@riverpod
Future<List<AnalyticsDataPoint>> earningsHistory(Ref ref, String period) async {
  final service = ref.watch(analyticsServiceProvider);
  final raw = await service.getEarnings(period: period);
  return raw.map(AnalyticsDataPoint.fromEarnings).toList();
}

/// Top gifts recebidos.
@riverpod
Future<List<Map<String, dynamic>>> topGifts(Ref ref, {int limit = 10}) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getTopGifts(limit: limit);
}
