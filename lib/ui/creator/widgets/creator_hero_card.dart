import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';

/// Card "wow" gradient — usado na landing do programa e no dashboard.
class CreatorHeroCard extends StatelessWidget {
  const CreatorHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.workspace_premium_rounded,
    this.gradient = AppColors.brandGradient,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -20,
            top: -30,
            child: Icon(icon,
                size: 160, color: Colors.white.withValues(alpha: 0.12)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'BRAWE CREATOR NETWORK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: gradient.first,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
