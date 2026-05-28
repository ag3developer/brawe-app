import 'package:flutter/material.dart';

import '../../../domain/models/creator_network.dart';
import '../../core/themes/brawe_colors.dart';

class CreatorStatusChip extends StatelessWidget {
  const CreatorStatusChip({
    super.key,
    required this.status,
    required this.label,
    this.dense = false,
  });

  final ApplicationStatus status;
  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = status.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 12,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: dense ? 12 : 14, color: c),
          SizedBox(width: dense ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              color: c,
              fontWeight: FontWeight.w700,
              fontSize: dense ? 11 : 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Versão neutra (cinza) para o caso "sem inscrição".
class CreatorNeutralChip extends StatelessWidget {
  const CreatorNeutralChip({super.key, required this.label, this.icon});
  final String label;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.colors.surfaceHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: context.colors.textSecondary),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              )),
        ],
      ),
    );
  }
}
