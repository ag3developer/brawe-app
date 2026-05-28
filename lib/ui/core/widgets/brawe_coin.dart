// ============================================================================
// BRAWE COIN — Widget reutilizável da moeda dourada
// ============================================================================
// Renderiza o ícone oficial da Brawe Coin (asset PNG) com sombra suave
// dourada opcional, mantendo consistência visual em toda a Wallet,
// vitrines de gifts e telas de saldo.
// ============================================================================

import 'package:flutter/material.dart';

class BraweCoin extends StatelessWidget {
  /// Tamanho do lado da moeda em pixels lógicos.
  final double size;

  /// Quando `true`, adiciona uma sombra dourada que destaca a moeda
  /// (recomendado em fundos claros/coloridos da Wallet).
  final bool glow;

  const BraweCoin({
    super.key,
    this.size = 24,
    this.glow = false,
  });

  static const _asset = 'assets/images/brawe_coin.png';

  @override
  Widget build(BuildContext context) {
    final coin = Image.asset(
      _asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );

    if (!glow) return coin;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD24A).withValues(alpha: 0.45),
            blurRadius: size * 0.45,
            spreadRadius: 0,
          ),
        ],
      ),
      child: coin,
    );
  }
}
