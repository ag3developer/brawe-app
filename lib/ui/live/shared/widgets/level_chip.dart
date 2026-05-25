import 'package:flutter/material.dart';

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
    final fontSize = (height * 0.6).clamp(10.0, 14.0);

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.35),
        gradient: LinearGradient(
          colors: [base, base.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.45),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lado esquerdo: imagem PNG OU emoji de fallback
          _BadgeIcon(
            imageUrl: imageUrl,
            emoji: badge ?? '💎',
            size: height - 4,
          ),
          const SizedBox(width: 3),
          // Lado direito: número do nível
          Text(
            '$level',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: fontSize,
              decoration: TextDecoration.none,
              shadows: const [
                Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1)),
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
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => _emojiFallback(),
              loadingBuilder: (ctx, child, progress) =>
                  progress == null ? child : _emojiFallback(),
            ),
    );
  }

  Widget _emojiFallback() => FittedBox(
        fit: BoxFit.contain,
        child: Text(
          emoji,
          style: const TextStyle(decoration: TextDecoration.none),
        ),
      );
}
