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
  /// Top 3 compacto, na altura dos outros botões do topo: avatares de 22px
  /// sobrepostos, só o anel da medalha (o #1 por cima). Os pontos ficam na
  /// gaveta do ranking — aqui não cabem sem estourar o topo.
  Widget _buildGifters(BuildContext context) {
    final top = topGifters.take(3).toList();
    const size = 22.0;
    const step = 14.0; // sobreposição
    // Desenha do 3º para o 1º: o #1 fica por cima.
    final order = [for (var i = top.length - 1; i >= 0; i--) top[i].userId];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
        ),
        child: SizedBox(
          width: size + step * (top.length - 1),
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final id in order)
                AnimatedPositioned(
                  key: ValueKey(id),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  left: top.indexWhere((e) => e.userId == id) * step,
                  top: 0,
                  child: _GifterBadge(
                    entry: top.firstWhere((e) => e.userId == id),
                    position: top.indexWhere((e) => e.userId == id) + 1,
                    size: size,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GifterBadge extends StatelessWidget {
  const _GifterBadge({required this.entry, required this.position, required this.size});

  final GifterEntry entry;
  final int position;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = medalColor(position);
    final url = entry.avatarUrl;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1D2B),
        border: Border.all(color: color, width: 1.5),
      ),
      child: ClipOval(
        child: url != null
            ? Image.network(
                url,
                cacheWidth: context.decodePx(size),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _Initial(name: entry.name, color: color),
              )
            : _Initial(name: entry.name, color: color),
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
      style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w800),
    ),
  );
}
