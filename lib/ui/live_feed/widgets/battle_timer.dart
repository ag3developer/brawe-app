import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Cronômetro da batalha (MM:SS).
///
/// Nos últimos [urgentSeconds] segundos (padrão 10; 0 desliga) fica laranja
/// da marca, pulsa e dá um toque leve de vibração a cada segundo
/// (vermelho é exclusivo do selo AO VIVO). Use [compact] para o HUD pequeno.
/// [onUrgentTick] avisa cada segundo da reta final (som opcional do servidor).
class BattleTimer extends StatefulWidget {
  const BattleTimer({
    super.key,
    required this.timeRemaining,
    this.compact = false,
    this.urgentSeconds = 10,
    this.onUrgentTick,
  });

  final Duration timeRemaining;
  final bool compact;
  final int urgentSeconds;
  final void Function(int secondsLeft)? onUrgentTick;

  @override
  State<BattleTimer> createState() => _BattleTimerState();
}

class _BattleTimerState extends State<BattleTimer>
    with SingleTickerProviderStateMixin {
  static const _orange = Color(0xFFFFB366);

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  bool _isUrgent(Duration d) {
    final s = d.inSeconds;
    return widget.urgentSeconds > 0 && s > 0 && s <= widget.urgentSeconds;
  }

  @override
  void initState() {
    super.initState();
    if (_isUrgent(widget.timeRemaining)) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant BattleTimer old) {
    super.didUpdateWidget(old);
    final was = _isUrgent(old.timeRemaining);
    final now = _isUrgent(widget.timeRemaining);
    if (now && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!now && was) {
      _pulse
        ..stop()
        ..value = 0;
    }
    if (now && old.timeRemaining.inSeconds != widget.timeRemaining.inSeconds) {
      HapticFeedback.lightImpact();
      widget.onUrgentTick?.call(widget.timeRemaining.inSeconds);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final timeRemaining = widget.timeRemaining;
    final minutes = timeRemaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = timeRemaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final label = '$minutes:$seconds';

    final urgent = _isUrgent(timeRemaining);
    final fg = urgent ? _orange : const Color(0xFFF4F6FA);
    final fontSize = compact ? 13.0 : 17.0;

    final pill = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xB30B0E14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: urgent
              ? _orange.withValues(alpha: 0.7)
              : const Color(0x14FFFFFF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.timer, size: compact ? 12 : 15, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: S.of(context).battleTimer,
      value: label,
      child: urgent
          ? ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.08).animate(
                CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
              ),
              child: pill,
            )
          : pill,
    );
  }
}
