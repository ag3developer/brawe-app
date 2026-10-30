import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../data/services/post_service.dart';
import '../../../domain/models/conversation.dart';
import '../../../domain/models/follow_user.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import 'story_composer_screen.dart';

/// Folha "Compartilhar" de um post — minimalista, no padrão dos apps de
/// vídeo curto atuais (TikTok/Instagram):
///
/// 1. **Pessoas** (conversas recentes + quem você segue) numa linha de
///    avatares. **Um toque envia** — sem seleção + botão "Enviar". O avatar
///    mostra "Enviado" e não envia duas vezes.
/// 2. **Ações** em ícones redondos: Stories · Repostar · Copiar link · Mais.
///
/// Cores do tema do app (claro/escuro, via `context.colors`) e textos
/// traduzidos (`S`). A folha usa o tema do app mesmo quando aberta de uma
/// tela com tema escuro forçado (ex.: For You).
class ShareToChatSheet extends ConsumerStatefulWidget {
  const ShareToChatSheet({
    super.key,
    required this.postId,
    required this.postCaption,
    this.postImageUrl,
    this.authorName,
    this.storyMediaUrl,
    this.isReposted = false,
    this.onRepostChanged,
  });

  final String postId;
  final String postCaption;

  /// Mantidos por compatibilidade com quem chama (não exibidos).
  final String? postImageUrl;
  final String? authorName;

  /// Mídia (vídeo ou imagem) do post. Quando informada, aparece a ação
  /// "Stories" — reposta o post como story dentro do app.
  final String? storyMediaUrl;

  /// Estado atual do repost do usuário (o botão vira "Desfazer repost").
  final bool isReposted;
  final ValueChanged<bool>? onRepostChanged;

  static Future<void> show(
    BuildContext context, {
    required String postId,
    required String postCaption,
    String? postImageUrl,
    String? authorName,
    String? storyMediaUrl,
    bool isReposted = false,
    ValueChanged<bool>? onRepostChanged,
  }) {
    // Contexto do navigator raiz: a folha herda o tema do APP (claro ou
    // escuro), não o tema escuro forçado do feed de onde foi aberta.
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    return showModalBottomSheet<void>(
      context: rootContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareToChatSheet(
        postId: postId,
        postCaption: postCaption,
        postImageUrl: postImageUrl,
        authorName: authorName,
        storyMediaUrl: storyMediaUrl,
        isReposted: isReposted,
        onRepostChanged: onRepostChanged,
      ),
    );
  }

  @override
  ConsumerState<ShareToChatSheet> createState() => _ShareToChatSheetState();
}

enum _SendState { sending, sent, failed }

class _Recipient {
  const _Recipient({
    required this.userId,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.conversationId,
  });

  final String userId;
  final String name;
  final String username;
  final String? avatarUrl;
  final String? conversationId;
}

class _ShareToChatSheetState extends ConsumerState<ShareToChatSheet> {
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = true;
  bool _loadFailed = false;
  List<_Recipient> _people = const [];
  final Map<String, _SendState> _sendState = {};
  bool _tracked = false;
  String _query = '';

  String get _postUrl => 'https://brawe.app/connect/p/${widget.postId}';

  bool get _canStory =>
      widget.storyMediaUrl != null && widget.storyMediaUrl!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.trim().toLowerCase();
      if (q != _query) setState(() => _query = q);
    });
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    final chatRepo = ref.read(chatRepositoryProvider);
    final socialRepo = ref.read(socialRepositoryProvider);
    final me = ref.read(authStateProvider).asData?.value;

    // Em paralelo e independentes: se uma falhar, a outra ainda aparece.
    final recentFuture = chatRepo
        .listConversations(page: 1, limit: 20)
        .then<List<Conversation>>((v) => v)
        .catchError((Object e) {
          debugPrint('[ShareToChatSheet] listConversations failed: $e');
          return <Conversation>[];
        });
    final followingFuture = me == null
        ? Future.value(<FollowUser>[])
        : socialRepo
              .getUserFollowing(me.id, page: 1, limit: 50)
              .then<List<FollowUser>>((r) => r.items)
              .catchError((Object e) {
                debugPrint('[ShareToChatSheet] getUserFollowing failed: $e');
                return <FollowUser>[];
              });

    final recent = await recentFuture;
    final following = await followingFuture;
    if (!mounted) return;

    // Recentes primeiro, depois quem você segue (sem repetir pessoas).
    final seen = <String>{};
    final people = <_Recipient>[
      for (final c in recent)
        if (c.participantId.isNotEmpty && seen.add(c.participantId))
          _Recipient(
            userId: c.participantId,
            name: c.participantName,
            username: c.participantUsername ?? '',
            avatarUrl: c.participantAvatarUrl,
            conversationId: c.id,
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

    setState(() {
      _people = people;
      _loading = false;
      _loadFailed = people.isEmpty && me != null;
    });
  }

  List<_Recipient> get _visiblePeople {
    if (_query.isEmpty) return _people;
    return _people
        .where(
          (p) =>
              p.name.toLowerCase().contains(_query) ||
              p.username.toLowerCase().contains(_query),
        )
        .toList(growable: false);
  }

  void _trackShareOnce() {
    if (_tracked) return;
    _tracked = true;
    unawaited(ref.read(postServiceProvider).trackShare(widget.postId));
  }

  /// Um toque = envia o post para a pessoa (DM com o link → o chat mostra
  /// o card de prévia). Tocar de novo só reenvia se o envio falhou.
  Future<void> _sendTo(_Recipient person) async {
    final state = _sendState[person.userId];
    if (state == _SendState.sending || state == _SendState.sent) return;
    HapticFeedback.selectionClick();
    setState(() => _sendState[person.userId] = _SendState.sending);
    final chatRepo = ref.read(chatRepositoryProvider);
    try {
      var conversationId = person.conversationId;
      if (conversationId == null) {
        final slug = person.username.isNotEmpty
            ? person.username
            : person.userId;
        conversationId = (await chatRepo.getOrCreateConversationByUser(
          slug,
        )).conversationId;
      }
      await chatRepo.sendMessage(
        conversationId: conversationId,
        message: _postUrl,
      );
      _trackShareOnce();
      if (mounted) setState(() => _sendState[person.userId] = _SendState.sent);
    } catch (e) {
      debugPrint('[ShareToChatSheet] send failed: $e');
      if (mounted) {
        setState(() => _sendState[person.userId] = _SendState.failed);
      }
    }
  }

  // ── Ações ──────────────────────────────────────────────────────────────

  void _shareToStory() {
    final navigator = Navigator.of(context, rootNavigator: true);
    Navigator.of(context).pop();
    _trackShareOnce();
    navigator.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ForceDarkTheme(
          child: StoryComposerScreen(
            initialRemoteUrl: widget.storyMediaUrl,
            initialOriginPostId: widget.postId,
          ),
        ),
      ),
    );
  }

  /// Repostar ou, se já repostado, desfazer o repost.
  Future<void> _repost() async {
    final messenger = ScaffoldMessenger.of(context);
    final s = S.of(context);
    final was = widget.isReposted;
    Navigator.of(context).pop();
    try {
      await ref.read(postRepositoryProvider).toggleRepost(widget.postId, was);
      if (!was) _trackShareOnce();
      widget.onRepostChanged?.call(!was);
      messenger.showSnackBar(
        SnackBar(content: Text(was ? s.feedRepostUndone : s.feedReposted)),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.feedCannotShare)));
    }
  }

  Future<void> _copyLink() async {
    final messenger = ScaffoldMessenger.of(context);
    final s = S.of(context);
    await Clipboard.setData(ClipboardData(text: _postUrl));
    _trackShareOnce();
    if (!mounted) return;
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(s.feedLinkCopied)));
  }

  Future<void> _shareMore() async {
    final text = widget.postCaption.isNotEmpty
        ? '${widget.postCaption}\n\n$_postUrl'
        : _postUrl;
    try {
      await SharePlus.instance.share(ShareParams(text: text));
      _trackShareOnce();
    } catch (_) {
      /* usuário cancelou / indisponível */
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
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
              _searchField(colors, s),
              const SizedBox(height: 12),
              SizedBox(height: 96, child: _peopleRow(colors, s)),
              Divider(height: 1, color: colors.divider),
              const SizedBox(height: 14),
              _actionsRow(colors, s),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BraweColors colors, S s) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            s.shareSheetTitle,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Positioned(
            right: 4,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close_rounded, color: colors.textSecondary),
              iconSize: 22,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField(BraweColors colors, S s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 38,
        child: TextField(
          controller: _searchCtrl,
          style: TextStyle(color: colors.textPrimary, fontSize: 14),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: s.shareSearchHint,
            hintStyle: TextStyle(color: colors.textTertiary, fontSize: 14),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colors.textTertiary,
              size: 20,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            filled: true,
            fillColor: colors.surfaceHighest,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _peopleRow(BraweColors colors, S s) {
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
    if (_loadFailed) {
      return Center(
        child: TextButton(
          onPressed: _load,
          child: Text(
            '${s.shareLoadError} ${s.shareTryAgain}',
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }
    final people = _visiblePeople;
    if (people.isEmpty) {
      return Center(
        child: Text(
          s.shareNoContacts,
          style: TextStyle(color: colors.textTertiary, fontSize: 13),
        ),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: people.length,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (_, i) {
        final p = people[i];
        return _PersonTile(
          person: p,
          state: _sendState[p.userId],
          sentLabel: s.shareSentBadge,
          retryLabel: s.shareRetry,
          fallbackName: s.shareUserFallback,
          onTap: () => _sendTo(p),
        );
      },
    );
  }

  Widget _actionsRow(BraweColors colors, S s) {
    final actions = <Widget>[
      if (_canStory)
        _ActionButton(
          icon: LucideIcons.aperture,
          label: s.shareActionStories,
          gradient: LinearGradient(
            colors: [colors.accentPink, colors.accentPrimary],
          ),
          onTap: _shareToStory,
        ),
      _ActionButton(
        icon: LucideIcons.repeat2,
        label: widget.isReposted ? s.feedRepostUndo : s.shareActionRepost,
        onTap: _repost,
      ),
      _ActionButton(
        icon: LucideIcons.link,
        label: s.shareActionCopyLink,
        onTap: _copyLink,
      ),
      _ActionButton(
        icon: LucideIcons.ellipsis,
        label: s.shareActionMore,
        onTap: _shareMore,
      ),
    ];
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (_, i) => actions[i],
      ),
    );
  }
}

/// Avatar + nome. Um toque envia; mostra enviando / "Enviado" / falha.
class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.person,
    required this.state,
    required this.sentLabel,
    required this.retryLabel,
    required this.fallbackName,
    required this.onTap,
  });

  final _Recipient person;
  final _SendState? state;
  final String sentLabel;
  final String retryLabel;
  final String fallbackName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final avatar = person.avatarUrl;
    final hasAvatar = avatar != null && avatar.isNotEmpty;
    final name = person.name.trim().isEmpty ? fallbackName : person.name;
    final sent = state == _SendState.sent;
    final failed = state == _SendState.failed;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 62,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: sent ? 0.55 : 1,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: colors.surfaceHighest,
                    backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
                    child: hasAvatar
                        ? null
                        : Text(
                            name.characters.first.toUpperCase(),
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                if (state == _SendState.sending)
                  Positioned.fill(
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.accentPrimary,
                        ),
                      ),
                    ),
                  ),
                if (sent || failed)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: failed ? colors.danger : colors.accentPrimary,
                        border: Border.all(
                          color: colors.surfaceElevated,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        failed ? Icons.refresh_rounded : Icons.check_rounded,
                        size: 12,
                        color: colors.textOnAccent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              sent ? sentLabel : (failed ? retryLabel : name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: sent
                    ? colors.accentPrimary
                    : (failed ? colors.danger : colors.textSecondary),
                fontSize: 11.5,
                fontWeight: sent ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ação redonda (ícone + rótulo), no padrão dos apps de vídeo curto.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.gradient,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gradient == null ? colors.surfaceHighest : null,
                gradient: gradient,
              ),
              child: Icon(
                icon,
                size: 20,
                color: gradient == null
                    ? colors.textPrimary
                    : colors.textOnAccent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}
