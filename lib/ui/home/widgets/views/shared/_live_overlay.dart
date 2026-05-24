import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../../gen/l10n/app_localizations.dart';

/// "AO VIVO • XX viewers" badge usado por todas as live views.
class LiveBadge extends StatelessWidget {
  const LiveBadge({
    super.key,
    required this.viewerCount,
    this.label,
  });
  final int viewerCount;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final resolvedLabel = label ?? S.of(context).liveBadgeLive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.mutedRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(resolvedLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              )),
          const SizedBox(width: 8),
          const Icon(Icons.visibility, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            _format(viewerCount),
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  static String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
