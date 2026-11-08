// Brawe Ads — acesso à API de anúncios do Connect (/api/v1/ads/*) e envio de eventos em lote.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/device_identity.dart';
import '../../core/network/live_dio_provider.dart';
import '../../domain/models/ad_models.dart';

final adsRepositoryProvider = Provider<AdsRepository>((ref) {
  final repo = AdsRepository(ref.watch(liveDioProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

/// Erro da API de anúncios já com a mensagem em português vinda do servidor.
/// Conteúdos meus com impulsionamento aberto ("post:ID"), feitos no app ou no site.
/// O foguete do post fica azul e o fluxo mostra a campanha em vez de criar outra.
final openBoostsProvider = FutureProvider<Set<String>>((ref) async {
  final list = await ref.read(adsRepositoryProvider).campaigns();
  return {
    for (final c in list)
      if (c.kind == 'boost' && c.isOpen && c.contentId != null)
        '${c.contentType}:${c.contentId}',
  };
});

class AdsFailure implements Exception {
  const AdsFailure(this.message, {this.code, this.field});
  final String message;
  final String? code;
  final String? field;
  @override
  String toString() => message;
}

class AdsRepository {
  AdsRepository(this._dio);
  final Dio _dio;

  String get platform => Platform.isIOS ? 'ios' : 'android';

  Future<Options> _viewer() async => Options(
    headers: {
      'X-Ad-Viewer': (await DeviceIdentity.instance.deviceId()).replaceAll(
        RegExp(r'[^A-Za-z0-9_-]'),
        '',
      ),
    },
  );

  AdsFailure _fail(Object e) {
    if (e is DioException) {
      final d = e.response?.data;
      final det = d is Map ? d['detail'] : null;
      if (det is Map && det['message'] != null) {
        return AdsFailure(
          det['message'].toString(),
          code: det['code']?.toString(),
          field: det['field']?.toString(),
        );
      }
      if (det is String) return AdsFailure(det);
    }
    return const AdsFailure('');
  }

  Future<T> _run<T>(Future<T> Function() f) async {
    try {
      return await f();
    } catch (e) {
      throw _fail(e);
    }
  }

  Map<String, dynamic> _map(dynamic d) =>
      d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};

  // ── entrega ───────────────────────────────────────────────────────────

  /// Anúncios para um espaço. Nunca lança: sem anúncio, o feed segue normal.
  Future<AdServeResult> serve(
    String placement, {
    int count = 1,
    List<String> exclude = const [],
    String? hostCreatorId,
  }) async {
    try {
      final r = await _dio.get(
        '/ads/serve',
        queryParameters: {
          'placement': placement,
          'platform': platform,
          'count': count.clamp(1, 5),
          if (exclude.isNotEmpty) 'exclude': exclude.take(40).join(','),
          'host_creator_id': ?hostCreatorId,
        },
        options: await _viewer(),
      );
      final m = _map(r.data);
      final items = (m['items'] as List? ?? const [])
          .map((e) => FeedAd.fromJson(_map(e)))
          .where((a) => a.token.isNotEmpty)
          .toList();
      return AdServeResult(items, (m['every'] as num?)?.toInt() ?? 7);
    } catch (_) {
      return const AdServeResult([], 7);
    }
  }

  // eventos em lote: 1 envio a cada 2 s (clique/contato/ocultar/denunciar vão na hora)
  final List<Map<String, dynamic>> _queue = [];
  Timer? _timer;

  void track(
    String token,
    String event, {
    int? valueMs,
    String? scope,
    String? reason,
  }) {
    _queue.add({
      'token': token,
      'event': event,
      'value_ms': ?valueMs,
      'scope': ?scope,
      'reason': ?reason,
    });
    const now = {'click', 'contact_whatsapp', 'contact_dm', 'hide', 'report'};
    if (now.contains(event)) {
      flush();
    } else {
      _timer ??= Timer(const Duration(seconds: 2), flush);
    }
  }

  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    if (_queue.isEmpty) return;
    final batch = _queue.take(50).toList();
    _queue.removeRange(0, batch.length);
    try {
      await _dio.post(
        '/ads/events',
        data: {'events': batch},
        options: await _viewer(),
      );
    } catch (_) {
      // evento perdido não atrapalha o feed
    }
    if (_queue.isNotEmpty) {
      _timer = Timer(const Duration(milliseconds: 500), flush);
    }
  }

  void dispose() {
    _timer?.cancel();
    flush();
  }

  Future<List<String>> why(String token) => _run(() async {
    final r = await _dio.get(
      '/ads/why',
      queryParameters: {'token': token},
      options: await _viewer(),
    );
    return ((_map(r.data)['reasons'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList();
  });

  // ── impulsionar ──────────────────────────────────────────────────────

  AdsPublicConfig? _config;
  Future<AdsPublicConfig> config() async {
    if (_config != null) return _config!;
    return _run(
      () async => _config = AdsPublicConfig.fromJson(
        _map((await _dio.get('/ads/config')).data),
      ),
    );
  }

  Future<AdWhereAmI> whereAmI({double? lat, double? lng}) => _run(() async {
    final r = _map(
      (await _dio.get(
        '/ads/whereami',
        queryParameters: {'lat': ?lat, 'lng': ?lng},
      )).data,
    );
    final c = r['city'] is Map ? AdCity.fromJson(_map(r['city'])) : null;
    return AdWhereAmI(
      lat: (r['lat'] as num?)?.toDouble(),
      lng: (r['lng'] as num?)?.toDouble(),
      city: c,
      exact: r['source'] == 'gps',
    );
  });

  Future<List<AdCity>> searchCities(String q) async {
    if (q.trim().length < 2) return const [];
    return _run(() async {
      final r = _map(
        (await _dio.get(
          '/ads/locations',
          queryParameters: {'q': q.trim()},
        )).data,
      );
      return ((r['cities'] as List?) ?? const [])
          .map((e) => AdCity.fromJson(_map(e)))
          .toList();
    });
  }

  Future<AdEstimate?> estimate(Map<String, dynamic> body) async {
    try {
      final r = _map(
        (await _dio.post('/ads/audience-estimate', data: body)).data,
      );
      final buys = r['daily_budget_buys'] is Map
          ? _map(r['daily_budget_buys'])['label']?.toString()
          : null;
      return AdEstimate(
        display: r['display']?.toString() ?? '',
        buysLabel: buys,
      );
    } catch (_) {
      return null;
    }
  }

  Future<({int coins, double coinBrl})> quote(double totalBrl) =>
      _run(() async {
        final r = _map(
          (await _dio.post('/ads/quote', data: {'total_brl': totalBrl})).data,
        );
        return (
          coins: (r['coins'] as num).toInt(),
          coinBrl: (r['coin_brl'] as num).toDouble(),
        );
      });

  /// Cria o rascunho e já envia (paga em Coins). Devolve a campanha.
  Future<AdCampaign> createAndSubmit(Map<String, dynamic> body) =>
      _run(() async {
        final created = AdCampaign.fromJson(
          _map((await _dio.post('/ads/campaigns', data: body)).data),
        );
        try {
          return AdCampaign.fromJson(
            _map((await _dio.post('/ads/campaigns/${created.id}/submit')).data),
          );
        } catch (e) {
          // pagamento falhou: o rascunho não fica perdido na lista
          try {
            await _dio.delete('/ads/campaigns/${created.id}');
          } catch (_) {}
          rethrow;
        }
      });

  // ── meus anúncios ────────────────────────────────────────────────────

  Future<List<AdCampaign>> campaigns({String status = ''}) => _run(() async {
    final r = _map(
      (await _dio.get(
        '/ads/campaigns',
        queryParameters: {
          'page_size': 50,
          if (status.isNotEmpty) 'status': status,
        },
      )).data,
    );
    return ((r['items'] as List?) ?? const [])
        .map((e) => AdCampaign.fromJson(_map(e)))
        .toList();
  });

  Future<AdCampaign> campaign(String id) => _run(
    () async =>
        AdCampaign.fromJson(_map((await _dio.get('/ads/campaigns/$id')).data)),
  );

  Future<AdReportSummary> report(String id) => _run(
    () async => AdReportSummary.fromJson(
      _map((await _dio.get('/ads/campaigns/$id/report')).data),
    ),
  );

  /// Relatório completo (gráfico, público, horários, onde apareceu, Coins) — o app monta a tela com ele.
  Future<Map<String, dynamic>> reportFull(String id) => _run(
    () async => _map((await _dio.get('/ads/campaigns/$id/report')).data),
  );

  Future<AdCampaign> action(String id, String action) => _run(
    () async => AdCampaign.fromJson(
      _map((await _dio.post('/ads/campaigns/$id/$action')).data),
    ),
  );

  Future<({int daysLeft, double extra, int coins})> dailyQuote(
    String id,
    double daily,
  ) => _run(() async {
    final r = _map(
      (await _dio.get(
        '/ads/campaigns/$id/daily-quote',
        queryParameters: {'daily_budget_brl': daily.toStringAsFixed(2)},
      )).data,
    );
    return (
      daysLeft: (r['days_left'] as num).toInt(),
      extra: (r['extra_brl'] as num).toDouble(),
      coins: (r['coins'] as num).toInt(),
    );
  });

  Future<AdCampaign> increaseDaily(String id, double daily) => _run(
    () async => AdCampaign.fromJson(
      _map(
        (await _dio.post(
          '/ads/campaigns/$id/daily',
          data: {'daily_budget_brl': daily.toStringAsFixed(2)},
        )).data,
      ),
    ),
  );

  Future<AdCampaign> updateTargeting(
    String id,
    Map<String, dynamic> targeting,
  ) => _run(
    () async => AdCampaign.fromJson(
      _map(
        (await _dio.patch(
          '/ads/campaigns/$id/targeting',
          data: {'targeting': targeting},
        )).data,
      ),
    ),
  );

  Future<double> coinBalance() async {
    try {
      final r = _map(
        (await _dio.get('/ads/wallet', queryParameters: {'page_size': 1})).data,
      );
      return ((_map(r['summary'])['coins']) as num?)?.toDouble() ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
