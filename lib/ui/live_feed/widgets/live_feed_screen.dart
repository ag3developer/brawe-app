import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../view_models/live_feed_view_model.dart';
import '../../../domain/models/live_room.dart';
import '../../../data/services/socket_service.dart';
import '../../core/themes/app_colors.dart';

class LiveFeedScreen extends ConsumerStatefulWidget {
  const LiveFeedScreen({super.key});

  @override
  ConsumerState<LiveFeedScreen> createState() => _LiveFeedScreenState();
}

class _LiveFeedScreenState extends ConsumerState<LiveFeedScreen> {
  LiveFeedCategory _selectedCategory = LiveFeedCategory.forYou;

  @override
  Widget build(BuildContext context) {
    final liveFeedState = ref.watch(liveFeedViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A), // Near-black background
      body: Stack(
        children: [
          liveFeedState.when(
            data: (rooms) {
              if (rooms.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam_off_outlined,
                        color: Colors.white24,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedCategory == LiveFeedCategory.forYou
                            ? 'No lives in For You right now.'
                            : 'No active lives at the moment.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check back later or try refreshing.',
                        style: TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => ref
                            .read(liveFeedViewModelProvider.notifier)
                            .refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6E4DFF),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(liveFeedViewModelProvider.notifier).refresh(),
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return LiveRoomItem(room: room);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${error.toString()}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(liveFeedViewModelProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.topCenter,
                child: _LiveFeedCategorySelector(
                  selected: _selectedCategory,
                  onSelected: _onCategorySelected,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onCategorySelected(LiveFeedCategory category) async {
    setState(() {
      _selectedCategory = category;
    });
    await ref.read(liveFeedViewModelProvider.notifier).selectCategory(category);
  }
}

class _LiveFeedCategorySelector extends StatelessWidget {
  const _LiveFeedCategorySelector({
    required this.selected,
    required this.onSelected,
  });

  final LiveFeedCategory selected;
  final ValueChanged<LiveFeedCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CategoryButton(
            label: 'For You',
            isSelected: selected == LiveFeedCategory.forYou,
            onTap: () => onSelected(LiveFeedCategory.forYou),
          ),
          _CategoryButton(
            label: 'All Lives',
            isSelected: selected == LiveFeedCategory.allLives,
            onTap: () => onSelected(LiveFeedCategory.allLives),
          ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.electricPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class LiveRoomItem extends ConsumerStatefulWidget {
  final LiveRoom room;

  const LiveRoomItem({super.key, required this.room});

  @override
  ConsumerState<LiveRoomItem> createState() => _LiveRoomItemState();
}

class _LiveRoomItemState extends ConsumerState<LiveRoomItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  late final SocketService _socketService;

  @override
  void initState() {
    super.initState();
    _socketService = ref.read(socketServiceProvider);
    _initializePlayer();
    _connectSocket();
  }

  Future<void> _initializePlayer() async {
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

  void _connectSocket() {
    _socketService.connect().then((_) {
      _socketService.joinRoom(widget.room.id);

      _socketService.on(AppConstants.eventNewMessage, (data) {
        // Handle new message (e.g., show in chat overlay)
        debugPrint('New message in room ${widget.room.id}: $data');
      });

      _socketService.on(AppConstants.eventViewerCount, (data) {
        // Update viewer count
        debugPrint('Viewer count updated for ${widget.room.id}: $data');
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    WakelockPlus.disable();
    _socketService.leaveRoom(widget.room.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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

        // Live Badge & Viewers
        Positioned(
          top: 50,
          left: 16,
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
                  'LIVE ${widget.room.viewerCount}',
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

        // Stream Info (Bottom)
        Positioned(
          bottom: 24,
          left: 16,
          right: 80, // Space for right-side interaction buttons
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.room.title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
              _buildIconButton(Icons.favorite, 'Like'),
              const SizedBox(height: 16),
              _buildIconButton(Icons.card_giftcard, 'Gift'),
              const SizedBox(height: 16),
              _buildIconButton(Icons.share, 'Share'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1B2B6B), // Deep blue from theme
      child: const Center(
        child: Icon(Icons.live_tv, color: Colors.white24, size: 64),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label) {
    return Column(
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
    );
  }
}

