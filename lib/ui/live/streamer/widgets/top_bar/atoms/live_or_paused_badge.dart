import 'package:flutter/material.dart';

import '../../../../../../gen/l10n/app_localizations.dart';
import '../../../../../core/themes/app_colors.dart';

/// Red "LIVE" / orange "PAUSED" badge shown on the streamer top bar.
class LiveOrPausedBadge extends StatelessWidget {
  const LiveOrPausedBadge({
    super.key,
    required this.isStreaming,
    required this.isPaused,
  });

  final bool isStreaming;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final showPaused = isPaused;
    final showLive = isStreaming && !isPaused;

    if (!showPaused && !showLive) {
      return const SizedBox.shrink();
    }

    final s = S.of(context);
    final color = showPaused ? Colors.orange : AppColors.liveRed;
    final label = showPaused ? s.broadcasterBadgePaused : s.broadcasterBadgeLive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
