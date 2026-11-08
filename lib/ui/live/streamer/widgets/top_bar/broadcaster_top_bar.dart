import 'package:flutter/material.dart';

import 'atoms/atoms.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  /// Valor recebido em presentes — é USD (USDT), não "diamantes".
  String _formatGiftValue(double v) {
    if (v <= 0) return '\$0';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}K';
    if (v >= 10) return '\$${v.toStringAsFixed(0)}';
    return '\$${v.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final showStats = isStreaming || isPaused;
    return Row(
      children: [
        CircleIconButton(icon: LucideIcons.x, onTap: onClose),
        const SizedBox(width: 8),
        LiveOrPausedBadge(isStreaming: isStreaming, isPaused: isPaused),
        // Cronômetro FIXO ao lado do selo — antes era o último item de uma
        // linha rolável e aparecia cortado ("26:…") sem indicação de scroll.
        if (showStats) ...[
          const SizedBox(width: 6),
          InlineStat(icon: LucideIcons.timer, label: elapsedLabel),
        ],
        const SizedBox(width: 6),
        if (showStats)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  InlineStat(
                    icon: LucideIcons.eye,
                    label: countFormatter(viewerCount),
                  ),
                  const SizedBox(width: 6),
                  InlineStat(
                    icon: LucideIcons.gift,
                    label: _formatGiftValue(totalGiftsValue),
                    iconColor: const Color(0xFF4ADE80),
                  ),
                  const SizedBox(width: 6),
                  InlineStat(
                    icon: LucideIcons.heart,
                    label: countFormatter(likes),
                    iconColor: Colors.redAccent,
                  ),
                  const SizedBox(width: 6),
                  InlineStat(
                    icon: LucideIcons.messageCircle,
                    label: countFormatter(messages),
                  ),
                ],
              ),
            ),
          )
        else
          const Spacer(),
        const SizedBox(width: 6),
        if (onSwitchCamera != null)
          CircleIconButton(
            icon: LucideIcons.switchCamera,
            onTap: onSwitchCamera!,
          ),
      ],
    );
  }
}
