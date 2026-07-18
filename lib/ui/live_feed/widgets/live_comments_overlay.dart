import 'package:flutter/material.dart';

import '../../../domain/models/live_comment.dart';
import '../../../core/text/brawe_rich_text.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../live/shared/widgets/level_chip.dart';

class LiveCommentsOverlay extends StatefulWidget {
  const LiveCommentsOverlay({
    super.key,
    required this.comments,
    required this.isSending,
    required this.onSendComment,
    this.onClose,
  });

  final List<LiveComment> comments;
  final bool isSending;
  final ValueChanged<String> onSendComment;
  final VoidCallback? onClose;

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
    final s = S.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chat messages list — minimal style
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
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
        // Input field — TikTok style: transparent, minimalist
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  // ✅ TRANSPARENT instead of dark background
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _commentController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  cursorColor: Colors.white70,
                  decoration: InputDecoration(
                    hintText: s.liveCommentsHint,
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Send button — minimal
            GestureDetector(
              onTap: widget.isSending ? null : _submitComment,
              child: widget.isSending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 8),
            // Close button
            GestureDetector(
              onTap: widget.onClose,
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white54,
                size: 20,
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
    final s = S.of(context);
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Level pin + userName
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🎖️ Level pin (TikTok-style) — só aparece se Lv > 1
                        if (comment.gifterLevel > 1) ...[
                          LevelChip(
                            level: comment.gifterLevel,
                            badge: comment.gifterBadge,
                            colorHex: comment.gifterColor,
                            imageUrl: comment.gifterImageUrl,
                            height: 16,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          comment.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // Message: com @menção e #hashtag clicáveis
                    BraweRichText(
                      comment.message,
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: comment.isPending ? 0.72 : 0.88,
                        ),
                        fontSize: 12,
                      ),
                    ),
                    // Pending indicator
                    if (comment.isPending)
                      Text(
                        s.liveCommentsSending,
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
        ],
      ),
    );
  }
}
