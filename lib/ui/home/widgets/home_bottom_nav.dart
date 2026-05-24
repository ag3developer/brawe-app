import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../feed/widgets/create_post_sheet.dart';
import '../../feed/widgets/create_video_sheet.dart';
import '../../feed/widgets/story_composer_screen.dart';
import '../../core/ui/app_spacing.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../gen/l10n/app_localizations.dart';

class HomeBottomNav extends ConsumerStatefulWidget {
  const HomeBottomNav({super.key});

  @override
  ConsumerState<HomeBottomNav> createState() => _HomeBottomNavState();
}

class _HomeBottomNavState extends ConsumerState<HomeBottomNav> {
  int _selected = 0;

  List<_NavDestination> _buildDestinations(S s) => [
    _NavDestination(icon: Icons.home_filled, label: s.navHome, route: '/home'),
    _NavDestination(icon: Icons.newspaper, label: s.navFeed, route: '/feed'),
    _NavDestination(icon: Icons.sensors, label: s.navLives, route: '/live'),
    _NavDestination(
        icon: Icons.chat_bubble_outline, label: s.navChat, route: '/chat'),
    _NavDestination(icon: Icons.person_outline, label: s.navProfile, route: null),
  ];

  void _onTap(int index, String? route, String? userId) {
    setState(() => _selected = index);
    if (index == 4 && userId != null) {
      context.go('/profile/$userId');
    } else if (route != null) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final colors = context.colors;
    final s = S.of(context);
    final destinations = _buildDestinations(s);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.75),
            border: Border(top: BorderSide(color: colors.divider)),
          ),
          child: SizedBox(
            height: 56,
            child: Row(
              children: List.generate(destinations.length, (i) {
                // Center item = post button
                if (i == 2) {
                  return Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _showCreateOptions(context),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colors.accentPrimary,
                                colors.accentSecondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: colors.accentPrimary
                                    .withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.add,
                              color: colors.textOnAccent, size: 26),
                        ),
                      ),
                    ),
                  );
                }

                final dest = destinations[i];
                final isSelected = _selected == i;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onTap(i, dest.route, user?.id),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          dest.icon,
                          color: isSelected
                              ? colors.accentPrimary
                              : colors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dest.label,
                          style: TextStyle(
                            color: isSelected
                                ? colors.accentPrimary
                                : colors.textSecondary,
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => const _CreateSheet(),
    );
  }
}

// ── Sheet de criar (Brawe Pulse — gradient cards, hero glow) ────────────
class _CreateSheet extends StatefulWidget {
  const _CreateSheet();

  @override
  State<_CreateSheet> createState() => _CreateSheetState();
}

class _CreateSheetState extends State<_CreateSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Animation<double> _stagger(int i) {
    final start = 0.15 + i * 0.10;
    return CurvedAnimation(
      parent: _c,
      curve: Interval(start, (start + 0.55).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
  }

  void _openPost() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreatePostSheet(),
    );
  }

  void _openVideo() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      useSafeArea: false,
      builder: (_) => const CreateVideoSheet(),
    );
  }

  void _openStory() {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ForceDarkTheme(child: StoryComposerScreen()),
      ),
    );
  }

  void _openLive() {
    Navigator.pop(context);
    context.push('/live/start');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.surface.withValues(alpha: 0.9),
                    colors.surfaceElevated.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: colors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.overlay.withValues(alpha: 0.5),
                    blurRadius: 50,
                    offset: const Offset(0, 22),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 10, bottom: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          colors.accentPrimary,
                          colors.accentSecondary,
                        ]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => LinearGradient(colors: [
                            colors.textPrimary,
                            colors.accentSecondary,
                          ]).createShader(b),
                          child: Text(
                            s.createSheetTitle,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.createSheetSubtitle,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        _AnimatedSlide(
                          animation: _stagger(0),
                          child: _CreateCard(
                            icon: LucideIcons.aperture,
                            title: s.createStoryTitle,
                            subtitle: s.createStorySubtitle,
                            iconSpin: true,
                            gradient: const [
                              Color(0xFF7C3AED),
                              Color(0xFF22D3EE),
                            ],
                            onTap: _openStory,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedSlide(
                          animation: _stagger(1),
                          child: _CreateCard(
                            icon: LucideIcons.video,
                            title: s.createVideoTitle,
                            subtitle: s.createVideoSubtitle,
                            gradient: const [
                              Color(0xFFEC4899),
                              Color(0xFF8B5CF6),
                            ],
                            onTap: _openVideo,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedSlide(
                          animation: _stagger(2),
                          child: _CreateCard(
                            icon: LucideIcons.radio,
                            title: s.createLiveTitle,
                            subtitle: s.createLiveSubtitle,
                            badge: s.liveBadge,
                            badgePulse: true,
                            gradient: const [
                              Color(0xFFEF4444),
                              Color(0xFFF97316),
                            ],
                            onTap: _openLive,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedSlide(
                          animation: _stagger(3),
                          child: _CreateCard(
                            icon: LucideIcons.edit3,
                            title: s.createPostTitle,
                            subtitle: s.createPostSubtitle,
                            gradient: const [
                              Color(0xFF6366F1),
                              Color(0xFF8B5CF6),
                            ],
                            onTap: _openPost,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          backgroundColor:
                              colors.surfaceHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          s.actionClose,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedSlide extends StatelessWidget {
  const _AnimatedSlide({required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, c) => Opacity(
        opacity: animation.value.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (1 - animation.value) * 18),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class _CreateCard extends StatefulWidget {
  const _CreateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.badge,
    this.badgePulse = false,
    this.iconSpin = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  final String? badge;
  final bool badgePulse;
  final bool iconSpin;

  @override
  State<_CreateCard> createState() => _CreateCardState();
}

class _CreateCardState extends State<_CreateCard>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.badgePulse) _pulse.repeat(reverse: true);
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.iconSpin) _spin.repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: widget.gradient.first.withValues(alpha: 0.25),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.gradient.first.withValues(alpha: 0.16),
                widget.gradient.last.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: widget.gradient.first.withValues(alpha: 0.35),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.20),
                blurRadius: 18,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.first.withValues(alpha: 0.55),
                      blurRadius: 16,
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: widget.iconSpin
                    ? RotationTransition(
                        turns: _spin,
                        child: Icon(widget.icon,
                            color: context.colors.textPrimary, size: 24),
                      )
                    : Icon(widget.icon, color: context.colors.textPrimary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.badge != null) ...[
                          const SizedBox(width: 8),
                          _BadgeChip(
                            label: widget.badge!,
                            pulse: widget.badgePulse,
                            pulseAnim: _pulse,
                            color: widget.gradient.first,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: context.colors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.label,
    required this.pulse,
    required this.pulseAnim,
    required this.color,
  });

  final String label;
  final bool pulse;
  final AnimationController pulseAnim;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.65)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulse) ...[
            AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, _) {
                final v = pulseAnim.value;
                return Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.45 + v * 0.45),
                        blurRadius: 4 + v * 4,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
    return chip;
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.label,
    this.route,
  });
  final IconData icon;
  final String label;
  final String? route;
}

// Keep old NavBarItem for backward compat
class NavBarItem extends StatelessWidget {
  const NavBarItem({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, color: context.colors.textPrimary, size: 28),
    );
  }
}
