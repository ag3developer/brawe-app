import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Cores de medalha (ouro, prata, bronze) por posição 1-based.
/// Posições > 3 usam um cinza neutro.
Color medalColor(int position) => switch (position) {
  1 => const Color(0xFFFFD700),
  2 => const Color(0xFFB0BEC5),
  3 => const Color(0xFFCD7F32),
  _ => const Color(0xFF8A94A6),
};

/// Pontos compactos: 950, 1.2K, 3.4M.
String compactPoints(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return '$v';
}

/// Moeda do app (mesmo asset dos preços dos presentes).
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 14});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/brawe_coin.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          Icon(LucideIcons.coins, size: size, color: const Color(0xFFFFD166)),
    );
  }
}

/// Número com separador de milhar: 1250 → 1.250.
String fmtGap(int v) {
  final t = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < t.length; i++) {
    if (i > 0 && (t.length - i) % 3 == 0) b.write('.');
    b.write(t[i]);
  }
  return b.toString();
}
