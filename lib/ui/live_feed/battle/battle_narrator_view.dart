import 'package:flutter/material.dart';

import 'battle_hud_parts.dart';
import 'battle_narrator.dart';

/// Altura da linha do narrador na faixa preta abaixo do vídeo.
const double kBattleNarratorH = 26;

/// Linha do narrador (§19.3): UMA frase por vez, centrada, na faixa do jogo.
/// [leading] é o espaço de uma rajada de mídia (ex.: início, MVP).
class BattleNarratorBar extends StatelessWidget {
  const BattleNarratorBar({super.key, required this.line, this.leading});

  final NarratorLine? line;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final l = line;
    return SizedBox(
      height: kBattleNarratorH,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.35),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.center,
          children: [...previous, ?current],
        ),
        child: l == null
            ? const SizedBox.shrink(key: ValueKey('narrator-empty'))
            : _Line(
                key: ValueKey('narrator-${l.key}-${l.text.hashCode}'),
                line: l,
                leading: leading,
              ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({super.key, required this.line, this.leading});

  final NarratorLine line;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final color = switch (line.style) {
      NarratorStyle.boost => kBattleBoost,
      NarratorStyle.gold => kBattleGold,
      NarratorStyle.normal => kBattleText,
    };
    final glow = line.style == NarratorStyle.normal
        ? null
        : [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8)];
    return Semantics(
      liveRegion: true,
      label: line.text,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              SizedBox(width: 24, height: 24, child: leading),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                line.text,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.none,
                  shadows: glow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
