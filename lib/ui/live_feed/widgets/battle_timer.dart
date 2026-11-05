import 'package:flutter/material.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Cronômetro da batalha (MM:SS).
///
/// Na reta final ([urgentSeconds]) fica laranja da marca com texto escuro
/// (vermelho é exclusivo do selo AO VIVO). Use [compact] para o HUD pequeno.
class BattleTimer extends StatelessWidget {
  const BattleTimer({
    super.key,
    required this.timeRemaining,
    this.compact = false,
    this.urgentSeconds = 30,
  });

  final Duration timeRemaining;
  final bool compact;
  final int urgentSeconds;

  @override
  Widget build(BuildContext context) {

    final minutes = timeRemaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = timeRemaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    final label = '$minutes:$seconds';

    final fg = const Color(0xFFF4F6FA);
    final fontSize = compact ? 13.0 : 17.0;

    return Semantics(
      label: S.of(context).battleTimer,
      value: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: const Color(0xB30B0E14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x14FFFFFF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: compact ? 12 : 15, color: fg),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
