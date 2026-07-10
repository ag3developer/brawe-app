import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/follow_user.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../feed/widgets/story_ring_avatar.dart';
import '../view_models/follows_view_model.dart';

class FollowsScreen extends ConsumerStatefulWidget {
  final String userId;
  final FollowsTab initialTab;

  const FollowsScreen({
    super.key,
    required this.userId,
    this.initialTab = FollowsTab.followers,
  });

  @override
  ConsumerState<FollowsScreen> createState() => _FollowsScreenState();
}

class _FollowsScreenState extends ConsumerState<FollowsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == FollowsTab.followers ? 0 : 1,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {}); // refresh title etc
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
        title: Text(s.followsTitle),
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.colors.textPrimary,
          unselectedLabelColor: context.colors.textSecondary,
          indicatorColor: AppColors.mutedRed,
          indicatorWeight: 2,
          tabs: [
            Tab(text: s.followsTabFollowers),
            Tab(text: s.followsTabFollowing),
          ],
        ),
      ),
      body: Column(
        children: [
          _SearchBar(
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _FollowsList(
                  userId: widget.userId,
                  tab: FollowsTab.followers,
                  query: _query,
                ),
                _FollowsList(
                  userId: widget.userId,
                  tab: FollowsTab.following,
                  query: _query,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(color: context.colors.textPrimary),
        decoration: InputDecoration(
          hintText: S.of(context).followsSearchHint,
          hintStyle: TextStyle(color: context.colors.textSecondary),
          prefixIcon: Icon(Icons.search, color: context.colors.textSecondary),
          filled: true,
          fillColor: Colors.white10,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _FollowsList extends ConsumerStatefulWidget {
  final String userId;
  final FollowsTab tab;
  final String query;

  const _FollowsList({
    required this.userId,
    required this.tab,
    required this.query,
  });

  @override
  ConsumerState<_FollowsList> createState() => _FollowsListState();
}

class _FollowsListState extends ConsumerState<_FollowsList>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scroll = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      ref
          .read(followsViewModelProvider(widget.userId, widget.tab).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final asyncState = ref.watch(
      followsViewModelProvider(widget.userId, widget.tab),
    );

    return asyncState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.mutedRed),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: context.colors.textSecondary,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).followsLoadError,
              style: TextStyle(color: context.colors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref
                  .read(
                    followsViewModelProvider(
                      widget.userId,
                      widget.tab,
                    ).notifier,
                  )
                  .refresh(),
              child: Text(
                S.of(context).followsTryAgain,
                style: const TextStyle(color: AppColors.mutedRed),
              ),
            ),
          ],
        ),
      ),
      data: (s) {
        final filtered = widget.query.isEmpty
            ? s.items
            : s.items.where((u) {
                final n = (u.displayName ?? '').toLowerCase();
                final un = u.username.toLowerCase();
                return n.contains(widget.query) || un.contains(widget.query);
              }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.tab == FollowsTab.followers
                        ? Icons.people_outline
                        : Icons.person_add_alt_outlined,
                    size: 56,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.query.isNotEmpty
                        ? S.of(context).followsNoResults(widget.query)
                        : widget.tab == FollowsTab.followers
                        ? S.of(context).followsEmptyFollowers
                        : S.of(context).followsEmptyFollowing,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.mutedRed,
          backgroundColor: context.colors.background,
          onRefresh: () => ref
              .read(
                followsViewModelProvider(widget.userId, widget.tab).notifier,
              )
              .refresh(),
          child: ListView.separated(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: filtered.length + (s.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, _) =>
                Divider(color: context.colors.divider, height: 1),
            itemBuilder: (context, i) {
              if (i >= filtered.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.mutedRed,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              final u = filtered[i];
              return _UserRow(
                user: u,
                onTap: () => context.push('/profile/${u.userId}'),
                onFollowTap: () => ref
                    .read(
                      followsViewModelProvider(
                        widget.userId,
                        widget.tab,
                      ).notifier,
                    )
                    .toggleFollow(u.userId),
              );
            },
          ),
        );
      },
    );
  }
}

class _UserRow extends StatelessWidget {
  final FollowUser user;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  const _UserRow({
    required this.user,
    required this.onTap,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = (user.displayName?.isNotEmpty ?? false)
        ? user.displayName!
        : (user.username.isNotEmpty
              ? '@${user.username}'
              : S.of(context).followsUserFallback);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                StoryRingAvatar(
                  userId: user.userId,
                  avatarUrl: user.avatarUrl,
                  fallbackText: name,
                  radius: 22,
                  onTapWithoutStories: onTap,
                ),
                if (user.isLive)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mutedRed,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Text(
                        S.of(context).followsLiveBadge,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 14,
                          color: Colors.lightBlueAccent,
                        ),
                      ],
                    ],
                  ),
                  if (user.username.isNotEmpty)
                    Text(
                      '@${user.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  if ((user.bio ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.bio!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _FollowChip(isFollowing: user.isFollowing, onTap: onFollowTap),
          ],
        ),
      ),
    );
  }
}

class _FollowChip extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;
  const _FollowChip({required this.isFollowing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isFollowing ? Colors.white10 : AppColors.mutedRed,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFollowing ? Colors.white24 : Colors.transparent,
            ),
          ),
          child: Text(
            isFollowing
                ? S.of(context).actionUnfollow
                : S.of(context).actionFollow,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
