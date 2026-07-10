import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/post_repository.dart';
import '../../../domain/models/post_liker.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/follow_button.dart';

/// Provider AutoDispose+Family que busca os "likers" de um post.
final postLikersProvider = FutureProvider.autoDispose
    .family<PostLikesPage, String>((ref, postId) async {
      final repo = ref.watch(postRepositoryProvider);
      return repo.getLikers(postId, limit: 100);
    });

/// Tela que lista quem curtiu uma publicação, com chips de breakdown
/// por tipo de reação (❤️ 🔥 😂 😮 😢) — estilo Instagram/Facebook.
///
/// Acessível tocando no contador de likes em qualquer PostCard.
class PostLikersScreen extends ConsumerWidget {
  const PostLikersScreen({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final colors = context.colors;
    final asyncPage = ref.watch(postLikersProvider(postId));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.postLikersTitle),
        backgroundColor: colors.background,
      ),
      body: asyncPage.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_outline,
                  color: colors.textSecondary,
                  size: 56,
                ),
                const SizedBox(height: 12),
                Text(
                  s.postLikersLoadError,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textPrimary),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(postLikersProvider(postId)),
                  child: Text(s.walletTryAgain),
                ),
              ],
            ),
          ),
        ),
        data: (page) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(postLikersProvider(postId));
            await ref.read(postLikersProvider(postId).future);
          },
          child: page.likers.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 120),
                    Icon(
                      Icons.favorite_outline,
                      size: 56,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        s.postLikersEmpty,
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ),
                  ],
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          s.postLikersTotal(page.total),
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (page.reactionsBreakdown.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _ReactionsBreakdownStrip(
                          breakdown: page.reactionsBreakdown,
                        ),
                      ),
                    SliverList.separated(
                      itemCount: page.likers.length,
                      itemBuilder: (_, i) => _LikerTile(liker: page.likers[i]),
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: colors.divider),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ReactionsBreakdownStrip extends StatelessWidget {
  const _ReactionsBreakdownStrip({required this.breakdown});
  final Map<String, int> breakdown;

  @override
  Widget build(BuildContext context) {
    final entries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final e = entries[i];
            return _ReactionChip(type: e.key, count: e.value);
          },
        ),
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({required this.type, required this.count});
  final String type;
  final int count;

  static const _emojiByType = {
    'like': '👍',
    'love': '❤️',
    'fire': '🔥',
    'laugh': '😂',
    'wow': '😮',
    'sad': '😢',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final emoji = _emojiByType[type] ?? '👍';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            _format(count),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _LikerTile extends ConsumerWidget {
  const _LikerTile({required this.liker});
  final PostLiker liker;

  static const _emojiByType = {
    'like': '👍',
    'love': '❤️',
    'fire': '🔥',
    'laugh': '😂',
    'wow': '😮',
    'sad': '😢',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final emoji = _emojiByType[liker.reactionType] ?? '👍';

    return InkWell(
      onTap: () {
        if (liker.userId.isNotEmpty) {
          context.push('/profile/${liker.userId}');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar com emoji da reação no canto
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colors.surface,
                  backgroundImage:
                      (liker.avatarUrl != null && liker.avatarUrl!.isNotEmpty)
                      ? CachedNetworkImageProvider(liker.avatarUrl!)
                      : null,
                  child: (liker.avatarUrl == null || liker.avatarUrl!.isEmpty)
                      ? Text(
                          liker.displayName.isNotEmpty
                              ? liker.displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(color: colors.textPrimary),
                        )
                      : null,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Nome + verificado
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      liker.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (liker.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      size: 16,
                      color: Color(0xFF1DA1F2),
                    ),
                  ],
                ],
              ),
            ),
            // Follow button inline (não aparece se já segue ou é o próprio user)
            if (liker.userId.isNotEmpty)
              FollowButton(userId: liker.userId, compact: true),
          ],
        ),
      ),
    );
  }
}
