import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';

/// Horizontal advantage bar showing the score split between A and B.
///
/// Use [compact: true] for the streamer HUD (8dp height) and
/// [compact: false] for the full viewer experience (20dp height).
class BattleScoreBar extends StatelessWidget {
  const BattleScoreBar({
    super.key,
    required this.progressA,
    required this.scoreA,
    required this.scoreB,
    this.nameA = '',
    this.nameB = '',
    this.compact = false,
    this.animated = true,
  });

  final double progressA;
  final double scoreA;
  final double scoreB;
  final String nameA;
  final String nameB;
  final bool compact;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 8.0 : 20.0;
    final labelStyle = TextStyle(
      color: Colors.white,
      fontSize: compact ? 11 : 13,
      fontWeight: FontWeight.w700,
      shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatScore(scoreA), style: labelStyle),
                Text(_formatScore(scoreB), style: labelStyle),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: progressA.clamp(0.0, 1.0)),
              duration: animated
                  ? const Duration(milliseconds: 600)
                  : Duration.zero,
              curve: Curves.easeOutCubic,
              builder: (_, value, _) {
                return Stack(
                  children: [
                    // B side (right, pink)
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.hotPink, AppColors.brandPink],
                        ),
                      ),
                    ),
                    // A side (left, purple)
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.braweBlue,
                              AppColors.braweBlueLight,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Center divider line
                    Center(
                      child: Container(
                        width: 2,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    // VS badge
                    if (!compact)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'VS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        if (!compact)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nameA,
                  style: labelStyle.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  nameB,
                  style: labelStyle.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatScore(double score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toStringAsFixed(0);
  }
}
