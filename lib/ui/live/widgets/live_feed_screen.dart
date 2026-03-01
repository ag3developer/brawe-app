import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/live_feed_view_model.dart';
import '../../../domain/models/live_room.dart';

class LiveFeedScreen extends ConsumerWidget {
  const LiveFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveFeedState = ref.watch(liveFeedViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A), // Near-black background
      body: liveFeedState.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(
              child: Text(
                'No live rooms available.',
                style: TextStyle(color: Colors.white),
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
                return _LiveRoomItem(room: room);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Failed to load live feed.',
                style: TextStyle(color: Colors.red),
              ),
              ElevatedButton(
                onPressed: () =>
                    ref.read(liveFeedViewModelProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveRoomItem extends StatelessWidget {
  final LiveRoom room;

  const _LiveRoomItem({required this.room});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background - Stream or Thumbnail placeholder
        if (room.thumbnailUrl != null)
          Image.network(
            room.thumbnailUrl!,
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
                  'LIVE ${room.viewerCount}',
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
                    backgroundImage: room.streamerAvatarUrl != null
                        ? NetworkImage(room.streamerAvatarUrl!)
                        : null,
                    child: room.streamerAvatarUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    room.streamerName,
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
                room.title,
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
