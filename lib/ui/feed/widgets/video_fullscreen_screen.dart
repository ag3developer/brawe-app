import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../data/repositories/post_repository.dart';
import '../../../data/services/feedback_service.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/post.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/feed_view_model.dart';
import 'comments_sheet.dart';
import 'reactions_bar.dart';
import 'share_to_chat_sheet.dart';

/// Player de vídeo em **tela cheia** com action rail vertical (TikTok style).
///
/// Carrega o post via [postRepositoryProvider] caso ainda não esteja em cache.
/// Reproduz com som ON, autoplay, loop e progress bar interativa.
class VideoFullscreenScreen extends ConsumerStatefulWidget {
  const VideoFullscreenScreen({
    super.key,
    required this.postId,
    this.initialUrl,
  });

  final String postId;

  /// URL do vídeo já conhecida (evita roundtrip). Se `null`, busca via API.
  final String? initialUrl;

  @override
  ConsumerState<VideoFullscreenScreen> createState() =>
      _VideoFullscreenScreenState();
}

class _VideoFullscreenScreenState extends ConsumerState<VideoFullscreenScreen> {
  VideoPlayerController? _ctrl;
  Post? _post;
  bool _loading = true;
  bool _error = false;
  bool _muted = false;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final repo = ref.read(postRepositoryProvider);
      final post = await repo.getById(widget.postId);
      if (!mounted) return;
      _post = post;
      final url = widget.initialUrl ?? post.imageUrl;
      if (url == null || url.isEmpty) {
        setState(() {
          _loading = false;
          _error = true;
        });
        return;
      }
      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      c
        ..setLooping(true)
        ..setVolume(1)
        ..play();
      // Marca view.
      repo.incrementView(widget.postId);
      // Listener para rebuild da progress bar.
      c.addListener(_onTick);
      setState(() {
        _ctrl = c;
        _loading = false;
      });
    } on Failure catch (_) {
      if (mounted) setState(() {
        _loading = false;
        _error = true;
      });
    } catch (_) {
      if (mounted) setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ctrl?.removeListener(_onTick);
    _ctrl?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _ctrl;
    if (c == null) return;
    HapticFeedback.selectionClick();
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
    setState(() {});
  }

  void _toggleMute() {
    final c = _ctrl;
    if (c == null) return;
    HapticFeedback.selectionClick();
    setState(() => _muted = !_muted);
    c.setVolume(_muted ? 0 : 1);
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
  }

  Future<void> _onLike() async {
    final post = _post;
    if (post == null) return;
    ref.read(feedbackServiceProvider).like();
    await ref.read(feedViewModelProvider.notifier).toggleLike(post.id);
    setState(() {
      _post = post.copyWith(
        userLiked: !post.userLiked,
        likesCount:
            post.userLiked ? post.likesCount - 1 : post.likesCount + 1,
      );
    });
  }

  Future<void> _onReact(BraweReaction reaction) async {
    final post = _post;
    if (post == null) return;
    ref.read(feedbackServiceProvider).reaction();
    try {
      await ref
          .read(feedViewModelProvider.notifier)
          .reactToPost(post.id, reaction.key);
      if (!post.userLiked) {
        setState(() => _post = post.copyWith(
              userLiked: true,
              likesCount: post.likesCount + 1,
            ));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).feedCannotLike)),
      );
    }
  }

  void _onComment() {
    final post = _post;
    if (post == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(postId: post.id),
    );
  }

  Future<void> _onShare() async {
    final post = _post;
    if (post == null) return;
    ref.read(feedbackServiceProvider).share();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareToChatSheet(
        postId: post.id,
        postCaption: post.content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          onVerticalDragEnd: (d) {
            // Swipe-down para fechar
            if ((d.primaryVelocity ?? 0) > 600) {
              Navigator.of(context).maybePop();
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Vídeo
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFA855F7),
                  ),
                )
              else if (_error || _ctrl == null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.feedCannotShare, // genérico — pode-se trocar por chave dedicada
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              else
                Center(
                  child: AspectRatio(
                    aspectRatio: _ctrl!.value.aspectRatio,
                    child: VideoPlayer(_ctrl!),
                  ),
                ),

              // Overlay de play/pause
              if (_ctrl != null && !_ctrl!.value.isPlaying)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                  ),
                ),

              // Top bar (back + mute)
              if (_controlsVisible)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 4,
                  right: 4,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _muted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: Colors.white,
                        ),
                        onPressed: _toggleMute,
                      ),
                    ],
                  ),
                ),

              // Action rail
              if (_post != null && _controlsVisible)
                Positioned(
                  right: 8,
                  bottom: 110,
                  child: _VideoActionRail(
                    post: _post!,
                    onLike: _onLike,
                    onLikeLongPress: () async {
                      final size = MediaQuery.of(context).size;
                      final picked = await showReactionsBar(
                        context,
                        globalPosition:
                            Offset(size.width - 48, size.height * 0.5),
                      );
                      if (picked != null) _onReact(picked);
                    },
                    onLikeCountTap: () =>
                        context.push('/post/${_post!.id}/likes'),
                    onComment: _onComment,
                    onShare: _onShare,
                  ),
                ),

              // Bottom: caption + progress bar
              if (_post != null && _controlsVisible)
                Positioned(
                  left: 0,
                  right: 70,
                  bottom: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_post!.content.isNotEmpty)
                            Text(
                              _post!.content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          if (_ctrl != null) ...[
                            const SizedBox(height: 10),
                            _ProgressBar(controller: _ctrl!),
                          ],
                        ],
                      ),
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

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final position = value.position.inMilliseconds.toDouble();
    final duration = value.duration.inMilliseconds.toDouble().clamp(1, 1e12);
    final progress = (position / duration).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: const Color(0xFFA855F7),
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: progress,
            onChanged: (v) {
              final ms = (v * duration).toInt();
              controller.seekTo(Duration(milliseconds: ms));
            },
          ),
        ),
        Text(
          '${_fmt(value.position)} / ${_fmt(value.duration)}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _VideoActionRail extends StatelessWidget {
  const _VideoActionRail({
    required this.post,
    required this.onLike,
    required this.onLikeLongPress,
    required this.onLikeCountTap,
    required this.onComment,
    required this.onShare,
  });

  final Post post;
  final VoidCallback onLike;
  final VoidCallback onLikeLongPress;
  final VoidCallback onLikeCountTap;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RailItem(
          icon: post.userLiked
              ? Icons.favorite_rounded
              : Icons.favorite_outline_rounded,
          label: _fmt(post.likesCount),
          color: post.userLiked ? const Color(0xFFFF3B5C) : Colors.white,
          onTap: onLike,
          onLongPress: onLikeLongPress,
          onLabelTap: onLikeCountTap,
        ),
        const SizedBox(height: 18),
        _RailItem(
          icon: Icons.mode_comment_outlined,
          label: _fmt(post.commentsCount),
          color: Colors.white,
          onTap: onComment,
        ),
        const SizedBox(height: 18),
        _RailItem(
          icon: Icons.send_rounded,
          label: _fmt(post.repostsCount),
          color: Colors.white,
          onTap: onShare,
        ),
      ],
    );
  }

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.onLongPress,
    this.onLabelTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onLabelTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          behavior: HitTestBehavior.opaque,
          child: Icon(
            icon,
            color: color,
            size: 34,
            shadows: const [
              Shadow(color: Colors.black54, blurRadius: 6),
            ],
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
    );
  }
}
