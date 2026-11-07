// Monetização do criador — saldo de diamantes e saques (/creator/payouts).
//
// Regra do produto: DIAMANTES vêm só de presentes recebidos em lives e stories
// e são o único saldo sacável. COINS são compradas e só servem para gastar no
// app — nunca aparecem aqui.

double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
int _i(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
String? _s(Object? v) => v == null ? null : '$v';
DateTime? _dt(Object? v) => v is String && v.isNotEmpty ? DateTime.tryParse(v)?.toLocal() : null;
Map<String, dynamic> _m(Object? v) => v is Map ? Map<String, dynamic>.from(v) : const {};

/// Valor em BRL e USD (ex.: total já recebido em saques).
class PayoutMoney {
  const PayoutMoney({required this.brl, required this.usd});
  final double brl;
  final double usd;
  factory PayoutMoney.fromJson(Object? j) {
    final m = _m(j);
    return PayoutMoney(brl: _d(m['BRL']), usd: _d(m['USD']));
  }
  double of(String currency) => currency == 'BRL' ? brl : usd;
}

class PayoutSource {
  const PayoutSource({required this.diamonds, required this.usd});
  final int diamonds;
  final double usd;
  factory PayoutSource.fromJson(Object? j) {
    final m = _m(j);
    return PayoutSource(diamonds: _i(m['diamonds']), usd: _d(m['usd']));
  }
}

/// Conta do saldo: recebido − aguardando liberação − em saque − sacado = disponível.
class PayoutBalance {
  const PayoutBalance({
    required this.available,
    required this.availableUsd,
    required this.holding,
    required this.inProgress,
    required this.withdrawn,
    required this.lifetime,
    required this.withdrawnNet,
    required this.holdDays,
    this.nextReleaseAt,
    this.fromLive,
    this.fromStory,
    this.fromOther,
  });

  final int available;
  final double availableUsd;
  final int holding;
  final int inProgress;
  final int withdrawn;
  final int lifetime;
  final PayoutMoney withdrawnNet;
  final int holdDays;
  final DateTime? nextReleaseAt;

  /// Origem do total recebido (null em servidor antigo).
  final PayoutSource? fromLive;
  final PayoutSource? fromStory;
  final PayoutSource? fromOther;

  factory PayoutBalance.fromJson(Object? j) {
    final m = _m(j);
    final src = _m(m['by_source']);
    PayoutSource? s(String k) => src.containsKey(k) ? PayoutSource.fromJson(src[k]) : null;
    return PayoutBalance(
      available: _i(m['available_diamonds']),
      availableUsd: _d(m['available_usd']),
      holding: _i(m['holding_diamonds']),
      inProgress: _i(m['in_progress_diamonds']),
      withdrawn: _i(m['withdrawn_diamonds']),
      lifetime: _i(m['lifetime_diamonds']),
      withdrawnNet: PayoutMoney.fromJson(m['withdrawn_net']),
      holdDays: _i(m['hold_days']),
      nextReleaseAt: _dt(m['next_release_at']),
      fromLive: s('live'),
      fromStory: s('story'),
      fromOther: s('other'),
    );
  }
}

class PayoutRules {
  const PayoutRules({
    required this.diamondUsd,
    required this.minAmount,
    required this.holdDays,
    required this.paymentDays,
    required this.currency,
    this.minDiamonds,
  });
  final double diamondUsd;
  final PayoutMoney minAmount;
  final int holdDays;
  final int paymentDays;
  final String currency;
  final int? minDiamonds;

  factory PayoutRules.fromJson(Object? j) {
    final m = _m(j);
    return PayoutRules(
      diamondUsd: _d(m['diamond_usd']),
      minAmount: PayoutMoney.fromJson(m['min_amount']),
      holdDays: _i(m['hold_days']),
      paymentDays: _i(m['payment_days']),
      currency: _s(m['currency']) ?? 'BRL',
      minDiamonds: m['min_diamonds'] == null ? null : _i(m['min_diamonds']),
    );
  }

  double get minForCurrency => minAmount.of(currency);
}

class PayoutFx {
  const PayoutFx({required this.quote, this.refDate, this.bulletin});
  final double quote;
  final String? refDate;
  final String? bulletin;
  static PayoutFx? fromJson(Object? j) {
    if (j is! Map) return null;
    final m = _m(j);
    return PayoutFx(quote: _d(m['quote']), refDate: _s(m['ref_date']), bulletin: _s(m['bulletin']));
  }
}

enum PayoutAccountStatus { pendingReview, verified, rejected }

class PayoutAccount {
  const PayoutAccount({
    required this.id,
    required this.country,
    required this.method,
    required this.holderName,
    required this.holderTaxIdMasked,
    required this.display,
    required this.status,
    this.holderType,
    this.rejectReason,
  });
  final String id;
  final String country;
  final String method;
  final String holderName;
  final String holderTaxIdMasked;
  final String display;
  final PayoutAccountStatus status;
  final String? holderType;
  final String? rejectReason;

  static PayoutAccount? fromJson(Object? j) {
    if (j is! Map) return null;
    final m = _m(j);
    return PayoutAccount(
      id: _s(m['id']) ?? '',
      country: _s(m['country']) ?? '',
      method: _s(m['method']) ?? '',
      holderName: _s(m['holder_name']) ?? '',
      holderTaxIdMasked: _s(m['holder_tax_id_masked']) ?? '',
      display: _s(m['display']) ?? '',
      holderType: _s(m['holder_type']),
      rejectReason: _s(m['reject_reason']),
      status: switch (_s(m['status'])) {
        'verified' => PayoutAccountStatus.verified,
        'rejected' => PayoutAccountStatus.rejected,
        _ => PayoutAccountStatus.pendingReview,
      },
    );
  }
}

/// Opções do formulário da conta (vêm do servidor: países, métodos e campos).
class PayoutAccountForm {
  const PayoutAccountForm({
    required this.countries,
    required this.methodsByCountry,
    required this.methodFields,
    required this.pixKeyTypes,
    required this.currencyByCountry,
    required this.taxRegimes,
  });
  final List<String> countries;
  final Map<String, List<String>> methodsByCountry;
  final Map<String, List<String>> methodFields;
  final List<String> pixKeyTypes;
  final Map<String, String> currencyByCountry;
  final List<String> taxRegimes;

  factory PayoutAccountForm.fromJson(Object? j) {
    final m = _m(j);
    List<String> list(Object? v) => v is List ? [for (final x in v) '$x'] : const [];
    Map<String, List<String>> mapList(Object? v) => {for (final e in _m(v).entries) e.key: list(e.value)};
    final regimes = list(m['tax_regimes']);
    return PayoutAccountForm(
      countries: list(m['countries']),
      methodsByCountry: mapList(m['methods_by_country']),
      methodFields: mapList(m['method_fields']),
      pixKeyTypes: list(m['pix_key_types']),
      currencyByCountry: {for (final e in _m(m['currency_by_country']).entries) e.key: '${e.value}'},
      taxRegimes: regimes.isEmpty ? const ['simples', 'normal'] : regimes,
    );
  }
}

class PayoutTax {
  const PayoutTax({required this.label, required this.amount});
  final String label;
  final double amount;
  static List<PayoutTax> listFrom(Object? v) => v is List
      ? [for (final x in v) PayoutTax(label: _s(_m(x)['label']) ?? '', amount: _d(_m(x)['amount']))]
      : const [];
}

enum PayoutStatus { requested, approved, paid, rejected, canceled }

class Payout {
  const Payout({
    required this.id,
    required this.status,
    required this.diamonds,
    required this.currency,
    required this.gross,
    required this.taxTotal,
    required this.net,
    required this.accountDisplay,
    required this.taxes,
    this.createdAt,
    this.paidAt,
    this.rejectReason,
    this.paymentReference,
  });
  final String id;
  final PayoutStatus status;
  final int diamonds;
  final String currency;
  final double gross;
  final double taxTotal;
  final double net;
  final String accountDisplay;
  final List<PayoutTax> taxes;
  final DateTime? createdAt;
  final DateTime? paidAt;
  final String? rejectReason;
  final String? paymentReference;

  bool get isOpen => status == PayoutStatus.requested || status == PayoutStatus.approved;

  factory Payout.fromJson(Object? j) {
    final m = _m(j);
    return Payout(
      id: _s(m['id']) ?? '',
      status: switch (_s(m['status'])) {
        'approved' => PayoutStatus.approved,
        'paid' => PayoutStatus.paid,
        'rejected' => PayoutStatus.rejected,
        'canceled' => PayoutStatus.canceled,
        _ => PayoutStatus.requested,
      },
      diamonds: _i(m['diamonds']),
      currency: _s(m['currency']) ?? 'BRL',
      gross: _d(m['gross']),
      taxTotal: _d(m['tax_total']),
      net: _d(m['net']),
      accountDisplay: _s(m['account_display']) ?? '',
      taxes: PayoutTax.listFrom(m['taxes']),
      createdAt: _dt(m['created_at']),
      paidAt: _dt(m['paid_at']),
      rejectReason: _s(m['reject_reason']),
      paymentReference: _s(m['payment_reference']),
    );
  }
}

class PayoutOverview {
  const PayoutOverview({
    required this.enabled,
    required this.balance,
    required this.rules,
    required this.form,
    required this.open,
    required this.history,
    this.fx,
    this.account,
  });
  final bool enabled;
  final PayoutBalance balance;
  final PayoutRules rules;
  final PayoutFx? fx;
  final PayoutAccount? account;
  final PayoutAccountForm form;
  final List<Payout> open;
  final List<Payout> history;

  String get currency => rules.currency;

  /// Valor aproximado de [diamonds] na moeda da conta (null sem cotação).
  double? approx(int diamonds) {
    final rate = currency == 'BRL' ? fx?.quote : 1.0;
    if (rate == null || rate <= 0) return null;
    return diamonds * rules.diamondUsd * rate;
  }

  factory PayoutOverview.fromJson(Map<String, dynamic> j) {
    List<Payout> payouts(Object? v) => v is List ? [for (final x in v) Payout.fromJson(x)] : const [];
    return PayoutOverview(
      enabled: j['enabled'] == true,
      balance: PayoutBalance.fromJson(j['balance']),
      rules: PayoutRules.fromJson(j['rules']),
      fx: PayoutFx.fromJson(j['fx']),
      account: PayoutAccount.fromJson(j['account']),
      form: PayoutAccountForm.fromJson(j['account_form']),
      open: payouts(j['open']),
      history: payouts(j['history']),
    );
  }
}

class PayoutQuote {
  const PayoutQuote({
    required this.diamonds,
    required this.amountUsd,
    required this.currency,
    required this.fxQuote,
    required this.gross,
    required this.taxes,
    required this.taxTotal,
    required this.net,
    this.fxRefDate,
    this.monthPriorGross = 0,
  });
  final int diamonds;
  final double amountUsd;
  final String currency;
  final double fxQuote;
  final double gross;
  final List<PayoutTax> taxes;
  final double taxTotal;
  final double net;
  final String? fxRefDate;
  final double monthPriorGross;

  factory PayoutQuote.fromJson(Object? j) {
    final m = _m(j);
    return PayoutQuote(
      diamonds: _i(m['diamonds']),
      amountUsd: _d(m['amount_usd']),
      currency: _s(m['currency']) ?? 'BRL',
      fxQuote: _d(m['fx_quote']),
      gross: _d(m['gross']),
      taxes: PayoutTax.listFrom(m['taxes']),
      taxTotal: _d(m['tax_total']),
      net: _d(m['net']),
      fxRefDate: _s(_m(m['fx'])['ref_date']),
      monthPriorGross: _d(m['month_prior_gross']),
    );
  }
}

/// Pedido aguardando o código enviado por e-mail.
class PayoutChallenge {
  const PayoutChallenge({required this.id, required this.resendIn, this.emailMasked, this.quote});
  final String id;
  final int resendIn;
  final String? emailMasked;
  final PayoutQuote? quote;
  factory PayoutChallenge.fromJson(Map<String, dynamic> j) => PayoutChallenge(
        id: _s(j['challenge_id']) ?? '',
        resendIn: _i(j['resend_in']),
        emailMasked: _s(j['email_masked']),
        quote: j['quote'] is Map ? PayoutQuote.fromJson(j['quote']) : null,
      );
}

/// Erro com o código estável do backend (a UI traduz).
class PayoutException implements Exception {
  const PayoutException(this.code, {this.extra = const {}, this.statusCode});
  final String code;
  final Map<String, dynamic> extra;
  final int? statusCode;
  @override
  String toString() => 'PayoutException($code)';
}
