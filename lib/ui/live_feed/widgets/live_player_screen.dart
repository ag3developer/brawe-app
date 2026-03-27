import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../view_models/live_room_comments_view_model.dart';
import '../view_models/top_gifters_view_model.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/live_room.dart';
import '../../core/ui/follow_button.dart';
import 'gifts_overlay.dart';
import 'gift_animation_overlay.dart';
import 'live_comments_overlay.dart';

class LivePlayerScreen extends ConsumerStatefulWidget {
  final LiveRoom room;

  const LivePlayerScreen({super.key, required this.room});

  @override
  ConsumerState<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends ConsumerState<LivePlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.room.totalLikes;
    _initializePlayer();
  }

  Future<void> _handleLike() async {
    final newIsLiked = !_isLiked;
    setState(() {
      _isLiked = newIsLiked;
      _likesCount += newIsLiked ? 1 : -1;
    });

    try {
      await ref
          .read(liveRepositoryProvider)
          .toggleLike(widget.room.id, !newIsLiked);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiked = !newIsLiked;
          _likesCount += !newIsLiked ? 1 : -1;
        });
      }
    }
  }

  Future<void> _handleShare() async {
    final url = 'https://brawe.io/live/${widget.room.slug}';
    final message = 'Check out this live on Brawe: ${widget.room.title}\n$url';
    await SharePlus.instance.share(ShareParams(text: message));
  }

  Future<void> _initializePlayer() async {
    if (_controller != null) return;

    final streamUrl = widget.room.streamUrl;
    if (streamUrl == null || streamUrl.isEmpty) return;

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(streamUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();
        _controller!.setLooping(true);
        _controller!.setVolume(1.0);
        WakelockPlus.enable();
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(liveRoomCommentsViewModelProvider(widget.room.id));

    ref.listen<LiveRoomCommentsState>(
      liveRoomCommentsViewModelProvider(widget.room.id),
      (previous, next) {
        final errorMessage = next.errorMessage;
        if (errorMessage == null || errorMessage == previous?.errorMessage) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorMessage)));
        ref
            .read(liveRoomCommentsViewModelProvider(widget.room.id).notifier)
            .clearError();
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background - Stream or Thumbnail placeholder
          if (_isInitialized && _controller != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          else if (widget.room.thumbnailUrl != null)
            Image.network(
              widget.room.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          else
            _buildPlaceholder(),

          // Gradient overlay for text readability
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.6, 1.0],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => context.pop(),
            ),
          ),

          // Live Badge & Viewers
          Positioned(
            top: 50,
            left: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sensors, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE ${commentsState.viewerCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Gifters
          Positioned(
            top: 50,
            right: 16,
            child: Consumer(
              builder: (context, ref, child) {
                final giftersState = ref.watch(topGiftersViewModelProvider(widget.room.id));
                return giftersState.when(
                  data: (gifters) => Row(
                    children: gifters.take(3).map((gifter) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white24,
                        backgroundImage: gifter.avatarUrl != null ? NetworkImage(gifter.avatarUrl!) : null,
                        child: gifter.avatarUrl == null ? const Icon(Icons.person, size: 12, color: Colors.white) : null,
                      ),
                    )).toList(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                );
              },
            ),
          ),

          // Gift Animation Overlay
          GiftAnimationOverlay(roomId: widget.room.id),

          // Stream Info (Bottom)
          Positioned(
            bottom: 116,
            left: 16,
            right: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile/${widget.room.streamerId}'),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: widget.room.streamerAvatarUrl != null
                            ? NetworkImage(widget.room.streamerAvatarUrl!)
                            : null,
                        child: widget.room.streamerAvatarUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.room.streamerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      FollowButton(userId: widget.room.streamerId, compact: true),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.room.title,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                LiveCommentsOverlay(
                  comments: commentsState.comments,
                  isSending: commentsState.isSending,
                  onSendComment: (message) => ref
                      .read(
                        liveRoomCommentsViewModelProvider(widget.room.id).notifier,
                      )
                      .sendComment(message),
                ),
              ],
            ),
          ),

          // Interaction Buttons (Right side)
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIconButton(
                  Icons.favorite,
                  _likesCount.toString(),
                  onTap: _handleLike,
                ),
                const SizedBox(height: 16),
                _buildIconButton(
                  Icons.card_giftcard,
                  'Gift',
                  onTap: () => GiftsOverlay.show(
                    context,
                    widget.room.id,
                    widget.room.streamerId,
                  ),
                ),
                const SizedBox(height: 16),
                _buildIconButton(Icons.share, 'Share', onTap: _handleShare),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1B2B6B),
      child: const Center(
        child: Icon(Icons.live_tv, color: Colors.white24, size: 64),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
