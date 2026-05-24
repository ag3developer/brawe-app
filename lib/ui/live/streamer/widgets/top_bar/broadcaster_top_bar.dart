import 'package:flutter/material.dart';

import 'atoms/atoms.dart';

/// Top HUD bar for the broadcaster screen: close button, LIVE/PAUSED badge,
/// inline stats (viewers, gifts, likes, messages, elapsed) and camera flip.
class BroadcasterTopBar extends StatelessWidget {
  const BroadcasterTopBar({
    super.key,
    required this.isStreaming,
    required this.isPaused,
    required this.viewerCount,
    required this.likes,
    required this.messages,
    required this.totalGiftsValue,
    required this.elapsedLabel,
    required this.countFormatter,
    required this.onClose,
    required this.onSwitchCamera,
  });

  final bool isStreaming;
  final bool isPaused;
  final int viewerCount;
  final int likes;
  final int messages;
  final double totalGiftsValue;
  final String elapsedLabel;
  final String Function(int) countFormatter;
  final VoidCallback onClose;
  final VoidCallback? onSwitchCamera;

  String _formatGiftValue(double v) {
    if (v <= 0) return '0';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    if (v >= 10) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final showStats = isStreaming || isPaused;
    return Row(
      children: [
        CircleIconButton(icon: Icons.close, onTap: onClose),
        const SizedBox(width: 8),
        LiveOrPausedBadge(isStreaming: isStreaming, isPaused: isPaused),
        const SizedBox(width: 8),
        if (showStats)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  InlineStat(icon: Icons.visibility, label: countFormatter(viewerCount)),
                  const SizedBox(width: 6),
                  InlineStat(
                    icon: Icons.diamond_outlined,
                    label: _formatGiftValue(totalGiftsValue),
                    iconColor: const Color(0xFF7DD3FC),
                  ),
                  const SizedBox(width: 6),
                  InlineStat(icon: Icons.favorite, label: countFormatter(likes), iconColor: Colors.redAccent),
                  const SizedBox(width: 6),
                  InlineStat(icon: Icons.chat_bubble_outline, label: countFormatter(messages)),
                  const SizedBox(width: 6),
                  InlineStat(icon: Icons.timer_outlined, label: elapsedLabel),
                ],
              ),
            ),
          )
        else
          const Spacer(),
        const SizedBox(width: 6),
        if (onSwitchCamera != null)
          CircleIconButton(icon: Icons.flip_camera_ios_outlined, onTap: onSwitchCamera!),
      ],
    );
  }
}
