// ============================================================================
// SHARED POST SHEET — preview rico de post compartilhado no chat
// ============================================================================
// Bottom sheet inteligente que abre quando o usuário toca em um card de
// post compartilhado dentro do chat. Mostra TUDO sem sair da conversa:
//   • Header com autor (avatar + nome + verified + botão "ver perfil")
//   • Mídia: imagem zoomável OU vídeo com autoplay (mute por padrão, tap-to-unmute)
//   • Caption completa (expansível)
//   • Stats: likes, comments, reposts, views
//   • Ações: ❤️ Like (toggle), 💬 Comentar (snack "abra a publicação"),
//            🔁 Repost, ↗️ Compartilhar de novo
//   • Long-press no Like abre seletor de reações (👍 ❤️ 😂 😮 😢 😡)
//   • Rodapé: "Abrir publicação completa" como fallback
//
// Suporta tema claro/escuro via context.colors e i18n via S.of(context).
// ============================================================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../data/repositories/post_repository.dart';
import '../../../data/services/feedback_service.dart';
import '../../../domain/models/post.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../core/text/brawe_rich_text.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../feed/widgets/comments_sheet.dart';
import '../../feed/widgets/share_to_chat_sheet.dart';
import '../../../core/network/media_headers.dart';

bool _isVideoUrl(String url) {
  final u = url.toLowerCase().split('?').first;
  return u.endsWith('.mp4') ||
      u.endsWith('.mov') ||
      u.endsWith('.webm') ||
      u.endsWith('.m4v');
}

/// Provider local para refetch ao tocar em like / repost.
final _sharedPostDetailProvider = FutureProvider.autoDispose
    .family<Post, String>((ref, postId) async {
      ref.keepAlive();
      final repo = ref.watch(postRepositoryProvider);
      return repo.getById(postId);
    });

class SharedPostSheet extends ConsumerStatefulWidget {
  const SharedPostSheet({super.key, required this.postId});
  final String postId;

  static Future<void> show(BuildContext context, String postId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => SharedPostSheet(postId: postId),
    );
  }

  @override
  ConsumerState<SharedPostSheet> createState() => _SharedPostSheetState();
}

class _SharedPostSheetState extends ConsumerState<SharedPostSheet> {
  // Estado otimista para like / repost — atualiza UI antes da resposta.
  bool? _optimisticLiked;
  bool? _optimisticReposted;
  int _likesDelta = 0;
  int _repostsDelta = 0;

  @override
  void initState() {
    super.initState();
    // Conta a visualização (best-effort).
    Future.microtask(() {
      ref
          .read(postRepositoryProvider)
          .incrementView(widget.postId)
          .catchError((_) {});
    });
  }

  Future<void> _toggleLike(Post post) async {
    final fb = ref.read(feedbackServiceProvider);
    fb.like();
    final wasLiked = _optimisticLiked ?? post.userLiked;
    setState(() {
      _optimisticLiked = !wasLiked;
      _likesDelta += wasLiked ? -1 : 1;
    });
    try {
      await ref.read(postRepositoryProvider).toggleLike(post.id, wasLiked);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _optimisticLiked = wasLiked;
        _likesDelta += wasLiked ? 1 : -1;
      });
    }
  }

  Future<void> _showReactionPicker(Post post) async {
    HapticFeedback.mediumImpact();
    final s = S.of(context);
    final reactions = const [
      ('like', '👍'),
      ('love', '❤️'),
      ('haha', '😂'),
      ('wow', '😮'),
      ('sad', '😢'),
      ('angry', '😡'),
    ];
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final r in reactions)
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(r.$1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(r.$2, style: const TextStyle(fontSize: 32)),
                ),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    try {
      await ref.read(postRepositoryProvider).react(post.id, chosen);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.sharedPostReactionApplied)));
    } catch (_) {
      /* ignore */
    }
  }

  Future<void> _toggleRepost(Post post) async {
    final fb = ref.read(feedbackServiceProvider);
    fb.like();
    final wasReposted = _optimisticReposted ?? post.userReposted;
    setState(() {
      _optimisticReposted = !wasReposted;
      _repostsDelta += wasReposted ? -1 : 1;
    });
    try {
      await ref.read(postRepositoryProvider).toggleRepost(post.id, wasReposted);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _optimisticReposted = wasReposted;
        _repostsDelta += wasReposted ? 1 : -1;
      });
    }
  }

  void _shareAgain(Post post) {
    Navigator.of(context).pop();
    ShareToChatSheet.show(
      context,
      postId: post.id,
      postCaption: post.content,
      postImageUrl: post.imageUrl,
      authorName: post.author.name,
    );
  }

  void _openAuthor(Post post) {
    final router = GoRouter.of(context);
    final nav = Navigator.of(context);
    router.push('/profile/${post.author.id}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (nav.canPop()) nav.pop();
    });
  }

  void _openComments(Post post) {
    // Abre o CommentsSheet DIRETAMENTE — não dependemos da PostDetailScreen.
    // Fecha primeiro o preview do post compartilhado, depois abre o sheet
    // de comentários no próximo frame para a animação não colidir.
    final rootContext = context;
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: rootContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useSafeArea: true,
        builder: (_) => CommentsSheet(postId: post.id),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncPost = ref.watch(_sharedPostDetailProvider(widget.postId));
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: asyncPost.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _ErrorView(onClose: () => Navigator.of(ctx).pop()),
          data: (post) => _SheetContent(
            post: post,
            scrollCtrl: scrollCtrl,
            optimisticLiked: _optimisticLiked,
            optimisticReposted: _optimisticReposted,
            likesDelta: _likesDelta,
            repostsDelta: _repostsDelta,
            onLikeTap: () => _toggleLike(post),
            onLikeLongPress: () => _showReactionPicker(post),
            onCommentTap: () => _openComments(post),
            onRepostTap: () => _toggleRepost(post),
            onShareTap: () => _shareAgain(post),
            onAuthorTap: () => _openAuthor(post),
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//   CONTENT
// ───────────────────────────────────────────────────────────────────────────
class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.post,
    required this.scrollCtrl,
    required this.optimisticLiked,
    required this.optimisticReposted,
    required this.likesDelta,
    required this.repostsDelta,
    required this.onLikeTap,
    required this.onLikeLongPress,
    required this.onCommentTap,
    required this.onRepostTap,
    required this.onShareTap,
    required this.onAuthorTap,
    required this.onClose,
  });

  final Post post;
  final ScrollController scrollCtrl;
  final bool? optimisticLiked;
  final bool? optimisticReposted;
  final int likesDelta;
  final int repostsDelta;
  final VoidCallback onLikeTap;
  final VoidCallback onLikeLongPress;
  final VoidCallback onCommentTap;
  final VoidCallback onRepostTap;
  final VoidCallback onShareTap;
  final VoidCallback onAuthorTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isLiked = optimisticLiked ?? post.userLiked;
    final isReposted = optimisticReposted ?? post.userReposted;
    final likes = post.likesCount + likesDelta;
    final reposts = post.repostsCount + repostsDelta;

    return Column(
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.textSecondary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            controller: scrollCtrl,
            padding: EdgeInsets.zero,
            children: [
              // ── Header: autor ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onAuthorTap,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: context.colors.surfaceElevated,
                        backgroundImage:
                            (post.author.avatarUrl != null &&
                                post.author.avatarUrl!.isNotEmpty)
                            ? NetworkImage(post.author.avatarUrl!)
                            : null,
                        child:
                            (post.author.avatarUrl == null ||
                                post.author.avatarUrl!.isEmpty)
                            ? Icon(
                                Icons.person,
                                color: context.colors.textPrimary,
                                size: 22,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: onAuthorTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    post.author.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.colors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (post.author.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    color: AppColors.braweSky,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                            if (post.author.username.isNotEmpty)
                              Text(
                                '@${post.author.username}',
                                style: TextStyle(
                                  color: context.colors.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: Icon(
                        Icons.close,
                        color: context.colors.textSecondary,
                      ),
                      tooltip: s.actionClose,
                    ),
                  ],
                ),
              ),

              // ── Mídia (imagem ou vídeo) ───────────────────────────
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                _MediaBlock(url: post.imageUrl!, hlsUrl: post.hlsUrl),

              // ── Caption ───────────────────────────────────────────
              if (post.content.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: BraweRichText(
                    post.content,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                ),

              // ── Stats row ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    _StatChip(
                      icon: Icons.visibility_outlined,
                      value: post.viewsCount,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(width: 14),
                    _StatChip(
                      icon: Icons.access_time,
                      label: _timeAgo(context, post.createdAt),
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),

              // ── Action bar ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ActionButton(
                      icon: isLiked ? Icons.favorite : Icons.favorite_border,
                      iconColor: isLiked
                          ? Colors.redAccent
                          : context.colors.textPrimary,
                      label: _compact(likes),
                      onTap: onLikeTap,
                      onLongPress: onLikeLongPress,
                    ),
                    _ActionButton(
                      icon: Icons.mode_comment_outlined,
                      iconColor: context.colors.textPrimary,
                      label: _compact(post.commentsCount),
                      onTap: onCommentTap,
                    ),
                    _ActionButton(
                      icon: Icons.repeat_rounded,
                      iconColor: isReposted
                          ? context.colors.accentPrimary
                          : context.colors.textPrimary,
                      label: _compact(reposts),
                      onTap: onRepostTap,
                    ),
                    _ActionButton(
                      icon: Icons.ios_share,
                      iconColor: context.colors.textPrimary,
                      label: s.actionShare,
                      onTap: onShareTap,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // (Removido o CTA "Ver publicação": o sheet já É a publicação,
              // então o botão era redundante. Para acessar a thread completa
              // de comentários o usuário toca em "Comentar".)
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//   MEDIA: imagem ou vídeo
// ───────────────────────────────────────────────────────────────────────────
class _MediaBlock extends StatelessWidget {
  const _MediaBlock({required this.url, this.hlsUrl});
  final String url;

  /// Versão leve (HLS do Bunny), quando o vídeo já foi convertido.
  final String? hlsUrl;

  @override
  Widget build(BuildContext context) {
    if (_isVideoUrl(url)) {
      final playUrl = (hlsUrl?.isNotEmpty ?? false) ? hlsUrl! : url;
      return AspectRatio(aspectRatio: 1, child: _AutoplayVideo(url: playUrl));
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 480),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        placeholder: (_, _) =>
            Container(height: 240, color: context.colors.surfaceElevated),
        errorWidget: (_, _, _) => Container(
          height: 240,
          color: context.colors.surfaceElevated,
          child: Icon(Icons.broken_image, color: context.colors.textSecondary),
        ),
      ),
    );
  }
}

class _AutoplayVideo extends StatefulWidget {
  const _AutoplayVideo({required this.url});
  final String url;

  @override
  State<_AutoplayVideo> createState() => _AutoplayVideoState();
}

class _AutoplayVideoState extends State<_AutoplayVideo> {
  VideoPlayerController? _ctrl;
  bool _ready = false;
  bool _muted = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        httpHeaders: mediaHeadersFor(widget.url),
      );
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);
      await c.play();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _ctrl = c;
        _ready = true;
      });
    } catch (_) {
      if (mounted) setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    _ctrl?.pause();
    _ctrl?.dispose();
    super.dispose();
  }

  void _toggleMute() {
    final c = _ctrl;
    if (c == null) return;
    setState(() {
      _muted = !_muted;
      c.setVolume(_muted ? 0 : 1.0);
    });
    HapticFeedback.selectionClick();
  }

  void _togglePlay() {
    final c = _ctrl;
    if (c == null) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = _ctrl;
    if (!_ready) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      );
    }
    if (c == null || !c.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Icon(
          Icons.videocam_off,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      );
    }
    final isPlaying = c.value.isPlaying;
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: c.value.size.width,
              height: c.value.size.height,
              child: VideoPlayer(c),
            ),
          ),
        ),
        if (!isPlaying)
          IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 10,
          right: 10,
          child: GestureDetector(
            onTap: _toggleMute,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _muted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//   Pequenos blocos
// ───────────────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip({this.icon, this.value, this.label, required this.color});
  final IconData? icon;
  final int? value;
  final String? label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          label ?? _compact(value ?? 0),
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.onLongPress,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link_off, size: 42, color: context.colors.textSecondary),
          const SizedBox(height: 12),
          Text(
            s.chatDetailPostUnavailable,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onClose, child: Text(s.actionClose)),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//   Helpers
// ───────────────────────────────────────────────────────────────────────────
String _compact(int n) {
  if (n < 1000) return '$n';
  if (n < 1_000_000) return '${(n / 1000).toStringAsFixed(n < 10000 ? 1 : 0)}K';
  return '${(n / 1_000_000).toStringAsFixed(1)}M';
}

String _timeAgo(BuildContext context, DateTime dt) {
  final s = S.of(context);
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return s.viewerTimeNow;
  if (diff.inMinutes < 60) return s.sharedPostMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return s.sharedPostHoursAgo(diff.inHours);
  if (diff.inDays < 7) return s.sharedPostDaysAgo(diff.inDays);
  return '${dt.day}/${dt.month}/${dt.year}';
}
