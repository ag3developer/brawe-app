// Brawe Ads — relatório completo da campanha no app (tudo o que GET /ads/campaigns/{id}/report entrega):
// números principais, gráfico por dia, vídeo, quem viu (idade, cidades, estados, regiões, interesses),
// melhores horários, onde apareceu, aparelhos, live e Coins (pagas, usadas, devolvidas, alterações).
// Grupos pequenos já chegam somados em "outros" (o servidor protege a privacidade de quem viu).

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../creator/widgets/analytics/analytics_charts.dart';
import '../../creator/widgets/analytics/analytics_format.dart';

// ── dados ───────────────────────────────────────────────────────────────

Map<String, dynamic> _m(dynamic v) =>
    v is Map ? v.cast<String, dynamic>() : const {};
List<Map<String, dynamic>> _l(dynamic v) =>
    v is List ? v.map(_m).toList() : const [];
int _i(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

class AdDay {
  const AdDay(
    this.day,
    this.impressions,
    this.reach,
    this.clicks,
    this.views,
    this.spend,
  );
  final DateTime day;
  final int impressions, reach, clicks, views;
  final double spend;
}

class AdBreakdown {
  const AdBreakdown(this.key, this.impressions, this.clicks, this.spend);
  final String key;
  final int impressions, clicks;
  final double spend;
}

class AdBudgetChange {
  const AdBudgetChange(this.kind, this.before, this.after, this.coins, this.at);
  final String kind;
  final double? before, after;
  final int coins;
  final DateTime? at;
}

class AdFullReport {
  AdFullReport.fromJson(Map<String, dynamic> j)
    : impressions = _i(_m(j['metrics'])['impressions']),
      reach = _i(_m(j['metrics'])['reach']),
      frequency = _d(_m(j['metrics'])['frequency']),
      clicks = _i(_m(j['metrics'])['clicks']),
      contacts = _i(_m(j['metrics'])['contacts']),
      objective = '${_m(j['campaign'])['objective'] ?? ''}',
      ctr = _d(_m(j['metrics'])['ctr_pct']),
      spend = _d(_m(j['metrics'])['spend_brl']),
      cpm = _d(_m(j['metrics'])['cpm_brl']),
      newFollowers = _i(_m(_m(j['metrics'])['engagement'])['new_followers']),
      profileVisits = _i(_m(_m(j['metrics'])['engagement'])['profile_visits']),
      view25 = _i(_m(_m(j['metrics'])['video'])['view_25']),
      view50 = _i(_m(_m(j['metrics'])['video'])['view_50']),
      view100 = _i(_m(_m(j['metrics'])['video'])['view_100']),
      avgWatch = _d(_m(_m(j['metrics'])['video'])['avg_watch_seconds']),
      from = DateTime.tryParse('${_m(j['period'])['from']}'),
      to = DateTime.tryParse('${_m(j['period'])['to']}'),
      byDay = [
        for (final x in _l(j['by_day']))
          if (DateTime.tryParse('${x['day']}') != null)
            AdDay(
              DateTime.parse('${x['day']}'),
              _i(x['impressions']),
              _i(x['reach']),
              _i(x['clicks']),
              _i(x['views']),
              _d(x['spend_brl']),
            ),
      ],
      byPlacement = [
        for (final x in _l(j['by_placement']))
          AdBreakdown(
            '${x['placement']}',
            _i(x['impressions']),
            _i(x['clicks']),
            _d(x['spend_brl']),
          ),
      ],
      byPlatform = [
        for (final x in _l(j['by_platform']))
          AdBreakdown(
            '${x['platform']}',
            _i(x['impressions']),
            _i(x['clicks']),
            _d(x['spend_brl']),
          ),
      ],
      byHour = {
        for (final x in _l(j['by_hour'])) _i(x['hour']): _i(x['impressions']),
      },
      age = _counts(_m(j['audience'])['age']),
      cities = _counts(_m(j['audience'])['city']),
      states = _counts(_m(j['audience'])['state']),
      regions = _counts(_m(j['audience'])['region']),
      interests = _counts(_m(j['audience'])['interests']),
      loggedOut = _i(_m(j['audience'])['logged_out_viewers']),
      coinsPaid = _i(_m(_m(j['budget'])['coins'])['paid']),
      coinsUsed = _i(_m(_m(j['budget'])['coins'])['used']),
      coinsRefunded = _i(_m(_m(j['budget'])['coins'])['refunded']),
      changes = [
        for (final x in _l(_m(j['budget'])['changes']))
          AdBudgetChange(
            '${x['kind']}',
            x['before'] == null ? null : _d(x['before']),
            x['after'] == null ? null : _d(x['after']),
            _i(x['coins']),
            DateTime.tryParse('${x['at']}'),
          ),
      ],
      live = j['live'] is Map ? _m(j['live']) : null;

  final String objective;
  final int contacts;
  final int impressions,
      reach,
      clicks,
      newFollowers,
      profileVisits,
      view25,
      view50,
      view100,
      loggedOut;
  final double frequency, ctr, spend, cpm, avgWatch;
  final DateTime? from, to;
  final List<AdDay> byDay;
  final List<AdBreakdown> byPlacement, byPlatform;
  final Map<int, int> byHour;
  final List<MapEntry<String, int>> age, cities, states, regions, interests;
  final int coinsPaid, coinsUsed, coinsRefunded;
  final List<AdBudgetChange> changes;
  final Map<String, dynamic>? live;

  /// Lista ordenada (maior primeiro), com "outros" sempre no fim.
  static List<MapEntry<String, int>> _counts(dynamic v) {
    final e = _m(v).entries
        .map((x) => MapEntry(x.key, _i(x.value)))
        .where((x) => x.value > 0)
        .toList();
    e.sort(
      (a, b) => a.key == 'outros'
          ? 1
          : (b.key == 'outros' ? -1 : b.value.compareTo(a.value)),
    );
    return e;
  }

  /// Dias do período inteiro (os sem exibição entram com zero, para o gráfico não "pular" dias).
  List<AdDay> get days {
    if (byDay.isEmpty) return const [];
    final start = from ?? byDay.first.day;
    final today = DateTime.now();
    var end = to ?? byDay.last.day;
    final todayDate = DateTime(today.year, today.month, today.day);
    if (end.isAfter(todayDate)) end = todayDate;
    if (end.isBefore(byDay.last.day)) end = byDay.last.day;
    final map = {
      for (final d in byDay) DateTime(d.day.year, d.day.month, d.day.day): d,
    };
    final out = <AdDay>[];
    for (
      var d = DateTime(start.year, start.month, start.day);
      !d.isAfter(end);
      d = DateTime(d.year, d.month, d.day + 1)
    ) {
      out.add(map[d] ?? AdDay(d, 0, 0, 0, 0, 0));
      if (out.length > 120) break;
    }
    return out;
  }
}

// ── tela ────────────────────────────────────────────────────────────────

class AdReportView extends StatefulWidget {
  const AdReportView({super.key, required this.report});
  final AdFullReport report;

  @override
  State<AdReportView> createState() => _AdReportViewState();
}

class _AdReportViewState extends State<AdReportView> {
  String _metric = 'reach';
  String _audience = 'age';

  AdFullReport get r => widget.report;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final fmt = AnalyticsFmt.of(context);

    if (r.impressions == 0) {
      return _Card(
        child: Row(
          children: [
            Icon(
              LucideIcons.chartNoAxesColumn,
              size: 22,
              color: colors.textTertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s.adsRepEmpty,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── números principais
        _Grid(
          children: [
            if (r.objective == 'contacts')
              _Kpi(
                label: s.adsRepContacts,
                value: fmt.compact(r.contacts),
                strong: true,
              ),
            _Kpi(
              label: s.myAdsReach,
              value: fmt.compact(r.reach),
              hint: s.adsRepPeople,
              strong: r.objective != 'contacts',
            ),
            _Kpi(
              label: s.myAdsImpressions,
              value: fmt.compact(r.impressions),
              hint:
                  '${s.adsRepFrequency} ${NumberFormat('0.0#', fmt.locale).format(r.frequency)}',
            ),
            _Kpi(
              label: s.myAdsClicks,
              value: fmt.compact(r.clicks),
              hint: '${s.adsRepCtr} ${fmt.percent(r.ctr)}',
            ),
            _Kpi(
              label: s.myAdsSpent,
              value: fmt.money(r.spend),
              hint: '${s.adsRepCpm} ${fmt.money(r.cpm)}',
            ),
            _Kpi(
              label: s.myAdsNewFollowers,
              value: fmt.compact(r.newFollowers),
            ),
            _Kpi(
              label: s.myAdsProfileVisits,
              value: fmt.compact(r.profileVisits),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── gráfico por dia
        if (r.days.isNotEmpty)
          _Card(
            title: s.adsRepOverTime,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Pills(
                  value: _metric,
                  items: {
                    'reach': s.myAdsReach,
                    'impressions': s.myAdsImpressions,
                    'clicks': s.myAdsClicks,
                    'spend': s.myAdsSpent,
                  },
                  onChanged: (v) => setState(() => _metric = v),
                ),
                const SizedBox(height: 16),
                _dayChart(context, fmt),
              ],
            ),
          ),

        // ── vídeo
        if (r.view25 > 0) ...[
          const SizedBox(height: 14),
          _Card(
            title: s.adsRepVideo,
            trailing: r.avgWatch > 0
                ? s.adsRepAvgWatch(
                    NumberFormat('0.#', fmt.locale).format(r.avgWatch),
                  )
                : null,
            child: _Bars(
              total: r.view25,
              items: [
                MapEntry(s.adsRepWatched25, r.view25),
                MapEntry(s.adsRepWatched50, r.view50),
                MapEntry(s.adsRepWatched100, r.view100),
              ],
              fmt: fmt,
              showPct: true,
            ),
          ),
        ],

        // ── quem viu
        const SizedBox(height: 14),
        _Card(
          title: s.adsRepAudience,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Pills(
                value: _audience,
                items: {
                  'age': s.adsRepAge,
                  'city': s.adsRepCities,
                  'state': s.adsRepStates,
                  'region': s.adsRepRegions,
                  'interests': s.adsRepInterests,
                },
                onChanged: (v) => setState(() => _audience = v),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(_audience),
                  child: _audienceList(context, fmt),
                ),
              ),
              const SizedBox(height: 14),
              _Footnote(icon: LucideIcons.shieldCheck, text: s.adsRepPrivacy),
              if (r.loggedOut > 0) ...[
                const SizedBox(height: 6),
                _Footnote(
                  icon: LucideIcons.userX,
                  text: s.adsRepLoggedOut(fmt.integer(r.loggedOut)),
                ),
              ],
            ],
          ),
        ),

        // ── melhores horários
        if (r.byHour.values.any((v) => v > 0)) ...[
          const SizedBox(height: 14),
          _Card(
            title: s.adsRepHours,
            child: _Hours(byHour: r.byHour, fmt: fmt),
          ),
        ],

        // ── onde apareceu + aparelhos
        if (r.byPlacement.isNotEmpty) ...[
          const SizedBox(height: 14),
          _Card(
            title: s.adsRepWhere,
            child: _Bars(
              total: r.impressions,
              items: [
                for (final p in r.byPlacement)
                  MapEntry(_placement(s, p.key), p.impressions),
              ],
              fmt: fmt,
              showPct: true,
            ),
          ),
        ],
        if (r.byPlatform.isNotEmpty) ...[
          const SizedBox(height: 14),
          _Card(
            title: s.adsRepPlatforms,
            child: _Split(
              items: [
                for (final p in r.byPlatform)
                  MapEntry(_platform(p.key), p.impressions),
              ],
              fmt: fmt,
            ),
          ),
        ],

        // ── live impulsionada
        if (r.live != null) ...[
          const SizedBox(height: 14),
          _Card(
            title: s.adsRepLive,
            child: _Grid(
              inner: true,
              children: [
                _Kpi(
                  label: s.adsRepLiveFromAd,
                  value: fmt.compact(_i(r.live!['entered_from_ad'])),
                  strong: true,
                ),
                _Kpi(
                  label: s.adsRepLivePeak,
                  value: fmt.compact(_i(r.live!['peak_viewers'])),
                ),
                _Kpi(
                  label: s.adsRepLiveGifts,
                  value: fmt.compact(
                    _i(_m(r.live!['gifts_during_campaign'])['coins']),
                  ),
                  hint: s.adsRepCoins,
                ),
                _Kpi(
                  label: s.adsRepLiveMinutes,
                  value: fmt.compact(_i(r.live!['live_minutes'])),
                ),
              ],
            ),
          ),
        ],

        // ── Coins
        const SizedBox(height: 14),
        _Card(
          title: s.adsRepCoins,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: s.adsRepCoinsPaid,
                      value: fmt.integer(r.coinsPaid),
                    ),
                  ),
                  Expanded(
                    child: _MiniStat(
                      label: s.adsRepCoinsUsed,
                      value: fmt.integer(r.coinsUsed),
                    ),
                  ),
                  Expanded(
                    child: _MiniStat(
                      label: s.adsRepCoinsRefunded,
                      value: fmt.integer(r.coinsRefunded),
                    ),
                  ),
                ],
              ),
              if (r.changes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  s.adsRepChanges,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                for (final c in r.changes.reversed)
                  _ChangeRow(change: c, fmt: fmt),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _dayChart(BuildContext context, AnalyticsFmt fmt) {
    final s = S.of(context);
    final colors = context.colors;
    final days = r.days;
    final (label, values, money) = switch (_metric) {
      'impressions' => (
        s.myAdsImpressions,
        [for (final d in days) d.impressions.toDouble()],
        false,
      ),
      'clicks' => (
        s.myAdsClicks,
        [for (final d in days) d.clicks.toDouble()],
        false,
      ),
      'spend' => (s.myAdsSpent, [for (final d in days) d.spend], true),
      _ => (s.myAdsReach, [for (final d in days) d.reach.toDouble()], false),
    };
    return AnalyticsLineChart(
      key: ValueKey(_metric),
      dates: [for (final d in days) d.day],
      lines: [
        ChartLine(
          label: label,
          color: colors.accentPrimary,
          values: values,
          area: true,
        ),
      ],
      valueFormatter: money ? fmt.money : fmt.integer,
      periodDays: days.length,
      height: 210,
      integerAxis: !money,
    );
  }

  Widget _audienceList(BuildContext context, AnalyticsFmt fmt) {
    final s = S.of(context);
    final list = switch (_audience) {
      'city' => r.cities,
      'state' => r.states,
      'region' => r.regions,
      'interests' => r.interests,
      _ => _ageOrdered(r.age),
    };
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          s.adsRepNoData,
          style: TextStyle(color: context.colors.textTertiary),
        ),
      );
    }
    final total = _audience == 'interests'
        ? r.reach
        : list.fold<int>(0, (a, e) => a + e.value);
    return _Bars(
      total: math.max(total, 1),
      items: [for (final e in list) MapEntry(_bucket(s, e.key), e.value)],
      fmt: fmt,
      showPct: true,
    );
  }

  /// Idade na ordem natural (18-24, 25-34…), não por tamanho.
  static List<MapEntry<String, int>> _ageOrdered(
    List<MapEntry<String, int>> l,
  ) {
    int rank(String k) => k == 'outros'
        ? 99
        : (k == 'desconhecida'
              ? 98
              : int.tryParse(k.split(RegExp('[-+]')).first) ?? 97);
    return [...l]..sort((a, b) => rank(a.key).compareTo(rank(b.key)));
  }
}

String _bucket(S s, String k) => switch (k) {
  'outros' => s.adsRepOthers,
  'desconhecida' || 'desconhecido' => s.adsRepUnknown,
  _ =>
    k.contains('-') && RegExp(r'^\d').hasMatch(k) ? k.replaceAll('-', '–') : k,
};

String _placement(S s, String k) => switch (k) {
  'foryou' => s.adsRepPlForyou,
  'following' => s.adsRepPlFollowing,
  'stories' => s.adsRepPlStories,
  'lives' => s.adsRepPlLives,
  'explore' => s.adsRepPlExplore,
  'web_home' => s.adsRepPlWeb,
  _ => k,
};

String _platform(String k) => switch (k) {
  'ios' => 'iPhone',
  'android' => 'Android',
  'web' => 'Web',
  _ => k,
};

// ── peças visuais ───────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child, this.title, this.trailing});
  final Widget child;
  final String? title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (trailing != null)
                  Text(
                    trailing!,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children, this.inner = false});
  final List<Widget> children;
  final bool inner;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final cols = box.maxWidth > 520 ? 3 : 2;
      final w = (box.maxWidth - (cols - 1) * 10) / cols;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final c in children)
            SizedBox(
              width: w,
              child: inner
                  ? c
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: c,
                    ),
            ),
        ],
      );
    },
  );
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    this.hint,
    this.strong = false,
  });
  final String label;
  final String value;
  final String? hint;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: strong ? colors.accentPrimary : colors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(
              hint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textTertiary, fontSize: 11.5),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

/// Seletor em pílulas com rolagem lateral (cabe em qualquer largura).
class _Pills extends StatelessWidget {
  const _Pills({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final e in items.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: e.key == value
                        ? colors.textPrimary
                        : colors.surfaceHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      color: e.key == value
                          ? colors.background
                          : colors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Barras horizontais com valor e porcentagem.
class _Bars extends StatelessWidget {
  const _Bars({
    required this.total,
    required this.items,
    required this.fmt,
    this.showPct = false,
  });
  final int total;
  final List<MapEntry<String, int>> items;
  final AnalyticsFmt fmt;
  final bool showPct;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxV = items.fold<int>(1, (a, e) => math.max(a, e.value));
    return Column(
      children: [
        for (final e in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      fmt.integer(e.value),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    if (showPct) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 44,
                        child: Text(
                          fmt.percent(e.value * 100 / math.max(total, 1)),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: e.value / maxV),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      color: colors.accentPrimary,
                      backgroundColor: colors.surfaceHighest,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Barra única dividida (ex.: iPhone × Android × Web) com legenda.
class _Split extends StatelessWidget {
  const _Split({required this.items, required this.fmt});
  final List<MapEntry<String, int>> items;
  final AnalyticsFmt fmt;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = items.fold<int>(0, (a, e) => a + e.value);
    final palette = [
      colors.accentPrimary,
      colors.accentPink,
      colors.accentGold,
      colors.textTertiary,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  if (items[i].value > 0)
                    Expanded(
                      flex: math.max(1, items[i].value),
                      child: ColoredBox(color: palette[i % palette.length]),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            for (var i = 0; i < items.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: palette[i % palette.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${items[i].key} ',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    fmt.percent(items[i].value * 100 / math.max(total, 1)),
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// 24 colunas (0h–23h), a mais forte em destaque.
class _Hours extends StatelessWidget {
  const _Hours({required this.byHour, required this.fmt});
  final Map<int, int> byHour;
  final AnalyticsFmt fmt;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final maxV = byHour.values.fold<int>(1, math.max);
    final best = byHour.entries.reduce((a, b) => b.value > a.value ? b : a).key;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(LucideIcons.clock, size: 15, color: colors.accentPrimary),
            const SizedBox(width: 6),
            Text(
              s.adsRepBestHour('$best'),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var h = 0; h < 24; h++)
                Expanded(
                  child: Tooltip(
                    message: '${h}h · ${fmt.integer(byHour[h] ?? 0)}',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.2),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: (byHour[h] ?? 0) / maxV),
                        duration: Duration(milliseconds: 300 + h * 12),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => Container(
                          height: math.max(3, 90 * v),
                          decoration: BoxDecoration(
                            color: h == best
                                ? colors.accentPrimary
                                : colors.accentPrimary.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final h in const [0, 6, 12, 18, 23])
              Text(
                '${h}h',
                style: TextStyle(color: colors.textTertiary, fontSize: 10.5),
              ),
          ],
        ),
      ],
    );
  }
}

class _Footnote extends StatelessWidget {
  const _Footnote({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 14, color: colors.textTertiary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colors.textTertiary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({required this.change, required this.fmt});
  final AdBudgetChange change;
  final AnalyticsFmt fmt;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final c = change;
    final label = switch (c.kind) {
      'daily_up' || 'daily_budget' => s.adsRepChangeDaily,
      'top_up' => s.adsRepChangeTotal,
      'end_at' => s.adsRepChangeEnd,
      _ => c.kind,
    };
    final values = c.before != null && c.after != null
        ? '${fmt.money(c.before!)} → ${fmt.money(c.after!)}'
        : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(LucideIcons.trendingUp, size: 16, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (values.isNotEmpty)
                  Text(
                    values,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (c.coins > 0)
                Text(
                  '+${fmt.integer(c.coins)} ${s.adsRepCoins}',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (c.at != null)
                Text(
                  fmt.dayShort(c.at!.toLocal()),
                  style: TextStyle(color: colors.textTertiary, fontSize: 11.5),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
