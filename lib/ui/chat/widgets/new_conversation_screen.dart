import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';

part 'new_conversation_screen.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider — busca lista de quem o usuário segue, filtrável por query
// ─────────────────────────────────────────────────────────────────────────────
@riverpod
class FollowingQuery extends _$FollowingQuery {
  @override
  String build() => '';

  void set(String q) => state = q;
}

final _followingListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final query = ref.watch(followingQueryProvider);
  return ref.read(chatRepositoryProvider).getFollowingForDm(query: query);
});

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class NewConversationScreen extends ConsumerStatefulWidget {
  const NewConversationScreen({super.key});

  @override
  ConsumerState<NewConversationScreen> createState() =>
      _NewConversationScreenState();
}

class _NewConversationScreenState extends ConsumerState<NewConversationScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _starting = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(followingQueryProvider.notifier).set(v.trim());
    });
  }

  Future<void> _openDm(Map<String, dynamic> user) async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      final userId = user['user_id']?.toString() ?? '';
      final convId = await ref
          .read(chatRepositoryProvider)
          .startConversation(participantId: userId);
      if (!mounted) return;
      context.go(
        '/chat/$convId',
        extra: {
          'participantName':
              user['display_name'] ??
              user['username'] ??
              S.of(context).chatFallbackName,
          'participantAvatarUrl': user['avatar_url'],
          'participantId': userId,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).chatStartConversationError(e))),
      );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(_followingListProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.colors.textPrimary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/chat'),
        ),
        title: Text(
          S.of(context).chatNewMessageTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          // ─── Search bar ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: context.colors.surfaceHighest,
              ),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.none,
                onChanged: _onSearch,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: S.of(context).chatSearchHint,
                  hintStyle: TextStyle(
                    color: context.colors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    LucideIcons.search,
                    color: context.colors.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            LucideIcons.x,
                            color: context.colors.textSecondary,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(followingQueryProvider.notifier).set('');
                          },
                        ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),

          // ─── Section label ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: [
                Text(
                  S.of(context).chatFollowingLabel,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ─── List ───
          Expanded(
            child: usersAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: context.colors.accentPrimary,
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  S.of(context).chatLoadError(e),
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return const _EmptySearchState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 2),
                  itemBuilder: (ctx, i) {
                    final user = users[i];
                    return _UserTile(
                      user: user,
                      onTap: () => _openDm(user),
                      loading: _starting,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.onTap,
    required this.loading,
  });

  final Map<String, dynamic> user;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final name = (user['display_name'] as String? ?? '').isNotEmpty
        ? user['display_name'] as String
        : user['username'] as String? ?? '?';
    final username = user['username'] as String? ?? '';
    final avatarUrl = user['avatar_url'] as String?;
    final isLive = user['is_live'] == true;
    final isVerified = user['is_verified'] == true;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: loading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isLive
                          ? LinearGradient(
                              colors: [
                                context.colors.danger,
                                context.colors.accentGold,
                              ],
                            )
                          : null,
                    ),
                    padding: EdgeInsets.all(isLive ? 2.2 : 0),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: context.colors.surfaceElevated,
                      backgroundImage: avatarUrl != null
                          ? CachedNetworkImageProvider(
                              avatarUrl,
                              maxWidth: context.decodePx(48),
                            )
                          : null,
                      child: avatarUrl == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  if (isLive)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.danger,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: context.colors.background,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          S.of(context).chatLiveBadge,
                          style: TextStyle(
                            color: context.colors.textOnAccent,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) const VerifiedBadge(size: 14, gap: 4),
                      ],
                    ),
                    if (username.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '@$username',
                        style: TextStyle(
                          color: context.colors.textTertiary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              Icon(
                LucideIcons.chevronRight,
                color: context.colors.textTertiary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.surfaceHighest,
            ),
            child: Icon(
              LucideIcons.userSearch,
              size: 48,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).chatEmptySearchTitle,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              S.of(context).chatEmptySearchSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
