import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../feed/widgets/create_post_sheet.dart';
import '../../feed/widgets/create_video_sheet.dart';
import '../../feed/widgets/story_composer_screen.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

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
    _NavDestination(
      icon: Icons.chat_bubble_outline,
      label: s.navChat,
      route: '/chat',
    ),
    _NavDestination(
      icon: Icons.person_outline,
      label: s.navProfile,
      route: null,
    ),
  ];

  void _onTap(int index, String? route, String? userId) {
    setState(() => _selected = index);
    if (route == null && userId != null) {
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
              children: List.generate(destinations.length + 1, (i) {
                // índice 2 = botão + central
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
                                color: colors.accentPrimary.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add,
                            color: colors.textOnAccent,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // índices 0,1 → destinations[0,1]; 3,4,5 → destinations[2,3,4]
                final destIdx = i < 2 ? i : i - 1;
                final dest = destinations[destIdx];
                final isSelected = _selected == destIdx;

                // Profile tab: show avatar instead of icon
                final isProfile = dest.route == null;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onTap(destIdx, dest.route, user?.id),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isProfile)
                          _AvatarIcon(
                            avatarUrl: user?.avatarUrl,
                            isSelected: isSelected,
                            accentColor: colors.accentPrimary,
                          )
                        else
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'create',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      ),
      pageBuilder: (ctx, _, _) => const _CreateOverlay(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CREATE OVERLAY — TikTok-style fullscreen
// ─────────────────────────────────────────────────────────────────────────────

class _CreateOverlay extends ConsumerStatefulWidget {
  const _CreateOverlay();

  @override
  ConsumerState<_CreateOverlay> createState() => _CreateOverlayState();
}

class _CreateOverlayState extends ConsumerState<_CreateOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Animation<double> _stagger(int i) => CurvedAnimation(
    parent: _c,
    curve: Interval(
      0.05 + i * 0.08,
      (0.4 + i * 0.08).clamp(0, 1),
      curve: Curves.easeOutBack,
    ),
  );

  void _close() => Navigator.of(context).pop();

  void _openPost() {
    _close();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreatePostSheet(),
    );
  }

  void _openVideo() {
    _close();
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
    _close();
    // rootNavigator: o editor de story é tela cheia — cobre a barra de
    // navegação (antes abria dentro da aba e a nav ficava por cima).
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ForceDarkTheme(child: StoryComposerScreen()),
      ),
    );
  }

  void _openLive() {
    _close();
    context.push('/live/start');
  }

  void _openSounds() {
    _close();
    context.push('/sounds');
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop blur + dark tint
          GestureDetector(
            onTap: _close,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(color: Colors.black.withValues(alpha: 0.72)),
            ),
          ),

          // Close button top-right
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: GestureDetector(
                  onTap: _close,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Action grid — anchored to bottom
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _OverlayItem(
                          anim: _stagger(0),
                          icon: LucideIcons.aperture,
                          label: s.createStoryTitle,
                          onTap: _openStory,
                        ),
                        _OverlayItem(
                          anim: _stagger(1),
                          icon: LucideIcons.video,
                          label: s.createVideoTitle,
                          onTap: _openVideo,
                        ),
                        _OverlayItem(
                          anim: _stagger(2),
                          icon: LucideIcons.radio,
                          label: s.createLiveTitle,
                          onTap: _openLive,
                          accent: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Row 2
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _OverlayItem(
                          anim: _stagger(3),
                          icon: LucideIcons.edit3,
                          label: s.createPostTitle,
                          onTap: _openPost,
                        ),
                        _OverlayItem(
                          anim: _stagger(4),
                          iconWidget: Image.asset(
                            'assets/images/brawe_sounds_icon.png',
                            width: 26,
                            height: 26,
                            color: Colors.white,
                          ),
                          label: s.createSoundsTitle,
                          onTap: _openSounds,
                        ),
                        // Spacer para manter grid equilibrado
                        const SizedBox(width: 72),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayItem extends StatelessWidget {
  const _OverlayItem({
    required this.anim,
    required this.label,
    required this.onTap,
    this.icon,
    this.iconWidget,
    this.accent = false,
  });

  final Animation<double> anim;
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? iconWidget;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: Transform.scale(scale: anim.value.clamp(0.0, 1.0), child: child),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accent
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.2),
                    width: accent ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child:
                      iconWidget ?? Icon(icon, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String? route;
}

class _AvatarIcon extends StatelessWidget {
  const _AvatarIcon({
    required this.avatarUrl,
    required this.isSelected,
    required this.accentColor,
  });

  final String? avatarUrl;
  final bool isSelected;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? accentColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? CachedNetworkImage(
              memCacheWidth: context.decodePx(48),
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => _fallback(context),
                errorWidget: (_, _, _) => _fallback(context),
              )
            : _fallback(context),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person_outline,
        size: 16,
        color: isSelected
            ? accentColor
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
