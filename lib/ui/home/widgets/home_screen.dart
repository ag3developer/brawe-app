import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/app_colors.dart';
import '../../core/ui/app_radius.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/view_models/profile_view_model.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/user.dart';
import '../view_models/top_streamers_view_model.dart';
import 'home_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HomeTopBar(),
                  const SizedBox(height: AppSpacing.lg),
                  _LiveBattlesSection(),
                  const SizedBox(height: AppSpacing.lg),
                  const _TopStreamersSection(),
                  const SizedBox(height: AppSpacing.lg),
                  const _CategoriesSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _StreamCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _LiveCommerceSection(),
                  // Extra space for the floating bottom navigation
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: HomeBottomNav(),
          ),
        ],
      ),
    );
  }
}

class _HomeTopBar extends ConsumerWidget {
  const _HomeTopBar();

  void _showProfileSheet(BuildContext context, WidgetRef ref, User? user) {
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.nearBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Consumer(
            builder: (context, ref, child) {
              final profileState = ref.watch(profileViewModelProvider(user.id));

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.slate,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? const Icon(Icons.person, color: Colors.white, size: 40)
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${user.displayId}',
                      style: const TextStyle(
                        color: AppColors.coolGray,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Social Stats
                    profileState.stats.when(
                      data: (stats) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            label: 'Followers',
                            value: '${stats.followersCount}',
                          ),
                          _StatItem(
                            label: 'Following',
                            value: '${stats.followingCount}',
                          ),
                          _StatItem(
                            label: 'Lives',
                            value: '${stats.livesCount}',
                          ),
                        ],
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, _) => const Text(
                        'Error loading stats',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.electricPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: AppColors.electricPurple.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        user.userType.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.electricPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/profile/${user.id}');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: const Text('View Full Profile', style: TextStyle(color: Colors.white)),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Recent Lives',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    profileState.lives.when(
                      data: (lives) {
                        if (lives.isEmpty) {
                          return const Text(
                            'No past lives found',
                            style: TextStyle(color: AppColors.coolGray),
                          );
                        }
                        return SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: lives.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final live = lives[index];
                              return Container(
                                width: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.slate,
                                  borderRadius: BorderRadius.circular(8),
                                  image: live.thumbnailUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(live.thumbnailUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    if (live.thumbnailUrl == null)
                                      const Center(
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white24,
                                          size: 32,
                                        ),
                                      ),
                                    Positioned(
                                      bottom: 4,
                                      left: 4,
                                      right: 4,
                                      child: Text(
                                        live.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 4,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, _) => const Text(
                        'Error loading lives',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(authStateProvider.notifier).logout();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Row(
      children: [
        GestureDetector(
          onTap: () => _showProfileSheet(context, ref, user),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.slate,
            backgroundImage: user?.avatarUrl != null
                ? NetworkImage(user!.avatarUrl!)
                : null,
            child: user?.avatarUrl == null
                ? const Icon(Icons.person_outline, color: Colors.white)
                : null,
          ),
        ),
        const Spacer(),
        Text(
          'BRAWE',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search, color: Colors.white),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: Colors.white),
        ),
      ],
    );
  }
}

class _LiveBattlesSection extends StatelessWidget {
  const _LiveBattlesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LIVE STREAM BATTLES',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () => context.push('/live'),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              gradient: LinearGradient(
                colors: [
                  AppColors.deepBlue.withValues(alpha: 0.8),
                  AppColors.electricPurple.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white10),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const _BattleProfile(name: 'AlexvsVS.', isLeft: true),
                          Text(
                            'Vs',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                          const _BattleProfile(name: 'SarahK', isLeft: false),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.coolCyan,
                              AppColors.electricPurple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Text(
                          'WATCH & BET',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: _LiveIndicator(count: '24K'),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: _BattleInfo(label: 'PK battle', time: '08:52'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (index) => Container(
              width: index == 0 ? 20 : 8,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index == 0 ? AppColors.coolCyan : Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BattleProfile extends StatelessWidget {
  const _BattleProfile({required this.name, required this.isLeft});
  final String name;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isLeft
                  ? [AppColors.coolCyan, Colors.transparent]
                  : [AppColors.electricPurple, Colors.transparent],
            ),
          ),
          child: const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.slate,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator({required this.count});
  final String count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.person, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}

class _BattleInfo extends StatelessWidget {
  const _BattleInfo({required this.label, required this.time});
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white60),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _TopStreamersSection extends ConsumerWidget {
  const _TopStreamersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topStreamersState = ref.watch(topStreamersViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOP STREAMERS',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 100,
          child: topStreamersState.when(
            data: (streamers) {
              if (streamers.isEmpty) {
                return const Center(
                  child: Text(
                    'No streamers yet',
                    style: TextStyle(color: Colors.white60),
                  ),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: streamers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final profile = streamers[index];
                  return GestureDetector(
                    onTap: () {
                      context.push('/profile/${profile.id}');
                    },
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.electricPurple,
                                    AppColors.coolCyan,
                                  ],
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.slate,
                                backgroundImage: profile.avatarUrl != null
                                    ? NetworkImage(profile.avatarUrl!)
                                    : null,
                                child: profile.avatarUrl == null
                                    ? const Icon(Icons.person, color: Colors.white)
                                    : null,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mutedRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 60,
                          child: Text(
                            profile.displayName ?? profile.username ?? 'User',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(
                'Error',
                style: TextStyle(color: Colors.red.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORIES',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final categories = ['FPS', 'Shoppers', 'RPG', 'Tech'];
              final icons = [
                Icons.videogame_asset,
                Icons.shopping_bag,
                Icons.sports_esports,
                Icons.laptop,
              ];
              return Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.slate,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Icon(icons[index], color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categories[index],
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StreamCard extends StatelessWidget {
  const _StreamCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STREAM CARD',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () => context.push('/live'),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.slate, AppColors.nearBlack],
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mutedRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                '@StreamerJane',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.people_outline, size: 18),
                            const SizedBox(width: 4),
                            const Text('2.4k', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 12),
                            const Icon(Icons.favorite_border, size: 18),
                            const SizedBox(width: 4),
                            const Text('12k', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'StreamerJane: i comments',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'sarah_: i rmex comments',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.keyboard, size: 20),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Keyboard',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('\$149.99', style: TextStyle(fontSize: 10)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveCommerceSection extends StatelessWidget {
  const _LiveCommerceSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LIVE COMMERCE SHOW',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () => context.push('/live'),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              gradient: LinearGradient(
                colors: [
                  AppColors.deepBlue.withValues(alpha: 0.6),
                  AppColors.electricPurple.withValues(alpha: 0.4),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 100,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.md),
                      bottomLeft: Radius.circular(AppRadius.md),
                    ),
                    color: AppColors.slate,
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: const [
                      CircleAvatar(radius: 10, backgroundColor: Colors.white24),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '@TechTori',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            _ProductItem(icon: Icons.keyboard, price: '149.99'),
                            _ProductItem(icon: Icons.headset, price: '239.99'),
                            _ProductItem(icon: Icons.mouse, price: '249.99'),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.electricPurple,
                                AppColors.softViolet,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'LIVE CHAT/BUY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductItem extends StatelessWidget {
  const _ProductItem({required this.icon, required this.price});
  final IconData icon;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          '\$$price',
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
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
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.coolGray,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
