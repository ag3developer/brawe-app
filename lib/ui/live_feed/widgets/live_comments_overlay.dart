import 'package:flutter/material.dart';

import '../../../domain/models/live_comment.dart';

class LiveCommentsOverlay extends StatefulWidget {
  const LiveCommentsOverlay({
    super.key,
    required this.comments,
    required this.isSending,
    required this.onSendComment,
  });

  final List<LiveComment> comments;
  final bool isSending;
  final ValueChanged<String> onSendComment;

  @override
  State<LiveCommentsOverlay> createState() => _LiveCommentsOverlayState();
}

class _LiveCommentsOverlayState extends State<LiveCommentsOverlay> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          child: widget.comments.isEmpty
              ? const SizedBox.shrink()
              : ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: widget.comments.length,
                  itemBuilder: (context, index) {
                    final comment =
                        widget.comments[widget.comments.length - 1 - index];
                    return _LiveCommentBubble(comment: comment);
                  },
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: _commentController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: 'Say something...',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.isSending ? null : _submitComment,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white10,
                  shape: BoxShape.circle,
                ),
                child: widget.isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submitComment() {
    final message = _commentController.text.trim();
    if (message.isEmpty) {
      return;
    }

    widget.onSendComment(message);
    _commentController.clear();
  }
}

class _LiveCommentBubble extends StatelessWidget {
  const _LiveCommentBubble({required this.comment});

  final LiveComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: comment.avatarUrl != null
                ? NetworkImage(comment.avatarUrl!)
                : null,
            backgroundColor: Colors.white10,
            child: comment.avatarUrl == null
                ? Text(
                    comment.userName.isEmpty
                        ? '?'
                        : comment.userName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: comment.isPending ? Colors.black38 : Colors.black45,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${comment.userName} ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: comment.message,
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: comment.isPending ? 0.72 : 0.88,
                          ),
                          fontSize: 12,
                        ),
                      ),
                      if (comment.isPending)
                        TextSpan(
                          text: '  Sending...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
