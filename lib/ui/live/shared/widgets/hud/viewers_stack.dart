import 'package:flutter/material.dart';

/// Stack horizontal de até 3 avatares de viewers + bucket de contador.
///
/// Quando [avatarUrls] está disponível (vem do socket `viewer_joined`),
/// mostra fotos reais. Enquanto a lista está vazia (antes do 1º evento),
/// usa placeholders coloridos — sem flash visual na troca.
class ViewersStack extends StatelessWidget {
  const ViewersStack({
    super.key,
    required this.viewerCount,
    this.avatarUrls = const [],
    this.onTap,
    this.placeholderColors = const [
      Color(0xFFFF9F43),
      Color(0xFF9C88FF),
      Color(0xFF4DD0E1),
    ],
    this.borderColor = const Color(0xFF0A0B14),
  });

  final int viewerCount;
  /// Avatares reais (URL) dos viewers mais recentes. Máx. 3. Quando vazio,
  /// usa [placeholderColors] como fallback.
  final List<String> avatarUrls;
  /// Callback ao tocar — abre o ranking de presenteadores.
  final VoidCallback? onTap;
  final List<Color> placeholderColors;
  final Color borderColor;

  /// Bucket de viewers (TikTok-style): 0, 50+, 100+, 1.2K, etc.
  static String formatBucket(int n) {
    if (n <= 0) return '0';
    if (n < 50) return '$n';
    if (n < 100) return '50+';
    if (n < 500) return '${(n ~/ 100) * 100}+';
    if (n < 1000) return '500+';
    if (n < 10000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '${(n / 1000).round()}K+';
  }

  @override
  Widget build(BuildContext context) {
    // Decide quantos círculos mostrar (máx 3).
    final count = avatarUrls.isNotEmpty
        ? avatarUrls.length.clamp(1, 3)
        : placeholderColors.length.clamp(1, 3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 3, 10, 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12.0 * (count - 1) + 22,
            height: 22,
            child: Stack(
              children: [
                for (var i = 0; i < count; i++)
                  Positioned(
                    left: i * 12.0,
                    child: _AvatarCircle(
                      url: avatarUrls.isNotEmpty ? avatarUrls[i] : null,
                      fallbackColor: placeholderColors[i % placeholderColors.length],
                      borderColor: borderColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            formatBucket(viewerCount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      ),  // Container
    );   // GestureDetector
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.url,
    required this.fallbackColor,
    required this.borderColor,
  });

  final String? url;
  final Color fallbackColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fallbackColor,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: url != null
          ? ClipOval(
              child: Image.network(
                url!,
                width: 22,
                height: 22,
                fit: BoxFit.cover,
                // Se a imagem falhar (URL inválida, sem rede), mantém o
                // placeholder colorido — sem quebrar a UI.
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            )
          : null,
    );
  }
}
