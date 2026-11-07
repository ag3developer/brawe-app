// Saque em etapas: valor (com cotação ao vivo) → revisão do cálculo →
// código por e-mail → pronto. Igual ao site (brawe.app/earnings).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../data/repositories/creator_payout_repository.dart';
import '../../../../domain/models/creator_payout.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import '../agency/agency_widgets.dart';
import 'monetization_account_screen.dart' show PayoutErrorBox;
import 'monetization_l10n.dart';

enum _Step { amount, review, code, done }

class MonetizationWithdrawScreen extends ConsumerStatefulWidget {
  const MonetizationWithdrawScreen({super.key, required this.overview});
  final PayoutOverview overview;

  @override
  ConsumerState<MonetizationWithdrawScreen> createState() => _MonetizationWithdrawScreenState();
}

class _MonetizationWithdrawScreenState extends ConsumerState<MonetizationWithdrawScreen> {
  _Step _step = _Step.amount;
  final _amount = TextEditingController();
  final _code = TextEditingController();
  Timer? _debounce;
  Timer? _resendTimer;
  int _quoteSeq = 0;
  bool _quoting = false;
  PayoutQuote? _quote;
  Object? _quoteErr;
  PayoutChallenge? _challenge;
  int _resendIn = 0;
  bool _busy = false;
  String _error = '';
  String _notice = '';
  Payout? _created;

  PayoutOverview get _ov => widget.overview;
  int get _diamonds => int.tryParse(_amount.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _resendTimer?.cancel();
    _amount.dispose();
    _code.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    _debounce?.cancel();
    final seq = ++_quoteSeq;
    setState(() {
      _quote = null;
      _quoteErr = null;
      _quoting = _diamonds > 0;
    });
    if (_diamonds <= 0) return;
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final q = await ref.read(creatorPayoutRepositoryProvider).quote(_diamonds);
        if (mounted && seq == _quoteSeq) setState(() { _quote = q; _quoting = false; });
      } catch (e) {
        if (mounted && seq == _quoteSeq) setState(() { _quoteErr = e; _quoting = false; });
      }
    });
  }

  void _startResendCountdown(int seconds) {
    _resendTimer?.cancel();
    setState(() => _resendIn = seconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _resendIn = _resendIn > 0 ? _resendIn - 1 : 0);
      if (_resendIn == 0) t.cancel();
    });
  }

  Future<void> _sendRequest() async {
    final s = S.of(context);
    final f = PayoutFmt.of(context);
    setState(() { _busy = true; _error = ''; _notice = ''; });
    try {
      final ch = await ref.read(creatorPayoutRepositoryProvider).request(_diamonds);
      if (!mounted) return;
      _code.clear();
      setState(() { _challenge = ch; _step = _Step.code; });
      _startResendCountdown(ch.resendIn > 0 ? ch.resendIn : 60);
    } catch (e) {
      if (mounted) setState(() => _error = payoutErrorText(s, f, e, _ov));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final ch = _challenge;
    if (ch == null || _resendIn > 0) return;
    final s = S.of(context);
    final f = PayoutFmt.of(context);
    setState(() { _busy = true; _error = ''; _notice = ''; });
    try {
      final r = await ref.read(creatorPayoutRepositoryProvider).resend(ch.id);
      if (!mounted) return;
      _startResendCountdown(r.resendIn > 0 ? r.resendIn : 60);
      setState(() => _notice = s.payoutCodeResent(r.emailMasked ?? ch.emailMasked ?? ''));
    } catch (e) {
      if (!mounted) return;
      if (e is PayoutException && e.code == 'resend_too_soon') {
        final wait = e.extra['retry_after'];
        _startResendCountdown(wait is num ? wait.toInt() : 30);
      }
      setState(() => _error = payoutErrorText(s, f, e, _ov));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final ch = _challenge;
    if (ch == null || _code.text.length != 6) return;
    final s = S.of(context);
    final f = PayoutFmt.of(context);
    FocusScope.of(context).unfocus();
    setState(() { _busy = true; _error = ''; _notice = ''; });
    try {
      final p = await ref.read(creatorPayoutRepositoryProvider).confirm(ch.id, _code.text);
      if (!mounted) return;
      _resendTimer?.cancel();
      setState(() { _created = p; _step = _Step.done; });
    } catch (e) {
      if (!mounted) return;
      if (e is PayoutException && e.code == 'code_invalid') _code.clear();
      setState(() => _error = payoutErrorText(s, f, e, _ov));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _back() {
    if (_busy) return false;
    setState(() { _error = ''; _notice = ''; });
    switch (_step) {
      case _Step.review:
        setState(() => _step = _Step.amount);
        return false;
      case _Step.code:
        setState(() => _step = _Step.review);
        return false;
      case _Step.amount:
      case _Step.done:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final stepIndex = _step.index + 1;
    return PopScope(
      canPop: _step == _Step.amount || _step == _Step.done,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          backgroundColor: c.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(s.payoutWithdrawTitle, style: TextStyle(color: c.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          automaticallyImplyLeading: _step != _Step.done,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              if (_step != _Step.done) ...[
                Row(children: [
                  for (var i = 1; i <= 3; i++) ...[
                    if (i > 1) const SizedBox(width: 6),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= stepIndex ? c.accentPrimary : c.surfaceHighest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: 6),
                Text(s.payoutWithdrawStepOf('$stepIndex', '3'), style: AgencyText.caption(context)),
                const SizedBox(height: 18),
              ],
              ...switch (_step) {
                _Step.amount => _amountStep(context),
                _Step.review => _reviewStep(context),
                _Step.code => _codeStep(context),
                _Step.done => _doneStep(context),
              },
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. valor ──
  List<Widget> _amountStep(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final f = PayoutFmt.of(context);
    final avail = _ov.balance.available;
    final minAmount = _ov.rules.minForCurrency;
    final minDiamonds = _ov.rules.minDiamonds ?? 0;
    final q = _quote;

    Widget quoteBody() {
      if (_diamonds <= 0) return Text(s.payoutWithdrawTypeToQuote, style: AgencyText.caption(context));
      if (_quoting) {
        return Row(children: [
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 10),
          Text(s.payoutWithdrawCalculating, style: AgencyText.caption(context)),
        ]);
      }
      if (_quoteErr != null) {
        return Text(payoutErrorText(s, f, _quoteErr!, _ov), style: TextStyle(color: c.danger, fontSize: 13));
      }
      if (q == null) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.payoutWithdrawYouReceive, style: AgencyText.caption(context)),
        const SizedBox(height: 2),
        Text(f.money(q.net, q.currency), style: AgencyText.number(context, size: 28)),
        if (q.taxTotal > 0) ...[
          const SizedBox(height: 2),
          Text(s.payoutWithdrawAfterRetentions(f.money(q.gross, q.currency), f.money(q.taxTotal, q.currency)),
              style: AgencyText.caption(context).copyWith(fontSize: 11.5)),
        ],
      ]);
    }

    return [
      Text(s.payoutWithdrawAmountTitle, style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(s.payoutWithdrawAmountSubtitle(f.integer(avail)), style: AgencyText.caption(context)),
      const SizedBox(height: 16),
      TextField(
        controller: _amount,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
        onChanged: (_) => _onAmountChanged(),
        style: AgencyText.number(context, size: 22),
        decoration: InputDecoration(
          labelText: s.payoutWithdrawDiamondsLabel,
          hintText: '0',
          prefixIcon: Icon(LucideIcons.gem, size: 18, color: c.textTertiary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TextButton(
              onPressed: avail > 0
                  ? () {
                      _amount.text = '$avail';
                      _onAmountChanged();
                    }
                  : null,
              child: Text(s.payoutWithdrawAll),
            ),
          ),
        ),
      ),
      if (minDiamonds > 0) ...[
        const SizedBox(height: 6),
        Text(s.payoutWithdrawMinHint(f.money(minAmount, _ov.currency), f.integer(minDiamonds)),
            style: AgencyText.caption(context).copyWith(fontSize: 11.5)),
      ],
      const SizedBox(height: 16),
      AgencyBox(child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 56), child: quoteBody())),
      const SizedBox(height: 20),
      SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: q != null && !_quoting ? () => setState(() { _error = ''; _step = _Step.review; }) : null,
          child: Text(s.payoutWithdrawContinue),
        ),
      ),
    ];
  }

  // ── 2. revisão ──
  List<Widget> _reviewStep(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final f = PayoutFmt.of(context);
    final q = _quote!;
    final acc = _ov.account!;
    final brl = _ov.currency == 'BRL';
    return [
      Text(s.payoutWithdrawReviewTitle, style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(s.payoutWithdrawReviewSubtitle, style: AgencyText.caption(context)),
      const SizedBox(height: 16),
      AgencyBox(
        child: Column(children: [
          AgencyInfoRow(label: s.payoutWithdrawDiamonds, value: f.integer(q.diamonds)),
          if (brl)
            AgencyInfoRow(
              label: s.payoutWithdrawPtax(f.date(DateTime.tryParse(q.fxRefDate ?? _ov.fx?.refDate ?? ''))),
              value: r'US$ 1 = R$ ' + f.fx(q.fxQuote),
            )
          else
            AgencyInfoRow(label: s.payoutWithdrawValueUsd, value: f.money(q.amountUsd, 'USD')),
          AgencyInfoRow(label: s.payoutWithdrawGross, value: f.money(q.gross, q.currency)),
          if (q.taxes.isEmpty)
            AgencyInfoRow(label: s.payoutWithdrawRetentions, value: s.payoutWithdrawNoRetentions, valueColor: c.textSecondary)
          else
            for (final t in q.taxes)
              AgencyInfoRow(label: t.label, value: '− ${f.money(t.amount, q.currency)}', valueColor: c.textSecondary),
          if (q.taxes.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(s.payoutWithdrawRetentionsHelp, style: AgencyText.caption(context).copyWith(fontSize: 11)),
            ),
          const SizedBox(height: 8),
          const AgencyDivider(),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Text(s.payoutWithdrawNet, style: AgencyText.title(context))),
            Text(f.money(q.net, q.currency), style: AgencyText.number(context, size: 22)),
          ]),
        ]),
      ),
      if (q.monthPriorGross > 0) ...[
        const SizedBox(height: 8),
        Text(s.payoutWithdrawMonthPrior(f.money(q.monthPriorGross, q.currency)),
            style: AgencyText.caption(context).copyWith(fontSize: 11.5)),
      ],
      const SizedBox(height: 12),
      AgencyBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.payoutWithdrawPaidTo, style: AgencyText.caption(context)),
          const SizedBox(height: 4),
          Text(acc.display, style: AgencyText.title(context)),
          Text([acc.holderName, ?payoutHolderTypeLabel(s, acc.holderType)].join(' · '), style: AgencyText.caption(context)),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(LucideIcons.clock, size: 15, color: c.textTertiary),
            const SizedBox(width: 8),
            Expanded(child: Text(s.payoutWithdrawSla(_ov.rules.paymentDays), style: AgencyText.caption(context))),
          ]),
          if (acc.status == PayoutAccountStatus.pendingReview) ...[
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(LucideIcons.shieldCheck, size: 15, color: c.textTertiary),
              const SizedBox(width: 8),
              Expanded(child: Text(s.payoutWithdrawFirstPaymentCheck, style: AgencyText.caption(context))),
            ]),
          ],
        ]),
      ),
      if (_error.isNotEmpty) ...[const SizedBox(height: 14), PayoutErrorBox(text: _error)],
      const SizedBox(height: 20),
      SizedBox(
        height: 48,
        child: FilledButton.icon(
          onPressed: _busy ? null : _sendRequest,
          icon: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(LucideIcons.mail, size: 18),
          label: Text(s.payoutWithdrawSendCode),
        ),
      ),
    ];
  }

  // ── 3. código ──
  List<Widget> _codeStep(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final ch = _challenge!;
    return [
      Text(s.payoutCodeTitle, style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(s.payoutCodeSubtitle(ch.emailMasked ?? ''), style: AgencyText.caption(context)),
      const SizedBox(height: 18),
      TextField(
        controller: _code,
        autofocus: true,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
        onChanged: (v) {
          setState(() {});
          if (v.length == 6 && !_busy) _confirm();
        },
        style: AgencyText.number(context, size: 28).copyWith(letterSpacing: 10),
        decoration: InputDecoration(
          hintText: '000000',
          semanticCounterText: s.payoutCodeLabel,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      if (_error.isNotEmpty) ...[const SizedBox(height: 14), PayoutErrorBox(text: _error)],
      if (_notice.isNotEmpty && _error.isEmpty) ...[
        const SizedBox(height: 12),
        Row(children: [
          Icon(LucideIcons.circleCheck, size: 15, color: c.success),
          const SizedBox(width: 8),
          Expanded(child: Text(_notice, style: AgencyText.caption(context))),
        ]),
      ],
      const SizedBox(height: 20),
      SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: _busy || _code.text.length != 6 ? null : _confirm,
          child: _busy
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(s.payoutCodeConfirm),
        ),
      ),
      const SizedBox(height: 8),
      Center(
        child: TextButton(
          onPressed: _busy || _resendIn > 0 ? null : _resend,
          child: Text(_resendIn > 0 ? s.payoutCodeResendIn('$_resendIn') : s.payoutCodeResend),
        ),
      ),
    ];
  }

  // ── 4. pronto ──
  List<Widget> _doneStep(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final f = PayoutFmt.of(context);
    final p = _created;
    return [
      const SizedBox(height: 24),
      Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: c.success.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(LucideIcons.circleCheck, size: 34, color: c.success),
        ),
      ),
      const SizedBox(height: 18),
      Text(s.payoutDoneTitle,
          textAlign: TextAlign.center, style: TextStyle(color: c.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text(s.payoutDoneSubtitle(_ov.rules.paymentDays), textAlign: TextAlign.center, style: AgencyText.caption(context)),
      if (p != null) ...[
        const SizedBox(height: 20),
        AgencyBox(
          child: Column(children: [
            AgencyInfoRow(label: s.payoutWithdrawDiamonds, value: f.integer(p.diamonds)),
            AgencyInfoRow(label: s.payoutWithdrawPaidTo, value: p.accountDisplay),
            AgencyInfoRow(label: s.payoutDoneStatus, value: s.payoutStatusRequested),
            const SizedBox(height: 6),
            const AgencyDivider(),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Text(s.payoutWithdrawNet, style: AgencyText.title(context))),
              Text(f.money(p.net, p.currency), style: AgencyText.number(context, size: 20)),
            ]),
          ]),
        ),
      ],
      const SizedBox(height: 24),
      SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.payoutDoneBackMonetization),
        ),
      ),
    ];
  }
}
