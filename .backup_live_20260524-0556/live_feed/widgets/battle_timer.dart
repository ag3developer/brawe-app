import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';

/// Battle countdown timer widget.
///
/// Shows MM:SS. Pulses red when ≤ 30 seconds remain.
/// Use [compact: true] for streamer HUD (smaller font).
class BattleTimer extends StatelessWidget {
  const BattleTimer({
    super.key,
    required this.timeRemaining,
    this.compact = false,
  });

  final Duration timeRemaining;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isUrgent = timeRemaining.inSeconds <= 30 && timeRemaining > Duration.zero;
    final isZero = timeRemaining == Duration.zero;

    final minutes = timeRemaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = timeRemaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    final label = '$minutes:$seconds';

    final fontSize = compact ? 13.0 : 18.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: isZero
            ? Colors.grey.withValues(alpha: 0.7)
            : isUrgent
                ? AppColors.mutedRed.withValues(alpha: 0.85)
                : Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent
              ? AppColors.mutedRed
              : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: compact ? 12 : 15,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
