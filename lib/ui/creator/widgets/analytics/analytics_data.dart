import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/services/analytics_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dados das telas de análise: séries diárias normalizadas (sem buracos),
// com o período anterior alinhado por posição, e os totais devolvidos pelo
// backend (`summary`). Os providers abaixo não usam geração de código.
// ─────────────────────────────────────────────────────────────────────────────

int analyticsPeriodDays(String period) => switch (period) {
  '7d' => 7,
  '90d' => 90,
  '365d' => 365,
  _ => 30,
};

/// Um ponto do gráfico. [date] é o início do balde (dia, ou semana em 1A).
class SeriesPoint {
  final DateTime date;
  final double value;
  final double? second;
  const SeriesPoint(this.date, this.value, [this.second]);
}

/// Série pronta para o gráfico: período atual + anterior (mesmo tamanho).
class AnalyticsSeries {
  final List<SeriesPoint> current;
  final List<SeriesPoint> previous;

  /// Período anterior da métrica secundária (`second`), quando existir.
  final List<SeriesPoint>? previousSecond;
  final Map<String, dynamic> summary;
  final String period;
  const AnalyticsSeries({
    required this.current,
    required this.previous,
    this.previousSecond,
    required this.summary,
    required this.period,
  });

  bool get isEmpty => current.every((p) => p.value == 0 && (p.second ?? 0) == 0);

  /// Sem nenhum valor > 0 na métrica exibida (principal ou secundária).
  bool emptyFor({bool second = false}) =>
      current.every((p) => (second ? (p.second ?? 0) : p.value) == 0);

  double val(String key) => (summary[key] as num?)?.toDouble() ?? 0;

  /// Variação % do backend (null quando não há base de comparação).
  double? pct(String key) => (summary[key] as num?)?.toDouble();
}

DateTime _day(String s) {
  final d = DateTime.tryParse(s) ?? DateTime.now();
  return DateTime(d.year, d.month, d.day);
}

/// Monta a série diária completa (preenche dias sem dados com 0) e agrupa em
/// semanas no período de 1 ano. [cumulative] = o valor é um acumulado (usa o
/// último valor do balde em vez da soma e repete o último valor nos buracos).
AnalyticsSeries buildSeries({
  required Map<String, dynamic> body,
  required String period,
  required String valueKey,
  String? secondKey,
  bool cumulative = false,
  bool secondIsMax = false,
  String? previousValueKey,
}) {
  final days = analyticsPeriodDays(period);
  final today = DateTime.now();
  final end = DateTime(today.year, today.month, today.day);
  final start = end.subtract(Duration(days: days - 1));

  List<Map<String, dynamic>> rows(String k) {
    final v = body[k];
    return v is List ? v.whereType<Map<String, dynamic>>().toList() : [];
  }

  List<double> daily(
    List<Map<String, dynamic>> src,
    DateTime from,
    String key, {
    bool carry = false,
    bool useMax = false,
  }) {
    final out = List<double>.filled(days, 0);
    final seen = List<bool>.filled(days, false);
    for (final r in src) {
      final i = _day(r['date'].toString()).difference(from).inDays;
      if (i < 0 || i >= days) continue;
      final v = (r[key] as num?)?.toDouble() ?? 0;
      out[i] = useMax ? (v > out[i] ? v : out[i]) : out[i] + v;
      if (!useMax) {
        // para acumulado queremos o valor do dia, não a soma
        if (carry) out[i] = v;
      }
      seen[i] = true;
    }
    if (carry) {
      double last = 0;
      // valor inicial: total do início do período, se o backend informou
      final startTotal = (body['summary'] is Map)
          ? ((body['summary'] as Map)['start_total'] as num?)?.toDouble()
          : null;
      last = startTotal ?? 0;
      for (var i = 0; i < days; i++) {
        if (seen[i]) {
          last = out[i];
        } else {
          out[i] = last;
        }
      }
    }
    return out;
  }

  final cur = daily(rows('data'), start, valueKey, carry: cumulative);
  final prevStart = start.subtract(Duration(days: days));
  final prev = daily(
    rows('previous'),
    prevStart,
    previousValueKey ?? valueKey,
    carry: false,
  );
  final sec = secondKey == null
      ? null
      : daily(rows('data'), start, secondKey, useMax: secondIsMax);

  final prevSec = secondKey == null
      ? null
      : daily(rows('previous'), prevStart, secondKey, useMax: secondIsMax);

  // 1A: baldes semanais para o gráfico não ficar com 365 pontos.
  final bucket = days > 100 ? 7 : 1;
  final n = (days / bucket).ceil();
  double agg(List<double> l, int b, {bool last = false, bool max = false}) {
    final a = b * bucket;
    final z = (a + bucket) > l.length ? l.length : a + bucket;
    final slice = l.sublist(a, z);
    if (last) return slice.last;
    if (max) return slice.reduce((x, y) => x > y ? x : y);
    return slice.fold(0.0, (s, e) => s + e);
  }

  final current = <SeriesPoint>[];
  final previous = <SeriesPoint>[];
  final previousSecond = <SeriesPoint>[];
  for (var b = 0; b < n; b++) {
    final d = start.add(Duration(days: b * bucket));
    current.add(
      SeriesPoint(
        d,
        agg(cur, b, last: cumulative),
        sec == null ? null : agg(sec, b, max: secondIsMax),
      ),
    );
    previous.add(SeriesPoint(d, agg(prev, b)));
    if (prevSec != null) {
      previousSecond.add(SeriesPoint(d, agg(prevSec, b, max: secondIsMax)));
    }
  }

  return AnalyticsSeries(
    current: current,
    previous: previous,
    previousSecond: prevSec == null ? null : previousSecond,
    summary: (body['summary'] as Map?)?.cast<String, dynamic>() ?? const {},
    period: period,
  );
}

final earningsSeriesProvider =
    FutureProvider.family<AnalyticsSeries, String>((ref, period) async {
      final body = await ref
          .watch(analyticsServiceProvider)
          .getSeries('earnings', period: period);
      return buildSeries(
        body: body,
        period: period,
        valueKey: 'earnings',
        secondKey: 'gifts_count',
      );
    });

final viewersSeriesProvider =
    FutureProvider.family<AnalyticsSeries, String>((ref, period) async {
      final body = await ref
          .watch(analyticsServiceProvider)
          .getSeries('viewers', period: period);
      return buildSeries(
        body: body,
        period: period,
        valueKey: 'viewers',
        secondKey: 'peak_viewers',
        secondIsMax: true,
      );
    });

/// Seguidores: `current` = acumulado; `second` = novos por dia.
final followersSeriesProvider =
    FutureProvider.family<AnalyticsSeries, String>((ref, period) async {
      final body = await ref
          .watch(analyticsServiceProvider)
          .getSeries('followers', period: period);
      final total = buildSeries(
        body: body,
        period: period,
        valueKey: 'total',
        cumulative: true,
      );
      final news = buildSeries(
        body: body,
        period: period,
        valueKey: 'new_followers',
        previousValueKey: 'new_followers',
      );
      return AnalyticsSeries(
        current: [
          for (var i = 0; i < total.current.length; i++)
            SeriesPoint(
              total.current[i].date,
              total.current[i].value,
              news.current[i].value,
            ),
        ],
        previous: news.previous,
        previousSecond: news.previous,
        summary: total.summary,
        period: period,
      );
    });

/// Lives: `current` = lives por dia; `second` = minutos por dia.
final livesSeriesProvider =
    FutureProvider.family<AnalyticsSeries, String>((ref, period) async {
      final body = await ref
          .watch(analyticsServiceProvider)
          .getSeries('lives-series', period: period);
      return buildSeries(
        body: body,
        period: period,
        valueKey: 'lives',
        secondKey: 'minutes',
      );
    });

/// Top presentes do período selecionado.
final topGiftsByPeriodProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, period) {
      return ref
          .watch(analyticsServiceProvider)
          .getTopGiftsByPeriod(period: period, limit: 10);
    });
