import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/story.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../view_models/stories_view_model.dart';
import 'story_composer_screen.dart';
import 'story_viewer.dart';

/// Brawe "Pulse" Rail — substitui as antigas bolhinhas redondas estilo IG 2016.
///
/// Cards verticais 9:16 com preview real do conteúdo, borda neon animada
/// para stories não vistos, e tile "Criar" em primeiro lugar com gradiente
/// destacado. O próprio usuário é filtrado da lista (representado pelo tile
/// "Criar").
class StoriesRail extends ConsumerWidget {
  const StoriesRail({super.key});

  static const double _tileW = 92;
  static const double _tileH = 148;
  static const double _radius = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(storiesViewModelProvider);

    return SizedBox(
      height: _tileH + 14,
      child: asyncGroups.when(
        loading: () => _buildSkeleton(context),
        error: (_, _) => _buildError(context, ref),
        data: (groups) => _buildList(context, ref, groups),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: 6,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          width: _tileW,
          height: _tileH,
          decoration: BoxDecoration(
            color: context.colors.surfaceElevated,
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: TextButton.icon(
        icon: Icon(
          Icons.refresh,
          color: context.colors.textSecondary,
          size: 18,
        ),
        onPressed: () => ref.read(storiesViewModelProvider.notifier).refresh(),
        label: Text(
          S.of(context).storiesReload,
          style: TextStyle(color: context.colors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<UserStoriesGroup> groups,
  ) {
    // Filtra próprio usuário — ele já é representado pelo tile "Criar".
    final currentUserId = ref.watch(authStateProvider).asData?.value?.id;
    final mine = currentUserId == null
        ? null
        : groups
              .where((g) => g.userId == currentUserId)
              .cast<UserStoriesGroup?>()
              .firstWhere((_) => true, orElse: () => null);
    final others = currentUserId == null
        ? groups
        : groups.where((g) => g.userId != currentUserId).toList();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: others.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _CreateTile(
            width: _tileW,
            height: _tileH,
            radius: _radius,
            myGroup: mine,
            onTap: () => _openCreate(context),
            onTapMy: mine == null
                ? null
                : () => _openViewer(context, ref, mine),
          );
        }
        final g = others[index - 1];
        if (g.stories.isEmpty) return const SizedBox.shrink();
        return _StoryTile(
          width: _tileW,
          height: _tileH,
          radius: _radius,
          group: g,
          onTap: () {
            if (g.isLive && g.liveRoomId != null) {
              context.push('/live/${g.liveRoomId}');
            } else {
              _openViewer(context, ref, g);
            }
          },
        );
      },
    );
  }

  void _openCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ForceDarkTheme(child: StoryComposerScreen()),
      ),
    );
  }

  void _openViewer(
    BuildContext context,
    WidgetRef ref,
    UserStoriesGroup group,
  ) {
    // Modo imersivo — esconde status bar e nav bar do sistema durante o story.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // rootNavigator: true → sobe para o Navigator raiz (acima do ShellRoute),
    // cobrindo o BottomNavigationBar por completo — igual ao Instagram Stories.
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        pageBuilder: (_, _, _) => ForceDarkTheme(
          child: StoryViewer(
            stories: group.stories,
            initialIndex: 0,
            onStoryViewed: (id) =>
                ref.read(storiesViewModelProvider.notifier).markAsViewed(id),
          ),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 180),
      ),
    );
  }
}

/// Tile do próprio usuário — "Criar story".
///
/// Se já tem stories próprios: tap abre o viewer; long-press abre criar.
/// Sem stories: tap = criar.
class _CreateTile extends StatelessWidget {
  const _CreateTile({
    required this.width,
    required this.height,
    required this.radius,
    required this.myGroup,
    required this.onTap,
    this.onTapMy,
  });

  final double width;
  final double height;
  final double radius;
  final UserStoriesGroup? myGroup;
  final VoidCallback onTap;
  final VoidCallback? onTapMy;

  @override
  Widget build(BuildContext context) {
    final hasMine = myGroup != null && myGroup!.stories.isNotEmpty;
    final preview = hasMine ? myGroup!.stories.first : null;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: hasMine ? onTapMy : onTap,
        onLongPress: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fundo: preview do próprio story (se houver) ou gradiente neon.
              ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: preview != null
                    ? _MediaPreview(story: preview)
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.electricPurple,
                              AppColors.coolCyan,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
              ),
              // Vinheta inferior pra legibilidade.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Botão "+" centralizado no topo.
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.electricPurple,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electricPurple.withValues(
                              alpha: 0.6,
                            ),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
              // Rótulo
              Positioned(
                left: 6,
                right: 6,
                bottom: 8,
                child: Text(
                  hasMine
                      ? S.of(context).storiesYour
                      : S.of(context).storiesCreate,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tile do story de outro usuário.
class _StoryTile extends StatefulWidget {
  const _StoryTile({
    required this.width,
    required this.height,
    required this.radius,
    required this.group,
    required this.onTap,
  });

  final double width;
  final double height;
  final double radius;
  final UserStoriesGroup group;
  final VoidCallback onTap;

  @override
  State<_StoryTile> createState() => _StoryTileState();
}

class _StoryTileState extends State<_StoryTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.group.hasUnviewed) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _StoryTile old) {
    super.didUpdateWidget(old);
    if (widget.group.hasUnviewed && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.group.hasUnviewed && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    final preview = g.stories.first;
    final name =
        g.username ?? g.displayName ?? S.of(context).storiesFallbackUser;
    final unviewed = g.hasUnviewed;
    final isLive = g.isLive;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final intensity = (isLive || unviewed)
                ? (0.35 + 0.35 * _pulse.value)
                : 0.0;
            final glowColor = isLive
                ? AppColors.mutedRed
                : AppColors.electricPurple;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius + 2),
                boxShadow: (isLive || unviewed)
                    ? [
                        BoxShadow(
                          color: glowColor.withValues(alpha: intensity),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: EdgeInsets.all((isLive || unviewed) ? 2.0 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius + 2),
              gradient: isLive
                  ? const LinearGradient(
                      colors: [AppColors.mutedRed, AppColors.electricPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : unviewed
                  ? const LinearGradient(
                      colors: [AppColors.electricPurple, AppColors.coolCyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: (isLive || unviewed) ? null : Colors.transparent,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _MediaPreview(story: preview),
                  // Vinheta inferior
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Avatar mini no topo
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _AvatarMini(
                      avatarUrl: g.avatarUrl,
                      initial: name.characters.first.toUpperCase(),
                      isVerified: g.isVerified,
                    ),
                  ),
                  // Badge LIVE pulsante (quando o creator está ao vivo)
                  if (isLive)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _LiveBadge(pulse: _pulse),
                    ),
                  // Contador (X+1 se houver mais de um) — só se não estiver live
                  if (!isLive && g.stories.length > 1)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${g.stories.length}',
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  // Nome
                  Positioned(
                    left: 6,
                    right: 6,
                    bottom: 8,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
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

class _AvatarMini extends StatelessWidget {
  const _AvatarMini({
    required this.avatarUrl,
    required this.initial,
    required this.isVerified,
  });

  final String? avatarUrl;
  final String initial;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.textPrimary, width: 2),
        color: context.colors.surfaceElevated,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: hasImage
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    width: 26,
                    height: 26,
                    errorBuilder: (_, _, _) => _initialFallback(context),
                  )
                : _initialFallback(context),
          ),
          if (isVerified)
            const Positioned(
              right: -3,
              bottom: -3,
              child: Icon(
                Icons.verified,
                size: 12,
                color: AppColors.electricPurple,
              ),
            ),
        ],
      ),
    );
  }

  Widget _initialFallback(BuildContext context) => Container(
    width: 26,
    height: 26,
    alignment: Alignment.center,
    color: context.colors.surfaceElevated,
    child: Text(
      initial,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// Preview do conteúdo do story.
///
/// - Fotos: [Image.network] direto na [mediaUrl].
/// - Vídeos com [thumbnailUrl]: usa a thumb (mais leve, ideal).
/// - Vídeos sem thumb: cai no [_VideoFramePreview] que carrega o primeiro
///   frame com [VideoPlayerController] e pausa — sem áudio, sem loop.
class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.story});
  final Story story;

  @override
  Widget build(BuildContext context) {
    final isVideo = story.isVideo;
    final thumb = story.thumbnailUrl;
    final mediaUrl = story.mediaUrl;

    Widget content;
    if (!isVideo) {
      content = mediaUrl.isEmpty
          ? Container(color: context.colors.surfaceElevated)
          : _NetworkImage(url: mediaUrl);
    } else if (thumb != null && thumb.isNotEmpty) {
      content = _NetworkImage(url: thumb);
    } else if (mediaUrl.isNotEmpty) {
      content = _VideoFramePreview(url: mediaUrl);
    } else {
      content = Container(color: context.colors.surfaceElevated);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        content,
        if (isVideo)
          Positioned(
            right: 6,
            bottom: 28,
            child: Icon(
              Icons.play_circle_filled_rounded,
              size: 18,
              color: context.colors.textPrimary,
              shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),
      ],
    );
  }
}

/// Pequeno helper para [Image.network] com loading/erro consistentes.
class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) =>
          Container(color: context.colors.surfaceElevated),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: context.colors.surfaceElevated,
          alignment: Alignment.center,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: context.colors.textTertiary,
            ),
          ),
        );
      },
    );
  }
}

/// Preview de vídeo no rail: inicializa [VideoPlayerController.networkUrl],
/// renderiza o primeiro frame e pausa imediatamente. Sem som, sem loop.
///
/// Usado **apenas** quando o backend não devolve [Story.thumbnailUrl].
/// Em produção o ideal é o backend gerar a thumb no upload — esse widget
/// é o plano B pra não ter rail vazio.
class _VideoFramePreview extends StatefulWidget {
  const _VideoFramePreview({required this.url});
  final String url;

  @override
  State<_VideoFramePreview> createState() => _VideoFramePreviewState();
}

class _VideoFramePreviewState extends State<_VideoFramePreview> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _controller = c;
      await c.initialize();
      await c.setVolume(0);
      await c.seekTo(Duration.zero);
      await c.pause();
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Container(color: context.colors.surfaceElevated);
    }
    final c = _controller;
    if (!_ready || c == null || !c.value.isInitialized) {
      return Container(
        color: context.colors.surfaceElevated,
        alignment: Alignment.center,
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: context.colors.textTertiary,
          ),
        ),
      );
    }
    // BoxFit.cover via FittedBox para o tile 9:16 não distorcer o frame.
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: c.value.size.width,
        height: c.value.size.height,
        child: VideoPlayer(c),
      ),
    );
  }
}

/// Silenciador de warning quando o pacote dart:async não for usado
/// em algum build profile.
// ignore: unused_element
void _keepDartAsync(Timer? t) {}

/// Badge "LIVE" vermelho pulsante, exibido no canto superior direito
/// de um [_StoryTile] quando o creator está com uma live ativa.
class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        final t = pulse.value; // 0..1
        final scale = 1.0 + 0.06 * t;
        return Transform.scale(
          scale: scale,
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF3344), AppColors.mutedRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mutedRed.withValues(alpha: 0.55 * t + 0.25),
                  blurRadius: 8,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85 + 0.15 * t),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  S.of(context).storiesLiveBadge,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
