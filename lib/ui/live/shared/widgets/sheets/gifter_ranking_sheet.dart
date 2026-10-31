import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/themes/force_dark_theme.dart';
import '../../../../../ui/live_feed/view_models/live_room_comments_view_model.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// 🏆 Bottom sheet com ranking de presenteadores da live atual.
///
/// Abre ao tocar no stack de avatares no top bar.
/// O ranking é acumulado em tempo real via socket (`gift_received`)
/// — sem chamada de API.
class GifterRankingSheet extends StatelessWidget {
  const GifterRankingSheet._({required this.ranking});

  final List<GifterEntry> ranking;

  /// Abre o sheet. Passa a lista já ordenada (vem do state).
  static Future<void> show(
    BuildContext context, {
    required List<GifterEntry> ranking,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      isScrollControlled: true,
      builder: (_) =>
          ForceDarkTheme(child: GifterRankingSheet._(ranking: ranking)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top3 = ranking.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Handle ──
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // ── Título ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        const Text(
                          '🏆',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Top Presenteadores',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Desta live',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Top 3 ou estado vazio ──
                  if (top3.isEmpty)
                    _EmptyState()
                  else
                    for (var i = 0; i < top3.length; i++) ...[
                      _RankRow(
                        position: i + 1,
                        entry: top3[i],
                      ),
                      if (i < top3.length - 1)
                        Divider(
                          height: 1,
                          indent: 72,
                          endIndent: 20,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                    ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Linha de ranking ──────────────────────────────────────────────────────

class _RankRow extends StatelessWidget {
  const _RankRow({required this.position, required this.entry});

  final int position;
  final GifterEntry entry;

  /// Medalha + cor por posição (TikTok-style).
  static const _medals = ['🥇', '🥈', '🥉'];
  static const _medalColors = [
    Color(0xFFFFD700), // ouro
    Color(0xFFB0BEC5), // prata
    Color(0xFFCD7F32), // bronze
  ];

  String _fmtValue(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M 💎';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K 💎';
    return '$v 💎';
  }

  @override
  Widget build(BuildContext context) {
    final color = _medalColors[position - 1];
    final medal = _medals[position - 1];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // ── Posição ──
          SizedBox(
            width: 28,
            child: Text(
              medal,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 12),

          // ── Avatar ──
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: ClipOval(
              child: entry.avatarUrl != null
                  ? Image.network(
                    cacheWidth: context.decodePx(44),
                      entry.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _AvatarFallback(
                        name: entry.name,
                        color: color,
                      ),
                    )
                  : _AvatarFallback(name: entry.name, color: color),
            ),
          ),
          const SizedBox(width: 12),

          // ── Nome + contagem ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.giftCount} presente${entry.giftCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.50),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // ── Total de coins ──
          Text(
            _fmtValue(entry.totalValue),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fallback de avatar (inicial do nome) ─────────────────────────────────

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: color.withValues(alpha: 0.20),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}

// ─── Estado vazio ─────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        children: [
          Text(
            '🎁',
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum presente ainda',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Seja o primeiro a presentear!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.50),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
