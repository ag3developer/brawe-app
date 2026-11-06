import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/creator_agency.dart';
import '../../../../gen/l10n/app_localizations.dart';

String agencyLang(BuildContext context) => Localizations.localeOf(context).languageCode;

String agencyDate(BuildContext context, DateTime? d) =>
    d == null ? '—' : DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(d);

String agencyDateShort(BuildContext context, DateTime? d) =>
    d == null ? '—' : DateFormat.MMMd(Localizations.localeOf(context).toString()).format(d);

String agencyNumber(BuildContext context, num n) =>
    NumberFormat.decimalPattern(Localizations.localeOf(context).toString()).format(n);

String agencyHoursText(BuildContext context, double h) =>
    NumberFormat('#,##0.#', Localizations.localeOf(context).toString()).format(h);

String agencyMonthsText(S s, int? months) => months == null ? '—' : s.agencyContractMonths(months);

String agencyRoleLabel(S s, AgencyInviter? who) {
  switch (who?.role) {
    case 'owner':
      return s.agencyRoleOwner;
    case 'manager':
      return s.agencyRoleManager;
    case 'analyst':
      return s.agencyRoleAnalyst;
    default:
      return who?.isOwner == true ? s.agencyRoleOwner : s.agencyRoleUnknown;
  }
}

/// Mensagem localizada para os códigos 409/422/404 do Partners.
String agencyErrorText(BuildContext context, Object error) {
  final s = S.of(context);
  final e = error is AgencyException ? error : const AgencyException('unknown');
  switch (e.code) {
    case 'terms_version_mismatch':
      return s.agencyErrTermsMismatch;
    case 'cannot_leave_yet':
      return e.canLeaveAt == null
          ? s.agencyErrCannotLeaveYetNoDate
          : s.agencyErrCannotLeaveYet(agencyDate(context, e.canLeaveAt));
    case 'leave_requires_agreement':
      return s.agencyErrLeaveRequiresAgreement;
    case 'leave_is_free':
      return s.agencyErrLeaveIsFree;
    case 'leave_request_open':
      return s.agencyErrLeaveRequestOpen;
    case 'leave_request_cooldown':
      return e.retryAt == null ? s.agencyErrLeaveCooldownNoDate : s.agencyErrLeaveCooldown(agencyDate(context, e.retryAt));
    case 'leave_request_not_open':
    case 'leave_request_not_found':
      return s.agencyErrLeaveNotOpen;
    case 'reason_required':
      return s.agencyErrReasonRequired;
    case 'reason_too_short':
      return s.agencyErrReasonTooShort;
    case 'reason_too_long':
      return s.agencyErrReasonTooLong;
    case 'invite_not_pending':
      return s.agencyInviteUnavailable;
    case 'creator_already_in_agency':
      return s.agencyErrAlreadyInAgency;
    case 'agency_not_approved':
      return s.agencyErrNotApproved;
    case 'creator_not_eligible':
      return s.agencyErrNotEligible;
    case 'invite_not_found':
    case 'not_found':
      return s.agencyErrNotFound;
    case 'not_in_agency':
      return s.agencyErrNotInAgency;
    case 'network':
      return s.agencyErrNetwork;
    default:
      return s.agencyErrGeneric;
  }
}

/// "novembro de 2026" / "November 2026".
String agencyMonthName(BuildContext context, DateTime d) =>
    toBeginningOfSentenceCase(DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(d)) ?? '';

/// "nov. 2026" / "Nov 2026".
String agencyMonthYear(BuildContext context, DateTime? d) =>
    d == null ? '—' : DateFormat.yMMM(Localizations.localeOf(context).toString()).format(d);

/// "nov." / "Nov".
String agencyMonthAbbr(BuildContext context, DateTime d) =>
    DateFormat.MMM(Localizations.localeOf(context).toString()).format(d);

/// "nov. 26" para o eixo do gráfico (só o mês, curto).
String agencyMonthAxis(BuildContext context, DateTime d) =>
    DateFormat.MMM(Localizations.localeOf(context).toString()).format(d).replaceAll('.', '');

/// Texto do filtro de período: "Este mês" ou o nome do mês.
String agencyPeriodText(BuildContext context, S s, String month, String currentMonth) {
  if (month == currentMonth) return s.agencyPeriodThisMonth;
  final p = month.split('-');
  final d = DateTime(int.tryParse(p[0]) ?? 1970, p.length > 1 ? (int.tryParse(p[1]) ?? 1) : 1);
  return agencyMonthName(context, d);
}

/// Formata um número de forma compacta (12,3 mil).
String agencyCompact(BuildContext context, num n) =>
    NumberFormat.compact(locale: Localizations.localeOf(context).toString()).format(n);
