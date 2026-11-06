import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/services/comment_service.dart';
import '../../../domain/models/gif_item.dart';
import '../../../domain/models/post_comment.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/widgets/gif/gif_bubble.dart';
import '../../shared/widgets/gif/gif_picker_sheet.dart';
import '../../../core/text/brawe_rich_text.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/widgets/brawe_avatar.dart';
import '../view_models/comments_view_model.dart';
import 'story_ring_avatar.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';

class CommentsSheet extends ConsumerStatefulWidget {
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
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  PostComment? _replyingTo;

  /// GIF escolhido no seletor, ainda não enviado (vai junto com o texto, se houver).
  GifAttachment? _pendingGif;

  /// Controller da lista (vem do DraggableScrollableSheet). Guardado para
  /// rolar até o topo depois de enviar — o comentário novo entra no topo.
  ScrollController? _listController;

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
    final cursor = _controller.selection.baseOffset < 0 ? text.length : _controller.selection.baseOffset;
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

  @override
  void dispose() {
    _mentionDebounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    final gif = _pendingGif;
    if (text.isEmpty && gif == null) return;
    _controller.clear();
    setState(() => _pendingGif = null);
    try {
      await ref
          .read(commentsViewModelProvider(widget.postId).notifier)
          .addComment(text, parentId: _replyingTo?.id, gif: gif);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).commentsErrorSend),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) setState(() => _replyingTo = null);
    final list = _listController;
    if (mounted && list != null && list.hasClients && list.offset > 0) {
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

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsViewModelProvider(widget.postId));
    final s = S.of(context);
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
        builder: (_, scrollController) {
          _listController = scrollController;
          return Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: context.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Text(
                        s.commentsTitle,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      commentsState.when(
                        data: (comments) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.braweBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${comments.length}',
                            style: const TextStyle(
                              color: AppColors.braweBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                Divider(color: context.colors.divider, height: 1),

                // Comments list
                Expanded(
                  child: commentsState.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.braweBlue,
                      ),
                    ),
                    error: (_, _) => Center(
                      child: Text(
                        s.commentsErrorLoad,
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                    ),
                    data: (comments) => comments.isEmpty
                        ? Center(
                            child: Text(
                              s.commentsEmpty,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.only(top: 8),
                            itemCount: comments.length,
                            itemBuilder: (_, i) => _CommentTile(
                              comment: comments[i],
                              highlighted:
                                  widget.highlightCommentId != null &&
                                  comments[i].id == widget.highlightCommentId,
                              onReply: (c) {
                                setState(() => _replyingTo = c);
                                _focusNode.requestFocus();
                              },
                              onLike: (c) => ref
                                  .read(
                                    commentsViewModelProvider(
                                      widget.postId,
                                    ).notifier,
                                  )
                                  .toggleLike(c),
                            ),
                          ),
                  ),
                ),

                // Reply banner
                if (_replyingTo != null)
                  Container(
                    color: context.colors.surfaceElevated,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.reply,
                          color: AppColors.braweBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.commentsReplyingTo(_replyingTo!.authorUsername),
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _replyingTo = null),
                          child: Icon(
                            Icons.close,
                            color: context.colors.textSecondary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Sugestões de @ (acima do campo)
                if (_mentions.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceElevated,
                      border: Border(top: BorderSide(color: context.colors.divider)),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      children: [
                        for (final u in _mentions)
                          InkWell(
                            onTap: () => _pickMention(u['username']?.toString() ?? ''),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: context.colors.surfaceHighest,
                                    backgroundImage: (u['avatar_url']?.toString().isNotEmpty ?? false)
                                        ? NetworkImage(u['avatar_url'].toString())
                                        : null,
                                    child: (u['avatar_url']?.toString().isNotEmpty ?? false)
                                        ? null
                                        : Icon(Icons.person, size: 16, color: context.colors.textSecondary),
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
                                            color: context.colors.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '@${u['username'] ?? ''}',
                                          style: TextStyle(color: context.colors.textSecondary, fontSize: 12.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (u['follows'] == true)
                                    Text(
                                      s.commentsMentionFollowing,
                                      style: TextStyle(color: context.colors.textTertiary, fontSize: 11.5),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // GIF escolhido (pré-visualização)
                if (_pendingGif != null)
                  Container(
                    color: context.colors.surfaceElevated,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        GifBubble(gif: _pendingGif!, maxWidth: 110, borderRadius: 10),
                        const Spacer(),
                        IconButton(
                          tooltip: s.gifClearSearch,
                          onPressed: () => setState(() => _pendingGif = null),
                          icon: Icon(LucideIcons.x, size: 18, color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                  ),

                // Input
                Container(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    8,
                    12,
                    (keyboard > 0 ? 0 : media.viewPadding.bottom) + 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: context.colors.divider),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: context.colors.surfaceElevated,
                        child: Icon(
                          Icons.person,
                          color: context.colors.textSecondary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: TextStyle(color: context.colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: _replyingTo != null
                                ? s.commentsHintReply
                                : s.commentsHintAddMention,
                            hintStyle: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: context.colors.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendComment(),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: s.gifButtonSemantics,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        padding: EdgeInsets.zero,
                        onPressed: _pickGif,
                        icon: Icon(LucideIcons.imagePlay, size: 22, color: context.colors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _sendComment,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.braweBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.send,
                            color: context.colors.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.onReply,
    required this.onLike,
    this.highlighted = false,
  });
  final PostComment comment;
  final void Function(PostComment) onReply;
  final void Function(PostComment) onLike;

  /// Realça o comentário aberto via deep link de notificação.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: highlighted
          ? AppColors.braweBlue.withValues(alpha: 0.10)
          : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StoryRingAvatar(
                  userId: comment.authorId,
                  avatarUrl: comment.authorAvatarUrl,
                  fallbackText: comment.authorName,
                  radius: 16,
                  onTapWithoutStories: () =>
                      context.push('/profile/${comment.authorId}'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.authorName,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (comment.authorIsVerified) const VerifiedBadge(size: 13, gap: 3),
                          const SizedBox(width: 6),
                          Text(
                            comment.timeAgo,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      if (comment.content.isNotEmpty)
                        BraweRichText(
                          comment.content,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      if (comment.gif != null)
                        Padding(
                          padding: EdgeInsets.only(top: comment.content.isEmpty ? 0 : 6),
                          child: Align(alignment: Alignment.centerLeft, child: GifBubble(gif: comment.gif!)),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => onLike(comment),
                            child: Row(
                              children: [
                                Icon(
                                  comment.userLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: comment.userLiked
                                      ? Colors.red
                                      : context.colors.textSecondary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${comment.likesCount}',
                                  style: TextStyle(
                                    color: context.colors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => onReply(comment),
                            child: Text(
                              S.of(context).commentsReplyAction,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Replies
            if (comment.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 42, top: 8),
                child: Column(
                  children: comment.replies
                      .map(
                        (reply) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BraweAvatar(
                                avatarUrl: reply.authorAvatarUrl,
                                displayName: reply.authorName,
                                size: 26,
                                fontSize: 11,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            reply.authorName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: context.colors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        if (reply.authorIsVerified)
                                          const VerifiedBadge(size: 12, gap: 3),
                                      ],
                                    ),
                                    if (reply.content.isNotEmpty)
                                      Text(
                                        reply.content,
                                        style: TextStyle(
                                          color: context.colors.textPrimary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    if (reply.gif != null)
                                      Padding(
                                        padding: EdgeInsets.only(top: reply.content.isEmpty ? 0 : 4),
                                        child: Align(alignment: Alignment.centerLeft, child: GifBubble(gif: reply.gif!, maxWidth: 180)),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
