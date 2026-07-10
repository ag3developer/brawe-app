import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/app_colors.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../domain/models/follow_user.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Bottom sheet "Compartilhar live" — envia preview clicável da live aos
/// seguidores selecionados via DM. Cada destinatário recebe uma mensagem
/// `live_invite` que abre a live ao ser tocada no chat.
class ShareLiveSheet extends ConsumerStatefulWidget {
  const ShareLiveSheet({
    super.key,
    required this.roomId,
    required this.title,
    this.streamerName,
    this.thumbnailUrl,
  });

  final String roomId;
  final String title;
  final String? streamerName;
  final String? thumbnailUrl;

  static Future<void> show(
    BuildContext context, {
    required String roomId,
    required String title,
    String? streamerName,
    String? thumbnailUrl,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ShareLiveSheet(
        roomId: roomId,
        title: title,
        streamerName: streamerName,
        thumbnailUrl: thumbnailUrl,
      ),
    );
  }

  @override
  ConsumerState<ShareLiveSheet> createState() => _ShareLiveSheetState();
}

class _ShareLiveSheetState extends ConsumerState<ShareLiveSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  final Set<String> _selectedUserIds = <String>{};

  bool _loading = true;
  bool _sending = false;
  String? _error;
  List<FollowUser> _followers = const [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
      () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final s = S.of(context);
    final socialRepo = ref.read(socialRepositoryProvider);
    final me = ref.read(authStateProvider).asData?.value;
    try {
      if (me == null) {
        setState(() {
          _loading = false;
          _error = s.shareLiveLoginNeeded;
        });
        return;
      }
      final res = await socialRepo.getUserFollowers(me.id, page: 1, limit: 100);
      if (!mounted) return;
      setState(() {
        _followers = res.items;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[ShareLiveSheet] load failed: $e');
      if (!mounted) return;
      setState(() {
        _error = s.shareLiveLoadFollowersError;
        _loading = false;
      });
    }
  }

  List<FollowUser> get _filtered {
    if (_query.isEmpty) return _followers;
    return _followers
        .where((p) {
          final n = (p.displayName ?? '').toLowerCase();
          final u = p.username.toLowerCase();
          return n.contains(_query) || u.contains(_query);
        })
        .toList(growable: false);
  }

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
    final s = S.of(context);
    try {
      final repo = ref.read(liveRepositoryProvider);
      final note = _noteCtrl.text.trim();
      final sent = await repo.shareLiveToUsers(
        widget.roomId,
        userIds: _selectedUserIds.toList(),
        note: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.electricPurple,
          content: Text(s.shareLiveSentToCount(sent)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(s.shareLiveSendFailed),
        ),
      );
    }
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
            decoration: const BoxDecoration(
              color: AppColors.nearBlack,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _grabber(),
                _header(),
                _livePreview(),
                _search(),
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
                if (_selectedUserIds.isNotEmpty) _noteBar(),
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
      color: AppColors.coolGray.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        S.of(context).shareLiveTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );

  Widget _livePreview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.electricPurple.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child:
                      widget.thumbnailUrl != null &&
                          widget.thumbnailUrl!.isNotEmpty
                      ? Image.network(
                          widget.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _previewFallback(),
                        )
                      : _previewFallback(),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mutedRed,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      S.of(context).shareLiveBadge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.streamerName != null &&
                    widget.streamerName!.isNotEmpty)
                  Text(
                    widget.streamerName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.coolGray,
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
    child: const Icon(Icons.videocam_outlined, color: Colors.white54, size: 24),
  );

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: S.of(context).shareLiveSearchHint,
          hintStyle: const TextStyle(color: AppColors.coolGray),
          prefixIcon: const Icon(Icons.search, color: AppColors.coolGray),
          filled: true,
          fillColor: AppColors.slate,
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
    final s = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _error ?? s.shareLiveErrorGeneric,
            style: const TextStyle(color: AppColors.coolGray),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: Text(s.shareLiveRetry)),
        ],
      ),
    );
  }

  Widget _list(ScrollController controller) {
    final items = _filtered;
    final s = S.of(context);
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            s.shareLiveEmptyFollowers,
            style: const TextStyle(color: AppColors.coolGray),
          ),
        ),
      );
    }
    return ListView.builder(
      controller: controller,
      itemCount: items.length,
      itemBuilder: (_, i) {
        final p = items[i];
        final selected = _selectedUserIds.contains(p.userId);
        return _RecipientTile(
          name: (p.displayName != null && p.displayName!.isNotEmpty)
              ? p.displayName!
              : (p.username.isNotEmpty ? p.username : s.shareLiveDefaultUser),
          username: p.username.isNotEmpty ? p.username : null,
          avatarUrl: p.avatarUrl,
          isVerified: p.isVerified,
          selected: selected,
          onTap: () => _toggle(p.userId),
        );
      },
    );
  }

  Widget _noteBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: TextField(
        controller: _noteCtrl,
        style: const TextStyle(color: Colors.white),
        maxLines: 2,
        minLines: 1,
        decoration: InputDecoration(
          hintText: S.of(context).shareLiveNoteHint,
          hintStyle: const TextStyle(color: AppColors.coolGray),
          filled: true,
          fillColor: AppColors.slate,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
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
    final s = S.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasSelection && !_sending ? _send : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricPurple,
              disabledBackgroundColor: AppColors.electricPurple.withValues(
                alpha: 0.3,
              ),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    hasSelection
                        ? s.shareLiveSendTo(count)
                        : s.shareLiveSelectContacts,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
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
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String? username;
  final String? avatarUrl;
  final bool isVerified;
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
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.slate,
              backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? const Icon(Icons.person, color: Colors.white54, size: 22)
                  : null,
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
                          style: const TextStyle(
                            color: Colors.white,
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
                      style: const TextStyle(
                        color: AppColors.coolGray,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.electricPurple : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.electricPurple
                      : AppColors.coolGray.withValues(alpha: 0.5),
                  width: 1.6,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
