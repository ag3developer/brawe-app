import 'package:intl/intl.dart';

/// Formats a numeric value as Brazilian Real currency, e.g. `R$ 1.234,56`.
String formatBRL(double value) {
  final formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  return formatter.format(value);
}
