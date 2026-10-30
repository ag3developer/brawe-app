import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import 'dart:async';

import '../../../data/repositories/post_repository.dart';
import '../../../domain/models/post.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../core/text/brawe_rich_text.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../core/view_models/profile_view_model.dart';
import '../../feed/widgets/story_composer_screen.dart';

/// Grid de vídeos do perfil — mostra os vídeos publicados pelo usuário
/// na aba "Para Você" (posts com `imageUrl` em `.mp4/.mov/.webm`).
///
/// Se for o próprio perfil (`isMe`), permite **apagar** o vídeo via long-press
/// ou tap no menu de três pontos do viewer.
class ProfileVideosGrid extends ConsumerWidget {
  const ProfileVideosGrid({
    super.key,
    required this.userId,
    required this.isMe,
    required this.postsState,
  });

  final String userId;
  final bool isMe;
  final AsyncValue<List<Post>> postsState;

  static bool _isVideoUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.m4v');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return postsState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.electricPurple),
      ),
      error: (_, _) => _EmptyVideos(
        icon: Icons.error_outline,
        message: S.of(context).profileVideosLoadError,
      ),
      data: (posts) {
        final videos = posts
            .where((p) => _isVideoUrl(p.imageUrl))
            .toList(growable: false);
        if (videos.isEmpty) {
          return _EmptyVideos(
            icon: Icons.video_library_outlined,
            message: S.of(context).profileVideosEmpty,
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3 / 4,
          ),
          itemCount: videos.length,
          itemBuilder: (_, i) => _VideoTile(
            userId: userId,
            post: videos[i],
            videos: videos,
            initialIndex: i,
            isMe: isMe,
          ),
        );
      },
    );
  }
}

class _VideoTile extends ConsumerStatefulWidget {
  const _VideoTile({
    required this.userId,
    required this.post,
    required this.videos,
    required this.initialIndex,
    required this.isMe,
  });
  final String userId;
  final Post post;
  final List<Post> videos;
  final int initialIndex;
  final bool isMe;

  @override
  ConsumerState<_VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends ConsumerState<_VideoTile> {
  VideoPlayerController? _ctrl;
  bool _ready = false;
  bool _failed = false;

  /// Capa gerada pelo Bunny: quando existe, a miniatura é só uma imagem —
  /// sem abrir um player de vídeo por célula da grade.
  String? get _posterUrl {
    final u = widget.post.hlsThumbnailUrl;
    return (u != null && u.isNotEmpty) ? u : null;
  }

  @override
  void initState() {
    super.initState();
    if (_posterUrl == null) _initThumb();
  }

  /// Carrega o vídeo, posiciona no primeiro frame e mantém pausado
  /// (silencioso) — vira "thumbnail real" sem precisar de package nativo.
  Future<void> _initThumb() async {
    final url = widget.post.imageUrl ?? '';
    if (url.isEmpty) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    final c = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _ctrl = c;
    try {
      await c.initialize();
      await c.setVolume(0);
      await c.setLooping(false);
      await c.seekTo(Duration.zero);
      await c.pause();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _ready = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => _VideoPostViewer(
            userId: widget.userId,
            videos: widget.videos,
            initialIndex: widget.initialIndex,
            isMe: widget.isMe,
          ),
        ),
      ),
      onLongPress: widget.isMe
          ? () => _confirmDelete(context, ref, post: post)
          : null,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fundo escuro fallback
            Container(color: const Color(0xFF111122)),

            if (_posterUrl != null)
              Image.network(
                _posterUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),

            // Frame real do vídeo (preview)
            if (_ready && _ctrl != null)
              ClipRRect(
                borderRadius: BorderRadius.zero,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _ctrl!.value.size.width,
                    height: _ctrl!.value.size.height,
                    child: VideoPlayer(_ctrl!),
                  ),
                ),
              ),

            // Loading shimmer-ish enquanto carrega
            if (_posterUrl == null && !_ready && !_failed)
              const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white38,
                    strokeWidth: 2,
                  ),
                ),
              ),

            if (_failed)
              const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.white24,
                  size: 24,
                ),
              ),

            // Gradiente sutil pra legibilidade dos overlays
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // Play badge central (estilo Reels)
            IgnorePointer(
              child: Center(
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.4),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Likes (canto inferior esquerdo)
            if (post.likesCount > 0)
              Positioned(
                left: 6,
                bottom: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 12,
                      shadows: const [
                        Shadow(color: Colors.black87, blurRadius: 2),
                      ],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${post.likesCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 2)],
                      ),
                    ),
                  ],
                ),
              ),

            // Views (canto inferior direito)
            if (post.viewsCount > 0)
              Positioned(
                right: 6,
                bottom: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.remove_red_eye,
                      color: Colors.white,
                      size: 12,
                      shadows: const [
                        Shadow(color: Colors.black87, blurRadius: 2),
                      ],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatCount(post.viewsCount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 2)],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _formatCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref, {
  required Post post,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.colors.surface,
      title: Text(
        S.of(ctx).profileVideoDeleteTitle,
        style: TextStyle(color: ctx.colors.textPrimary),
      ),
      content: Text(
        S.of(ctx).profileVideoDeleteBody,
        style: TextStyle(color: ctx.colors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            S.of(ctx).actionCancel,
            style: TextStyle(color: ctx.colors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            S.of(ctx).profileVideoDelete,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await ref.read(postRepositoryProvider).deletePost(post.id);
    // Atualiza posts do perfil (a aba Vídeos vai re-filtrar sozinha).
    await ref.read(profileViewModelProvider(post.author.id).notifier).refresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.of(context).profileVideoDeleted)));
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).profileVideoDeleteError)),
    );
  }
}

/// Viewer fullscreen estilo Reels — `PageView` vertical com TODOS os
/// vídeos do perfil, autoplay no ativo, pausa nos demais.
class _VideoPostViewer extends ConsumerStatefulWidget {
  const _VideoPostViewer({
    required this.userId,
    required this.videos,
    required this.initialIndex,
    required this.isMe,
  });
  final String userId;
  final List<Post> videos;
  final int initialIndex;
  final bool isMe;

  @override
  ConsumerState<_VideoPostViewer> createState() => _VideoPostViewerState();
}

class _VideoPostViewerState extends ConsumerState<_VideoPostViewer> {
  late final PageController _pageCtrl;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleDelete(Post post) async {
    await _confirmDelete(context, ref, post: post);
    if (!mounted) return;
    // Se só restava 1 vídeo, fecha o viewer.
    if (widget.videos.length <= 1) {
      Navigator.of(context).pop();
    }
  }

  void _repostAsStory(Post post) {
    final url = post.imageUrl;
    if (url == null || url.isEmpty) return;
    HapticFeedback.selectionClick();
    // rootNavigator: o editor de story é tela cheia — cobre a barra de
    // navegação (antes abria dentro da aba e a nav ficava por cima).
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ForceDarkTheme(
          child: StoryComposerScreen(
            initialRemoteUrl: url,
            initialOriginPostId: post.id,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            scrollDirection: Axis.vertical,
            itemCount: widget.videos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => _ViewerPage(
              post: widget.videos[i],
              isActive: i == _currentIndex,
              isMe: widget.isMe,
              onDelete: () => _handleDelete(widget.videos[i]),
            ),
          ),
          // Top bar (botão voltar + menu)
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                // Repostar no Stories — mesmo ícone (LucideIcons.aperture) usado
                // no atalho de criar Story no bottom nav, p/ reforçar memória.
                IconButton(
                  tooltip: S.of(context).profileVideoRepostStory,
                  icon: const Icon(LucideIcons.aperture, color: Colors.white),
                  onPressed: () => _repostAsStory(widget.videos[_currentIndex]),
                ),
                if (widget.isMe)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    color: const Color(0xFF1C1C2E),
                    onSelected: (v) async {
                      if (v == 'delete') {
                        await _handleDelete(widget.videos[_currentIndex]);
                      } else if (v == 'story') {
                        _repostAsStory(widget.videos[_currentIndex]);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'story',
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.aperture,
                              color: Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              S.of(ctx).profileVideoRepostStory,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              S.of(ctx).profileVideoDeleteAction,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Hint "deslize pra cima" só na primeira página, primeiros segundos
          if (_currentIndex == widget.initialIndex && widget.videos.length > 1)
            const Positioned(
              right: 12,
              top: 80,
              child: IgnorePointer(child: _SwipeHint()),
            ),
        ],
      ),
    );
  }
}

/// Página individual do PageView — gerencia seu próprio controller de vídeo
/// e respeita o estado `isActive` para autoplay/pausa.
class _ViewerPage extends ConsumerStatefulWidget {
  const _ViewerPage({
    required this.post,
    required this.isActive,
    required this.isMe,
    required this.onDelete,
  });
  final Post post;
  final bool isActive;
  final bool isMe;
  final VoidCallback onDelete;

  @override
  ConsumerState<_ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends ConsumerState<_ViewerPage> {
  VideoPlayerController? _ctrl;
  bool _initialized = false;
  bool _failed = false;
  bool _userPaused = false;

  // View tracking — 1 view após 3s de reprodução ativa.
  Timer? _viewTimer;
  bool _viewSent = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant _ViewerPage old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive) _applyActive();
  }

  Future<void> _init() async {
    // HLS leve (Bunny) quando já convertido; senão o arquivo original.
    final url = widget.post.hlsUrl ?? widget.post.imageUrl ?? '';
    if (url.isEmpty) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    final c = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _ctrl = c;
    try {
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(1.0);
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _initialized = true);
      _applyActive();
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  void _applyActive() {
    final c = _ctrl;
    if (c == null || !_initialized) return;
    if (widget.isActive && !_userPaused) {
      c.play();
      _scheduleViewTracking();
    } else {
      c.pause();
      _viewTimer?.cancel();
      if (!widget.isActive) {
        c.seekTo(Duration.zero);
        _userPaused = false;
      }
    }
  }

  void _scheduleViewTracking() {
    if (_viewSent) return;
    _viewTimer?.cancel();
    _viewTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _viewSent) return;
      final c = _ctrl;
      if (c == null || !c.value.isPlaying) return;
      _viewSent = true;
      ref.read(postRepositoryProvider).incrementView(widget.post.id);
    });
  }

  @override
  void dispose() {
    _viewTimer?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _ctrl;
    if (c == null || !_initialized) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
        _viewTimer?.cancel();
        _userPaused = true;
      } else {
        c.play();
        _userPaused = false;
        _scheduleViewTracking();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return GestureDetector(
      onTap: _togglePlay,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_initialized && _ctrl != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _ctrl!.value.size.width,
                  height: _ctrl!.value.size.height,
                  child: VideoPlayer(_ctrl!),
                ),
              ),
            ),
          if (!_initialized && !_failed)
            const Center(
              child: CircularProgressIndicator(color: AppColors.electricPurple),
            ),
          if (_failed)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white54,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).profileVideoLoadError,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          // Gradiente p/ legibilidade
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.2, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // Métricas + autor + caption
          Positioned(
            left: 16,
            right: 16,
            bottom: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: post.author.avatarUrl != null
                            ? CachedNetworkImage(
                                imageUrl: post.author.avatarUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => Container(
                                  color: context.colors.surfaceElevated,
                                ),
                              )
                            : Container(color: context.colors.surfaceElevated),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '@${post.author.username}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 3)],
                      ),
                    ),
                  ],
                ),
                if (post.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: BraweRichText(
                      post.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 3)],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Metric(icon: Icons.favorite, value: post.likesCount),
                    const SizedBox(width: 14),
                    _Metric(
                      icon: Icons.mode_comment_outlined,
                      value: post.commentsCount,
                    ),
                    const SizedBox(width: 14),
                    _Metric(
                      icon: Icons.repeat_rounded,
                      value: post.repostsCount,
                    ),
                    const SizedBox(width: 14),
                    _Metric(
                      icon: Icons.remove_red_eye_outlined,
                      value: post.viewsCount,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Barra de progresso
          if (_initialized && _ctrl != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: VideoProgressIndicator(
                  _ctrl!,
                  allowScrubbing: false,
                  padding: EdgeInsets.zero,
                  colors: VideoProgressColors(
                    playedColor: AppColors.electricPurple,
                    bufferedColor: Colors.white.withValues(alpha: 0.25),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SwipeHint extends StatefulWidget {
  const _SwipeHint();
  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_c),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.keyboard_arrow_up,
            color: Colors.white.withValues(alpha: 0.9),
            size: 28,
          ),
          Text(
            S.of(context).profileVideoSwipeHint,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value});
  final IconData icon;
  final int value;

  String _f(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 16,
          shadows: const [Shadow(color: Colors.black87, blurRadius: 2)],
        ),
        const SizedBox(width: 4),
        Text(
          _f(value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black87, blurRadius: 2)],
          ),
        ),
      ],
    );
  }
}

class _EmptyVideos extends StatelessWidget {
  const _EmptyVideos({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: Colors.white24),
                const SizedBox(height: 8),
                Text(message, style: const TextStyle(color: Colors.white54)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
