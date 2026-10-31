// Helpers para decodificar imagens de rede no tamanho exibido.
// Decodifica no tamanho exibido — evita foto de 48 MB na memória.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

extension ImageDecodeContext on BuildContext {
  /// Pixels físicos para um tamanho lógico (usa o devicePixelRatio).
  int decodePx(double logical) =>
      (logical * MediaQuery.devicePixelRatioOf(this)).round();

  /// Largura da tela em pixels físicos, limitada a 1440.
  int get decodeScreenPx => math.min(1440, decodePx(MediaQuery.sizeOf(this).width));

  /// Fração da largura da tela (ex.: 1/3 para grid de 3 colunas), em px.
  int decodeScreenFracPx(double fraction) =>
      math.max(1, (decodeScreenPx * fraction).round());
}
