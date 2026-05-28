import 'package:flutter/material.dart';

import '../../core/themes/brawe_colors.dart';

class CreatorTimelineStep {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final bool active;
  final bool completed;
  const CreatorTimelineStep({
    required this.title,
    this.subtitle,
    required this.icon,
    this.color,
    this.active = false,
    this.completed = false,
  });
}

class CreatorTimeline extends StatelessWidget {
  const CreatorTimeline({super.key, required this.steps});
  final List<CreatorTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _Step(
            step: steps[i],
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.step, required this.isLast});
  final CreatorTimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final accent = step.color ?? context.colors.accentPrimary;
    final inactive = context.colors.surfaceHighest;
    final dotColor = step.completed
        ? context.colors.success
        : step.active
            ? accent
            : inactive;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: step.active
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.45),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  step.completed ? Icons.check_rounded : step.icon,
                  size: 16,
                  color: step.completed || step.active
                      ? Colors.white
                      : context.colors.textTertiary,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: step.completed
                        ? context.colors.success.withValues(alpha: 0.6)
                        : context.colors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight:
                          step.active ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (step.subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      step.subtitle!,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
