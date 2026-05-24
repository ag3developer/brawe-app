import 'package:flutter/material.dart';

/// Stack horizontal de até 3 avatares + bucket de contador (ex.: "350+").
///
/// Hoje mostra placeholders coloridos enquanto não temos a lista real de
/// viewers no estado. Plugar avatares reais quando disponível.
class ViewersStack extends StatelessWidget {
  const ViewersStack({
    super.key,
    required this.viewerCount,
    this.placeholderColors = const [
      Color(0xFFFF9F43),
      Color(0xFF9C88FF),
      Color(0xFF4DD0E1),
    ],
    this.borderColor = const Color(0xFF0A0B14),
  });

  final int viewerCount;
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
    return Container(
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
            width: 46,
            height: 22,
            child: Stack(
              children: [
                for (var i = 0; i < placeholderColors.length; i++)
                  Positioned(
                    left: i * 12.0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: placeholderColors[i],
                        border: Border.all(
                          color: borderColor,
                          width: 1.5,
                        ),
                      ),
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
    );
  }
}
