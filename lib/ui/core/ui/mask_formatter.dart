// Máscara de digitação para documentos e números: a pessoa digita só os números e a pontuação aparece sozinha.
// "0" no padrão = um dígito; o resto é fixo. Ex.: CNPJ "00.000.000/0000-00", CEP "00000-000".

import 'package:flutter/services.dart';

class DigitMask extends TextInputFormatter {
  DigitMask(this.pattern) : maxDigits = '0'.allMatches(pattern).length;

  final String pattern;
  final int maxDigits;

  static final cpf = DigitMask('000.000.000-00');
  static final cnpj = DigitMask('00.000.000/0000-00');
  static final cep = DigitMask('00000-000');
  static final phoneBr = DigitMask('(00) 00000-0000');

  /// Só os números do texto.
  static String digits(String s) => s.replaceAll(RegExp(r'\D'), '');

  /// Aplica a máscara num texto pronto (ex.: valor vindo do servidor).
  String apply(String raw) {
    final d = digits(raw);
    final out = StringBuffer();
    var i = 0;
    for (final ch in pattern.split('')) {
      if (i >= d.length) break;
      if (ch == '0') {
        out.write(d[i++]);
      } else {
        out.write(ch);
      }
    }
    return out.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var d = digits(newValue.text);
    // apagou um separador: apaga o número antes dele
    if (newValue.text.length < oldValue.text.length &&
        d == digits(oldValue.text) &&
        d.isNotEmpty) {
      d = d.substring(0, d.length - 1);
    }
    if (d.length > maxDigits) d = d.substring(0, maxDigits);
    final text = apply(d);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
