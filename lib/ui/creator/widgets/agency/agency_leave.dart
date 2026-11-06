import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../data/repositories/creator_agency_repository.dart';
import '../../../../domain/models/creator_agency.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../view_models/creator_agency_providers.dart';
import 'agency_l10n.dart';
import 'agency_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Saída da agência — BRAWE_PARTNERS §4.1.
// Livre no fim do contrato; antes, por acordo (pedido → a agência aprova);
// em caso de abuso, o criador pede análise da Brawe.
// ─────────────────────────────────────────────────────────────────────────────

const _maxReason = 500;
// Texto livre é sempre obrigatório (regra do dono); mesmo mínimo do servidor.
const _minReason = 10;

class AgencyLeaveSection extends ConsumerStatefulWidget {
  const AgencyLeaveSection({super.key, required this.link});
  final AgencyLink link;
  @override
  ConsumerState<AgencyLeaveSection> createState() => _AgencyLeaveSectionState();
}

class _AgencyLeaveSectionState extends ConsumerState<AgencyLeaveSection> {
  bool _busy = false;

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _run(Future<void> Function() f, {String? okMessage}) async {
    setState(() => _busy = true);
    try {
      await f();
      ref.invalidate(creatorAgencyProvider);
      if (mounted && okMessage != null) _snack(okMessage);
    } catch (e) {
      if (!mounted) return;
      _snack(agencyErrorText(context, e));
      ref.invalidate(creatorAgencyProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leaveFree() async {
    final s = S.of(context);
    final ok = await showAgencyConfirm(
      context,
      icon: LucideIcons.doorOpen,
      title: s.agencyLeaveConfirmTitle(widget.link.agency.name),
      body: s.agencyLeaveConfirmBody,
      action: s.agencyLeaveConfirmAction,
      danger: true,
    );
    if (!ok || !mounted) return;
    final okMsg = s.agencyLeftSnack;
    await _run(() => ref.read(creatorAgencyRepositoryProvider).leave(), okMessage: okMsg);
  }

  Future<void> _ask({required bool review}) async {
    final result = await showModalBottomSheet<_LeaveForm>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _LeaveSheet(review: review),
    );
    if (result == null || !mounted) return;
    final s = S.of(context);
    final ok = await showAgencyConfirm(
      context,
      icon: review ? LucideIcons.shieldAlert : LucideIcons.handshake,
      title: review ? s.agencyReviewConfirmTitle : s.agencyLeaveRequestConfirmTitle,
      body: review ? s.agencyReviewConfirmBody : s.agencyLeaveRequestConfirmBody,
      action: review ? s.agencyReviewSend : s.agencyLeaveRequestSend,
      danger: true,
    );
    if (!ok || !mounted) return;
    final okMsg = review ? s.agencyReviewSentSnack : s.agencyLeaveRequestSentSnack;
    await _run(
      () => ref.read(creatorAgencyRepositoryProvider).requestLeave(
            kind: review ? 'brawe_review' : 'early',
            reason: result.reason,
            category: result.category,
          ),
      okMessage: okMsg,
    );
  }

  Future<void> _cancel(AgencyLeaveRequest r) async {
    final okMsg = S.of(context).agencyLeaveCancelledSnack;
    await _run(() => ref.read(creatorAgencyRepositoryProvider).cancelLeaveRequest(r.id), okMessage: okMsg);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final leave = widget.link.leave;
    const spinner = SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2));
    Widget body(String t) => Text(t, style: AgencyText.caption(context).copyWith(fontSize: 13.5, height: 1.45));
    Widget full(Widget w) => SizedBox(width: double.infinity, child: w);

    // 1) Fim do contrato: saída livre.
    if (leave.isFree) {
      return AgencyBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AgencyBoxTitle(icon: LucideIcons.doorOpen, text: s.agencyLeaveTitle, color: c.danger),
          const SizedBox(height: 8),
          body(s.agencyLeaveAllowed),
          const SizedBox(height: 12),
          full(FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: c.danger, foregroundColor: Colors.white, minimumSize: const Size(48, 48)),
            onPressed: _busy ? null : _leaveFree,
            icon: _busy ? spinner : const Icon(LucideIcons.doorOpen, size: 17),
            label: Text(s.agencyLeaveButton),
          )),
        ]),
      );
    }

    // 2) Pedido em aberto (com a agência ou com a Brawe).
    final req = leave.request;
    if (leave.isPending && req != null) {
      final brawe = req.isBraweReview && req.isWithBrawe;
      final due = req.answerDueAt ??
          (req.createdAt != null && leave.answerDays != null ? req.createdAt!.add(Duration(days: leave.answerDays!)) : null);
      return AgencyBox(
        borderColor: c.warning.withValues(alpha: 0.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AgencyBoxTitle(
            icon: req.isBraweReview ? LucideIcons.shieldAlert : LucideIcons.hourglass,
            text: req.isBraweReview ? s.agencyReviewPendingTitle : s.agencyLeavePendingTitle,
            color: c.warning,
          ),
          const SizedBox(height: 8),
          if (!req.isBraweReview && !brawe) body(s.agencyLeavePendingSent(agencyDate(context, req.createdAt))),
          if (req.isBraweReview && req.createdAt != null) body(s.agencyLeaveSentOn(agencyDate(context, req.createdAt))),
          if (brawe) ...[
            const SizedBox(height: 4),
            body(s.agencyLeavePendingBrawe),
          ],
          if (!req.isBraweReview && due != null) ...[
            const SizedBox(height: 6),
            body(s.agencyLeavePendingDue(agencyDate(context, due))),
          ],
          const SizedBox(height: 12),
          full(OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: _busy ? null : () => _cancel(req),
            icon: _busy ? spinner : const Icon(LucideIcons.x, size: 17),
            label: Text(s.agencyLeaveCancel),
          )),
        ]),
      );
    }

    // 3) Antes do fim: pedir desligamento (ou aguardar o prazo após recusa).
    final declined = leave.lastDeclined;
    final blocked = leave.retryBlocked();
    return AgencyBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AgencyBoxTitle(icon: LucideIcons.doorOpen, text: s.agencyLeaveSectionTitle),
        const SizedBox(height: 8),
        if (declined != null && blocked) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(LucideIcons.circleX, size: 16, color: c.warning),
            const SizedBox(width: 8),
            Expanded(child: Text(s.agencyLeaveDeclinedTitle, style: AgencyText.title(context))),
          ]),
          const SizedBox(height: 4),
          body(s.agencyLeaveDeclinedBody),
          if (declined.answerNote != null) ...[
            const SizedBox(height: 6),
            Text('${s.agencyLeaveAgencyAnswer}: \u201c${declined.answerNote}\u201d',
                style: TextStyle(color: c.textPrimary, fontSize: 13, height: 1.4, fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 6),
          body(s.agencyLeaveRetryAt(agencyDate(context, leave.retryAt))),
        ] else
          body(leave.contractEndsAt != null
              ? s.agencyLeaveRequestBody(agencyDate(context, leave.contractEndsAt))
              : s.agencyLeaveRequestBodyNoDate),
        const SizedBox(height: 12),
        full(OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
              foregroundColor: c.danger, minimumSize: const Size(48, 48), side: BorderSide(color: blocked ? c.border : c.danger)),
          onPressed: (blocked || _busy) ? null : () => _ask(review: false),
          icon: _busy ? spinner : const Icon(LucideIcons.handshake, size: 17),
          label: Text(s.agencyLeaveRequestButton, textAlign: TextAlign.center),
        )),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: c.textSecondary, visualDensity: VisualDensity.compact, minimumSize: const Size(48, 44)),
            onPressed: (leave.reviewBlocked() || _busy) ? null : () => _ask(review: true),
            icon: const Icon(LucideIcons.shieldAlert, size: 15),
            label: Text(s.agencyReviewLink, style: const TextStyle(fontSize: 12.5)),
          ),
        ),
      ]),
    );
  }
}

class _LeaveForm {
  const _LeaveForm({required this.reason, this.category});
  final String reason;
  final String? category;
}

/// Folha para o pedido à agência (motivo obrigatório) ou para a análise da Brawe (categoria + texto).
class _LeaveSheet extends StatefulWidget {
  const _LeaveSheet({required this.review});
  final bool review;
  @override
  State<_LeaveSheet> createState() => _LeaveSheetState();
}

class _LeaveSheetState extends State<_LeaveSheet> {
  final _ctrl = TextEditingController();
  String _category = 'charging_money';

  bool get _valid => _ctrl.text.trim().length >= _minReason;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final review = widget.review;
    final cats = <(String, String)>[
      ('charging_money', s.agencyReviewCatMoney),
      ('offplatform_payment', s.agencyReviewCatOffplatform),
      ('pressure', s.agencyReviewCatPressure),
      ('agency_suspended', s.agencyReviewCatSuspended),
      ('other', s.agencyReviewCatOther),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(review ? LucideIcons.shieldAlert : LucideIcons.handshake, color: review ? c.danger : c.accentPrimary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(review ? s.agencyReviewSheetTitle : s.agencyLeaveRequestSheetTitle,
                  style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(review ? s.agencyReviewSheetBody : s.agencyLeaveRequestSheetBody,
              style: TextStyle(color: c.textSecondary, fontSize: 13.5, height: 1.45)),
          if (review) ...[
            const SizedBox(height: 14),
            Text(s.agencyReviewCategoryLabel, style: TextStyle(color: c.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            for (final cat in cats)
              Semantics(
                inMutuallyExclusiveGroup: true,
                checked: _category == cat.$1,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _category = cat.$1),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Row(children: [
                      Icon(_category == cat.$1 ? LucideIcons.circleDot : LucideIcons.circle,
                          size: 20, color: _category == cat.$1 ? c.accentPrimary : c.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(child: Text(cat.$2, style: TextStyle(color: c.textPrimary, fontSize: 14, height: 1.3))),
                    ]),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            maxLength: _maxReason,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              helperText: s.agencyReasonMinHint,
              labelText: review ? s.agencyReviewDetailLabel : s.agencyLeaveReasonLabel,
              hintText: review ? null : s.agencyLeaveReasonHint,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: Text(s.actionCancel)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: review ? FilledButton.styleFrom(backgroundColor: c.danger, foregroundColor: Colors.white) : null,
                onPressed: !_valid
                    ? null
                    : () => Navigator.of(context).pop(_LeaveForm(
                          reason: _ctrl.text.trim(),
                          category: review ? _category : null,
                        )),
                child: Text(review ? s.agencyReviewSend : s.agencyLeaveRequestSend, textAlign: TextAlign.center),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
