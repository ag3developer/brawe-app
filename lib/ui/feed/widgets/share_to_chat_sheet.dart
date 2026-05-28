import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'dart:async';

import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../data/services/post_service.dart';
import '../../../domain/models/conversation.dart';
import '../../../domain/models/follow_user.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Instagram-style "Send to..." bottom sheet.
class ShareToChatSheet extends ConsumerStatefulWidget {
  const ShareToChatSheet({
    super.key,
    required this.postId,
    required this.postCaption,
    this.postImageUrl,
    this.authorName,
  });

  final String postId;
  final String postCaption;
  final String? postImageUrl;
  final String? authorName;

  static Future<void> show(
    BuildContext context, {
    required String postId,
    required String postCaption,
    String? postImageUrl,
    String? authorName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ShareToChatSheet(
        postId: postId,
        postCaption: postCaption,
        postImageUrl: postImageUrl,
        authorName: authorName,
      ),
    );
  }

  @override
  ConsumerState<ShareToChatSheet> createState() => _ShareToChatSheetState();
}

class _ShareToChatSheetState extends ConsumerState<ShareToChatSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _commentCtrl = TextEditingController();
  final Set<String> _selectedUserIds = <String>{};

  bool _loading = true;
  bool _sending = false;
  String? _error;
  List<Conversation> _recent = const [];
  List<FollowUser> _following = const [];
  String _query = '';

  String get _postUrl => 'https://brawe.app/connect/p/${widget.postId}';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final chatRepo = ref.read(chatRepositoryProvider);
    final socialRepo = ref.read(socialRepositoryProvider);
    final me = ref.read(authStateProvider).asData?.value;

    // Carrega em paralelo, mas tratando erros de forma independente: se uma
    // falhar a outra continua disponível.
    final recentFuture = chatRepo
        .listConversations(page: 1, limit: 20)
        .then<List<Conversation>>((v) => v)
        .catchError((e, st) {
          debugPrint('[ShareToChatSheet] listConversations failed: $e');
          return <Conversation>[];
        });

    final followingFuture = (me != null)
        ? socialRepo
            .getUserFollowing(me.id, page: 1, limit: 50)
            .then<List<FollowUser>>((r) => r.items)
            .catchError((e, st) {
              debugPrint('[ShareToChatSheet] getUserFollowing failed: $e');
              return <FollowUser>[];
            })
        : Future.value(<FollowUser>[]);

    try {
      final recent = await recentFuture;
      final following = await followingFuture;
      if (!mounted) return;
      setState(() {
        _recent = recent;
        _following = following;
        _loading = false;
        _error = (recent.isEmpty && following.isEmpty)
            ? S.of(context).shareLoadError
            : null;
      });
    } catch (e, st) {
      debugPrint('[ShareToChatSheet] load failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = S.of(context).shareLoadError;
        _loading = false;
      });
    }
  }

  bool _matches(String q, {String? a, String? b}) {
    if (q.isEmpty) return true;
    return (a ?? '').toLowerCase().contains(q) ||
        (b ?? '').toLowerCase().contains(q);
  }

  List<Conversation> get _filteredRecent => _recent
      .where((c) =>
          _matches(_query, a: c.participantName, b: c.participantUsername))
      .toList(growable: false);

  List<FollowUser> get _filteredFollowing => _following
      .where((p) => _matches(_query, a: p.displayName, b: p.username))
      .toList(growable: false);

  void _toggle(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  Future<void> _send() async {
    if (_selectedUserIds.isEmpty || _sending) return;
    setState(() => _sending = true);
    final chatRepo = ref.read(chatRepositoryProvider);

    final comment = _commentCtrl.text.trim();
    final content = comment.isEmpty ? _postUrl : '$comment\n\n$_postUrl';

    final Map<String, String> userIdToConv = {
      for (final c in _recent) c.participantId: c.id,
    };

    int sent = 0;
    final failures = <String>[];

    for (final userId in _selectedUserIds) {
      try {
        String? conversationId = userIdToConv[userId];
        if (conversationId == null) {
          final profile = _following.firstWhere(
            (p) => p.userId == userId,
            orElse: () => const FollowUser(userId: ''),
          );
          final slug = profile.username.isNotEmpty ? profile.username : userId;
          final result = await chatRepo.getOrCreateConversationByUser(slug);
          conversationId = result.conversationId;
        }
        await chatRepo.sendMessage(
          conversationId: conversationId,
          message: content,
        );
        sent++;
      } catch (_) {
        failures.add(userId);
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    // Quest progress: share_1_post (best-effort, não bloqueia UX)
    if (sent > 0) {
      unawaited(
        ref.read(postServiceProvider).trackShare(widget.postId),
      );
    }
    final s = S.of(context);
    final msg = failures.isEmpty
        ? s.shareSentSuccess(sent)
        : s.shareSentPartial(sent, failures.length);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _externalShare() async {
    final text = widget.postCaption.isNotEmpty
        ? '${widget.postCaption}\n\n$_postUrl'
        : _postUrl;
    try {
      await Share.share(text);
      // Quest progress: share_1_post (best-effort)
      unawaited(
        ref.read(postServiceProvider).trackShare(widget.postId),
      );
    } catch (_) {/* ignore */}
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration:  BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _grabber(),
                _header(),
                _postPreview(),
                _searchField(),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.electricPurple,
                          ),
                        )
                      : _error != null
                          ? _errorState()
                          : _list(scrollController),
                ),
                if (_selectedUserIds.isNotEmpty) _commentBar(),
                _bottomActions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _grabber() => Container(
        margin: const EdgeInsets.only(top: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.colors.textSecondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _header() => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            S.of(context).shareTitle,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );

  Widget _postPreview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: widget.postImageUrl != null &&
                      widget.postImageUrl!.isNotEmpty
                  ? Image.network(
                      widget.postImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _previewFallback(),
                    )
                  : _previewFallback(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.authorName != null && widget.authorName!.isNotEmpty)
                  Text(
                    widget.authorName!,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                Text(
                  widget.postCaption.isNotEmpty
                      ? widget.postCaption
                      : S.of(context).sharePostFallback,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:  TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewFallback() => Container(
        color: AppColors.deepBlue,
        child: Icon(Icons.image_outlined,
            color: context.colors.textTertiary, size: 20),
      );

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: TextField(
        controller: _searchCtrl,
        style: TextStyle(color: context.colors.textPrimary),
        decoration: InputDecoration(
          hintText: S.of(context).shareSearchHint,
          hintStyle:  TextStyle(color: context.colors.textSecondary),
          prefixIcon:  Icon(Icons.search, color: context.colors.textSecondary),
          filled: true,
          fillColor: context.colors.surfaceElevated,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error ?? S.of(context).shareErrorGeneric,
              style:  TextStyle(color: context.colors.textSecondary)),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: Text(S.of(context).shareTryAgain)),
        ],
      ),
    );
  }

  Widget _list(ScrollController controller) {
    final recents = _filteredRecent;
    final recentIds = recents.map((c) => c.participantId).toSet();
    final filteredFollowing = _filteredFollowing
        .where((p) => !recentIds.contains(p.userId))
        .toList(growable: false);

    return CustomScrollView(
      controller: controller,
      slivers: [
        if (recents.isNotEmpty) ...[
           SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                S.of(context).shareRecents,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 96,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: recents.length,
                itemBuilder: (_, i) {
                  final c = recents[i];
                  final selected = _selectedUserIds.contains(c.participantId);
                  return _QuickRecipient(
                    name: c.participantName,
                    avatarUrl: c.participantAvatarUrl,
                    selected: selected,
                    onTap: () => _toggle(c.participantId),
                  );
                },
              ),
            ),
          ),
        ],
        if (filteredFollowing.isNotEmpty) ...[
           SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                S.of(context).shareFollowers,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: filteredFollowing.length,
            itemBuilder: (_, i) {
              final p = filteredFollowing[i];
              final selected = _selectedUserIds.contains(p.userId);
              return _RecipientTile(
                name: (p.displayName != null && p.displayName!.isNotEmpty)
                    ? p.displayName!
                    : (p.username.isNotEmpty ? p.username : S.of(context).shareUserFallback),
                username: p.username.isNotEmpty ? p.username : null,
                avatarUrl: p.avatarUrl,
                isVerified: p.isVerified,
                isLive: p.isLive,
                selected: selected,
                onTap: () => _toggle(p.userId),
              );
            },
          ),
        ],
        if (recents.isEmpty && filteredFollowing.isEmpty)
           SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  S.of(context).shareNoContacts,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
      ],
    );
  }

  Widget _commentBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: TextField(
        controller: _commentCtrl,
        style: TextStyle(color: context.colors.textPrimary),
        maxLines: 2,
        minLines: 1,
        decoration: InputDecoration(
          hintText: S.of(context).shareCommentHint,
          hintStyle:  TextStyle(color: context.colors.textSecondary),
          filled: true,
          fillColor: context.colors.surfaceElevated,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _bottomActions() {
    final count = _selectedUserIds.length;
    final hasSelection = count > 0;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _externalShare,
                icon: const Icon(Icons.ios_share, size: 18),
                label: Text(S.of(context).shareOutsideBrawe),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.textPrimary,
                  side: BorderSide(
                    color: context.colors.textSecondary.withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: hasSelection && !_sending ? _send : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricPurple,
                  disabledBackgroundColor:
                      AppColors.electricPurple.withValues(alpha: 0.3),
                  foregroundColor: context.colors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _sending
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: context.colors.textPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        hasSelection ? S.of(context).shareSendWithCount(count) : S.of(context).shareSend,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickRecipient extends StatelessWidget {
  const _QuickRecipient({
    required this.name,
    required this.avatarUrl,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String? avatarUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.electricPurple
                          : Colors.transparent,
                      width: 2.4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: context.colors.surfaceElevated,
                    backgroundImage:
                        (avatarUrl != null && avatarUrl!.isNotEmpty)
                            ? NetworkImage(avatarUrl!)
                            : null,
                    child: (avatarUrl == null || avatarUrl!.isEmpty)
                        ? Icon(Icons.person,
                            color: context.colors.textTertiary, size: 24)
                        : null,
                  ),
                ),
                if (selected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.electricPurple,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Icon(Icons.check,
                          color: context.colors.textPrimary, size: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipientTile extends StatelessWidget {
  const _RecipientTile({
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.isVerified,
    required this.isLive,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String? username;
  final String? avatarUrl;
  final bool isVerified;
  final bool isLive;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isLive
                        ? Border.all(color: AppColors.mutedRed, width: 2)
                        : null,
                  ),
                  padding: EdgeInsets.all(isLive ? 2 : 0),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: context.colors.surfaceElevated,
                    backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: (avatarUrl == null || avatarUrl!.isEmpty)
                        ? Icon(Icons.person, color: context.colors.textTertiary, size: 22)
                        : null,
                  ),
                ),
                if (isLive)
                  Positioned(
                    bottom: -2,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.mutedRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          S.of(context).storiesLiveBadge,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
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
                      if (isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 14,
                          color: AppColors.coolCyan,
                        ),
                      ],
                    ],
                  ),
                  if (username != null && username!.isNotEmpty)
                    Text(
                      '@$username',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            _Checkmark(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _Checkmark extends StatelessWidget {
  const _Checkmark({required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.electricPurple : Colors.transparent,
        border: Border.all(
          color: selected
              ? AppColors.electricPurple
              : context.colors.textSecondary.withValues(alpha: 0.5),
          width: 1.6,
        ),
      ),
      child: selected
          ? Icon(Icons.check, size: 16, color: context.colors.textPrimary)
          : null,
    );
  }
}
