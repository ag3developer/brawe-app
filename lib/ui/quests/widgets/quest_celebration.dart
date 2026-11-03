import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import 'quest_visuals.dart';

const _confettiColors = [
  Color(0xFFFFD93D),
  Color(0xFFFF4D8D),
  Color(0xFF22D3EE),
  Color(0xFF7C5CFF),
  Color(0xFF2BD995),
  Color(0xFFFF8B33),
];

class _Particle {
  _Particle(math.Random r, {required this.spread, required this.speed})
      : angle = -math.pi / 2 + (r.nextDouble() - 0.5) * spread,
        velocity = speed * (0.55 + r.nextDouble() * 0.6),
        size = 4 + r.nextDouble() * 6,
        spin = (r.nextDouble() - 0.5) * 12,
        color = _confettiColors[r.nextInt(_confettiColors.length)],
        circle = r.nextBool();

  final double spread;
  final double speed;
  final double angle;
  final double velocity;
  final double size;
  final double spin;
  final Color color;
  final bool circle;
}

/// Pinta confetes saindo de [origin] com gravidade.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.particles,
    required this.t,
    required this.origin,
  });

  final List<_Particle> particles;
  final double t; // 0..1
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    final time = t * 1.4; // segundos "virtuais"
    final fade = (1 - Curves.easeIn.transform(t)).clamp(0.0, 1.0);
    for (final p in particles) {
      final dx = math.cos(p.angle) * p.velocity * time;
      final dy = math.sin(p.angle) * p.velocity * time + 620 * time * time;
      final pos = origin + Offset(dx, dy);
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * time);
      if (p.circle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}

/// Explosão de confete + "+XP / +moedas" subindo a partir de [origin]
/// (coordenadas globais). Não bloqueia toques.
void showQuestRewardBurst(
  BuildContext context, {
  required Offset origin,
  required int xp,
  required int coins,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  HapticFeedback.mediumImpact();
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _RewardBurst(
      origin: origin,
      xp: xp,
      coins: coins,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _RewardBurst extends StatefulWidget {
  const _RewardBurst({
    required this.origin,
    required this.xp,
    required this.coins,
    required this.onDone,
  });

  final Offset origin;
  final int xp;
  final int coins;
  final VoidCallback onDone;

  @override
  State<_RewardBurst> createState() => _RewardBurstState();
}

class _RewardBurstState extends State<_RewardBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    _particles = List.generate(
      36,
      (_) => _Particle(r, spread: math.pi * 1.1, speed: 520),
    );
    _c.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Material transparente: sem ele, textos no Overlay ganham o sublinhado
    // amarelo de "sem tema".
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) {
            final t = _c.value;
            final rise = Curves.easeOutCubic.transform(t);
            final opacity = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3);
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      t: t,
                      origin: widget.origin,
                    ),
                  ),
                ),
                Positioned(
                  left: widget.origin.dx - 90,
                  width: 180,
                  top: widget.origin.dy - 40 - 90 * rise,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.6 + 0.5 * Curves.elasticOut.transform(
                        (t * 1.6).clamp(0.0, 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.xp > 0)
                            _FloatChip(
                              text: '+${widget.xp} XP',
                              icon: Icons.bolt_rounded,
                              colors: const [Color(0xFF7C5CFF), Color(0xFF22D3EE)],
                            ),
                          if (widget.xp > 0 && widget.coins > 0)
                            const SizedBox(width: 6),
                          if (widget.coins > 0)
                            _FloatChip(
                              text: '+${widget.coins}',
                              icon: Icons.monetization_on_rounded,
                              colors: const [Color(0xFFFFD93D), Color(0xFFFF8B33)],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FloatChip extends StatelessWidget {
  const _FloatChip({
    required this.text,
    required this.icon,
    required this.colors,
  });

  final String text;
  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Janelas de comemoração
// ════════════════════════════════════════════════════════════════════════

Future<void> showQuestLevelUp(BuildContext context, int level) {
  HapticFeedback.heavyImpact();
  final s = S.of(context);
  return _showCelebrationDialog(
    context,
    hero: _LevelHero(level: level),
    title: s.questsLevelUpTitle,
    body: s.questsLevelUpBody(level),
    colors: const [Color(0xFF7C5CFF), Color(0xFF22D3EE)],
  );
}

Future<void> showQuestBadgeUnlocked(BuildContext context, String badgeKey) {
  HapticFeedback.heavyImpact();
  final s = S.of(context);
  return _showCelebrationDialog(
    context,
    hero: QuestBadgeMedal(badgeKey: badgeKey, unlocked: true, size: 120),
    title: s.questsBadgeUnlockedTitle,
    body: questBadgeName(s, badgeKey),
    subtitle: s.questsBadgeRequirement(questBadgeThreshold(badgeKey)),
    colors: questBadgeColors(badgeKey),
  );
}

Future<void> _showCelebrationDialog(
  BuildContext context, {
  required Widget hero,
  required String title,
  required String body,
  String? subtitle,
  required List<Color> colors,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 420),
    pageBuilder: (ctx, _, _) => _CelebrationCard(
      hero: hero,
      title: title,
      body: body,
      subtitle: subtitle,
      colors: colors,
    ),
    transitionBuilder: (ctx, anim, _, child) {
      final curve = CurvedAnimation(parent: anim, curve: Curves.elasticOut);
      return Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.6 + 0.4 * curve.value, child: child),
      );
    },
  );
}

class _CelebrationCard extends StatefulWidget {
  const _CelebrationCard({
    required this.hero,
    required this.title,
    required this.body,
    required this.colors,
    this.subtitle,
  });

  final Widget hero;
  final String title;
  final String body;
  final String? subtitle;
  final List<Color> colors;

  @override
  State<_CelebrationCard> createState() => _CelebrationCardState();
}

class _CelebrationCardState extends State<_CelebrationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    _particles = List.generate(
      40,
      (_) => _Particle(r, spread: math.pi * 1.6, speed: 460),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 300,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: widget.colors.first.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: widget.colors.last.withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Topo colorido.
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 150,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          widget.colors.first.withValues(alpha: 0.45),
                          widget.colors.last.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (_, _) => CustomPaint(
                      painter: _ConfettiPainter(
                        particles: _particles,
                        t: _c.value,
                        origin: const Offset(150, 110),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Pulse(minScale: 0.96, maxScale: 1.04, child: widget.hero),
                      const SizedBox(height: 20),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.body,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: widget.colors),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              S.of(context).questsContinue,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelHero extends StatelessWidget {
  const _LevelHero({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/quests/stat_trophy.png',
            width: 120,
            height: 120,
            errorBuilder: (_, _, _) => const Icon(
              Icons.emoji_events_rounded,
              size: 100,
              color: Color(0xFFFFD93D),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C5CFF), Color(0xFF22D3EE)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                S.of(context).questsLevelShort(level),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
