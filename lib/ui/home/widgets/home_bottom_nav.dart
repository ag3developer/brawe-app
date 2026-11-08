import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../chat/view_models/unread_chats_provider.dart';
import '../../chat/widgets/unread_badge.dart';
import '../../feed/widgets/create_post_sheet.dart';
import '../../feed/widgets/create_video_sheet.dart';
import '../../feed/widgets/story_composer_screen.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// Comentários abertos no Para você: a barra sai e o painel vai até a borda (como no TikTok).
final ValueNotifier<bool> navHiddenByMedia = ValueNotifier<bool>(false);

/// Rolando para baixo em qualquer aba a barra compacta; subindo, volta (o ShellRoute avisa).
final navCompactProvider = NotifierProvider<NavCompact, bool>(NavCompact.new);

class NavCompact extends Notifier<bool> {
  @override
  bool build() => false;

  double _acc = 0;

  /// Recebe o quanto a lista andou (positivo = para baixo) e a posição atual.
  void onScroll(double delta, double pixels) {
    if (pixels < 40) {
      _acc = 0;
      if (state) state = false;
      return;
    }
    _acc = (delta.sign == _acc.sign) ? _acc + delta : delta;
    if (_acc > 24 && !state) state = true;
    if (_acc < -18 && state) state = false;
  }

  void expand() {
    _acc = 0;
    if (state) state = false;
  }
}

/// Barra de navegação flutuante (cápsula de vidro, só ícones), no estilo do iOS 26.
/// - iOS: vidro com desfoque. Android: sem desfoque (pesa em aparelhos simples), superfície quase opaca.
/// - Compacta ao rolar para baixo; na tela Para você (vídeo) fica sempre compacta e escura.
/// - A altura reservada é sempre a mesma: compactar não faz as telas "pularem".
class HomeBottomNav extends ConsumerStatefulWidget {
  const HomeBottomNav({super.key, required this.location});

  /// Rota atual (para saber a aba ativa).
  final String location;

  /// Altura reservada pela barra (sem a área segura do aparelho).
  static const double reservedHeight = 72;

  /// Telas de tarefa (ajustes, formulários, painéis, comentários): sem a barra, como no Instagram.
  static bool hiddenOn(String path) {
    const prefixes = [
      '/settings',
      '/edit-profile',
      '/artist-profile',
      '/business-profile',
      '/wallet',
      '/creator',
      '/admin',
      '/sounds',
      '/scan-qr',
    ];
    if (prefixes.any(path.startsWith)) return true;
    return RegExp(r'^/post/[^/]+/(comments|likes|video)').hasMatch(path);
  }

  /// Mídia em tela cheia (vídeo do post): NUNCA mostra a barra, nem quando a
  /// tela foi aberta sem ter para onde voltar (só a aba Para você mostra).
  static bool fullscreenMedia(String path) =>
      RegExp(r'^/post/[^/]+/video').hasMatch(path);

  @override
  ConsumerState<HomeBottomNav> createState() => _HomeBottomNavState();
}

class _HomeBottomNavState extends ConsumerState<HomeBottomNav> {
  static final bool _glass =
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  void didUpdateWidget(covariant HomeBottomNav old) {
    super.didUpdateWidget(old);
    if (old.location != widget.location) {
      // trocou de tela: a barra volta ao tamanho normal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(navCompactProvider.notifier).expand();
      });
    }
  }

  int _activeIndex(String? myId) {
    final p = widget.location;
    if (p.startsWith('/home')) return 0;
    if (p.startsWith('/feed')) return 1;
    if (p.startsWith('/chat')) return 2;
    if (myId != null && p.startsWith('/profile/$myId')) return 3;
    return -1;
  }

  void _go(String route) {
    HapticFeedback.selectionClick();
    ref.read(navCompactProvider.notifier).expand();
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final s = S.of(context);
    final unreadChats = ref.watch(unreadChatsProvider).length;
    final onVideo = widget.location.startsWith('/home');
    final compact = onVideo || ref.watch(navCompactProvider);
    final active = _activeIndex(user?.id);
    final colors = context.colors;
    final dark = onVideo || Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final dur = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 380);
    const curve = Curves.easeOutCubic;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final iconColor = dark ? Colors.white : colors.textPrimary;

    // cor do vidro (iOS) ou da superfície (Android)
    final fill = _glass
        ? (dark
              ? Colors.black.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.62))
        : (dark
              ? const Color(0xF0181B22)
              : colors.surface.withValues(alpha: 0.97));
    final edge = dark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.85);

    Widget item({
      required int index,
      required String label,
      required Widget icon,
      required VoidCallback onTap,
    }) {
      final on = index == active;
      return Semantics(
        button: true,
        selected: on,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: dur,
            curve: curve,
            width: compact ? 44 : 54,
            height: compact ? 40 : 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on
                  ? iconColor.withValues(alpha: dark ? 0.16 : 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: AnimatedScale(
              scale: compact ? 0.88 : 1,
              duration: dur,
              curve: curve,
              child: icon,
            ),
          ),
        ),
      );
    }

    Icon ic(IconData d, int index) => Icon(
      d,
      size: 25,
      color: index == active ? iconColor : iconColor.withValues(alpha: 0.72),
    );

    final pill = AnimatedContainer(
      duration: dur,
      curve: curve,
      width: compact
          ? 236
          : MediaQuery.sizeOf(context).width.clamp(0, 520) - 36,
      height: compact ? 52 : 64,
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: edge, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.45 : 0.14),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          item(
            index: 0,
            label: s.navHome,
            icon: ic(LucideIcons.house, 0),
            onTap: () => _go('/home'),
          ),
          item(
            index: 1,
            label: s.navFeed,
            icon: ic(LucideIcons.newspaper, 1),
            onTap: () => _go('/feed'),
          ),
          // Criar: azul, no meio
          Semantics(
            button: true,
            label: s.navCreate,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _showCreateOptions(context);
              },
              child: AnimatedContainer(
                duration: dur,
                curve: curve,
                width: compact ? 44 : 52,
                height: compact ? 36 : 42,
                decoration: BoxDecoration(
                  color: colors.accentPrimary,
                  borderRadius: BorderRadius.circular(compact ? 14 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accentPrimary.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.plus,
                  color: colors.textOnAccent,
                  size: 24,
                ),
              ),
            ),
          ),
          item(
            index: 2,
            label: s.navChatUnreadSemantics(unreadChats),
            icon: UnreadBadge(
              count: unreadChats,
              semanticsLabel: s.navChatUnreadSemantics(unreadChats),
              child: ic(LucideIcons.messageCircle, 2),
            ),
            onTap: () => _go('/chat'),
          ),
          item(
            index: 3,
            label: s.navProfile,
            icon: _AvatarIcon(
              avatarUrl: user?.avatarUrl,
              isSelected: active == 3,
              accentColor: iconColor,
            ),
            onTap: () {
              if (user?.id != null) _go('/profile/${user!.id}');
            },
          ),
        ],
      ),
    );

    // No Feed o conteúdo passa por trás (extendBody): faixa transparente.
    // Nas outras telas a faixa reservada pinta a cor da página (antes ficava preta atrás do vidro).
    final stripColor = widget.location.startsWith('/feed')
        ? Colors.transparent
        : (onVideo ? Colors.black : colors.background);
    return Container(
      color: stripColor,
      // altura sempre igual (a cápsula anima por dentro): as telas não mudam de tamanho
      height: HomeBottomNav.reservedHeight + bottomInset,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: bottomInset > 0 ? bottomInset - 6 : 6,
          ),
          child: _glass
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: pill,
                  ),
                )
              : pill,
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
