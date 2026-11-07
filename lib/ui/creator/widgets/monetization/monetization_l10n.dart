// Textos da Monetização: rótulos vindos do servidor (campos, métodos, status)
// e erros com código estável → frase traduzida (nunca "[object Object]").
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/creator_payout.dart';
import '../../../../gen/l10n/app_localizations.dart';

/// Formatação de números, dinheiro e datas no idioma do app.
class PayoutFmt {
  PayoutFmt(this.locale);
  final String locale;

  factory PayoutFmt.of(BuildContext context) => PayoutFmt(Localizations.localeOf(context).toLanguageTag());

  String integer(num v) => NumberFormat.decimalPattern(locale).format(v);

  String money(num v, String currency) => NumberFormat.currency(
        locale: locale,
        name: currency,
        symbol: currency == 'BRL' ? r'R$' : r'US$',
        decimalDigits: 2,
      ).format(v);

  String date(DateTime? d, {bool time = false}) {
    if (d == null) return '';
    return (time ? DateFormat.yMMMd(locale).add_Hm() : DateFormat.yMMMd(locale)).format(d);
  }

  String fx(num v) => NumberFormat('0.0000', locale).format(v);
}

String payoutFieldLabel(S s, String k) => switch (k) {
      'country' => s.payoutFieldsCountry,
      'method' => s.payoutFieldsMethod,
      'holder_name' => s.payoutFieldsHolderName,
      'holder_tax_id' => s.payoutFieldsHolderTaxId,
      'key_type' => s.payoutFieldsKeyType,
      'key' => s.payoutFieldsKey,
      'bank_code' => s.payoutFieldsBankCode,
      'branch' => s.payoutFieldsBranch,
      'account' => s.payoutFieldsAccount,
      'account_digit' => s.payoutFieldsAccountDigit,
      'iban' => s.payoutFieldsIban,
      'routing_number' => s.payoutFieldsRoutingNumber,
      'account_number' => s.payoutFieldsAccountNumber,
      'account_type' => s.payoutFieldsAccountType,
      'swift' => s.payoutFieldsSwift,
      'bank_name' => s.payoutFieldsBankName,
      'bank_address' => s.payoutFieldsBankAddress,
      'tax_regime' => s.payoutFieldsTaxRegime,
      _ => '',
    };

String payoutMethodLabel(S s, String m) => switch (m) {
      'pix' => s.payoutMethodsPix,
      'bank_br' => s.payoutMethodsBankBr,
      'iban' => s.payoutMethodsIban,
      'us_ach' => s.payoutMethodsUsAch,
      'swift' => s.payoutMethodsSwift,
      _ => m,
    };

String payoutPixKeyTypeLabel(S s, String k) => switch (k) {
      'cpf' => s.payoutPixKeyTypesCpf,
      'cnpj' => s.payoutPixKeyTypesCnpj,
      'email' => s.payoutPixKeyTypesEmail,
      'phone' => s.payoutPixKeyTypesPhone,
      'random' => s.payoutPixKeyTypesRandom,
      _ => k,
    };

String payoutKeyPlaceholder(S s, String? keyType) => switch (keyType) {
      'cpf' => s.payoutKeyPlaceholderCpf,
      'cnpj' => s.payoutKeyPlaceholderCnpj,
      'email' => s.payoutKeyPlaceholderEmail,
      'phone' => s.payoutKeyPlaceholderPhone,
      'random' => s.payoutKeyPlaceholderRandom,
      _ => s.payoutKeyPlaceholderNone,
    };

String payoutAccountTypeLabel(S s, String k) => k == 'savings' ? s.payoutAccountTypesSavings : s.payoutAccountTypesChecking;

String payoutTaxRegimeLabel(S s, String k) => k == 'normal' ? s.payoutTaxRegimesNormal : s.payoutTaxRegimesSimples;

String? payoutHolderTypeLabel(S s, String? k) => switch (k) {
      'pf' => s.payoutHolderTypesPf,
      'pj' => s.payoutHolderTypesPj,
      'pj_simples' => s.payoutHolderTypesPjSimples,
      _ => null,
    };

String payoutCountryLabel(S s, String c) => switch (c) {
      'BR' => s.payoutCountryBR,
      'US' => s.payoutCountryUS,
      'PT' => s.payoutCountryPT,
      'AR' => s.payoutCountryAR,
      'CL' => s.payoutCountryCL,
      'CO' => s.payoutCountryCO,
      'MX' => s.payoutCountryMX,
      'PE' => s.payoutCountryPE,
      'UY' => s.payoutCountryUY,
      'ES' => s.payoutCountryES,
      'OTHER' => s.payoutAccountOtherCountry,
      _ => c,
    };

String payoutStatusLabel(S s, PayoutStatus st) => switch (st) {
      PayoutStatus.requested => s.payoutStatusRequested,
      PayoutStatus.approved => s.payoutStatusApproved,
      PayoutStatus.paid => s.payoutStatusPaid,
      PayoutStatus.rejected => s.payoutStatusRejected,
      PayoutStatus.canceled => s.payoutStatusCanceled,
    };

String payoutAccountStatusLabel(S s, PayoutAccountStatus st) => switch (st) {
      PayoutAccountStatus.pendingReview => s.payoutAccountStatusPendingReview,
      PayoutAccountStatus.verified => s.payoutAccountStatusVerified,
      PayoutAccountStatus.rejected => s.payoutAccountStatusRejected,
    };

int _int(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
double _dbl(Object? v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

/// Erro → frase traduzida. [ov] dá contexto (moeda, saldo, mínimo).
String payoutErrorText(S s, PayoutFmt f, Object error, [PayoutOverview? ov]) {
  final e = error is PayoutException ? error : const PayoutException('generic');
  final x = e.extra;
  final cur = ov?.currency ?? 'BRL';
  switch (e.code) {
    case 'network':
      return s.payoutErrorsNetwork;
    case 'payouts_disabled':
      return s.payoutErrorsDisabled;
    case 'payout_account_required':
      return s.payoutErrorsAccountRequired;
    case 'payout_account_rejected':
      return s.payoutErrorsAccountRejected;
    case 'payout_in_progress':
      return s.payoutErrorsInProgress;
    case 'payout_open_limit':
      return s.payoutErrorsOpenLimit;
    case 'payout_conflict':
      return s.payoutErrorsConflict;
    case 'fx_unavailable':
      return s.payoutErrorsFxUnavailable;
    case 'net_not_positive':
      return s.payoutErrorsNetNotPositive;
    case 'invalid_amount':
      return s.payoutErrorsInvalidAmount;
    case 'below_minimum':
      final min = x['min_amount'] != null ? _dbl(x['min_amount']) : (ov?.rules.minForCurrency ?? 0);
      return s.payoutErrorsBelowMinimum(f.money(min, '${x['currency'] ?? cur}'), f.integer(_int(x['min_diamonds'])));
    case 'insufficient_balance':
      return s.payoutErrorsInsufficient(f.integer(x['available_diamonds'] != null ? _int(x['available_diamonds']) : (ov?.balance.available ?? 0)));
    case 'too_many_requests':
      return s.payoutErrorsTooMany;
    case 'email_send_failed':
      return s.payoutErrorsSendFailed;
    case 'resend_too_soon':
      return s.payoutErrorsResendTooSoon('${_int(x['retry_after'])}');
    case 'code_invalid':
      return s.payoutErrorsCodeInvalid(_int(x['attempts_left']));
    case 'code_expired':
      return s.payoutErrorsCodeExpired;
    case 'too_many_attempts':
      return s.payoutErrorsTooManyAttempts;
    case 'holder_mismatch':
      return s.payoutErrorsHolderMismatch;
    case 'invalid_method':
      return s.payoutErrorsInvalidMethod;
    case 'invalid_payout_field':
    case 'missing_payout_field':
      final label = payoutFieldLabel(s, '${x['field'] ?? ''}');
      return label.isEmpty ? s.payoutErrorsInvalidData : s.payoutErrorsInvalidField(label);
    default:
      if (e.statusCode == 429) return s.payoutErrorsTooMany;
      return s.payoutErrorsGeneric;
  }
}
