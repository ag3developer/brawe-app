import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../domain/models/follow_user.dart';
import '../../../gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';

/// Bottom sheet "Compartilhar live" — envia preview clicável da live aos
/// seguidores selecionados via DM. Cada destinatário recebe uma mensagem
/// `live_invite` que abre a live ao ser tocada no chat.
class ShareLiveSheet extends ConsumerStatefulWidget {
  const ShareLiveSheet({
    super.key,
    required this.roomId,
    required this.title,
    this.slug,
    this.streamerName,
    this.thumbnailUrl,
  });

  final String roomId;
  final String title;

  /// Slug do link público (`brawe.app/live/<slug>`) — habilita o
  /// compartilhamento externo (WhatsApp, Instagram…).
  final String? slug;
  final String? streamerName;
  final String? thumbnailUrl;

  static Future<void> show(
    BuildContext context, {
    required String roomId,
    required String title,
    String? slug,
    String? streamerName,
    String? thumbnailUrl,
  }) {
    return showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ForceDarkTheme(
        child: ShareLiveSheet(
          roomId: roomId,
          title: title,
          slug: slug,
          streamerName: streamerName,
          thumbnailUrl: thumbnailUrl,
        ),
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
  String? _sendError;
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

  /// Limite do backend por envio (`/live/rooms/{id}/share`).
  static const _maxRecipients = 50;

  void _toggle(String userId) {
    if (!_selectedUserIds.contains(userId) &&
        _selectedUserIds.length >= _maxRecipients) {
      setState(() => _sendError = S.of(context).livexShareMax);
      return;
    }
    setState(() {
      _sendError = null;
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  /// Compartilhamento EXTERNO (sistema): WhatsApp, Instagram, SMS…
  Future<void> _shareExternally() async {
    final slug = widget.slug;
    if (slug == null || slug.isEmpty) return;
    final url = AppConstants.liveUrl(slug);
    final who = widget.streamerName?.trim();
    final text = who != null && who.isNotEmpty
        ? S.of(context).livexShareText(who, widget.title, url)
        : S.of(context).livexShareTextSelf(widget.title, url);
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (e) {
      debugPrint('[ShareLiveSheet] external share failed: $e');
    }
  }

  Future<void> _send() async {
    if (_selectedUserIds.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _sendError = null;
    });
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
      // Captura antes de fechar o sheet: o aviso de sucesso aparece na tela de baixo.
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: context.colors.accentPrimary,
          content: Text(
            s.shareLiveSentToCount(sent),
            style: TextStyle(color: context.colors.textOnAccent),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Falha: o sheet continua aberto, então o erro aparece dentro dele.
      setState(() {
        _sending = false;
        _sendError = s.shareLiveSendFailed;
      });
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
            decoration: BoxDecoration(
              color: context.colors.background,
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
                      ? Center(
                          child: CircularProgressIndicator(
                            color: context.colors.accentPrimary,
                          ),
                        )
                      : _error != null
                      ? _errorState()
                      : _list(scrollController),
                ),
                if (_sendError != null) _errorBanner(_sendError!),
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
      color: context.colors.textSecondary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            S.of(context).shareLiveTitle,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (widget.slug != null && widget.slug!.isNotEmpty)
          TextButton.icon(
            onPressed: _shareExternally,
            icon: const Icon(LucideIcons.send, size: 18),
            label: Text(S.of(context).livexShareOtherApps),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.textPrimary,
            ),
          ),
      ],
    ),
  );

  Widget _livePreview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.accentPrimary.withValues(alpha: 0.25),
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
                          cacheWidth: context.decodePx(56),
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
                      color: context.colors.danger,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      S.of(context).shareLiveBadge,
                      style: TextStyle(
                        color: Colors.white, // selo sobre a miniatura da live
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
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
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
    color: context.colors.surfaceHighest,
    child: Icon(
      LucideIcons.video,
      color: context.colors.textSecondary,
      size: 24,
    ),
  );

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: TextField(
        controller: _searchCtrl,
        style: TextStyle(color: context.colors.textPrimary),
        decoration: InputDecoration(
          hintText: S.of(context).shareLiveSearchHint,
          hintStyle: TextStyle(color: context.colors.textSecondary),
          prefixIcon: Icon(
            LucideIcons.search,
            color: context.colors.textSecondary,
          ),
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
    final s = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _error ?? s.shareLiveErrorGeneric,
            style: TextStyle(color: context.colors.textSecondary),
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
            style: TextStyle(color: context.colors.textSecondary),
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

  Widget _errorBanner(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        children: [
          Icon(LucideIcons.circleAlert, size: 16, color: context.colors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: context.colors.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        controller: _noteCtrl,
        style: TextStyle(color: context.colors.textPrimary),
        maxLines: 2,
        minLines: 1,
        decoration: InputDecoration(
          hintText: S.of(context).shareLiveNoteHint,
          hintStyle: TextStyle(color: context.colors.textSecondary),
          filled: true,
          fillColor: context.colors.surfaceElevated,
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
              backgroundColor: context.colors.accentPrimary,
              disabledBackgroundColor: context.colors.accentPrimary.withValues(
                alpha: 0.3,
              ),
              foregroundColor: context.colors.textOnAccent,
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
                      color: context.colors.textOnAccent,
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
              backgroundColor: context.colors.surfaceElevated,
              backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? ResizeImage(
                      NetworkImage(avatarUrl!),
                      width: context.decodePx(44),
                    )
                  : null,
              child: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? Icon(
                      LucideIcons.user,
                      color: context.colors.textSecondary,
                      size: 22,
                    )
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
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isVerified) const VerifiedBadge(size: 14, gap: 4),
                    ],
                  ),
                  if (username != null && username!.isNotEmpty)
                    Text(
                      '@$username',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textSecondary,
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
                color: selected
                    ? context.colors.accentPrimary
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? context.colors.accentPrimary
                      : context.colors.textSecondary.withValues(alpha: 0.5),
                  width: 1.6,
                ),
              ),
              child: selected
                  ? Icon(
                      LucideIcons.check,
                      size: 16,
                      color: context.colors.textOnAccent,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
