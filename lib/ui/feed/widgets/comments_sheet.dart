import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/post_comment.dart';
import '../../../core/text/brawe_rich_text.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/widgets/brawe_avatar.dart';
import '../view_models/comments_view_model.dart';
import 'story_ring_avatar.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    try {
      await ref
          .read(commentsViewModelProvider(widget.postId).notifier)
          .addComment(text, parentId: _replyingTo?.id);
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
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsViewModelProvider(widget.postId));
    final s = S.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                          color: AppColors.braweBlue.withValues(
                            alpha: 0.2,
                          ),
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

              // Input
              Container(
                padding: EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  MediaQuery.of(context).viewInsets.bottom + 12,
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
                              : s.commentsHintAdd,
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
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                          if (comment.authorIsVerified) ...[
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.verified,
                              color: AppColors.braweBlue,
                              size: 13,
                            ),
                          ],
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
                      BraweRichText(
                        comment.content,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
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
                                    Text(
                                      reply.authorName,
                                      style: TextStyle(
                                        color: context.colors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      reply.content,
                                      style: TextStyle(
                                        color: context.colors.textPrimary,
                                        fontSize: 13,
                                      ),
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
