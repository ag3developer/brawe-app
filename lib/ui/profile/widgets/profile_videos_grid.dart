import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'dart:async';

import '../../../data/repositories/post_repository.dart';
import '../../../data/services/feedback_service.dart';
import '../../../domain/models/post.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../core/text/brawe_rich_text.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../core/view_models/profile_view_model.dart';
import '../../feed/widgets/create_post_sheet.dart';
import '../../feed/widgets/media_comments_layout.dart';
import '../../feed/widgets/one_tap_repost.dart';
import '../../feed/widgets/reactions_bar.dart';
import '../../feed/widgets/share_to_chat_sheet.dart';
import '../../core/themes/app_colors.dart';
import '../../feed/widgets/story_composer_screen.dart';
import '../../../core/network/media_headers.dart';
import 'package:brawe_app/core/media/media_utils.dart';

/// Abre o criador de post (mesma folha do botão "+" da barra de navegação).
void showProfileCreatePost(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CreatePostSheet(),
  );
}

/// Estado vazio amigável das abas do perfil. No próprio perfil traz a ação
/// "Publicar"; no de outras pessoas, só a mensagem.
class ProfileEmptyState extends StatelessWidget {
  const ProfileEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 56, 32, 32),
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surfaceHighest,
            ),
            child: Icon(icon, size: 30, color: colors.textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accentPrimary,
                  foregroundColor: colors.textOnAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Grade do perfil: 3 colunas, miniaturas quadradas (estilo Instagram).
///
/// Com [videosOnly] = `false` mostra todos os posts com foto ou vídeo (aba
/// "grade"); com `true`, só os vídeos (aba "vídeos"). Vídeo abre o visor
/// estilo Reels; foto abre o post.
///
/// Se for o próprio perfil (`isMe`), permite **apagar** o vídeo via long-press
/// ou pelo menu de três pontos do visor.
class ProfileVideosGrid extends ConsumerWidget {
  const ProfileVideosGrid({
    super.key,
    required this.userId,
    required this.isMe,
    required this.postsState,
    this.videosOnly = true,
  });

  final String userId;
  final bool isMe;
  final AsyncValue<List<Post>> postsState;
  final bool videosOnly;

  static bool _isVideo(Post p) =>
      isVideoMedia(mediaType: p.mediaType, url: p.imageUrl);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    return postsState.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: context.colors.accentPrimary),
      ),
      error: (_, _) => ProfileEmptyState(
        icon: LucideIcons.circleAlert,
        title: videosOnly ? s.profileVideosLoadError : s.profilePostsLoadError,
      ),
      data: (posts) {
        final videos = posts.where(_isVideo).toList(growable: false);
        final items = videosOnly
            ? videos
            : posts
                  .where((p) => (p.imageUrl ?? '').isNotEmpty)
                  .toList(growable: false);
        if (items.isEmpty) {
          return ProfileEmptyState(
            icon: videosOnly ? LucideIcons.clapperboard : LucideIcons.camera,
            title: videosOnly
                ? (isMe ? s.profileEmptyMeVideos : s.profileVideosEmpty)
                : (isMe ? s.profileEmptyMeGrid : s.profileEmptyOtherGrid),
            actionLabel: isMe ? s.profileEmptyMeAction : null,
            onAction: isMe ? () => showProfileCreatePost(context) : null,
          );
        }
        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 2, bottom: 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final post = items[i];
            return _MediaTile(
              userId: userId,
              post: post,
              videos: videos,
              videoIndex: videos.indexWhere((v) => v.id == post.id),
              isMe: isMe,
            );
          },
        );
      },
    );
  }
}

class _MediaTile extends ConsumerWidget {
  const _MediaTile({
    required this.userId,
    required this.post,
    required this.videos,
    required this.videoIndex,
    required this.isMe,
  });
  final String userId;
  final Post post;
  final List<Post> videos;

  /// Posição deste post em [videos]; `-1` quando é foto.
  final int videoIndex;
  final bool isMe;

  bool get _isVideo => videoIndex >= 0;

  /// Vídeo: capa gerada pelo Bunny. A grade NUNCA abre player de vídeo:
  /// antes, vídeo sem capa abria um player por célula só para mostrar o 1º
  /// quadro — com várias células visíveis o Android ficava sem memória e
  /// matava o app. Foto: a própria imagem.
  String? get _thumbUrl {
    if (_isVideo) {
      final u = post.coverUrl;
      return (u != null && u.isNotEmpty) ? u : null;
    }
    final t = post.thumbnailUrl;
    if (t != null && t.isNotEmpty) return t;
    return post.imageUrl;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final thumb = _thumbUrl;
    return GestureDetector(
      onTap: () {
        if (_isVideo) {
          // Navegador raiz: tela cheia cobre a barra de navegação do app.
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => _VideoPostViewer(
                userId: userId,
                videos: videos,
                initialIndex: videoIndex,
                isMe: isMe,
              ),
            ),
          );
        } else {
          context.push('/post/${post.id}');
        }
      },
      onLongPress: _isVideo && isMe
          ? () => _confirmDelete(context, ref, post: post)
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: colors.surfaceHighest),
          if (thumb != null)
            Image.network(
              thumb,
              headers: mediaHeadersFor(thumb),
              fit: BoxFit.cover,
              // Célula da grade (3 colunas): decodifica nesse tamanho.
              cacheWidth:
                  (MediaQuery.sizeOf(context).width /
                          3 *
                          MediaQuery.devicePixelRatioOf(context))
                      .round(),
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          // Vídeo sem capa: fundo neutro + play (sem abrir player na grade).
          if (_isVideo && thumb == null)
            Center(
              child: Icon(
                LucideIcons.play,
                color: colors.textTertiary,
                size: 28,
              ),
            ),
          if (_isVideo) ...[
            // Gradiente sutil embaixo, para a contagem de views.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),
            const Positioned(
              right: 6,
              top: 6,
              child: Icon(
                LucideIcons.video,
                color: Colors.white,
                size: 16,
                shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
              ),
            ),
            if (post.viewsCount > 0)
              Positioned(
                left: 6,
                bottom: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.play,
                      color: Colors.white,
                      size: 12,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatCount(post.viewsCount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
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
            style: TextStyle(color: ctx.colors.danger),
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

  /// Painel de comentários embutido: o vídeo encolhe acima dele e segue tocando.
  final MediaCommentsController _comments = MediaCommentsController();
  bool _showHint = true;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
    _comments.addListener(_onCommentsChanged);
    _hintTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  void _onCommentsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _comments.removeListener(_onCommentsChanged);
    _comments.dispose();
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
    final commentsOpen = _comments.isOpen;
    return Scaffold(
      // Fullscreen video viewer: always dark behind the media.
      backgroundColor: Colors.black,
      // O teclado dos comentários é tratado pelo MediaCommentsLayout.
      resizeToAvoidBottomInset: false,
      body: MediaCommentsLayout(
        controller: _comments,
        media: PageView.builder(
          controller: _pageCtrl,
          scrollDirection: Axis.vertical,
          physics: commentsOpen ? const NeverScrollableScrollPhysics() : null,
          itemCount: widget.videos.length,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemBuilder: (_, i) => _ViewerPage(
            key: ValueKey(widget.videos[i].id),
            post: widget.videos[i],
            isActive: i == _currentIndex,
            isMe: widget.isMe,
            comments: _comments,
            commentsOpen: commentsOpen,
            onDelete: () => _handleDelete(widget.videos[i]),
            onStory: () => _repostAsStory(widget.videos[i]),
          ),
        ),
        overlay: Stack(
          fit: StackFit.expand,
          children: [
            // Top bar (botão voltar + menu)
            SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  if (widget.isMe)
                    PopupMenuButton<String>(
                      icon: const Icon(
                        LucideIcons.ellipsisVertical,
                        color: Colors.white,
                      ),
                      color: context.colors.surfaceElevated,
                      onSelected: (v) async {
                        if (v == 'delete') {
                          await _handleDelete(widget.videos[_currentIndex]);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.trash2,
                                color: ctx.colors.danger,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                S.of(ctx).profileVideoDeleteAction,
                                style: TextStyle(color: ctx.colors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Dica "deslize pra cima": só na primeira página, nos primeiros segundos
            if (_showHint &&
                _currentIndex == widget.initialIndex &&
                widget.videos.length > 1)
              Positioned(
                left: 0,
                right: 0,
                top: MediaQuery.paddingOf(context).top + 60,
                child: const IgnorePointer(child: Center(child: _SwipeHint())),
              ),
          ],
        ),
      ),
    );
  }
}

/// Página individual do PageView — gerencia seu próprio controller de vídeo
/// e respeita o estado `isActive` para autoplay/pausa.
class _ViewerPage extends ConsumerStatefulWidget {
  const _ViewerPage({
    super.key,
    required this.post,
    required this.isActive,
    required this.isMe,
    required this.comments,
    required this.commentsOpen,
    required this.onDelete,
    required this.onStory,
  });
  final Post post;
  final bool isActive;
  final bool isMe;
  final MediaCommentsController comments;

  /// Comentários abertos: some a interface por cima do vídeo (que encolhe).
  final bool commentsOpen;
  final VoidCallback onDelete;
  final VoidCallback onStory;

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

  // Estado local (otimista) das ações, como no rail do Para você.
  late bool _liked = widget.post.userLiked;
  late int _likes = widget.post.likesCount;
  late bool _reposted = widget.post.userReposted;
  late int _reposts = widget.post.repostsCount;
  late int _commentsCount = widget.post.commentsCount;
  bool _watchingComments = false;
  bool _busyLike = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _onLike() async {
    if (_busyLike) return;
    _busyLike = true;
    ref.read(feedbackServiceProvider).like();
    final was = _liked;
    final wasCount = _likes;
    setState(() {
      _liked = !was;
      _likes = (wasCount + (was ? -1 : 1)).clamp(0, 1 << 30);
    });
    try {
      await ref.read(postRepositoryProvider).toggleLike(widget.post.id, was);
    } catch (_) {
      if (mounted) {
        setState(() {
          _liked = was;
          _likes = wasCount;
        });
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(S.of(context).feedCannotLike),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _busyLike = false;
    }
  }

  Future<void> _onLikeLongPress() async {
    ref.read(feedbackServiceProvider).reaction();
    final size = MediaQuery.sizeOf(context);
    final picked = await showReactionsBar(
      context,
      globalPosition: Offset(size.width - 56, size.height * 0.55),
    );
    if (picked == null || !mounted) return;
    if (!_liked) {
      setState(() {
        _liked = true;
        _likes += 1;
      });
    }
    try {
      await ref.read(postRepositoryProvider).react(widget.post.id, picked.key);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(S.of(context).feedCannotLike),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onComment() {
    HapticFeedback.selectionClick();
    if (!_watchingComments) {
      _watchingComments = true;
      watchCommentsCount(ref, widget.post.id, _commentsCount, (count) {
        if (mounted) setState(() => _commentsCount = count);
      });
    }
    widget.comments.open(widget.post.id);
  }

  Future<void> _onRepost() => oneTapRepost(
    context: context,
    ref: ref,
    postId: widget.post.id,
    currentlyReposted: _reposted,
    apply: (reposted) {
      if (!mounted) return;
      setState(() {
        _reposted = reposted;
        _reposts = (_reposts + (reposted ? 1 : -1)).clamp(0, 1 << 30);
      });
    },
  );

  void _onShare() {
    ref.read(feedbackServiceProvider).share();
    ShareToChatSheet.show(
      context,
      postId: widget.post.id,
      postCaption: widget.post.content,
      storyMediaUrl: widget.post.imageUrl,
    );
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
      httpHeaders: mediaHeadersFor(url),
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
            Builder(
              builder: (context) {
                final c = _ctrl!;
                final screen = MediaQuery.sizeOf(context);
                final screenAspect = screen.width / screen.height;
                final a = c.value.aspectRatio;
                // Vídeo em pé (≈ proporção da tela): preenche. Deitado,
                // quadrado, 4:3…: mostra INTEIRO sobre o fundo desfocado
                // (antes era cortado para preencher a tela).
                final fill = a > 0 && a <= screenAspect * 1.15;
                final player = FittedBox(
                  fit: fill ? BoxFit.cover : BoxFit.contain,
                  child: SizedBox(
                    width: c.value.size.width,
                    height: c.value.size.height,
                    child: VideoPlayer(c),
                  ),
                );
                if (fill) return SizedBox.expand(child: player);
                final cover = post.coverUrl;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: Colors.black),
                    if (cover != null && cover.isNotEmpty)
                      ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                          sigmaX: 28,
                          sigmaY: 28,
                        ),
                        child: Opacity(
                          opacity: 0.55,
                          child: CachedNetworkImage(
                            imageUrl: cover,
                            fit: BoxFit.cover,
                            memCacheWidth: 300,
                            errorWidget: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    Center(child: player),
                  ],
                );
              },
            ),
          if (!_initialized && !_failed)
            Center(
              child: CircularProgressIndicator(
                color: context.colors.accentPrimary,
              ),
            ),
          if (_failed)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.circleAlert,
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
          Positioned.fill(
            child: IgnorePointer(
              ignoring: widget.commentsOpen,
              child: AnimatedOpacity(
                opacity: widget.commentsOpen ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Stack(
                  children: [
                    // Autor + caption + visualizações (somem com os comentários abertos)
                    Positioned(
                      left: 16,
                      right: 80,
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
                                            color:
                                                context.colors.surfaceElevated,
                                          ),
                                        )
                                      : Container(
                                          color: context.colors.surfaceElevated,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '@${post.author.username}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black87,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (post.content.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: BraweRichText(
                                post.content,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black87,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          _Metric(
                            icon: LucideIcons.eye,
                            value: post.viewsCount,
                          ),
                        ],
                      ),
                    ),
                    // Rail de ações (igual ao do Para você): curtir, comentar,
                    // repostar, enviar e repostar no Story.
                    Positioned(
                      right: 8,
                      bottom: 56,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RailBtn(
                            icon: _liked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _liked ? Colors.red : Colors.white,
                            label: _formatCount(_likes),
                            onTap: _onLike,
                            onLongPress: _onLikeLongPress,
                            onLabelTap: () =>
                                context.push('/post/${post.id}/likes'),
                          ),
                          const SizedBox(height: 18),
                          _RailBtn(
                            icon: Icons.mode_comment_outlined,
                            label: _formatCount(_commentsCount),
                            onTap: _onComment,
                          ),
                          const SizedBox(height: 18),
                          _RailBtn(
                            icon: Icons.repeat_rounded,
                            color: _reposted ? AppColors.success : Colors.white,
                            label: _formatCount(_reposts),
                            onTap: _onRepost,
                          ),
                          const SizedBox(height: 18),
                          _RailBtn(
                            icon: Icons.send_rounded,
                            label: S.of(context).actionShare,
                            onTap: _onShare,
                          ),
                          const SizedBox(height: 18),
                          _RailBtn(
                            icon: LucideIcons.aperture,
                            label: S.of(context).mediaStoryLabel,
                            semantics: S.of(context).mediaRepostStoryTooltip,
                            onTap: widget.onStory,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                    playedColor: context.colors.accentPrimary,
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

/// Botão do rail lateral (ícone + contagem/rótulo), igual ao do Para você.
class _RailBtn extends StatelessWidget {
  const _RailBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
    this.onLongPress,
    this.onLabelTap,
    this.semantics,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onLabelTap;
  final String? semantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantics ?? label,
      excludeSemantics: true,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              icon,
              color: color,
              size: 32,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onLabelTap ?? onTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
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
            LucideIcons.chevronUp,
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
