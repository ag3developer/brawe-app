import 'package:flutter/material.dart';

import '../../../domain/models/creator_network.dart';
import '../../core/themes/brawe_colors.dart';

/// Card individual de tier — mostra ícone, nome, descrição, perks.
class CreatorTierCard extends StatelessWidget {
  const CreatorTierCard({
    super.key,
    required this.tier,
    required this.title,
    required this.description,
    this.perks = const [],
    this.compact = false,
    this.selected = false,
    this.onTap,
  });

  final CreatorTier tier;
  final String title;
  final String description;
  final List<String> perks;
  final bool compact;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardBg = context.colors.surface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(compact ? 14 : 18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? tier.color.withValues(alpha: 0.9)
                  : context.colors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: compact ? 44 : 56,
                    height: compact ? 44 : 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: tier.gradient),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: tier.color.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(tier.icon,
                        color: Colors.white, size: compact ? 22 : 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: compact ? 15 : 17,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tier.name.toUpperCase(),
                          style: TextStyle(
                            color: tier.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle_rounded,
                        color: tier.color, size: 22),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              if (perks.isNotEmpty && !compact) ...[
                const SizedBox(height: 14),
                ...perks.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_rounded,
                            size: 16, color: tier.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
