import 'package:flutter/material.dart';

import '../../../domain/models/creator_network.dart';

/// Pequeno selo colorido com ícone do tier — usado em perfis, comentários,
/// lives, ranking. Tamanho configurável.
class CreatorTierBadge extends StatelessWidget {
  const CreatorTierBadge({
    super.key,
    required this.tier,
    this.size = 18,
    this.showLabel = false,
    this.label,
  });

  final CreatorTier tier;
  final double size;
  final bool showLabel;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final color = tier.color;
    final icon = tier.icon;

    if (!showLabel) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: tier.gradient),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: size * 0.6,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Icon(icon, size: size * 0.65, color: Colors.white),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.6, vertical: size * 0.25),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: tier.gradient),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size * 0.85, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label ?? tier.name.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.62,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
