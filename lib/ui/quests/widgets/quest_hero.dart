import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/models/quest.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/image_decode.dart';
import 'quest_visuals.dart';

const _streakMilestones = [3, 7, 14, 30, 60, 100];

/// Cartão do topo: nível, XP, sequência, bônus e tempo até as novas missões.
///
/// Usa um gradiente de marca fixo (contraste garantido nos dois temas, como
/// o cartão de saldo da carteira).
class QuestHeroCard extends StatelessWidget {
  const QuestHeroCard({
    super.key,
    required this.profile,
    required this.streak,
    required this.resetInSeconds,
    this.avatarUrl,
  });

  final QuestProfile profile;
  final QuestStreak streak;
  final int resetInSeconds;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final nextMilestone = _streakMilestones.firstWhere(
      (m) => m > streak.current,
      orElse: () => 0,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.braweBlue.withValues(alpha: 0.35),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: ShineSweep(
          opacity: 0.18,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2B1B8F), AppColors.braweBlue, Color(0xFF1E9BD7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Círculos decorativos.
                Positioned(
                  right: -40,
                  top: -50,
                  child: _circle(160, Colors.white.withValues(alpha: 0.07)),
                ),
                Positioned(
                  left: -30,
                  bottom: -60,
                  child: _circle(140, Colors.white.withValues(alpha: 0.05)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          QuestLevelAvatar(
                            level: profile.level,
                            avatarUrl: avatarUrl,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.questsLevel(profile.level),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                CountUpText(
                                  value: profile.xpIntoLevel,
                                  format: (n) => s.questsXpProgress(
                                    n,
                                    profile.xpToNextLevel,
                                  ),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _StreakFlame(days: streak.current),
                        ],
                      ),
                      const SizedBox(height: 16),
                      QuestProgressBar(
                        value: profile.levelProgressPercent / 100,
                        colors: const [Color(0xFFFFE066), Colors.white],
                        background: Colors.white.withValues(alpha: 0.2),
                        height: 10,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _HeroPill(
                            icon: Icons.schedule_rounded,
                            child: _Countdown(seconds: resetInSeconds),
                          ),
                          if (streak.multiplierLabel != null)
                            _HeroPill(
                              icon: Icons.flash_on_rounded,
                              iconColor: const Color(0xFFFFE066),
                              child: Text(
                                s.questsStreakBonus(streak.multiplierLabel!),
                                style: _pillText,
                              ),
                            ),
                          if (nextMilestone > 0)
                            _HeroPill(
                              icon: Icons.military_tech_rounded,
                              iconColor: const Color(0xFFFFB86B),
                              child: Text(
                                s.questsNextBadge(nextMilestone - streak.current),
                                style: _pillText,
                              ),
                            ),
                        ],
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

  static Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

const _pillText = TextStyle(
  color: Colors.white,
  fontSize: 12,
  fontWeight: FontWeight.w700,
);

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.child, this.iconColor});

  final IconData icon;
  final Widget child;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? Colors.white),
          const SizedBox(width: 5),
          child,
        ],
      ),
    );
  }
}

/// Contagem regressiva até as novas missões (atualiza a cada segundo).
class _Countdown extends StatefulWidget {
  const _Countdown({required this.seconds});
  final int seconds;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  late DateTime _endsAt;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _endsAt = DateTime.now().add(Duration(seconds: widget.seconds));
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant _Countdown old) {
    super.didUpdateWidget(old);
    if (old.seconds != widget.seconds) {
      _endsAt = DateTime.now().add(Duration(seconds: widget.seconds));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = _endsAt.difference(DateTime.now()).inSeconds;
    return Text(
      S.of(context).questsResetsIn(formatQuestCountdown(left < 0 ? 0 : left)),
      style: _pillText.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// Chama da sequência: pulsa quando há sequência ativa.
class _StreakFlame extends StatelessWidget {
  const _StreakFlame({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    final active = days > 0;
    return Column(
      children: [
        Pulse(
          enabled: active,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: active
                  ? const RadialGradient(
                      colors: [Color(0xFFFFE066), Color(0xFFFF8B33), Color(0xFFFF3D6E)],
                    )
                  : null,
              color: active ? null : Colors.white.withValues(alpha: 0.15),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF8B33).withValues(alpha: 0.7),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 30,
              color: active ? Colors.white : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          S.of(context).questsStreakDays(days),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Avatar com moldura do nível
// ════════════════════════════════════════════════════════════════════════

class _LevelTier {
  final String frameAsset;
  final List<Color> ringColors;
  final List<Color> badgeColors;
  final Color glow;

  const _LevelTier({
    required this.frameAsset,
    required this.ringColors,
    required this.badgeColors,
    required this.glow,
  });

  static _LevelTier fromLevel(int level) {
    if (level >= 50) return _legendary;
    if (level >= 25) return _epic;
    if (level >= 10) return _gold;
    if (level >= 5) return _silver;
    return _bronze;
  }

  static const _bronze = _LevelTier(
    frameAsset: 'frame_bronze.png',
    ringColors: [Color(0xFFCD7F32), Color(0xFF8B5A2B)],
    badgeColors: [Color(0xFFCD7F32), Color(0xFF8B5A2B)],
    glow: Color(0xFFCD7F32),
  );
  static const _silver = _LevelTier(
    frameAsset: 'frame_silver.png',
    ringColors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
    badgeColors: [Color(0xFFBDBDBD), Color(0xFF757575)],
    glow: Color(0xFFE0E0E0),
  );
  static const _gold = _LevelTier(
    frameAsset: 'frame_gold.png',
    ringColors: [Color(0xFFFFD93D), Color(0xFFFF8B33)],
    badgeColors: [Color(0xFFFFD93D), Color(0xFFFF8B33)],
    glow: Color(0xFFFFD93D),
  );
  static const _epic = _LevelTier(
    frameAsset: 'frame_epic.png',
    ringColors: [Color(0xFFB14DFF), Color(0xFFFF4D8D)],
    badgeColors: [AppColors.braweBlueLight, Color(0xFFFF4D8D)],
    glow: Color(0xFFB14DFF),
  );
  static const _legendary = _LevelTier(
    frameAsset: 'frame_legendary.png',
    ringColors: [Color(0xFFFFD93D), Color(0xFFFF4D8D), AppColors.braweSky],
    badgeColors: [Color(0xFFFFD93D), Color(0xFFFF4D8D)],
    glow: Color(0xFFFFD93D),
  );
}

/// Foto do usuário dentro da moldura do patamar do nível (bronze → lendário).
class QuestLevelAvatar extends StatelessWidget {
  const QuestLevelAvatar({
    super.key,
    required this.level,
    this.avatarUrl,
    this.size = 76,
  });

  final int level;
  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tier = _LevelTier.fromLevel(level);
    // A moldura PNG tem o "buraco" em ~66% do diâmetro.
    final avatarSize = size * 0.64;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: avatarSize + 8,
            height: avatarSize + 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: tier.glow.withValues(alpha: 0.6),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: tier.ringColors),
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: (avatarUrl ?? '').isNotEmpty
                  ? Image.network(
                      avatarUrl!,
                      cacheWidth: context.decodePx(avatarSize),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallback(),
                    )
                  : _fallback(),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/quests/${tier.frameAsset}',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: tier.badgeColors),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                '$level',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 2)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(
        color: AppColors.braweDeep,
        alignment: Alignment.center,
        child: const Icon(Icons.person, color: Colors.white70, size: 26),
      );
}
