import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';
import '../../core/ui/app_radius.dart';
import '../../core/ui/app_spacing.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  static const List<_FeedPost> _mockPosts = [
    _FeedPost(
      username: 'ari.wave',
      caption: 'Próximo projeto bilionário!',
      audio: 'Original • Neon Drift',
      tags: ['#brawe', '#midnight', '#sketch'],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.midnightBlue, AppColors.deepBlue],
      ),
    ),
    _FeedPost(
      username: 'nova.lines',
      caption: 'City glow, soft focus, slow scroll.',
      audio: 'Original • Glass Echo',
      tags: ['#citylight', '#vibes'],
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.nearBlack, AppColors.slate],
      ),
    ),
    _FeedPost(
      username: 'kira.mono',
      caption: 'Finding calm in motion.',
      audio: 'Original • Pulse Fade',
      tags: ['#motion', '#minimal'],
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [AppColors.deepBlue, AppColors.electricPurple],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _mockPosts.length,
        itemBuilder: (context, index) {
          final post = _mockPosts[index];
          return _FeedPostView(post: post);
        },
      ),
    );
  }
}

class _FeedPostView extends StatelessWidget {
  const _FeedPostView({required this.post});

  final _FeedPost post;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(decoration: BoxDecoration(gradient: post.gradient)),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FeedTopBar(),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _PostDetails(post: post, textTheme: textTheme),
                    ),
                    const _FeedActions(),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedTopBar extends StatelessWidget {
  const _FeedTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            'Brawe',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
    );
  }
}

class _PostDetails extends StatelessWidget {
  const _PostDetails({required this.post, required this.textTheme});

  final _FeedPost post;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '@${post.username}',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(post.caption, style: textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          children: post.tags
              .map(
                (tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  labelStyle: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(Icons.graphic_eq, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              post.audio,
              style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeedActions extends StatelessWidget {
  const _FeedActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ActionButton(icon: Icons.favorite_border, label: '12.4k'),
        SizedBox(height: AppSpacing.md),
        _ActionButton(icon: Icons.chat_bubble_outline, label: '642'),
        SizedBox(height: AppSpacing.md),
        _ActionButton(icon: Icons.share, label: 'Share'),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class _FeedPost {
  const _FeedPost({
    required this.username,
    required this.caption,
    required this.audio,
    required this.tags,
    required this.gradient,
  });

  final String username;
  final String caption;
  final String audio;
  final List<String> tags;
  final LinearGradient gradient;
}
