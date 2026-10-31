import 'package:flutter/material.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// 🎖️ Chip de nível estilo TikTok — exibido ao lado do nome do usuário
/// no chat da live e nos toasts de gift.
///
/// Renderização em camadas (fallback automático):
///   1. Se [imageUrl] estiver presente e carregar → usa PNG do pin (256×256)
///   2. Se não → fundo gradient na cor do tier + emoji do badge + número Lv
///
/// Sempre mostra o número do nível à direita (mesmo com imagem),
/// pra reforçar a leitura rápida no chat (TikTok-style).
class LevelChip extends StatelessWidget {
  const LevelChip({
    super.key,
    required this.level,
    this.badge,
    this.colorHex,
    this.imageUrl,
    this.height = 18,
  });

  final int level;
  final String? badge; // emoji fallback (⭐, 🔥, 👑, 💎)
  final String? colorHex; // ex: "#FFD700"
  final String? imageUrl; // PNG remoto opcional (CDN ou /static)
  final double height;

  static Color _parseHex(String? hex) {
    if (hex == null) return const Color(0xFF4D90FF);
    final cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length != 6) return const Color(0xFF4D90FF);
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final base = _parseHex(colorHex);
    // 🎨 Tipografia mais discreta e proporcional — antes chegava a 14px
    // num chip de 18px de altura, brigando visualmente com o nome do
    // remetente (13px) e chamando mais atenção do que deveria num
    // elemento secundário. Agora escala mais devagar e tem piso/teto
    // menores, mantendo legibilidade sem "gritar".
    final fontSize = (height * 0.5).clamp(8.5, 11.5);
    final iconSize = (height * 0.62).clamp(8.0, 13.0);
    final radius = height / 2; // pill perfeito, mais premium que squircle

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        // 🥇 Gradiente metálico com 3 stops (em vez de 2 chapados) — dá
        // sensação de "pin" físico/premium ao invés de chip flat saturado.
        gradient: LinearGradient(
          colors: [
            Color.lerp(base, Colors.white, 0.18)!,
            base,
            Color.lerp(base, Colors.black, 0.22)!,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Borda "glass" sutil — separa o chip do fundo escuro do toast
        // sem precisar de saturação/tamanho extra pra se destacar.
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lado esquerdo: imagem PNG OU emoji de fallback
          _BadgeIcon(imageUrl: imageUrl, emoji: badge ?? '💎', size: iconSize),
          SizedBox(width: height * 0.12),
          // Lado direito: número do nível
          Text(
            '$level',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
              letterSpacing: -0.1,
              decoration: TextDecoration.none,
              shadows: const [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 1.5,
                  offset: Offset(0, 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.emoji, required this.size, this.imageUrl});
  final String emoji;
  final double size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: imageUrl == null || imageUrl!.trim().isEmpty
          ? _emojiFallback()
          : Image.network(
            cacheWidth: context.decodePx(size),
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => _emojiFallback(),
              loadingBuilder: (ctx, child, progress) =>
                  progress == null ? child : _emojiFallback(),
            ),
    );
  }

  Widget _emojiFallback() => FittedBox(
    fit: BoxFit.contain,
    child: Text(emoji, style: const TextStyle(decoration: TextDecoration.none)),
  );
}
