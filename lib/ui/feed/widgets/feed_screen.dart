import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/feed_view_model.dart';
import '../../../domain/models/post.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: feedState.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'No posts available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: posts.length,
            onPageChanged: (index) {
              ref
                  .read(feedViewModelProvider.notifier)
                  .onPostViewed(posts[index].id);
            },
            itemBuilder: (context, index) {
              return _PostItem(post: posts[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Failed to load feed.',
                style: TextStyle(color: Colors.red),
              ),
              ElevatedButton(
                onPressed: () =>
                    ref.read(feedViewModelProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostItem extends ConsumerWidget {
  final Post post;

  const _PostItem({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Content (Image or Placeholder)
        if (post.imageUrl != null)
          Image.network(
            post.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          )
        else
          _buildPlaceholder(),

        // Gradient overlay
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black87],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.7, 1.0],
            ),
          ),
        ),

        // Post Info (Bottom)
        Positioned(
          bottom: 24,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: post.author.avatarUrl != null
                        ? NetworkImage(post.author.avatarUrl!)
                        : null,
                    child: post.author.avatarUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '@${post.author.username}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (post.author.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.content,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
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
              _InteractionButton(
                icon: post.userLiked ? Icons.favorite : Icons.favorite_border,
                label: post.likesCount.toString(),
                color: post.userLiked ? Colors.red : Colors.white,
                onTap: () => ref
                    .read(feedViewModelProvider.notifier)
                    .toggleLike(post.id),
              ),
              const SizedBox(height: 16),
              _InteractionButton(
                icon: Icons.chat_bubble_outline,
                label: post.commentsCount.toString(),
                onTap: () {}, // TODO: Open comments
              ),
              const SizedBox(height: 16),
              _InteractionButton(
                icon: Icons.repeat,
                label: post.repostsCount.toString(),
                onTap: () {}, // TODO: Repost
              ),
              const SizedBox(height: 16),
              _InteractionButton(
                icon: Icons.share,
                label: 'Share',
                onTap: () {}, // TODO: Share
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1F2737),
      child: const Center(
        child: Icon(Icons.image, color: Colors.white10, size: 64),
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _InteractionButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
