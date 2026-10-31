import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';
import '../../../../live_feed/view_models/live_room_comments_view_model.dart';
import '../competition/medal_colors.dart';

/// Entrada do ranking no topo da live: os 3 maiores presenteadores (anel
/// ouro/prata/bronze + pontos). Sem ninguém no ranking, só um troféu.
class ViewersStack extends StatelessWidget {
  const ViewersStack({
    super.key,
    required this.viewerCount,
    this.avatarUrls = const [],
    this.topGifters = const [],
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

  /// Top 3 presenteadores da live (ordenado). Quando não vazio, substitui os
  /// avatares de viewers por avatar com anel de medalha + pontos compactos.
  final List<GifterEntry> topGifters;
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
    if (topGifters.isNotEmpty) return _buildGifters(context);
    // Ninguém presenteou ainda: nada de lugares "ocupados" de mentira —
    // só o troféu, discreto, que abre o ranking.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
        ),
        child: Icon(LucideIcons.trophy, size: 15, color: Colors.white.withValues(alpha: 0.85)),
      ),
    );
  }
}

extension on ViewersStack {
  Widget _buildGifters(BuildContext context) {
    final top = topGifters.take(3).toList();
    const slot = 31.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 3, 9, 6),
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
            // Stack por userId: AnimatedPositioned anima a troca de posição.
            SizedBox(
              width: slot * top.length,
              height: 34,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final id in ([...top.map((e) => e.userId)]..sort()))
                    AnimatedPositioned(
                      key: ValueKey(id),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      left:
                          top.indexWhere((e) => e.userId == id) * slot,
                      top: 0,
                      child: _GifterBadge(
                        entry: top.firstWhere((e) => e.userId == id),
                        position:
                            top.indexWhere((e) => e.userId == id) + 1,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                ViewersStack.formatBucket(viewerCount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GifterBadge extends StatelessWidget {
  const _GifterBadge({required this.entry, required this.position});

  final GifterEntry entry;
  final int position;

  @override
  Widget build(BuildContext context) {
    final color = medalColor(position);
    final url = entry.avatarUrl;
    return SizedBox(
      width: 28,
      height: 34,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.25),
              border: Border.all(color: color, width: 1.8),
            ),
            child: ClipOval(
              child: url != null
                  ? Image.network(
                      url,
                      cacheWidth: context.decodePx(26),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _Initial(
                        name: entry.name,
                        color: color,
                      ),
                    )
                  : _Initial(name: entry.name, color: color),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                compactPoints(entry.totalValue),
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 8,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
    ),
  );
}
