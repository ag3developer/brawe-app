import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Formatação de números, moeda e datas no idioma do app.
// O valor monetário é sempre exibido em USD (nunca "USDT").
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsFmt {
  final String locale;
  AnalyticsFmt._(this.locale);

  factory AnalyticsFmt.of(BuildContext context) =>
      AnalyticsFmt._(Localizations.localeOf(context).toLanguageTag());

  /// 6.658 / 6,658
  String integer(num v) => NumberFormat.decimalPattern(locale).format(v.round());

  /// 1,2 mil / 1.2K / 3,4 mi
  String compact(num v) {
    if (v.abs() < 1000) return integer(v);
    return NumberFormat.compact(locale: locale).format(v);
  }

  /// US$ 4.900,00
  String money(num v) => NumberFormat.currency(
    locale: locale,
    name: 'USD',
    symbol: r'US$',
    decimalDigits: 2,
  ).format(v);

  /// Moeda compacta para KPIs grandes: US$ 1,2 mil.
  String moneyCompact(num v) {
    if (v.abs() < 10000) return money(v);
    return 'US\$ ${NumberFormat.compact(locale: locale).format(v)}';
  }

  /// Eixo: 1,2 mil (sem símbolo).
  String axis(num v) {
    if (v.abs() >= 1000) return NumberFormat.compact(locale: locale).format(v);
    if (v == v.roundToDouble()) return integer(v);
    return NumberFormat.decimalPattern(locale).format(double.parse(v.toStringAsFixed(1)));
  }

  /// 12,5%
  String percent(num v) => '${NumberFormat('0.#', locale).format(v.abs())}%';

  /// 3 nov. / Nov 3
  String dayShort(DateTime d) => DateFormat.MMMd(locale).format(d);

  /// 3 de novembro de 2026
  String dayLong(DateTime d) => DateFormat.yMMMd(locale).format(d);

  /// 3 nov. 2026
  String dayYear(DateTime d) => DateFormat.yMMMd(locale).format(d);

  /// Minutos -> "2h 05min" via [hm]/[m] já traduzidos pelo chamador.
  static (int, int) hoursMinutes(num minutes) {
    final t = minutes.round();
    return (t ~/ 60, t % 60);
  }
}
