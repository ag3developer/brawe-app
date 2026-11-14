// ============================================================================
// PIX LOGO — símbolo oficial do Pix (Banco Central)
// ============================================================================
// Usado em todo lugar em que o Pix aparece como meio de pagamento ou de
// recebimento. Regras do Manual de Uso da Marca Pix (BCB, v1.6):
//  • tamanho mínimo do símbolo em telas: 24 px de largura;
//  • cores: verde Pix (padrão), preto, ou branco em fundo escuro — em botões
//    e ícones de app, também a cor principal da interface;
//  • sem gradiente, sombra, contorno ou distorção;
//  • em textos, a grafia é "Pix" (não "PIX").
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PixLogo extends StatelessWidget {
  /// Lado do símbolo em pixels lógicos (o manual pede no mínimo 24).
  final double size;

  /// Cor única do símbolo. `null` = verde Pix oficial.
  final Color? color;

  const PixLogo({super.key, this.size = 24, this.color});

  static const asset = 'assets/images/pix.svg';
  static const green = Color(0xFF32BCAD);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      semanticsLabel: 'Pix',
      colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
