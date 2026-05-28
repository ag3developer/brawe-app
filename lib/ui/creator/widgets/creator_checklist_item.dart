import 'package:flutter/material.dart';

import '../../core/themes/brawe_colors.dart';

class CreatorChecklistItem extends StatelessWidget {
  const CreatorChecklistItem({
    super.key,
    required this.title,
    required this.description,
    required this.completed,
    this.onTap,
  });

  final String title;
  final String description;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accentPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: completed
                  ? context.colors.success.withValues(alpha: 0.5)
                  : context.colors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: completed
                      ? context.colors.success
                      : accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  completed ? Icons.check_rounded : Icons.circle_outlined,
                  size: 18,
                  color: completed ? Colors.white : accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        decoration:
                            completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (!completed)
                Icon(Icons.chevron_right_rounded,
                    color: context.colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
