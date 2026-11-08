import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../data/services/messages_service.dart' show UserPresence;
import '../../../data/services/post_service.dart';
import '../../../data/services/social_service.dart';
import '../../../domain/models/conversation.dart';
import '../../../domain/models/follow_user.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../chat/view_models/presence_provider.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../core/widgets/brawe_avatar.dart';
import '../../core/widgets/report_sheet.dart';
import 'one_tap_repost.dart';
import 'story_composer_screen.dart';

/// O que está sendo compartilhado.
enum ShareKind { post, comment, profile, live }

/// Dados de um compartilhamento. O [ShareSheet] é o mesmo para posts,
/// vídeos, comentários, perfis e lives; cada tipo só liga/desliga ações.
class ShareTarget {
  const ShareTarget({
    required this.kind,
    required this.url,
    required this.shareText,
    this.chatText,
    this.postId,
    this.authorId,
    this.storyMediaUrl,
    this.isReposted = false,
    this.onRepostChanged,
  });

  final ShareKind kind;

  /// Link público (deep link) do conteúdo.
  final String url;

  /// Texto completo para apps externos (já contém o link).
  final String shareText;

  /// Mensagem enviada no chat; por padrão o próprio [url] (o chat mostra o
  /// card de prévia do post).
  final String? chatText;

  /// Posts/comentários: id do post (conta o compartilhamento e habilita
  /// repostar / denunciar).
  final String? postId;
  final String? authorId;

  /// Mídia do post, para "Adicionar ao Story".
  final String? storyMediaUrl;
  final bool isReposted;
  final ValueChanged<bool>? onRepostChanged;
}

/// Folha "Enviar para" no padrão dos apps de vídeo curto:
/// 1. pessoas (conversas recentes + quem você segue) com busca e seleção
///    múltipla; 2. apps externos (repostar, WhatsApp, copiar link, X, mais);
/// 3. ações neutras (Story, denunciar).
class ShareSheet extends ConsumerStatefulWidget {
  const ShareSheet({
    super.key,
    required this.target,
    required this.hostContext,
  });

  final ShareTarget target;

  /// Contexto de quem abriu a folha (para avisos e telas abertas depois de
  /// fechá-la).
  final BuildContext hostContext;

  /// Abre por cima de qualquer coisa aberta (ex.: painel de comentários),
  /// no navegador raiz, com o tema do app.
  static Future<void> show(BuildContext context, ShareTarget target) {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    return showModalBottomSheet<void>(
      context: rootContext,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) => ShareSheet(target: target, hostContext: context),
    );
  }

  @override
  ConsumerState<ShareSheet> createState() => _ShareSheetState();
}

class _Recipient {
  const _Recipient({
    required this.userId,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.conversationId,
    this.online = false,
  });

  final String userId;
  final String name;
  final String username;
  final String? avatarUrl;
  final String? conversationId;
  final bool online;
}

class _ShareSheetState extends ConsumerState<ShareSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  bool _loading = true;
  List<_Recipient> _people = const [];
  final Map<String, _Recipient> _selected = {};

  bool _searching = false;
  bool _searchBusy = false;
  List<_Recipient> _results = const [];
  Timer? _debounce;
  int _searchId = 0;

  bool _sending = false;
  bool _tracked = false;
  String? _notice;
  bool _noticeError = false;
  Timer? _noticeTimer;

  ShareTarget get _t => widget.target;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _noticeTimer?.cancel();
    _searchCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Dados ──────────────────────────────────────────────────────────────

  Future<void> _load() async {
    final chatRepo = ref.read(chatRepositoryProvider);
    final socialRepo = ref.read(socialRepositoryProvider);
    final me = ref.read(authStateProvider).asData?.value;

    final recentFuture = chatRepo
        .listConversations(page: 1, limit: 20)
        .then<List<Conversation>>((v) => v)
        .catchError((Object e) => <Conversation>[]);
    final followingFuture = me == null
        ? Future.value(<FollowUser>[])
        : socialRepo
              .getUserFollowing(me.id, page: 1, limit: 50)
              .then<List<FollowUser>>((r) => r.items)
              .catchError((Object e) => <FollowUser>[]);

    final recent = await recentFuture;
    final following = await followingFuture;
    if (!mounted) return;

    final seen = <String>{};
    final people = <_Recipient>[
      for (final c in recent)
        if (!c.isSystem &&
            c.participantId.isNotEmpty &&
            seen.add(c.participantId))
          _Recipient(
            userId: c.participantId,
            name: c.participantName,
            username: c.participantUsername ?? '',
            avatarUrl: c.participantAvatarUrl,
            conversationId: c.id,
            online: c.isOnline,
          ),
      for (final f in following)
        if (f.userId.isNotEmpty && seen.add(f.userId))
          _Recipient(
            userId: f.userId,
            name: (f.displayName?.trim().isNotEmpty ?? false)
                ? f.displayName!.trim()
                : f.username,
            username: f.username,
            avatarUrl: f.avatarUrl,
          ),
    ];
    ref
        .read(presenceCacheProvider.notifier)
        .watchAll(people.take(30).map((p) => p.userId));
    setState(() {
      _people = people;
      _loading = false;
    });
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    final q = text.trim();
    if (q.isEmpty) {
      setState(() {
        _results = const [];
        _searchBusy = false;
      });
      return;
    }
    setState(() => _searchBusy = true);
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _search(String q) async {
    final id = ++_searchId;
    try {
      final res = await ref.read(socialServiceProvider).searchUsers(q);
      if (!mounted || id != _searchId) return;
      final me = ref.read(authStateProvider).asData?.value;
      setState(() {
        _results = [
          for (final u in res)
            if ((u['user_id']?.toString() ?? '').isNotEmpty &&
                u['user_id'].toString() != me?.id)
              _Recipient(
                userId: u['user_id'].toString(),
                name:
                    ((u['display_name'] as String?)?.trim().isNotEmpty ?? false)
                    ? (u['display_name'] as String).trim()
                    : (u['username']?.toString() ?? ''),
                username: u['username']?.toString() ?? '',
                avatarUrl: u['avatar_url']?.toString(),
              ),
        ];
        _searchBusy = false;
      });
    } catch (_) {
      if (!mounted || id != _searchId) return;
      setState(() => _searchBusy = false);
    }
  }

  void _openSearch() => setState(() => _searching = true);

  void _closeSearch() {
    _debounce?.cancel();
    _searchCtrl.clear();
    setState(() {
      _searching = false;
      _results = const [];
      _searchBusy = false;
    });
  }

  // ── Aviso dentro da folha ──────────────────────────────────────────────

  void _flash(String text, {bool error = false}) {
    if (!mounted) return;
    _noticeTimer?.cancel();
    setState(() {
      _notice = text;
      _noticeError = error;
    });
    _noticeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _notice = null);
    });
  }

  void _trackShareOnce() {
    final id = _t.postId;
    if (_tracked || id == null) return;
    _tracked = true;
    unawaited(ref.read(postServiceProvider).trackShare(id));
  }

  // ── Enviar no chat ─────────────────────────────────────────────────────

  void _toggle(_Recipient p) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selected.remove(p.userId) == null) _selected[p.userId] = p;
    });
  }

  Future<void> _send() async {
    if (_selected.isEmpty || _sending) return;
    final s = S.of(context);
    setState(() => _sending = true);
    final chatRepo = ref.read(chatRepositoryProvider);
    final message = _t.chatText ?? _t.url;
    final note = _noteCtrl.text.trim();
    final failed = <String>[];
    var ok = 0;
    for (final p in _selected.values.toList()) {
      try {
        var conversationId = p.conversationId;
        if (conversationId == null) {
          final slug = p.username.isNotEmpty ? p.username : p.userId;
          conversationId = (await chatRepo.getOrCreateConversationByUser(
            slug,
          )).conversationId;
        }
        await chatRepo.sendMessage(
          conversationId: conversationId,
          message: message,
        );
        if (note.isNotEmpty) {
          await chatRepo.sendMessage(
            conversationId: conversationId,
            message: note,
          );
        }
        ok++;
      } catch (e) {
        debugPrint('[ShareSheet] send failed: $e');
        failed.add(p.userId);
      }
    }
    if (!mounted) return;
    if (ok > 0) _trackShareOnce();
    if (failed.isEmpty) {
      setState(() => _sending = false);
      _flash(s.cmtShareSentCount(ok));
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) Navigator.of(context).pop();
    } else {
      setState(() {
        _sending = false;
        _selected.removeWhere((id, _) => !failed.contains(id));
      });
      _flash(s.cmtShareSendFail, error: true);
    }
  }

  // ── Ações externas ─────────────────────────────────────────────────────

  Future<void> _launch(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (ok) {
        _trackShareOnce();
      } else {
        _flash(S.of(context).cmtShareOpenFail, error: true);
      }
    } catch (_) {
      if (mounted) _flash(S.of(context).cmtShareOpenFail, error: true);
    }
  }

  Future<void> _whatsapp() => _launch(
    Uri.parse('https://wa.me/?text=${Uri.encodeComponent(_t.shareText)}'),
  );

  Future<void> _x() => _launch(
    Uri.parse(
      'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(_t.shareText)}',
    ),
  );

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: _t.url));
    _trackShareOnce();
    if (mounted) _flash(S.of(context).feedLinkCopied);
  }

  Future<void> _more() async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    try {
      await SharePlus.instance.share(
        ShareParams(text: _t.shareText, sharePositionOrigin: origin),
      );
      _trackShareOnce();
    } catch (_) {
      /* cancelado / indisponível */
    }
  }

  void _repost() {
    final id = _t.postId;
    if (id == null) return;
    // O aviso do repost aparece na tela de baixo (a folha fecha logo).
    unawaited(
      oneTapRepost(
        context: widget.hostContext,
        ref: ref,
        postId: id,
        currentlyReposted: _t.isReposted,
        apply: (r) => _t.onRepostChanged?.call(r),
      ),
    );
    _trackShareOnce();
    Navigator.of(context).pop();
  }

  void _addToStory() {
    final media = _t.storyMediaUrl;
    final navigator = Navigator.of(context, rootNavigator: true);
    _trackShareOnce();
    Navigator.of(context).pop();
    navigator.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ForceDarkTheme(
          child: StoryComposerScreen(
            initialRemoteUrl: media,
            initialOriginPostId: _t.postId,
          ),
        ),
      ),
    );
  }

  void _report() {
    final host = widget.hostContext;
    final id = _t.postId;
    Navigator.of(context).pop();
    if (id != null && host.mounted) {
      showReportSheet(host, targetType: 'post', targetId: id);
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────

  bool get _isOwn {
    final me = ref.read(authStateProvider).asData?.value;
    return me != null && _t.authorId != null && me.id == _t.authorId;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final media = MediaQuery.of(context);
    final presence = ref.watch(presenceCacheProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _header(colors, s),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.topCenter,
                child: _notice == null
                    ? const SizedBox(width: double.infinity)
                    : _noticePill(colors),
              ),
              if (_searching)
                Flexible(child: _searchResults(colors, s, presence))
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 118,
                          child: _peopleRow(colors, s, presence),
                        ),
                        Divider(height: 1, color: colors.divider),
                        const SizedBox(height: 14),
                        _row(_externalActions(colors, s)),
                        ..._actionsSection(colors, s),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              if (_selected.isNotEmpty) _sendBar(colors, s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noticePill(BraweColors colors) {
    final c = _noticeError ? colors.danger : colors.success;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            _noticeError ? LucideIcons.circleAlert : LucideIcons.check,
            size: 16,
            color: c,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _notice!,
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BraweColors colors, S s) {
    if (_searching) {
      return SizedBox(
        height: 52,
        child: Row(
          children: [
            IconButton(
              tooltip: s.actionClose,
              onPressed: _closeSearch,
              icon: Icon(
                LucideIcons.arrowLeft,
                size: 22,
                color: colors.textSecondary,
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(color: colors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: s.cmtShareSearchHint,
                    hintStyle: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: colors.surfaceHighest,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(19),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      );
    }
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          IconButton(
            tooltip: s.cmtShareSearchHint,
            onPressed: _openSearch,
            icon: Icon(LucideIcons.search, size: 22, color: colors.textPrimary),
          ),
          Expanded(
            child: Text(
              s.cmtShareTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: s.actionClose,
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(LucideIcons.x, size: 22, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _peopleRow(
    BraweColors colors,
    S s,
    Map<String, UserPresence> presence,
  ) {
    if (_loading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.textTertiary,
          ),
        ),
      );
    }
    if (_people.isEmpty) {
      return Center(
        child: Text(
          s.shareNoContacts,
          style: TextStyle(color: colors.textTertiary, fontSize: 13),
        ),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: _people.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final p = _people[i];
        return _PersonTile(
          person: p,
          online: presence[p.userId]?.isOnline ?? p.online,
          selected: _selected.containsKey(p.userId),
          fallbackName: s.shareUserFallback,
          onTap: () => _toggle(p),
        );
      },
    );
  }

  Widget _searchResults(
    BraweColors colors,
    S s,
    Map<String, UserPresence> presence,
  ) {
    if (_searchBusy && _results.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.textTertiary,
            ),
          ),
        ),
      );
    }
    if (_results.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            _searchCtrl.text.trim().isEmpty
                ? s.cmtShareSearchHint
                : s.cmtShareNoResults,
            style: TextStyle(color: colors.textTertiary, fontSize: 13),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final p = _results[i];
        final sel = _selected.containsKey(p.userId);
        return InkWell(
          onTap: () => _toggle(p),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                BraweAvatar(
                  avatarUrl: p.avatarUrl,
                  displayName: p.name,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name.isEmpty ? s.shareUserFallback : p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (p.username.isNotEmpty)
                        Text(
                          '@${p.username}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sel ? colors.accentPrimary : Colors.transparent,
                    border: Border.all(
                      color: sel ? colors.accentPrimary : colors.border,
                      width: 1.5,
                    ),
                  ),
                  child: sel
                      ? Icon(
                          LucideIcons.check,
                          size: 14,
                          color: colors.textOnAccent,
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(List<Widget> items) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => items[i],
      ),
    );
  }

  List<Widget> _externalActions(BraweColors colors, S s) {
    final canRepost = _t.kind == ShareKind.post && _t.postId != null && !_isOwn;
    final isComment = _t.kind == ShareKind.comment;
    return [
      if (canRepost)
        _RoundAction(
          icon: LucideIcons.repeat2,
          label: _t.isReposted ? s.feedRepostUndo : s.shareActionRepost,
          background: colors.accentPrimary,
          foreground: colors.textOnAccent,
          onTap: _repost,
        ),
      if (!isComment)
        // Cor de marca de terceiros (exceção permitida).
        _RoundAction(
          icon: LucideIcons.messageCircle,
          label: s.cmtShareWhatsapp,
          background: const Color(0xFF25D366),
          foreground: Colors.white,
          onTap: _whatsapp,
        ),
      _RoundAction(
        icon: LucideIcons.link,
        label: s.shareActionCopyLink,
        background: colors.surfaceHighest,
        foreground: colors.textPrimary,
        onTap: _copyLink,
      ),
      if (!isComment)
        _RoundAction(
          glyph: 'X',
          label: 'X',
          background: const Color(0xFF000000),
          foreground: Colors.white,
          onTap: _x,
        ),
      _RoundAction(
        icon: LucideIcons.ellipsis,
        label: s.shareActionMore,
        background: colors.surfaceHighest,
        foreground: colors.textPrimary,
        onTap: _more,
      ),
    ];
  }

  List<Widget> _actionsSection(BraweColors colors, S s) {
    final canStory =
        _t.kind == ShareKind.post && (_t.storyMediaUrl?.isNotEmpty ?? false);
    final canReport = _t.kind == ShareKind.post && _t.postId != null && !_isOwn;
    final actions = <Widget>[
      if (canStory)
        _RoundAction(
          icon: LucideIcons.circlePlus,
          label: s.cmtShareAddStory,
          background: colors.surfaceHighest,
          foreground: colors.textPrimary,
          onTap: _addToStory,
        ),
      if (canReport)
        _RoundAction(
          icon: LucideIcons.flag,
          label: s.actionReport,
          background: colors.surfaceHighest,
          foreground: colors.textPrimary,
          onTap: _report,
        ),
    ];
    if (actions.isEmpty) return const [];
    return [
      Divider(height: 1, color: colors.divider),
      const SizedBox(height: 14),
      _row(actions),
    ];
  }

  Widget _sendBar(BraweColors colors, S s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _noteCtrl,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: s.cmtShareNoteHint,
                  hintStyle: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: colors.surfaceHighest,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: _sending ? null : _send,
              style: FilledButton.styleFrom(
                backgroundColor: colors.accentPrimary,
                foregroundColor: colors.textOnAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _sending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.textOnAccent,
                      ),
                    )
                  : Text(
                      s.cmtShareSendCount(_selected.length),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar 64 + ponto verde de online + selo de seleção + nome (até 2 linhas).
class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.person,
    required this.online,
    required this.selected,
    required this.fallbackName,
    required this.onTap,
  });

  final _Recipient person;
  final bool online;
  final bool selected;
  final String fallbackName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = person.name.trim().isEmpty ? fallbackName : person.name;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? colors.accentPrimary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: BraweAvatar(
                    avatarUrl: person.avatarUrl,
                    displayName: name,
                    size: 60,
                  ),
                ),
                if (online && !selected)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.success,
                        border: Border.all(
                          color: colors.surfaceElevated,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                if (selected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.accentPrimary,
                        border: Border.all(
                          color: colors.surfaceElevated,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.check,
                        size: 12,
                        color: colors.textOnAccent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? colors.textPrimary : colors.textSecondary,
                fontSize: 12,
                height: 1.15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ação redonda de 56 com rótulo.
class _RoundAction extends StatelessWidget {
  const _RoundAction({
    this.icon,
    this.glyph,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData? icon;

  /// Letra no lugar do ícone (marca sem ícone no Lucide).
  final String? glyph;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: background,
              ),
              alignment: Alignment.center,
              child: glyph != null
                  ? Text(
                      glyph!,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : Icon(icon, size: 24, color: foreground),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
