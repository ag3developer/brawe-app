import 'package:flutter/material.dart';

import '../../../../../domain/models/live_comment.dart';
import '../../../../core/themes/app_colors.dart';

/// Linha de comentário do chat da live — estilo TikTok Live.
///
/// Avatar pequeno (20px) + nome + mensagem flutuando direto sobre o vídeo,
/// sem caixa preta — confia em sombra + gradient da base para legibilidade.
class ChatLine extends StatelessWidget {
  const ChatLine({super.key, required this.comment});
  final LiveComment comment;

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        comment.avatarUrl != null && comment.avatarUrl!.isNotEmpty;
    final initial = comment.userName.isNotEmpty
        ? comment.userName.characters.first.toUpperCase()
        : '?';
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar pequeno (20px)
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.electricPurple,
              image: hasAvatar
                  ? DecorationImage(
                      image: NetworkImage(comment.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: hasAvatar
                ? null
                : Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          // Nome + mensagem flutuando direto (sombra para legibilidade)
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  children: [
                    TextSpan(
                      text: '${comment.userName} ',
                      style: const TextStyle(
                        color: Color(0xFFC9B6FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    TextSpan(
                      text: comment.message,
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: comment.isPending ? 0.7 : 0.98,
                        ),
                        fontWeight: FontWeight.w500,
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
