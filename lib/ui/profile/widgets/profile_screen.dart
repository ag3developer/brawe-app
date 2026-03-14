import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/follow_button.dart';
import '../../core/view_models/profile_view_model.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/live_room.dart';
import '../../../domain/models/post.dart';
import '../../../domain/models/profile.dart';
import '../../../domain/models/profile_state.dart';
import '../../../domain/models/social_stats.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
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
    final profileState = ref.watch(profileViewModelProvider(widget.userId));
    final currentUserId = ref.watch(authStateProvider).value?.id;
    final isMe = currentUserId == widget.userId;

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileViewModelProvider(widget.userId).notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                userId: widget.userId,
                isMe: isMe,
                profileState: profileState,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.electricPurple,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.coolGray,
                  tabs: const [
                    Tab(text: 'LIVES'),
                    Tab(text: 'POSTS'),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _LivesGrid(livesState: profileState.lives),
                  _PostsGrid(postsState: profileState.posts),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String userId;
  final bool isMe;
  final ProfileState profileState;

  const _ProfileHeader({
    required this.userId,
    required this.isMe,
    required this.profileState,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          profileState.profile.when(
            data: (profile) => _buildInfo(profile),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
 const Text('Error loading profile', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: AppSpacing.lg),
          profileState.stats.when(
            data: (stats) => _buildStats(stats),
            loading: () => const SizedBox(height: 40),
            error: (_, _) =>
 const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildActions(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildInfo(Profile profile) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.slate,
          backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
          child: profile.avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          profile.displayName ?? profile.username ?? 'User',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          '@${profile.username ?? userId}',
          style: const TextStyle(color: AppColors.coolGray, fontSize: 14),
        ),
        if (profile.bio != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            profile.bio!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildStats(SocialStats stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(label: 'Followers', value: '${stats.followersCount}'),
        _StatItem(label: 'Following', value: '${stats.followingCount}'),
        _StatItem(label: 'Likes', value: '${stats.totalLikes}'),
      ],
    );
  }

  Widget _buildActions() {
    if (isMe) {
      return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          minimumSize: const Size(double.infinity, 44),
        ),
        child: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
      );
    }

    return FollowButton(userId: userId);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.coolGray, fontSize: 12)),
      ],
    );
  }
}

class _LivesGrid extends StatelessWidget {
  final AsyncValue<List<LiveRoom>> livesState;

  const _LivesGrid({required this.livesState});

  @override
  Widget build(BuildContext context) {
    return livesState.when(
      data: (lives) {
        if (lives.isEmpty) {
          return const Center(child: Text('No lives yet', style: TextStyle(color: AppColors.coolGray)));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.7,
          ),
          itemCount: lives.length,
          itemBuilder: (context, index) {
            final live = lives[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.slate,
                borderRadius: BorderRadius.circular(8),
                image: live.thumbnailUrl != null
                    ? DecorationImage(image: NetworkImage(live.thumbnailUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: live.thumbnailUrl == null ? const Icon(Icons.play_circle_outline, color: Colors.white24) : null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) =>
 const Center(child: Text('Error loading lives', style: TextStyle(color: Colors.white))),
    );
  }
}

class _PostsGrid extends StatelessWidget {
  final AsyncValue<List<Post>> postsState;

  const _PostsGrid({required this.postsState});

  @override
  Widget build(BuildContext context) {
    return postsState.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text('No posts yet', style: TextStyle(color: AppColors.coolGray)));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.7,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.slate,
                borderRadius: BorderRadius.circular(8),
                image: post.imageUrl != null
                    ? DecorationImage(image: NetworkImage(post.imageUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: post.imageUrl == null ? const Icon(Icons.image_outlined, color: Colors.white24) : null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) =>
 const Center(child: Text('Error loading posts', style: TextStyle(color: Colors.white))),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.nearBlack,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
