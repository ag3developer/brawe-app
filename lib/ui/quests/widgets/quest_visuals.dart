import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/models/quest.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';

// ════════════════════════════════════════════════════════════════════════
// Paleta e ícones por tipo de missão
// ════════════════════════════════════════════════════════════════════════

class QuestPalette {
  final Color start;
  final Color end;
  const QuestPalette(this.start, this.end);
  List<Color> get colors => [start, end];
}

bool isLiveQuestAction(String actionType) =>
    actionType == 'watch_live' ||
    actionType == 'send_live_gift' ||
    actionType == 'live_chat' ||
    actionType == 'live_like';

QuestPalette questPalette({
  required String category,
  String actionType = '',
}) {
  if (isLiveQuestAction(actionType) || category == 'live') {
    return const QuestPalette(Color(0xFFFF3D6E), Color(0xFFFF8A4D));
  }
  switch (category) {
    case 'engagement':
      return const QuestPalette(AppColors.braweBlue, AppColors.braweSky);
    case 'social':
      return const QuestPalette(Color(0xFFFF4D8D), Color(0xFFFFB13D));
    case 'creator':
      return const QuestPalette(Color(0xFF14B87A), AppColors.braweSky);
    default:
      return const QuestPalette(AppColors.braweBlue, Color(0xFFB14DFF));
  }
}

QuestPalette paletteForQuest(DailyQuest q) =>
    questPalette(category: q.category, actionType: q.actionType);

IconData questIcon(String? key, [String? actionType]) {
  switch (actionType) {
    case 'watch_live':
      return Icons.live_tv_rounded;
    case 'send_live_gift':
      return Icons.card_giftcard_rounded;
    case 'live_chat':
      return Icons.forum_rounded;
    case 'live_like':
      return Icons.favorite_rounded;
  }
  switch (key) {
    case 'Radio':
      return Icons.live_tv_rounded;
    case 'Gift':
      return Icons.card_giftcard_rounded;
    case 'MessageSquare':
      return Icons.forum_rounded;
    case 'Play':
      return Icons.play_circle_rounded;
    case 'Heart':
      return Icons.favorite_rounded;
    case 'MessageCircle':
      return Icons.chat_bubble_rounded;
    case 'UserPlus':
      return Icons.person_add_rounded;
    case 'Share2':
      return Icons.share_rounded;
    case 'Camera':
      return Icons.camera_alt_rounded;
    default:
      return Icons.stars_rounded;
  }
}

/// Ilustração 3D da missão (assets/images/quests). `null` = usar só o ícone.
String? questArtAsset({
  String? icon,
  String? category,
  String actionType = '',
}) {
  if (isLiveQuestAction(actionType) || category == 'live') return null;
  switch (icon) {
    case 'Heart':
      return 'assets/images/quests/icon_like.png';
    case 'MessageCircle':
    case 'MessageSquare':
      return 'assets/images/quests/icon_comment.png';
    case 'UserPlus':
      return 'assets/images/quests/icon_follow.png';
    case 'Camera':
      return 'assets/images/quests/icon_post.png';
    case 'Share2':
      return 'assets/images/quests/icon_share.png';
    case 'Play':
      return 'assets/images/quests/icon_watch.png';
  }
  switch (category) {
    case 'engagement':
      return 'assets/images/quests/icon_like.png';
    case 'social':
      return 'assets/images/quests/icon_follow.png';
    case 'creator':
      return 'assets/images/quests/icon_post.png';
  }
  return null;
}

/// Arte da missão: ilustração 3D quando existe; senão ícone branco sobre o
/// gradiente da categoria (as ilustrações já têm fundo próprio).
class QuestArt extends StatelessWidget {
  const QuestArt({
    super.key,
    required this.icon,
    required this.category,
    required this.actionType,
    required this.size,
    this.dimmed = false,
  });

  final String? icon;
  final String? category;
  final String actionType;
  final double size;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final palette = questPalette(
      category: category ?? '',
      actionType: actionType,
    );
    final asset = questArtAsset(
      icon: icon,
      category: category,
      actionType: actionType,
    );
    final iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        questIcon(icon, actionType),
        color: Colors.white,
        size: size * 0.52,
      ),
    );
    final child = asset == null
        ? iconWidget
        : Image.asset(
            asset,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => iconWidget,
          );
    if (!dimmed) return child;
    return Opacity(opacity: 0.55, child: child);
  }
}

// ════════════════════════════════════════════════════════════════════════
// Emblemas de sequência
// ════════════════════════════════════════════════════════════════════════

String questBadgeName(S s, String key) {
  switch (key) {
    case 'streak_3':
      return s.questBadgeStreak3;
    case 'streak_7':
      return s.questBadgeStreak7;
    case 'streak_14':
      return s.questBadgeStreak14;
    case 'streak_30':
      return s.questBadgeStreak30;
    case 'streak_60':
      return s.questBadgeStreak60;
    case 'streak_100':
      return s.questBadgeStreak100;
    default:
      return key;
  }
}

int questBadgeThreshold(String key) =>
    int.tryParse(key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

String questBadgeEmoji(String key) {
  switch (key) {
    case 'streak_3':
      return '🔥';
    case 'streak_7':
      return '⚡';
    case 'streak_14':
      return '💎';
    case 'streak_30':
      return '👑';
    case 'streak_60':
      return '🏆';
    case 'streak_100':
      return '🌟';
    default:
      return '🏅';
  }
}

List<Color> questBadgeColors(String key) {
  switch (key) {
    case 'streak_3':
      return const [Color(0xFFE9A36A), Color(0xFFB4632E)];
    case 'streak_7':
      return const [Color(0xFF7DD3FC), Color(0xFF3B82F6)];
    case 'streak_14':
      return const [Color(0xFFC4B5FD), Color(0xFF6366F1)];
    case 'streak_30':
      return const [Color(0xFFFFE066), Color(0xFFFF8B33)];
    case 'streak_60':
      return const [Color(0xFFD946EF), Color(0xFFFF4D8D)];
    case 'streak_100':
      return const [Color(0xFFFFD93D), Color(0xFFFF4D8D), Color(0xFF22D3EE)];
    default:
      return const [AppColors.braweBlue, AppColors.braweSky];
  }
}

/// Medalha do emblema. Bloqueado: cinza + cadeado. Desbloqueado: gradiente,
/// brilho e um reflexo girando devagar.
class QuestBadgeMedal extends StatefulWidget {
  const QuestBadgeMedal({
    super.key,
    required this.badgeKey,
    required this.unlocked,
    this.size = 72,
    this.animate = true,
  });

  final String badgeKey;
  final bool unlocked;
  final double size;
  final bool animate;

  @override
  State<QuestBadgeMedal> createState() => _QuestBadgeMedalState();
}

class _QuestBadgeMedalState extends State<QuestBadgeMedal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void initState() {
    super.initState();
    if (widget.unlocked && widget.animate) _spin.repeat();
  }

  @override
  void didUpdateWidget(covariant QuestBadgeMedal old) {
    super.didUpdateWidget(old);
    if (widget.unlocked && widget.animate) {
      if (!_spin.isAnimating) _spin.repeat();
    } else {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final colors = questBadgeColors(widget.badgeKey);
    final locked = !widget.unlocked;
    final greyA = context.isDark ? const Color(0xFF3A3F55) : const Color(0xFFD6D9E3);
    final greyB = context.isDark ? const Color(0xFF262A3B) : const Color(0xFFB9BDCB);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!locked)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.last.withValues(alpha: 0.45),
                    blurRadius: size * 0.28,
                    spreadRadius: size * 0.02,
                  ),
                ],
              ),
            ),
          // Aro externo com reflexo girando.
          AnimatedBuilder(
            animation: _spin,
            builder: (_, _) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  transform: GradientRotation(_spin.value * 2 * math.pi),
                  colors: locked
                      ? [greyA, greyB, greyA]
                      : [
                          ...colors,
                          Colors.white.withValues(alpha: 0.9),
                          colors.first,
                        ],
                ),
              ),
            ),
          ),
          // Disco interno.
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: locked ? [greyB, greyA] : colors,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: locked ? 0.15 : 0.55),
                width: size * 0.025,
              ),
            ),
            alignment: Alignment.center,
            child: locked
                ? Opacity(
                    opacity: 0.35,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.33, 0.33, 0.33, 0, 0, //
                        0.33, 0.33, 0.33, 0, 0, //
                        0.33, 0.33, 0.33, 0, 0, //
                        0, 0, 0, 1, 0,
                      ]),
                      child: Text(
                        questBadgeEmoji(widget.badgeKey),
                        style: TextStyle(fontSize: size * 0.38),
                      ),
                    ),
                  )
                : Text(
                    questBadgeEmoji(widget.badgeKey),
                    style: TextStyle(
                      fontSize: size * 0.4,
                      shadows: const [
                        Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
          ),
          if (locked)
            Positioned(
              right: size * 0.02,
              bottom: size * 0.02,
              child: Container(
                padding: EdgeInsets.all(size * 0.06),
                decoration: BoxDecoration(
                  color: context.colors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.border),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: size * 0.16,
                  color: context.colors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Animações reutilizáveis
// ════════════════════════════════════════════════════════════════════════

/// Entra deslizando de baixo e aparecendo, com atraso por [index].
class StaggerIn extends StatefulWidget {
  const StaggerIn({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 55),
  });

  final int index;
  final Widget child;
  final Duration step;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  );

  @override
  void initState() {
    super.initState();
    final delay = widget.step * math.min(widget.index, 10);
    Future.delayed(delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: curve,
      builder: (_, child) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, 22 * (1 - curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Pulsação contínua (escala + brilho) para chamar atenção.
class Pulse extends StatefulWidget {
  const Pulse({
    super.key,
    required this.child,
    this.enabled = true,
    this.minScale = 0.94,
    this.maxScale = 1.06,
    this.period = const Duration(milliseconds: 1100),
  });

  final Widget child;
  final bool enabled;
  final double minScale;
  final double maxScale;
  final Duration period;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant Pulse old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.enabled && _c.isAnimating) {
      _c.stop();
      _c.value = 0.5;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.scale(
        scale: widget.minScale +
            (widget.maxScale - widget.minScale) *
                Curves.easeInOut.transform(_c.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Faixa de luz atravessando o filho de tempos em tempos.
///
/// Feita com uma camada por cima (sem ShaderMask): a máscara de shader
/// gerava blocos coloridos no iOS ao voltar para uma aba mantida em memória
/// e rolar a lista.
class ShineSweep extends StatefulWidget {
  const ShineSweep({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 3200),
    this.opacity = 0.35,
    this.borderRadius = BorderRadius.zero,
  });

  final Widget child;
  final Duration period;
  final double opacity;
  final BorderRadius borderRadius;

  @override
  State<ShineSweep> createState() => _ShineSweepState();
}

class _ShineSweepState extends State<ShineSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, _) {
                  // A faixa passa nos primeiros 40% do ciclo; depois some.
                  final t = (_c.value / 0.4).clamp(0.0, 1.0);
                  if (t >= 1) return const SizedBox.expand();
                  final x = -1.5 + 3.0 * t;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(x - 0.4, -0.6),
                        end: Alignment(x + 0.4, 0.6),
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: widget.opacity),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Número que anima até o valor novo.
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.style,
    this.format,
    this.duration = const Duration(milliseconds: 900),
  });

  final int value;
  final TextStyle style;
  final String Function(int)? format;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, _) {
        final n = v.round();
        return Text(format?.call(n) ?? _compact(n), style: style);
      },
    );
  }

  static String _compact(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

/// Barra de progresso animada com gradiente e brilho na ponta.
class QuestProgressBar extends StatelessWidget {
  const QuestProgressBar({
    super.key,
    required this.value,
    required this.colors,
    required this.background,
    this.height = 8,
  });

  final double value;
  final List<Color> colors;
  final Color background;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: background,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: v,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors.length == 1 ? [colors.first, colors.first] : colors,
                  ),
                  borderRadius: BorderRadius.circular(height),
                  boxShadow: [
                    BoxShadow(
                      color: colors.last.withValues(alpha: 0.5),
                      blurRadius: height,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "5h 12m" / "12m 30s" / "45s".
String formatQuestCountdown(int seconds) {
  if (seconds <= 0) return '0s';
  final d = seconds ~/ 86400;
  final h = (seconds % 86400) ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  if (d > 0) return '${d}d ${h}h';
  if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
  if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
  return '${s}s';
}

// ════════════════════════════════════════════════════════════════════════
// Visual de jogo
// ════════════════════════════════════════════════════════════════════════

/// Bloco "3D" de jogo: superfície arredondada sobre uma base mais escura
/// (a "espessura"). Ao pressionar, afunda.
class GameTile extends StatefulWidget {
  const GameTile({
    super.key,
    required this.child,
    required this.tint,
    this.onTap,
    this.depth = 5,
    this.radius = 24,
    this.padding = const EdgeInsets.all(14),
    this.glow = 0,
    this.borderColor,
  });

  final Widget child;
  final Color tint;
  final VoidCallback? onTap;
  final double depth;
  final double radius;
  final EdgeInsetsGeometry padding;

  /// 0..1 — intensidade do brilho externo (missão para coletar).
  final double glow;
  final Color? borderColor;

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = context.isDark;
    final tint = widget.tint;
    final face = Color.alphaBlend(
      tint.withValues(alpha: dark ? 0.10 : 0.05),
      colors.surface,
    );
    final base = Color.alphaBlend(
      tint.withValues(alpha: dark ? 0.55 : 0.35),
      dark ? Colors.black : colors.surfaceHighest,
    );
    final press = _down ? widget.depth * 0.7 : 0.0;

    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _down = false),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _down = false);
              widget.onTap!();
            },
      child: Padding(
        padding: EdgeInsets.only(top: press),
        child: Container(
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              if (widget.glow > 0)
                BoxShadow(
                  color: tint.withValues(alpha: 0.18 + 0.30 * widget.glow),
                  blurRadius: 14 + 14 * widget.glow,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          padding: EdgeInsets.only(bottom: widget.depth - press),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: face,
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(
                color: widget.borderColor ??
                    tint.withValues(alpha: dark ? 0.35 : 0.22),
                width: 1.4,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Faz o filho flutuar devagar (sobe e desce) — dá "vida" às ilustrações.
class Floating extends StatefulWidget {
  const Floating({
    super.key,
    required this.child,
    this.enabled = true,
    this.amplitude = 4,
    this.period = const Duration(milliseconds: 2400),
    this.phase = 0,
    this.tilt = 0.04,
  });

  final Widget child;
  final bool enabled;
  final double amplitude;
  final Duration period;

  /// 0..1 — desencontra elementos vizinhos.
  final double phase;
  final double tilt;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void initState() {
    super.initState();
    _c.value = widget.phase % 1;
    if (widget.enabled) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant Floating old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !_c.isAnimating) _c.repeat();
    if (!widget.enabled && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final a = _c.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(0, math.sin(a) * widget.amplitude),
          child: Transform.rotate(angle: math.sin(a + 0.8) * widget.tilt, child: child),
        );
      },
      child: widget.child,
    );
  }
}

/// Estrelinhas piscando em volta do filho (missão pronta para coletar).
class Sparkles extends StatefulWidget {
  const Sparkles({
    super.key,
    required this.child,
    this.enabled = true,
    this.color = const Color(0xFFFFE066),
    this.count = 6,
  });

  final Widget child;
  final bool enabled;
  final Color color;
  final int count;

  @override
  State<Sparkles> createState() => _SparklesState();
}

class _SparklesState extends State<Sparkles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  final _seeds = List.generate(12, (i) => math.Random(i * 7 + 3).nextDouble());

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant Sparkles old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !_c.isAnimating) _c.repeat();
    if (!widget.enabled && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, _) => CustomPaint(
                painter: _SparklePainter(
                  t: _c.value,
                  seeds: _seeds,
                  count: widget.count,
                  color: widget.color,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({
    required this.t,
    required this.seeds,
    required this.count,
    required this.color,
  });

  final double t;
  final List<double> seeds;
  final int count;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.62;
    for (var i = 0; i < count; i++) {
      final seed = seeds[i % seeds.length];
      final local = ((t + seed) % 1);
      final life = math.sin(local * math.pi); // 0→1→0
      if (life <= 0.02) continue;
      final ang = (i / count) * 2 * math.pi + seed * 2;
      final dist = r * (0.75 + 0.35 * seed);
      final p = c + Offset(math.cos(ang) * dist, math.sin(ang) * dist);
      final s = (2.5 + 3.5 * seed) * life;
      final paint = Paint()..color = color.withValues(alpha: life);
      final path = Path()
        ..moveTo(p.dx, p.dy - s * 1.6)
        ..quadraticBezierTo(p.dx, p.dy, p.dx + s * 1.6, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + s * 1.6)
        ..quadraticBezierTo(p.dx, p.dy, p.dx - s * 1.6, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - s * 1.6);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) => old.t != t;
}

/// Fundo vivo da tela: manchas de cor flutuando + estrelas piscando.
/// Adapta-se ao tema (mais forte no escuro, suave no claro).
class QuestBackdrop extends StatefulWidget {
  const QuestBackdrop({super.key});

  @override
  State<QuestBackdrop> createState() => _QuestBackdropState();
}

class _QuestBackdropState extends State<QuestBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final colors = context.colors;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(
          painter: _BackdropPainter(
            t: _c.value,
            dark: dark,
            background: colors.background,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({
    required this.t,
    required this.dark,
    required this.background,
  });

  final double t;
  final bool dark;
  final Color background;

  static final _stars = List.generate(40, (i) {
    final r = math.Random(i * 31 + 11);
    return (r.nextDouble(), r.nextDouble(), r.nextDouble(), 0.6 + r.nextDouble() * 1.6);
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final a = t * 2 * math.pi;
    final blobs = [
      (const Color(0xFF7C5CFF), 0.85, 0.08, 0.55),
      (const Color(0xFF22D3EE), 0.10, 0.32, 0.50),
      (const Color(0xFFFF4D8D), 0.80, 0.62, 0.45),
      (const Color(0xFFFFB13D), 0.15, 0.88, 0.40),
    ];
    for (var i = 0; i < blobs.length; i++) {
      final (color, bx, by, rr) = blobs[i];
      final cx = size.width * (bx + 0.08 * math.sin(a + i * 1.7));
      final cy = size.height * (by + 0.05 * math.cos(a * 0.8 + i));
      final radius = size.width * rr;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: dark ? 0.20 : 0.10),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
    // Estrelas.
    final starColor = dark ? Colors.white : const Color(0xFF7C5CFF);
    for (final (x, y, phase, s) in _stars) {
      final tw = 0.5 + 0.5 * math.sin(a * 3 + phase * 6.28);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        s * (0.6 + 0.4 * tw),
        Paint()..color = starColor.withValues(alpha: (dark ? 0.55 : 0.25) * tw),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) =>
      old.t != t || old.dark != dark || old.background != background;
}
