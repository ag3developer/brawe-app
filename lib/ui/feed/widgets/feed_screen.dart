import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/app_colors.dart';
import '../../core/widgets/brawe_logo.dart';
import '../../../domain/models/post.dart';
import '../../../domain/models/story.dart';
import '../view_models/feed_view_model.dart';
import '../view_models/stories_view_model.dart';
import 'comments_sheet.dart';
import 'create_post_sheet.dart';
import 'create_story_sheet.dart';
import 'story_viewer.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      body: SafeArea(
        child: Column(
          children: [
            _FeedTopBar(
              onCreatePost: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const CreatePostSheet(),
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.electricPurple,
              indicatorWeight: 2,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.coolGray,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Para Você'),
                Tab(text: 'Seguindo'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _FeedTab(tabType: FeedTabType.forYou),
                  _FeedTab(tabType: FeedTabType.following),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const CreatePostSheet(),
        ),
        backgroundColor: AppColors.electricPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _FeedTopBar extends StatelessWidget {
  const _FeedTopBar({required this.onCreatePost});
  final VoidCallback onCreatePost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const BraweLogo(iconSize: 32),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => context.push('/explore'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }
}

enum FeedTabType { forYou, following }

class _FeedTab extends ConsumerWidget {
  const _FeedTab({required this.tabType});
  final FeedTabType tabType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedViewModelProvider);

    return feedState.when(
      data: (posts) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _StoriesSection()),
          const SliverToBoxAdapter(
            child: Divider(color: Colors.white10, height: 1),
          ),
          if (posts.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Nenhum post ainda.\nSeja o primeiro!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.coolGray, fontSize: 16),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => PostCard(post: posts[index]),
                childCount: posts.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.electricPurple),
      ),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: AppColors.coolGray, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Falha ao carregar o feed.',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricPurple,
              ),
              onPressed: () =>
                  ref.read(feedViewModelProvider.notifier).refresh(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stories ─────────────────────────────────────────────────────────────────

class _StoriesSection extends ConsumerWidget {
  const _StoriesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(storiesViewModelProvider);

    return SizedBox(
      height: 100,
      child: asyncGroups.when(
        loading: () => _buildLoading(),
        error: (_, __) => _buildError(ref),
        data: (groups) => _buildList(context, ref, groups),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: 6,
      itemBuilder: (_, i) => i == 0
          ? const _AddStoryButton()
          : Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppColors.slate,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 10,
                    color: AppColors.slate,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildError(WidgetRef ref) {
    return Center(
      child: TextButton.icon(
        onPressed: () => ref.read(storiesViewModelProvider.notifier).refresh(),
        icon: const Icon(Icons.refresh, color: AppColors.coolGray, size: 16),
        label: const Text(
          'Recarregar stories',
          style: TextStyle(color: AppColors.coolGray, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List groups) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: groups.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return const _AddStoryButton();
        final group = groups[index - 1];
        // Capa = primeiro story do grupo (já vem ordenado pelo backend)
        if (group.stories.isEmpty) return const SizedBox.shrink();
        final cover = group.stories.first;
        return _StoryBubble(
          story: cover,
          hasUnviewed: group.hasUnviewed,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => StoryViewer(
                  stories: group.stories,
                  initialIndex: 0,
                  onStoryViewed: (storyId) {
                    ref
                        .read(storiesViewModelProvider.notifier)
                        .markAsViewed(storyId);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AddStoryButton extends StatelessWidget {
  const _AddStoryButton();

  void _openCreateStory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateStorySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openCreateStory(context),
        child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.slate,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.coolGray,
                  size: 28,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.electricPurple,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.add, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Seu story',
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({
    required this.story,
    required this.onTap,
    this.hasUnviewed,
  });
  final Story story;
  final VoidCallback onTap;
  final bool? hasUnviewed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: (hasUnviewed ?? !story.isSeen)
                    ? const LinearGradient(
                        colors: [
                          AppColors.electricPurple,
                          AppColors.coolCyan,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: (hasUnviewed ?? !story.isSeen) ? null : AppColors.slate,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.nearBlack,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  backgroundColor: AppColors.slate,
                  backgroundImage: story.mediaUrl.isNotEmpty
                      ? NetworkImage(story.mediaUrl)
                      : null,
                  child: story.mediaUrl.isEmpty
                      ? Text(
                          story.authorName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: Text(
                story.authorUsername,
                style: TextStyle(
                  color: (hasUnviewed ?? !story.isSeen) ? Colors.white : AppColors.coolGray,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Post Card ────────────────────────────────────────────────────────────────

class PostCard extends ConsumerStatefulWidget {
  const PostCard({super.key, required this.post});
  final Post post;

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.4), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_heartController);

    _heartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeart = false);
        _heartController.reset();
      }
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _doubleTapLike() {
    if (!widget.post.userLiked) {
      ref.read(feedViewModelProvider.notifier).toggleLike(widget.post.id);
    }
    setState(() => _showHeart = true);
    _heartController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: AppColors.nearBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile/${post.author.id}'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.slate,
                    backgroundImage: post.author.avatarUrl != null
                        ? NetworkImage(post.author.avatarUrl!)
                        : null,
                    child: post.author.avatarUrl == null
                        ? Text(
                            post.author.name.isNotEmpty
                                ? post.author.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.author.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.author.isVerified) ...[
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.verified,
                              color: AppColors.electricPurple,
                              size: 15,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '@${post.author.username} · ${_timeAgo(post.createdAt)}',
                        style: const TextStyle(
                          color: AppColors.coolGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: AppColors.coolGray,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showPostOptions(context),
                ),
              ],
            ),
          ),

          // Content text
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                post.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ),

          // Image with double-tap like
          if (post.imageUrl != null)
            GestureDetector(
              onDoubleTap: _doubleTapLike,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        post.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: AppColors.slate,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.coolGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showHeart)
                    ScaleTransition(
                      scale: _heartScale,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 90,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 12),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          // Action bar
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
            child: Row(
              children: [
                _ActionBtn(
                  icon: post.userLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: _formatCount(post.likesCount),
                  color: post.userLiked ? Colors.red : AppColors.coolGray,
                  onTap: () => ref
                      .read(feedViewModelProvider.notifier)
                      .toggleLike(post.id),
                ),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline,
                  label: _formatCount(post.commentsCount),
                  color: AppColors.coolGray,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CommentsSheet(postId: post.id),
                  ),
                ),
                _ActionBtn(
                  icon: post.userReposted
                      ? Icons.repeat_on_rounded
                      : Icons.repeat,
                  label: _formatCount(post.repostsCount),
                  color: post.userReposted
                      ? AppColors.coolCyan
                      : AppColors.coolGray,
                  onTap: () => _confirmRepost(context, post),
                ),
                _ActionBtn(
                  icon: Icons.bar_chart,
                  label: _formatCount(post.viewsCount),
                  color: AppColors.coolGray,
                  onTap: () {},
                ),
                const Spacer(),
                _ActionBtn(
                  icon: Icons.bookmark_border,
                  label: '',
                  color: AppColors.coolGray,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post salvo!'),
                      backgroundColor: AppColors.electricPurple,
                      duration: Duration(seconds: 2),
                    ),
                  ),
                ),
                _ActionBtn(
                  icon: Icons.share_outlined,
                  label: '',
                  color: AppColors.coolGray,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border, color: Colors.white),
              title: const Text('Salvar post',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.person_off_outlined, color: Colors.white),
              title: const Text('Deixar de seguir',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.red),
              title: const Text('Denunciar',
                  style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRepost(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post.userReposted
                    ? 'Desfazer repost?'
                    : 'Repostar para seus seguidores?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.repeat, color: AppColors.coolCyan),
              title: Text(
                post.userReposted ? 'Desfazer repost' : 'Repost',
                style: const TextStyle(color: AppColors.coolCyan),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Citar post',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 30) return '${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color, size: 19),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}
