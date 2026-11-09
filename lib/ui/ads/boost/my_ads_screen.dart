// Brawe Ads — "Meus anúncios": lista e detalhe (resultados, pausar/retomar, aumentar por dia, editar público, encerrar).
// O valor por dia só aumenta (nunca diminui).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/ads_repository.dart';
import '../../../domain/models/ad_models.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../wallet/widgets/top_up_coins_sheet.dart';
import 'ad_report_view.dart';
import 'boost_audience.dart';
import 'boost_flow_screen.dart' show brl, coinsFmt, audienceSummary;

(String, Color) _status(BuildContext context, AdCampaign c) {
  final s = S.of(context);
  final colors = context.colors;
  return switch (c.status) {
    'draft' => (s.myAdsStatusDraft, colors.textTertiary),
    'pending_review' => (s.myAdsStatusReview, colors.warning),
    'active' => (s.myAdsStatusActive, colors.success),
    'paused' => (s.myAdsStatusPaused, colors.textSecondary),
    'rejected' => (s.myAdsStatusRejected, colors.danger),
    _ => (s.myAdsStatusEnded, colors.textTertiary),
  };
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: child,
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.campaign);
  final AdCampaign campaign;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _status(context, campaign);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendBar extends StatelessWidget {
  const _SpendBar(this.c);
  final AdCampaign c;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '${s.myAdsSpent} ',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            Text(
              brl(context, c.spent),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              ' ${s.myAdsOf(brl(context, c.totalBudget))}',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: c.usedPct,
            minHeight: 5,
            color: colors.accentPrimary,
            backgroundColor: colors.surfaceHighest,
          ),
        ),
      ],
    );
  }
}

// ── lista ───────────────────────────────────────────────────────────────

class MyAdsScreen extends ConsumerStatefulWidget {
  const MyAdsScreen({super.key});

  @override
  ConsumerState<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends ConsumerState<MyAdsScreen> {
  late Future<List<AdCampaign>> _future = _fetch();

  Future<List<AdCampaign>> _fetch() async =>
      (await ref.read(adsRepositoryProvider).campaigns())
          .where((c) => c.status != 'draft')
          .toList(); // app e site juntos

  Future<void> _refresh() async {
    final f = _fetch();
    setState(() => _future = f);
    await f;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          s.myAdsTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<AdCampaign>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(snap.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: _refresh,
                    child: Text(s.boostRetry),
                  ),
                ],
              ),
            );
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return _Centered(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 96, 32, 32),
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: colors.surfaceHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.rocket,
                        size: 34,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      s.myAdsEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.myAdsEmptyHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator.adaptive(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal:
                    (MediaQuery.sizeOf(context).width - 640).clamp(
                          0,
                          double.infinity,
                        ) /
                        2 +
                    16,
                vertical: 12,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _CampaignCard(
                campaign: items[i],
                onTap: () async {
                  await context.push('/ads/campaigns/${items[i].id}');
                  if (mounted) _refresh();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign, required this.onTap});
  final AdCampaign campaign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final c = campaign;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _StatusPill(c),
                  const Spacer(),
                  Text(
                    '${brl(context, c.dailyBudget)} ${s.boostPerDayShort}',
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: colors.textTertiary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                c.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                kindGoalLabel(context, c),
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              if (c.endAt != null) ...[
                const SizedBox(height: 3),
                Text(
                  s.myAdsEndsOn(
                    DateFormat.MMMd(
                      Localizations.localeOf(context).toString(),
                    ).format(c.endAt!.toLocal()),
                  ),
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
              ],
              const SizedBox(height: 14),
              _SpendBar(c),
            ],
          ),
        ),
      ),
    );
  }
}

// ── detalhe ─────────────────────────────────────────────────────────────

class MyAdDetailScreen extends ConsumerStatefulWidget {
  const MyAdDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<MyAdDetailScreen> createState() => _MyAdDetailScreenState();
}

class _MyAdDetailScreenState extends ConsumerState<MyAdDetailScreen> {
  AdCampaign? _c;
  AdFullReport? _r;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(adsRepositoryProvider);
    try {
      final c = await repo.campaign(widget.id);
      AdFullReport? r;
      try {
        r = AdFullReport.fromJson(await repo.reportFull(widget.id));
      } catch (_) {}
      if (mounted) {
        setState(() {
          _c = c;
          _r = r;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), behavior: SnackBarBehavior.floating),
  );

  Future<void> _do(Future<AdCampaign> Function() f, {String? ok}) async {
    setState(() => _busy = true);
    try {
      final c = await f();
      if (!mounted) return;
      setState(() => _c = c);
      ref.invalidate(openBoostsProvider);
      HapticFeedback.mediumImpact();
      if (ok != null) _snack(ok);
    } on AdsFailure catch (e) {
      if (!mounted) return;
      if (e.code == 'insufficient_coins') {
        _snack(e.message);
        await TopUpCoinsSheet.show(context, reason: 'general');
      } else {
        _snack(e.message);
      }
    } catch (_) {
      if (mounted) _snack(S.of(context).boostError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final s = S.of(context);
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        content: Text(s.myAdsCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              s.myAdsCancel,
              style: TextStyle(color: context.colors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _do(
        () => ref.read(adsRepositoryProvider).action(widget.id, 'cancel'),
      );
    }
  }

  Future<void> _increase() async {
    final c = _c!;
    final cfg = await ref.read(adsRepositoryProvider).config();
    if (!mounted) return;
    final daily = await showModalBottomSheet<double>(
      useSafeArea: true,
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _IncreaseSheet(campaign: c, maxDaily: cfg.boostMaxDaily),
    );
    if (daily == null || !mounted) return;
    await _do(
      () => ref.read(adsRepositoryProvider).increaseDaily(widget.id, daily),
    );
  }

  Future<void> _editAudience() async {
    final cfg = await ref.read(adsRepositoryProvider).config();
    if (!mounted) return;
    final audience = BoostAudience.fromTargeting(_c!.targeting);
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            _EditAudienceScreen(id: widget.id, audience: audience, config: cfg),
      ),
    );
    if (saved == true && mounted) {
      _snack(S.of(context).myAdsAudienceSaved);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final c = _c;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          s.myAdsTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: c == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator.adaptive()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error.toString(), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: _load,
                          child: Text(s.boostRetry),
                        ),
                      ],
                    ),
            )
          : RefreshIndicator.adaptive(
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      (MediaQuery.sizeOf(context).width - 640).clamp(
                            0,
                            double.infinity,
                          ) /
                          2 +
                      20,
                  vertical: 12,
                ),
                children: [
                  Row(
                    children: [
                      _StatusPill(c),
                      const Spacer(),
                      if (c.endAt != null && c.isOpen)
                        Text(
                          s.myAdsEndsOn(
                            DateFormat.MMMd(
                              Localizations.localeOf(context).toString(),
                            ).format(c.endAt!.toLocal()),
                          ),
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    c.name,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (c.pausedBy == 'admin') ...[
                    const SizedBox(height: 10),
                    _Notice(
                      icon: LucideIcons.shieldAlert,
                      text: s.myAdsPausedByTeam,
                    ),
                  ],
                  const SizedBox(height: 18),
                  if (_r == null)
                    const _Metrics(report: null)
                  else
                    AdReportView(report: _r!),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SpendBar(c),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.wallet,
                              size: 16,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${brl(context, c.dailyBudget)} ${s.boostPerDayShort}',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.target,
                              size: 16,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                kindGoalLabel(context, c),
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (c.kind == 'boost') ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                LucideIcons.users,
                                size: 16,
                                color: colors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  audienceSummary(
                                    context,
                                    BoostAudience.fromTargeting(c.targeting),
                                  ),
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // mensagens: onde os contatos chegam
                  if (c.objective == 'contacts') ...[
                    const SizedBox(height: 12),
                    _Notice(
                      icon: c.ctaType == 'whatsapp'
                          ? LucideIcons.phone
                          : LucideIcons.messagesSquare,
                      text: c.ctaType == 'whatsapp'
                          ? s.myAdsLeadsWhatsapp
                          : s.myAdsLeadsChat,
                      info: true,
                      action: c.ctaType == 'whatsapp'
                          ? null
                          : (s.myAdsOpenChat, () => context.go('/chat')),
                    ),
                  ],
                  if (c.isOpen && c.kind != 'boost') ...[
                    const SizedBox(height: 12),
                    _Notice(
                      icon: LucideIcons.monitor,
                      text: s.myAdsBrandEditOnWeb,
                      info: true,
                    ),
                  ],
                  if (c.isOpen) ...[
                    const SizedBox(height: 18),
                    if (c.kind == 'boost') ...[
                      _ActionTile(
                        icon: LucideIcons.trendingUp,
                        label: s.myAdsIncreaseDaily,
                        onTap: _busy ? null : _increase,
                      ),
                      _ActionTile(
                        icon: LucideIcons.users,
                        label: s.myAdsEditAudience,
                        onTap: _busy ? null : _editAudience,
                      ),
                    ],
                    if (c.status == 'active')
                      _ActionTile(
                        icon: LucideIcons.pause,
                        label: s.myAdsPause,
                        onTap: _busy
                            ? null
                            : () => _do(
                                () => ref
                                    .read(adsRepositoryProvider)
                                    .action(widget.id, 'pause'),
                              ),
                      ),
                    if (c.status == 'paused' && c.pausedBy != 'admin')
                      _ActionTile(
                        icon: LucideIcons.play,
                        label: s.myAdsResume,
                        onTap: _busy
                            ? null
                            : () => _do(
                                () => ref
                                    .read(adsRepositoryProvider)
                                    .action(widget.id, 'resume'),
                              ),
                      ),
                    _ActionTile(
                      icon: LucideIcons.circleStop,
                      label: s.myAdsCancel,
                      danger: true,
                      onTap: _busy ? null : _cancel,
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.text,
    this.action,
    this.info = false,
  });
  final bool info; // azul (informação) em vez de amarelo (atenção)
  final IconData icon;
  final String text;
  final (String, VoidCallback)? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (info ? colors.accentPrimary : colors.warning).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: info ? colors.accentPrimary : colors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: colors.textPrimary, fontSize: 13.5),
            ),
          ),
          if (action != null)
            TextButton(onPressed: action!.$2, child: Text(action!.$1)),
        ],
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.report});
  final AdReportSummary? report;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final r = report;
    String n(int? v) => v == null
        ? '–'
        : NumberFormat.compact(
            locale: Localizations.localeOf(context).toString(),
          ).format(v);
    final items = [
      (s.myAdsReach, n(r?.reach)),
      (s.myAdsImpressions, n(r?.impressions)),
      (s.myAdsProfileVisits, n(r?.profileVisits)),
      (s.myAdsNewFollowers, n(r?.newFollowers)),
      (s.myAdsClicks, n(r?.clicks)),
      (s.myAdsViews, n(r?.views)),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final cols = box.maxWidth > 480 ? 3 : 2;
        final w = (box.maxWidth - (cols - 1) * 10) / cols;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (label, value) in items)
              Container(
                width: w,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = danger ? colors.danger : colors.textPrimary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, size: 20, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      trailing: danger
          ? null
          : Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: colors.textTertiary,
            ),
      onTap: onTap,
    );
  }
}

/// Aumentar o valor por dia (só para cima) com o custo extra em Coins.
class _IncreaseSheet extends ConsumerStatefulWidget {
  const _IncreaseSheet({required this.campaign, required this.maxDaily});
  final AdCampaign campaign;
  final double maxDaily;

  @override
  ConsumerState<_IncreaseSheet> createState() => _IncreaseSheetState();
}

class _IncreaseSheetState extends ConsumerState<_IncreaseSheet> {
  late final List<double> _options =
      {
            for (final m in [1.5, 2.0, 3.0, 5.0])
              (widget.campaign.dailyBudget * m).ceilToDouble(),
            for (final v in [20.0, 50.0, 100.0, 200.0]) v,
          }
          .where((v) => v > widget.campaign.dailyBudget && v <= widget.maxDaily)
          .toList()
        ..sort();
  double? _pick;
  ({int daysLeft, double extra, int coins})? _q;
  bool _loading = false;

  Future<void> _select(double v) async {
    setState(() {
      _pick = v;
      _q = null;
      _loading = true;
    });
    try {
      final q = await ref
          .read(adsRepositoryProvider)
          .dailyQuote(widget.campaign.id, v);
      if (mounted && _pick == v) setState(() => _q = q);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final opts = _options.take(4).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.myAdsIncreaseDaily,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${brl(context, widget.campaign.dailyBudget)} ${s.boostPerDayShort} · ${s.myAdsOnlyUp}',
              style: TextStyle(color: colors.textSecondary, fontSize: 13.5),
            ),
            const SizedBox(height: 18),
            if (opts.isEmpty)
              Text(s.myAdsAtMax, style: TextStyle(color: colors.textSecondary))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in opts)
                    ChoiceChip(
                      label: Text(brl(context, v)),
                      selected: _pick == v,
                      showCheckmark: false,
                      shape: const StadiumBorder(),
                      onSelected: (_) => _select(v),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            SizedBox(
              height: 22,
              child: _loading
                  ? const Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _q == null
                  ? null
                  : Text(
                      s.myAdsIncreaseCost(
                        '${_q!.daysLeft}',
                        coinsFmt(context, _q!.coins),
                      ),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _q == null
                    ? null
                    : () => Navigator.pop(context, _pick),
                child: Text(
                  s.myAdsSave,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditAudienceScreen extends ConsumerStatefulWidget {
  const _EditAudienceScreen({
    required this.id,
    required this.audience,
    required this.config,
  });
  final String id;
  final BoostAudience audience;
  final AdsPublicConfig config;

  @override
  ConsumerState<_EditAudienceScreen> createState() =>
      _EditAudienceScreenState();
}

class _EditAudienceScreenState extends ConsumerState<_EditAudienceScreen> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(adsRepositoryProvider)
          .updateTargeting(
            widget.id,
            widget.audience.toTargeting(widget.config),
          );
      if (mounted) Navigator.pop(context, true);
    } on AdsFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).boostError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.myAdsEditAudience,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: _Centered(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: BoostAudienceEditor(
            audience: widget.audience,
            config: widget.config,
            onChanged: () => setState(() {}),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _Centered(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: widget.audience.isValid && !_saving ? _save : null,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        s.myAdsSave,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Impulsionamento · Mensagens no chat" / "Anúncio da marca".
String kindGoalLabel(BuildContext context, AdCampaign c) {
  final s = S.of(context);
  if (c.kind != 'boost') return s.myAdsKindBrand;
  final goal = switch (c.objective) {
    'followers' => s.boostGoalFollowers,
    'profile_visits' => s.boostGoalProfile,
    'contacts' =>
      '${s.boostGoalContacts} · ${c.ctaType == 'whatsapp' ? s.boostContactWhatsapp : s.boostContactChat}',
    _ => s.boostGoalViews,
  };
  return '${s.myAdsKindBoost} · $goal';
}
