import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

/// Pílula `LIVE` vermelha (estilo TikTok / Instagram Live).
///
/// Uso: badge fixo no HUD para indicar que a transmissão está ao vivo.
/// Recebe o label externo para suportar i18n (`s.liveFeedBadgeLive`).
class LivePill extends StatelessWidget {
  const LivePill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.liveRed,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.liveRed.withValues(alpha: 0.35),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
