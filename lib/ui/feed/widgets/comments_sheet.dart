import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/comment_service.dart';
import '../../../domain/models/gif_item.dart';
import '../../../domain/models/post_comment.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/widgets/gif/gif_bubble.dart';
import '../../shared/widgets/gif/gif_picker_sheet.dart';
import '../../../core/text/brawe_rich_text.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/widgets/brawe_avatar.dart';
import '../../core/widgets/report_sheet.dart';
import '../view_models/comments_view_model.dart';
import '../../../data/services/privacy_ux_service.dart';
import 'share_sheet.dart';
import 'story_ring_avatar.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';

/// Folha modal de comentários (posts de imagem / cards do feed, onde não há
/// vídeo para manter visível). Para vídeos em tela cheia use
/// `MediaCommentsLayout`, que embute o mesmo [CommentsPanel] sem cobrir a mídia.
class CommentsSheet extends StatelessWidget {
  const CommentsSheet({
    super.key,
    required this.postId,
    this.highlightCommentId,
  });
  final String postId;

  /// Comentário a destacar quando a folha é aberta via deep link de
  /// notificação (comentário / resposta / menção). Opcional.
  final String? highlightCommentId;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    // Android 15 (edge-to-edge): a folha sobe junto com o teclado (Padding
    // externo encolhe a área do DraggableScrollableSheet, sem overflow
    // mesmo no tamanho mínimo) e, com o teclado fechado, o campo fica acima
    // da barra de navegação (gestos / 3 botões) via viewPadding.bottom.
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => CommentsPanel(
          postId: postId,
          highlightCommentId: highlightCommentId,
          scrollController: scrollController,
          bottomSafe: keyboard > 0 ? 0 : media.viewPadding.bottom,
        ),
      ),
    );
  }
}

/// Conteúdo dos comentários (cabeçalho, lista, respostas, @menções, GIF e
/// campo de envio). Usado dentro da folha modal ([CommentsSheet]) e embutido
/// ao lado da mídia (`MediaCommentsLayout`).
class CommentsPanel extends ConsumerStatefulWidget {
  const CommentsPanel({
    super.key,
    required this.postId,
    this.highlightCommentId,
    this.scrollController,
    this.bottomSafe = 0,
    this.onClose,
    this.onDragUpdate,
    this.onDragEnd,
  });
  final String postId;
  final String? highlightCommentId;

  /// Controller da lista (vem do DraggableScrollableSheet no modal).
  final ScrollController? scrollController;

  /// Espaço reservado sob o campo (área segura do aparelho) — 0 com teclado.
  final double bottomSafe;

  /// Quando informado (modo embutido), o X do cabeçalho chama este callback;
  /// sem ele (folha modal) o X fecha a folha.
  final VoidCallback? onClose;

  /// Arrasto vertical do cabeçalho (modo embutido): delta em px / velocidade.
  final ValueChanged<double>? onDragUpdate;
  final ValueChanged<double>? onDragEnd;

  @override
  ConsumerState<CommentsPanel> createState() => _CommentsPanelState();
}

class _CommentsPanelState extends ConsumerState<CommentsPanel> {
  static const _quickEmojis = [
    '😂',
    '😍',
    '🔥',
    '👏',
    '🙌',
    '😮',
    '😢',
    '😡',
    '👍',
    '💯',
    '🎉',
    '❤️',
  ];

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  /// Comentário/resposta a que estou respondendo (mostrado na faixa) e o
  /// comentário principal onde a resposta será anexada.
  PostComment? _replyingTo;
  String? _replyParentId;

  /// Comentários principais com as respostas à mostra.
  final Set<String> _expanded = {};

  /// GIF escolhido no seletor, ainda não enviado (vai junto com o texto, se houver).
  GifAttachment? _pendingGif;

  bool _emojiOpen = false;
  bool _hasText = false;

  String? _notice;
  Timer? _noticeTimer;

  /// Controller da lista (vem do DraggableScrollableSheet). Guardado para
  /// rolar até o topo depois de enviar — o comentário novo entra no topo.
  ScrollController? _listController;
  ScrollController? _ownScroll;

  // ── Marcar alguém (@) ──
  // Ao digitar "@nome" aparecem sugestões (quem eu sigo primeiro); tocar
  // troca o trecho por "@username " — quem foi marcado recebe um aviso.
  static final _mentionAtCursor = RegExp(r'@([A-Za-z0-9_.]{1,30})$');
  List<Map<String, dynamic>> _mentions = const [];
  Timer? _mentionDebounce;
  String? _mentionQuery;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
    final sel = _controller.selection;
    final upTo = sel.isValid && sel.baseOffset >= 0
        ? _controller.text.substring(0, sel.baseOffset)
        : _controller.text;
    final m = _mentionAtCursor.firstMatch(upTo);
    final q = m?.group(1);
    if (q == _mentionQuery) return;
    _mentionQuery = q;
    _mentionDebounce?.cancel();
    if (q == null) {
      if (_mentions.isNotEmpty) setState(() => _mentions = const []);
      return;
    }
    _mentionDebounce = Timer(const Duration(milliseconds: 220), () async {
      try {
        final res = await ref.read(commentServiceProvider).searchMentions(q);
        if (mounted && _mentionQuery == q) setState(() => _mentions = res);
      } catch (_) {}
    });
  }

  void _pickMention(String username) {
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset < 0
        ? text.length
        : _controller.selection.baseOffset;
    final before = text.substring(0, cursor);
    final start = before.lastIndexOf('@');
    if (start < 0) return;
    final insert = '@$username ';
    final next = text.replaceRange(start, cursor, insert);
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + insert.length),
    );
    setState(() => _mentions = const []);
  }

  /// Insere [value] na posição do cursor.
  void _insertAtCursor(String value) {
    final text = _controller.text;
    final sel = _controller.selection;
    final start = sel.isValid && sel.start >= 0 ? sel.start : text.length;
    final end = sel.isValid && sel.end >= 0 ? sel.end : text.length;
    _controller.value = TextEditingValue(
      text: text.replaceRange(start, end, value),
      selection: TextSelection.collapsed(offset: start + value.length),
    );
  }

  @override
  void dispose() {
    _mentionDebounce?.cancel();
    _noticeTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _ownScroll?.dispose();
    super.dispose();
  }

  /// Aviso dentro do próprio painel (não numa tela escondida atrás).
  void _flash(String text) {
    if (!mounted) return;
    _noticeTimer?.cancel();
    setState(() => _notice = text);
    _noticeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _notice = null);
    });
  }

  /// Mensagem do 403 de privacidade ao comentar (substitui o campo).
  String? _serverBlock;

  CommentsViewModel get _vm =>
      ref.read(commentsViewModelProvider(widget.postId).notifier);

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    final gif = _pendingGif;
    if (text.isEmpty && gif == null) return;
    final parentId = _replyParentId;
    _controller.clear();
    setState(() {
      _pendingGif = null;
      _emojiOpen = false;
    });
    try {
      await _vm.addComment(text, parentId: parentId, gif: gif);
      if (parentId != null && mounted) setState(() => _expanded.add(parentId));
    } on CommentBlockedException catch (e) {
      // 403 de privacidade: a mensagem do servidor vira o aviso do painel
      // (o campo é trocado por ela) e o rascunho volta ao campo.
      if (mounted) {
        ref.invalidate(postCommentRulesProvider(widget.postId));
        _controller.text = text;
        setState(() {
          _serverBlock = (e.message != null && e.message!.isNotEmpty)
              ? e.message
              : (e.code == 'comments_disabled'
                    ? S.of(context).privUxCommentsDisabledLine
                    : S.of(context).privUxCommentsRestrictedLine);
        });
      }
    } catch (_) {
      if (mounted) _flash(S.of(context).commentsErrorSend);
    }
    if (mounted) {
      setState(() {
        _replyingTo = null;
        _replyParentId = null;
      });
    }
    final list = _listController;
    if (mounted &&
        parentId == null &&
        list != null &&
        list.hasClients &&
        list.offset > 0) {
      list.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickGif() async {
    final gif = await showGifPicker(context);
    if (gif != null && mounted) {
      setState(() => _pendingGif = gif);
      _focusNode.requestFocus();
    }
  }

  void _startReply(PostComment target, PostComment parent) {
    setState(() {
      _replyingTo = target;
      _replyParentId = parent.id;
    });
    if (target.id != parent.id && target.authorUsername.isNotEmpty) {
      final tag = '@${target.authorUsername} ';
      _controller.value = TextEditingValue(
        text: tag,
        selection: TextSelection.collapsed(offset: tag.length),
      );
    }
    _focusNode.requestFocus();
  }

  void _cancelReply() => setState(() {
    _replyingTo = null;
    _replyParentId = null;
  });

  void _shareComment(PostComment c) {
    final s = S.of(context);
    final url = AppConstants.postUrl(widget.postId);
    final text = s.cmtShareCommentText(c.authorUsername, c.content, url);
    ShareSheet.show(
      context,
      ShareTarget(
        kind: ShareKind.comment,
        url: url,
        shareText: text,
        chatText: text,
      ),
    );
  }

  Future<void> _commentMenu(PostComment c, {required bool own}) async {
    final s = S.of(context);
    HapticFeedback.selectionClick();
    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.colors.surfaceElevated,
      constraints: const BoxConstraints(maxWidth: 640),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final colors = ctx.colors;
        Widget tile(String id, IconData icon, String label, {Color? color}) =>
            ListTile(
              leading: Icon(icon, size: 22, color: color ?? colors.textPrimary),
              title: Text(
                label,
                style: TextStyle(
                  color: color ?? colors.textPrimary,
                  fontSize: 15,
                ),
              ),
              onTap: () => Navigator.pop(ctx, id),
            );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (c.content.isNotEmpty)
                tile('copy', LucideIcons.copy, s.cmtCopyText),
              if (own)
                tile(
                  'delete',
                  LucideIcons.trash2,
                  s.cmtDelete,
                  color: colors.danger,
                )
              else
                tile(
                  'report',
                  LucideIcons.flag,
                  s.actionReport,
                  color: colors.danger,
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: c.content));
        _flash(s.cmtCopied);
      case 'delete':
        final ok = await _vm.deleteComment(c);
        if (!ok) _flash(s.cmtDeleteFail);
      case 'report':
        await showReportSheet(context, targetType: 'comment', targetId: c.id);
    }
  }

  int _total(List<PostComment> list) =>
      list.fold<int>(0, (n, c) => n + 1 + c.replies.length);

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsViewModelProvider(widget.postId));
    final s = S.of(context);
    final colors = context.colors;
    final scrollController =
        widget.scrollController ?? (_ownScroll ??= ScrollController());
    _listController = scrollController;
    final me = ref.watch(authStateProvider).asData?.value;
    final sort = _vm.sort;
    final rules = ref.watch(postCommentRulesProvider(widget.postId)).value;
    final String? lockedText =
        _serverBlock ??
        (rules?.disabled == true
            ? s.privUxCommentsDisabledLine
            : rules?.canComment == false
            ? s.privUxCommentsRestrictedLine
            : null);

    final header = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 2),
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: Row(
            children: [
              PopupMenuButton<String>(
                tooltip: s.cmtSortTooltip,
                color: colors.surfaceElevated,
                icon: Icon(
                  LucideIcons.listFilter,
                  size: 20,
                  color: colors.textSecondary,
                ),
                onSelected: (v) {
                  _vm.setSort(v);
                },
                itemBuilder: (_) => [
                  for (final (id, label) in [
                    ('top', s.cmtSortTop),
                    ('recent', s.cmtSortRecent),
                  ])
                    PopupMenuItem<String>(
                      value: id,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            child: sort == id
                                ? Icon(
                                    LucideIcons.check,
                                    size: 16,
                                    color: colors.accentPrimary,
                                  )
                                : null,
                          ),
                          Text(
                            label,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Text(
                  commentsState.maybeWhen(
                    data: (list) => s.cmtTitle(_total(list)),
                    orElse: () => s.commentsTitle,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: s.actionClose,
                onPressed:
                    widget.onClose ?? () => Navigator.of(context).maybePop(),
                icon: Icon(
                  LucideIcons.x,
                  size: 22,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Cabeçalho (no modo embutido também é a alça de arrasto)
          if (widget.onDragUpdate != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (d) => widget.onDragUpdate!(d.delta.dy),
              onVerticalDragEnd: (d) =>
                  widget.onDragEnd?.call(d.primaryVelocity ?? 0),
              child: header,
            )
          else
            header,
          Divider(color: colors.divider, height: 1),

          Expanded(
            child: commentsState.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: colors.accentPrimary),
              ),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.commentsErrorLoad,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(
                        commentsViewModelProvider(widget.postId),
                      ),
                      child: Text(s.shareTryAgain),
                    ),
                  ],
                ),
              ),
              data: (comments) => comments.isEmpty
                  ? _EmptyState(title: s.cmtEmptyTitle, body: s.cmtEmptyBody)
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(top: 6, bottom: 8),
                      itemCount: comments.length,
                      itemBuilder: (_, i) {
                        final c = comments[i];
                        final hl = widget.highlightCommentId;
                        final expanded =
                            _expanded.contains(c.id) ||
                            (hl != null && c.replies.any((r) => r.id == hl));
                        return _CommentThread(
                          comment: c,
                          meId: me?.id,
                          highlightId: hl,
                          expanded: expanded,
                          onToggleReplies: () => setState(() {
                            if (!_expanded.remove(c.id)) _expanded.add(c.id);
                          }),
                          onReply: (target) => _startReply(target, c),
                          onLike: (x) => _vm.toggleLike(x),
                          onShare: _shareComment,
                          onMenu: (x) =>
                              _commentMenu(x, own: x.authorId == me?.id),
                          onOpenProfile: (id) => _openProfile(context, id),
                        );
                      },
                    ),
            ),
          ),

          // Aviso (erro / copiado) no próprio painel
          if (_notice != null)
            Container(
              width: double.infinity,
              color: colors.surfaceElevated,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _notice!,
                style: TextStyle(color: colors.textPrimary, fontSize: 13),
              ),
            ),

          // Faixa "Respondendo a @nome ✕"
          if (_replyingTo != null && lockedText == null)
            Container(
              color: colors.surfaceElevated,
              padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.commentsReplyingTo(_replyingTo!.authorUsername),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: s.actionCancel,
                    visualDensity: VisualDensity.compact,
                    onPressed: _cancelReply,
                    icon: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Sugestões de @ (acima do campo)
          if (_mentions.isNotEmpty) _mentionList(colors, s),

          // GIF escolhido (pré-visualização)
          if (_pendingGif != null)
            Container(
              color: colors.surfaceElevated,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  GifBubble(gif: _pendingGif!, maxWidth: 110, borderRadius: 10),
                  const Spacer(),
                  IconButton(
                    tooltip: s.gifClearSearch,
                    onPressed: () => setState(() => _pendingGif = null),
                    icon: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Emojis rápidos
          if (_emojiOpen)
            Container(
              height: 46,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _quickEmojis.length,
                itemBuilder: (_, i) => InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _insertAtCursor(_quickEmojis[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Text(
                        _quickEmojis[i],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Comentários desativados / não permitidos: no lugar do campo.
          if (lockedText != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, 14, 16, widget.bottomSafe + 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: Text(
                lockedText,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textTertiary, fontSize: 14),
              ),
            )
          else
            // Campo de envio
            Container(
              padding: EdgeInsets.fromLTRB(12, 8, 12, widget.bottomSafe + 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: BraweAvatar(
                      avatarUrl: me?.avatarUrl,
                      displayName: me?.name ?? '',
                      size: 32,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceHighest,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.only(left: 14, right: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              textCapitalization: TextCapitalization.sentences,
                              controller: _controller,
                              focusNode: _focusNode,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: s.cmtAddHint,
                                hintStyle: TextStyle(
                                  color: colors.textTertiary,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                              ),
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.newline,
                              onTap: () {
                                if (_emojiOpen) {
                                  setState(() => _emojiOpen = false);
                                }
                              },
                            ),
                          ),
                          _FieldIcon(
                            tooltip: s.gifButtonSemantics,
                            icon: LucideIcons.imagePlay,
                            onTap: _pickGif,
                          ),
                          _FieldIcon(
                            tooltip: s.cmtEmojiTooltip,
                            icon: LucideIcons.smile,
                            active: _emojiOpen,
                            onTap: () =>
                                setState(() => _emojiOpen = !_emojiOpen),
                          ),
                          _FieldIcon(
                            tooltip: s.cmtMentionTooltip,
                            icon: LucideIcons.atSign,
                            onTap: () {
                              _insertAtCursor('@');
                              _focusNode.requestFocus();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.centerRight,
                    child: (_hasText || _pendingGif != null)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Tooltip(
                              message: s.cmtSendTooltip,
                              child: GestureDetector(
                                onTap: _sendComment,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colors.accentPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    LucideIcons.arrowUp,
                                    color: colors.textOnAccent,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _mentionList(BraweColors colors, S s) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          for (final u in _mentions)
            InkWell(
              onTap: () => _pickMention(u['username']?.toString() ?? ''),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    BraweAvatar(
                      avatarUrl: u['avatar_url']?.toString(),
                      displayName:
                          u['display_name']?.toString() ??
                          u['username']?.toString() ??
                          '',
                      size: 32,
                      fontSize: 13,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u['display_name']?.toString() ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '@${u['username'] ?? ''}',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (u['follows'] == true)
                      Text(
                        s.commentsMentionFollowing,
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 11.5,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FieldIcon extends StatelessWidget {
  const _FieldIcon({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.active = false,
  });
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
      padding: EdgeInsets.zero,
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 21,
        color: active ? colors.accentPrimary : colors.textSecondary,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.surfaceHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.messageCircle,
                size: 28,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Abre o perfil. Se os comentários estão sobre uma rota "solta" (folha
/// modal ou visor em tela cheia empilhado no navegador raiz), fecha essas
/// rotas antes — senão o perfil abriria por baixo delas.
void _openProfile(BuildContext context, String userId) {
  final route = ModalRoute.of(context);
  if (route != null && route.settings is! Page<dynamic>) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).popUntil((r) => r.settings is Page<dynamic> || r.isFirst);
  }
  context.push('/profile/$userId');
}

/// Comentário principal + respostas recolhíveis ("Exibir N respostas").
class _CommentThread extends StatelessWidget {
  const _CommentThread({
    required this.comment,
    required this.meId,
    required this.highlightId,
    required this.expanded,
    required this.onToggleReplies,
    required this.onReply,
    required this.onLike,
    required this.onShare,
    required this.onMenu,
    required this.onOpenProfile,
  });
  final PostComment comment;
  final String? meId;
  final String? highlightId;
  final bool expanded;
  final VoidCallback onToggleReplies;
  final void Function(PostComment) onReply;
  final void Function(PostComment) onLike;
  final void Function(PostComment) onShare;
  final void Function(PostComment) onMenu;
  final void Function(String userId) onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final n = comment.replies.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentRow(
          comment: comment,
          avatarSize: 36,
          highlighted: highlightId != null && comment.id == highlightId,
          onReply: onReply,
          onLike: onLike,
          onShare: onShare,
          onMenu: onMenu,
          onOpenProfile: onOpenProfile,
        ),
        if (n > 0 && expanded)
          for (final r in comment.replies)
            _CommentRow(
              comment: r,
              avatarSize: 26,
              indent: 48,
              highlighted: highlightId != null && r.id == highlightId,
              onReply: onReply,
              onLike: onLike,
              onShare: onShare,
              onMenu: onMenu,
              onOpenProfile: onOpenProfile,
            ),
        if (n > 0)
          Padding(
            padding: const EdgeInsets.only(left: 64, bottom: 6),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggleReplies,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 24, height: 1, color: colors.border),
                    const SizedBox(width: 8),
                    Text(
                      expanded ? s.cmtHideReplies : s.cmtViewReplies(n),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      expanded
                          ? LucideIcons.chevronUp
                          : LucideIcons.chevronDown,
                      size: 15,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({
    required this.comment,
    required this.avatarSize,
    required this.onReply,
    required this.onLike,
    required this.onShare,
    required this.onMenu,
    required this.onOpenProfile,
    this.indent = 0,
    this.highlighted = false,
  });
  final PostComment comment;
  final double avatarSize;
  final double indent;

  /// Realça o comentário aberto via deep link de notificação.
  final bool highlighted;
  final void Function(PostComment) onReply;
  final void Function(PostComment) onLike;
  final void Function(PostComment) onShare;
  final void Function(PostComment) onMenu;
  final void Function(String userId) onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final liked = comment.userLiked;
    final metaStyle = TextStyle(color: colors.textSecondary, fontSize: 13);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => onMenu(comment),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: highlighted
            ? colors.accentPrimary.withValues(alpha: 0.10)
            : Colors.transparent,
        padding: EdgeInsets.fromLTRB(16 + indent, 8, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatarSize >= 36
                ? StoryRingAvatar(
                    userId: comment.authorId,
                    avatarUrl: comment.authorAvatarUrl,
                    fallbackText: comment.authorName,
                    radius: avatarSize / 2,
                    onTapWithoutStories: () => onOpenProfile(comment.authorId),
                  )
                : GestureDetector(
                    onTap: () => onOpenProfile(comment.authorId),
                    child: BraweAvatar(
                      avatarUrl: comment.authorAvatarUrl,
                      displayName: comment.authorName,
                      size: avatarSize,
                      fontSize: 11,
                    ),
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
                          comment.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (comment.authorIsVerified)
                        const VerifiedBadge(size: 13, gap: 3),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (comment.content.isNotEmpty)
                    BraweRichText(
                      comment.content,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  if (comment.gif != null)
                    Padding(
                      padding: EdgeInsets.only(
                        top: comment.content.isEmpty ? 0 : 6,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GifBubble(
                          gif: comment.gif!,
                          maxWidth: avatarSize >= 36 ? 220 : 180,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(comment.timeAgo, style: metaStyle),
                      Text('  ·  ', style: metaStyle),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onReply(comment),
                        child: Text(
                          s.commentsReplyAction,
                          style: metaStyle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: s.cmtShareComment,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onShare(comment),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 2, 10, 6),
                  child: Icon(
                    LucideIcons.send,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onLike(comment),
              child: SizedBox(
                width: 34,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      // Lucide só tem coração de contorno; o preenchido vem do Material.
                      child: Icon(
                        liked ? Icons.favorite : LucideIcons.heart,
                        size: 19,
                        color: liked ? colors.danger : colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${comment.likesCount}',
                      style: TextStyle(
                        color: liked ? colors.danger : colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
