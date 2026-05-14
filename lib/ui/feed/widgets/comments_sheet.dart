import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/post_comment.dart';
import '../../core/themes/app_colors.dart';
import '../view_models/comments_view_model.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  const CommentsSheet({super.key, required this.postId});
  final String postId;

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
          const SnackBar(
            content: Text('Erro ao enviar comentário. Tente novamente.'),
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

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF141824),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    const Text(
                      'Comentários',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    commentsState.when(
                      data: (comments) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppColors.electricPurple.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${comments.length}',
                          style: const TextStyle(
                            color: AppColors.electricPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),

              // Comments list
              Expanded(
                child: commentsState.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.electricPurple),
                  ),
                  error: (_, __) => const Center(
                    child: Text(
                      'Erro ao carregar comentários.',
                      style: TextStyle(color: AppColors.coolGray),
                    ),
                  ),
                  data: (comments) => comments.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum comentário ainda.\nSeja o primeiro!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.coolGray, fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: comments.length,
                          itemBuilder: (_, i) => _CommentTile(
                            comment: comments[i],
                            onReply: (c) {
                              setState(() => _replyingTo = c);
                              _focusNode.requestFocus();
                            },
                            onLike: (c) => ref
                                .read(commentsViewModelProvider(widget.postId)
                                    .notifier)
                                .toggleLike(c),
                          ),
                        ),
                ),
              ),

              // Reply banner
              if (_replyingTo != null)
                Container(
                  color: AppColors.slate,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.reply,
                          color: AppColors.electricPurple, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Respondendo a @${_replyingTo!.authorUsername}',
                          style: const TextStyle(
                              color: AppColors.coolGray, fontSize: 13),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _replyingTo = null),
                        child: const Icon(Icons.close,
                            color: AppColors.coolGray, size: 18),
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
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.slate,
                      child: Icon(Icons.person,
                          color: AppColors.coolGray, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: _replyingTo != null
                              ? 'Responder...'
                              : 'Adicionar comentário...',
                          hintStyle: const TextStyle(
                              color: AppColors.coolGray, fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.slate,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
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
                          color: AppColors.electricPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send,
                            color: Colors.white, size: 18),
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
  });
  final PostComment comment;
  final void Function(PostComment) onReply;
  final void Function(PostComment) onLike;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.slate,
                backgroundImage: comment.authorAvatarUrl != null
                    ? NetworkImage(comment.authorAvatarUrl!)
                    : null,
                child: comment.authorAvatarUrl == null
                    ? Text(
                        comment.authorName[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      )
                    : null,
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (comment.authorIsVerified) ...[
                          const SizedBox(width: 3),
                          const Icon(Icons.verified,
                              color: AppColors.electricPurple, size: 13),
                        ],
                        const SizedBox(width: 6),
                        Text(
                          comment.timeAgo,
                          style: const TextStyle(
                              color: AppColors.coolGray, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      comment.content,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, height: 1.4),
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
                                    : AppColors.coolGray,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${comment.likesCount}',
                                style: const TextStyle(
                                    color: AppColors.coolGray, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => onReply(comment),
                          child: const Text(
                            'Responder',
                            style: TextStyle(
                              color: AppColors.coolGray,
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
                    .map((reply) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: AppColors.slate,
                                backgroundImage: reply.authorAvatarUrl != null
                                    ? NetworkImage(reply.authorAvatarUrl!)
                                    : null,
                                child: reply.authorAvatarUrl == null
                                    ? Text(
                                        reply.authorName[0].toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reply.authorName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      reply.content,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}