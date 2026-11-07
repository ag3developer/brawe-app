// ─────────────────────────────────────────────────────────────────────────────
// Aba Monetização do painel do criador.
//
// Só DIAMANTES (presentes recebidos em lives e stories) são sacáveis. Coins
// compradas servem para gastar no app e não aparecem aqui. O saldo é mostrado
// como conta: recebido − aguardando liberação − em saque − já sacado = disponível.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../data/repositories/creator_payout_repository.dart';
import '../../../../domain/models/creator_payout.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../view_models/creator_payout_providers.dart';
import '../agency/agency_widgets.dart';
import '../creator_panel_scope.dart';
import '../creator_state_views.dart';
import 'monetization_account_screen.dart';
import 'monetization_l10n.dart';
import 'monetization_withdraw_screen.dart';

class PanelMonetizationTab extends ConsumerWidget {
  const PanelMonetizationTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final async = ref.watch(creatorPayoutOverviewProvider);
    Future<void> refresh() async {
      ref.invalidate(creatorPayoutOverviewProvider);
      try {
        await ref.read(creatorPayoutOverviewProvider.future);
      } catch (_) {}
    }

    return PanelTabScroll(
      storageKey: 'panel-monetization',
      onRefresh: refresh,
      slivers: [
        async.when(
          skipLoadingOnRefresh: true,
          loading: () => const SliverToBoxAdapter(child: AgencySkeleton(blocks: [260, 120, 140])),
          error: (_, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: CreatorErrorView(message: s.payoutLoadError, onRetry: refresh),
          ),
          data: (ov) => SliverToBoxAdapter(
            child: AgencyColumns(
              left: [
                _BalanceCard(ov: ov),
                for (final p in ov.open) _OpenPayoutCard(payout: p, ov: ov),
              ],
              right: [_AccountCard(ov: ov), _HistoryCard(ov: ov)],
            ),
          ),
        ),
      ],
    );
  }
}

/// Abre a tela de conta e recarrega o resumo ao voltar.
Future<void> _openAccount(BuildContext context, WidgetRef ref, PayoutOverview ov) async {
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => MonetizationAccountScreen(overview: ov)),
  );
  if (saved == true) ref.invalidate(creatorPayoutOverviewProvider);
}

Future<void> _openWithdraw(BuildContext context, WidgetRef ref, PayoutOverview ov) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => MonetizationWithdrawScreen(overview: ov)),
  );
  ref.invalidate(creatorPayoutOverviewProvider);
}

// ── saldo ────────────────────────────────────────────────────────────────────

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard({required this.ov});
  final PayoutOverview ov;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final c = context.colors;
    final f = PayoutFmt.of(context);
    final b = ov.balance;
    final cur = ov.currency;
    String? approx(int d) {
      final v = ov.approx(d);
      return v == null ? null : f.money(v, cur);
    }

    final sources = <String>[
      if ((b.fromLive?.diamonds ?? 0) > 0) s.payoutBalanceFromLive(f.integer(b.fromLive!.diamonds)),
      if ((b.fromStory?.diamonds ?? 0) > 0) s.payoutBalanceFromStory(f.integer(b.fromStory!.diamonds)),
      if ((b.fromOther?.diamonds ?? 0) > 0) s.payoutBalanceFromOther(f.integer(b.fromOther!.diamonds)),
    ];
    final acc = ov.account;
    final availApprox = approx(b.available);

    return AgencyBox(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(LucideIcons.gem, size: 16, color: c.textSecondary),
          const SizedBox(width: 6),
          Text(s.payoutBalanceAvailable, style: AgencyText.caption(context)),
        ]),
        const SizedBox(height: 6),
        Text(f.integer(b.available), style: AgencyText.number(context, size: 34)),
        const SizedBox(height: 4),
        Text(availApprox != null ? s.payoutBalanceApprox(availApprox) : s.payoutBalanceNoRate,
            style: AgencyText.caption(context)),
        const SizedBox(height: 16),
        const AgencyDivider(),
        const SizedBox(height: 12),
        Text(s.payoutBalanceHowTitle.toUpperCase(), style: AgencyText.label(context)),
        const SizedBox(height: 4),
        _Line(
          label: s.payoutBalanceReceived,
          diamonds: f.integer(b.lifetime),
          money: approx(b.lifetime),
          hint: sources.isEmpty ? null : sources.join(' · '),
        ),
        _Line(
          sign: '−',
          label: s.payoutBalanceHolding,
          diamonds: f.integer(b.holding),
          money: approx(b.holding),
          icon: LucideIcons.hourglass,
          hint: b.holding > 0 && b.nextReleaseAt != null
              ? s.payoutBalanceReleaseNote(f.date(b.nextReleaseAt), b.holdDays)
              : s.payoutBalanceHoldingHint(b.holdDays),
        ),
        if (b.inProgress > 0)
          _Line(
            sign: '−',
            label: s.payoutBalanceInProgress,
            diamonds: f.integer(b.inProgress),
            money: approx(b.inProgress),
            hint: s.payoutBalanceInProgressHint,
          ),
        if (b.withdrawn > 0)
          _Line(sign: '−', label: s.payoutBalanceWithdrawn, diamonds: f.integer(b.withdrawn), money: approx(b.withdrawn)),
        _Line(
          sign: '=',
          strong: true,
          label: s.payoutBalanceAvailableShort,
          diamonds: f.integer(b.available),
          money: availApprox,
          divider: false,
        ),
        const SizedBox(height: 14),
        if (ov.enabled) ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: acc == null
                  ? () => _openAccount(context, ref, ov)
                  : acc.status == PayoutAccountStatus.rejected
                      ? null
                      : () => _openWithdraw(context, ref, ov),
              icon: const Icon(LucideIcons.banknote, size: 18),
              label: Text(acc == null ? s.payoutBalanceAddAccountFirst : s.payoutBalanceWithdraw),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              s.payoutBalanceMinimum(f.money(ov.rules.minForCurrency, cur), ov.rules.paymentDays),
              textAlign: TextAlign.center,
              style: AgencyText.caption(context).copyWith(fontSize: 11.5),
            ),
          ),
        ] else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: c.surfaceHighest, borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(LucideIcons.clock, size: 18, color: c.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.payoutSoonTitle, style: AgencyText.title(context).copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(s.payoutSoonSubtitle, style: AgencyText.caption(context)),
                ]),
              ),
            ]),
          ),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(LucideIcons.info, size: 14, color: c.textTertiary),
          const SizedBox(width: 8),
          Expanded(child: Text(s.payoutOnlyGiftsNote, style: AgencyText.caption(context).copyWith(fontSize: 11.5))),
        ]),
      ]),
    );
  }
}

/// Uma linha da conta do saldo: sinal, rótulo (+ explicação) e valor.
class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.diamonds,
    this.money,
    this.sign,
    this.hint,
    this.icon,
    this.strong = false,
    this.divider = true,
  });
  final String label;
  final String diamonds;
  final String? money;
  final String? sign;
  final String? hint;
  final IconData? icon;
  final bool strong;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final weight = strong ? FontWeight.w800 : FontWeight.w600;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 14,
            child: Text(sign ?? '', style: TextStyle(color: c.textTertiary, fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: weight)),
              if (hint != null) ...[
                const SizedBox(height: 2),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (icon != null) ...[
                    Padding(padding: const EdgeInsets.only(top: 1), child: Icon(icon, size: 12, color: c.textTertiary)),
                    const SizedBox(width: 4),
                  ],
                  Expanded(child: Text(hint!, style: AgencyText.caption(context).copyWith(fontSize: 11.5))),
                ]),
              ],
            ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(diamonds,
                  style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: weight, fontFeatures: kTabularFigures)),
              const SizedBox(width: 4),
              Icon(LucideIcons.gem, size: 12, color: c.textTertiary),
            ]),
            if (money != null)
              Text('≈ $money',
                  style: TextStyle(color: c.textSecondary, fontSize: 11.5, fontFeatures: kTabularFigures)),
          ]),
        ]),
      ),
      if (divider) const AgencyDivider(),
    ]);
  }
}

// ── saque em andamento ───────────────────────────────────────────────────────

class _OpenPayoutCard extends ConsumerStatefulWidget {
  const _OpenPayoutCard({required this.payout, required this.ov});
  final Payout payout;
  final PayoutOverview ov;
  @override
  ConsumerState<_OpenPayoutCard> createState() => _OpenPayoutCardState();
}

class _OpenPayoutCardState extends ConsumerState<_OpenPayoutCard> {
  bool _busy = false;

  Future<void> _cancel() async {
    final s = S.of(context);
    final f = PayoutFmt.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showAgencyConfirm(
      context,
      title: s.payoutCancelTitle,
      body: s.payoutOpenCancelConfirm,
      action: s.payoutOpenCancelYes,
      danger: true,
      icon: LucideIcons.circleX,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(creatorPayoutRepositoryProvider).cancel(widget.payout.id);
      ref.invalidate(creatorPayoutOverviewProvider);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(payoutErrorText(s, f, e, widget.ov))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final f = PayoutFmt.of(context);
    final p = widget.payout;
    final days = widget.ov.rules.paymentDays;
    return AgencyBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.payoutOpenTitle, style: AgencyText.caption(context)),
              const SizedBox(height: 4),
              Text(f.money(p.net, p.currency), style: AgencyText.number(context, size: 24)),
              const SizedBox(height: 2),
              Text('${s.payoutOpenDiamonds(f.integer(p.diamonds))} · ${p.accountDisplay}',
                  style: AgencyText.caption(context)),
            ]),
          ),
          PayoutStatusPill(status: p.status),
        ]),
        const SizedBox(height: 10),
        Text(p.status == PayoutStatus.requested ? s.payoutOpenRequestedNote(days) : s.payoutOpenApprovedNote(days),
            style: AgencyText.body(context).copyWith(fontSize: 13)),
        const SizedBox(height: 4),
        Text(s.payoutOpenRequestedAt(f.date(p.createdAt, time: true)),
            style: AgencyText.caption(context).copyWith(fontSize: 11.5)),
        if (p.status == PayoutStatus.requested) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _cancel,
            child: _busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(s.payoutOpenCancel),
          ),
        ],
      ]),
    );
  }
}

class PayoutStatusPill extends StatelessWidget {
  const PayoutStatusPill({super.key, required this.status});
  final PayoutStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = switch (status) {
      PayoutStatus.paid => c.success,
      PayoutStatus.rejected => c.danger,
      PayoutStatus.canceled => c.textTertiary,
      _ => c.accentPrimary,
    };
    return _Pill(text: payoutStatusLabel(S.of(context), status), color: color);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
      );
}

// ── conta de recebimento ─────────────────────────────────────────────────────

class _AccountCard extends ConsumerWidget {
  const _AccountCard({required this.ov});
  final PayoutOverview ov;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final c = context.colors;
    final acc = ov.account;
    return AgencyBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AgencyBoxTitle(icon: LucideIcons.landmark, text: s.payoutAccountTitle),
        const SizedBox(height: 10),
        if (acc == null) ...[
          Text(s.payoutAccountEmpty, style: AgencyText.caption(context)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => _openAccount(context, ref, ov), child: Text(s.payoutAccountAdd)),
        ] else ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(acc.display, style: AgencyText.title(context)),
                const SizedBox(height: 2),
                Text(
                  [acc.holderName, acc.holderTaxIdMasked, ?payoutHolderTypeLabel(s, acc.holderType)].join(' · '),
                  style: AgencyText.caption(context),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            _Pill(
              text: payoutAccountStatusLabel(s, acc.status),
              color: switch (acc.status) {
                PayoutAccountStatus.verified => c.success,
                PayoutAccountStatus.rejected => c.danger,
                PayoutAccountStatus.pendingReview => c.accentPrimary,
              },
            ),
          ]),
          if (acc.status == PayoutAccountStatus.pendingReview) ...[
            const SizedBox(height: 10),
            Text(s.payoutAccountPendingNote, style: AgencyText.caption(context)),
          ],
          if (acc.status == PayoutAccountStatus.rejected) ...[
            const SizedBox(height: 10),
            Text(s.payoutAccountRejectedNote(acc.rejectReason ?? s.payoutAccountNoReason),
                style: AgencyText.caption(context).copyWith(color: c.danger)),
          ],
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => _openAccount(context, ref, ov), child: Text(s.payoutAccountChange)),
        ],
      ]),
    );
  }
}

// ── histórico ────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.ov});
  final PayoutOverview ov;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final f = PayoutFmt.of(context);
    final total = ov.balance.withdrawnNet.of(ov.currency);
    return AgencyBox(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AgencyBoxTitle(icon: LucideIcons.history, text: s.payoutHistoryTitle),
        const SizedBox(height: 6),
        if (ov.history.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(s.payoutHistoryEmpty, style: AgencyText.caption(context)),
          )
        else
          for (var i = 0; i < ov.history.length; i++) ...[
            if (i > 0) const AgencyDivider(),
            _HistoryRow(p: ov.history[i]),
          ],
        if (total > 0) ...[
          const SizedBox(height: 4),
          Text(s.payoutHistoryTotalReceived(f.money(total, ov.currency)), style: AgencyText.caption(context)),
          const SizedBox(height: 8),
        ],
      ]),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.p});
  final Payout p;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final f = PayoutFmt.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.money(p.net, p.currency), style: AgencyText.number(context, size: 15)),
              const SizedBox(height: 2),
              Text('${s.payoutOpenDiamonds(f.integer(p.diamonds))} · ${f.date(p.paidAt ?? p.createdAt)}',
                  style: AgencyText.caption(context)),
            ]),
          ),
          PayoutStatusPill(status: p.status),
        ]),
        if (p.status == PayoutStatus.rejected) ...[
          const SizedBox(height: 6),
          Text(s.payoutHistoryRejectedNote(p.rejectReason ?? s.payoutAccountNoReason),
              style: AgencyText.caption(context).copyWith(fontSize: 11.5)),
        ],
        if (p.status == PayoutStatus.paid && (p.paymentReference ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(s.payoutHistoryReference(p.paymentReference!), style: AgencyText.caption(context).copyWith(fontSize: 11.5)),
        ],
      ]),
    );
  }
}
