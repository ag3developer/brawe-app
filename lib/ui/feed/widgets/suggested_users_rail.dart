import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/services/social_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';

part 'suggested_users_rail.g.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

@riverpod
Future<List<Map<String, dynamic>>> suggestedUsers(Ref ref) async {
  try {
    final result = await ref.watch(socialServiceProvider).getSuggestions(limit: 14);
    return result;
  } catch (e, st) {
    // ignore: avoid_print
    print('[SuggestedUsers] erro ao carregar sugestões: $e\n$st');
    rethrow;
  }
}

/// Tracks which users the user already followed (local optimistic state).
@riverpod
class FollowedNotifier extends _$FollowedNotifier {
  @override
  Set<String> build() => {};

  void add(String userId) => state = {...state, userId};
}

// ─── Design tokens (brand-only — surface/text colors come from theme) ────────

class _T {
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFFF59E0B)],
  );

  static const LinearGradient storyRing = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
  );

  static const Color live = Color(0xFFFF3B7E);
  static const Color liveGlow = Color(0x55FF3B7E);
}

// ─── Main widget ──────────────────────────────────────────────────────────────

/// Premium horizontal carousel of suggested users with story ring + live badge.
/// Insert this inside the feed's SliverList as a SliverToBoxAdapter.
class SuggestedUsersRail extends ConsumerWidget {
  const SuggestedUsersRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(suggestedUsersProvider);

    return async.when(
      loading: () => const _RailSkeleton(),
      error: (e, _) {
        // ignore: avoid_print
        print('[SuggestedUsersRail] error state: $e');
        return const SizedBox.shrink();
      },
      data: (users) {
        if (users.isEmpty) return const SizedBox.shrink();
        return _RailContent(users: users);
      },
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _RailContent extends ConsumerWidget {
  const _RailContent({required this.users});
  final List<Map<String, dynamic>> users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border),
          bottom: BorderSide(color: colors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                // Sparkle icon with gradient
                ShaderMask(
                  shaderCallback: (b) => _T.brand.createShader(b),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 17),
                ),
                const SizedBox(width: 8),
                Text(
                  S.of(context).suggestedTitle,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    S.of(context).suggestedSeeAll,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: colors.accentPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Carousel ────────────────────────────────────────────────────
          SizedBox(
            height: 178,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              itemCount: users.length,
              itemBuilder: (context, i) => _UserCard(user: users[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── User card ────────────────────────────────────────────────────────────────

class _UserCard extends ConsumerStatefulWidget {
  const _UserCard({required this.user});
  final Map<String, dynamic> user;

  @override
  ConsumerState<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<_UserCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _followCtrl;
  late final Animation<double> _followScale;

  @override
  void initState() {
    super.initState();
    _followCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _followScale = _followCtrl;
  }

  @override
  void dispose() {
    _followCtrl.dispose();
    super.dispose();
  }

  Future<void> _onFollow() async {
    HapticFeedback.lightImpact();
    final userId = widget.user['user_id'] as String? ?? '';
    // Bounce animation
    await _followCtrl.reverse();
    _followCtrl.forward();

    ref.read(followedProvider.notifier).add(userId);

    try {
      await ref.read(socialServiceProvider).followUser(userId);
    } catch (_) {
      // optimistic — ignore silent failure
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final userId = user['user_id'] as String? ?? '';
    final name = (user['display_name'] as String?)?.trim().isNotEmpty == true
        ? user['display_name'] as String
        : user['username'] as String? ?? 'User';
    final username = user['username'] as String? ?? '';
    final avatarUrl = user['avatar_url'] as String?;
    final isVerified = user['is_verified'] as bool? ?? false;
    final isLive = user['is_live'] as bool? ?? false;
    final hasStory = user['has_story'] as bool? ?? false;
    final followed = ref.watch(followedProvider).contains(userId);

    final bool showRing = isLive || hasStory;
    final colors = context.colors;

    return GestureDetector(
      onTap: () => context.push('/profile/$userId'),
      child: Container(
        width: 112,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // ── Avatar with ring / live badge ──────────────────────────
            _AvatarStack(
              avatarUrl: avatarUrl,
              name: name,
              isLive: isLive,
              showRing: showRing,
            ),

            const SizedBox(height: 10),

            // ── Name ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  if (isVerified) ...[
                    const SizedBox(width: 3),
                    ShaderMask(
                      shaderCallback: (b) => _T.brand.createShader(b),
                      child: const Icon(Icons.verified_rounded,
                          color: Colors.white, size: 13),
                    ),
                  ],
                ],
              ),
            ),

            // ── @username ─────────────────────────────────────────────
            if (username.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                child: Text(
                  '@$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const Spacer(),

            // ── Follow button ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: ScaleTransition(
                scale: _followScale,
                child: GestureDetector(
                  onTap: followed ? null : _onFollow,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: followed ? null : _T.brand,
                      color: followed ? colors.surfaceHighest : null,
                      borderRadius: BorderRadius.circular(10),
                      border: followed
                          ? Border.all(color: colors.border)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      followed ? S.of(context).suggestedFollowing : S.of(context).suggestedFollow,
                      style: TextStyle(
                        color: followed ? colors.textSecondary : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar Stack ─────────────────────────────────────────────────────────────

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({
    required this.avatarUrl,
    required this.name,
    required this.isLive,
    required this.showRing,
  });
  final String? avatarUrl;
  final String name;
  final bool isLive;
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    const double size = 54;
    const double ringPad = 2.5;
    final colors = context.colors;

    Widget avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: colors.surfaceHighest,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );

    if (showRing) {
      // Gradient ring (story or live)
      avatar = Container(
        width: size + ringPad * 2 + 3,
        height: size + ringPad * 2 + 3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isLive
              ? const LinearGradient(
                  colors: [Color(0xFFFF3B7E), Color(0xFFFF6B35)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : _T.storyRing,
        ),
        padding: const EdgeInsets.all(ringPad),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.surface,
          ),
          padding: const EdgeInsets.all(1.5),
          child: avatar,
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        avatar,
        if (isLive)
          Positioned(
            bottom: showRing ? -2 : -4,
            child: _LiveBadge(),
          ),
      ],
    );
  }
}

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Color.lerp(
            _T.live,
            const Color(0xFFFF6B35),
            _pulse.value,
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: _T.liveGlow,
              blurRadius: 6 + _pulse.value * 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Text(
          S.of(context).suggestedLiveBadge,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 7.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _RailSkeleton extends StatefulWidget {
  const _RailSkeleton();

  @override
  State<_RailSkeleton> createState() => _RailSkeletonState();
}

class _RailSkeletonState extends State<_RailSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _bone(double w, double h, {double r = 8}) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          gradient: LinearGradient(
            begin: Alignment(-1 + _ctrl.value * 2, 0),
            end: Alignment(1 + _ctrl.value * 2, 0),
            colors: [
              colors.shimmerBase,
              colors.shimmerHighlight,
              colors.shimmerBase,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: _bone(150, 14),
          ),
          SizedBox(
            height: 178,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              itemCount: 5,
              itemBuilder: (_, __) => Container(
                width: 112,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _bone(54, 54, r: 27),
                    const SizedBox(height: 10),
                    _bone(72, 11),
                    const SizedBox(height: 6),
                    _bone(50, 9),
                    const SizedBox(height: 12),
                    _bone(80, 28, r: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
