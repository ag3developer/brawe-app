import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
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
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
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
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppColors.braweBlue.withValues(alpha: 0.10),
                    AppColors.braweSky.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: context.colors.border,
                ),
              ),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
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
                    Icons.search,
                    color: context.colors.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.close,
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
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [AppColors.braweBlue, AppColors.braweSky],
                  ).createShader(b),
                  child: Text(
                    S.of(context).chatFollowingLabel,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── List ───
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.braweBlue,
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: context.colors.surface,
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isLive
                          ? const LinearGradient(
                              colors: [Colors.red, Colors.orange],
                            )
                          : null,
                    ),
                    padding: EdgeInsets.all(isLive ? 2.2 : 0),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: context.colors.surfaceElevated,
                      backgroundImage: avatarUrl != null
                          ? CachedNetworkImageProvider(avatarUrl, maxWidth: context.decodePx(48))
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
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: context.colors.background,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          S.of(context).chatLiveBadge,
                          style: TextStyle(
                            color: Colors.white,
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
                          color: context.colors.textSecondary.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.braweBlue, AppColors.braweSky],
                  ),
                ),
                child: Icon(Icons.send, color: Colors.white, size: 16),
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
              gradient: RadialGradient(
                colors: [
                  AppColors.braweBlue.withValues(alpha: 0.25),
                  AppColors.braweBlue.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Icon(
              Icons.person_search,
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
