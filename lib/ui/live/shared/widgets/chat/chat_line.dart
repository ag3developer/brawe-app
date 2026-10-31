import 'package:flutter/material.dart';

import '../../../../../domain/models/live_comment.dart';
import '../../../../core/themes/app_colors.dart';
import '../level_chip.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// Linha de comentário do chat da live — estilo TikTok Live.
///
/// Avatar pequeno (20px) + nome + mensagem flutuando direto sobre o vídeo,
/// sem caixa preta — confia em sombra + gradient da base para legibilidade.
///
/// [isHost] marca mensagens do dono da live com o selo "Criador".
/// [mentionsMe] destaca a linha quando a mensagem me menciona (@eu).
/// [onTap] abre o cartão do autor (Responder / Ver perfil).
class ChatLine extends StatelessWidget {
  const ChatLine({
    super.key,
    required this.comment,
    this.isHost = false,
    this.mentionsMe = false,
    this.onTap,
  });
  final LiveComment comment;
  final bool isHost;
  final bool mentionsMe;
  final VoidCallback? onTap;

  /// @menções no texto (username ou primeira palavra de um apelido).
  static final RegExp _mentionRegex = RegExp(r'@[\p{L}0-9_.]+', unicode: true);

  List<TextSpan> _messageSpans() {
    final base = TextStyle(
      color: Colors.white.withValues(alpha: comment.isPending ? 0.7 : 0.98),
      fontWeight: FontWeight.w500,
    );
    final spans = <TextSpan>[];
    var last = 0;
    for (final m in _mentionRegex.allMatches(comment.message)) {
      if (m.start > last) {
        spans.add(
          TextSpan(text: comment.message.substring(last, m.start), style: base),
        );
      }
      spans.add(
        TextSpan(
          text: m.group(0),
          style: base.copyWith(
            color: const Color(0xFF7DD3FC),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      last = m.end;
    }
    if (last < comment.message.length) {
      spans.add(TextSpan(text: comment.message.substring(last), style: base));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final line = _buildLine(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: mentionsMe
          ? Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.fromLTRB(6, 4, 8, 0),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3D6E).withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: line,
            )
          : line,
    );
  }

  Widget _buildSystemLine() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD166).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.trending_up_rounded,
              size: 14,
              color: Color(0xFFFFD166),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                comment.message,
                style: const TextStyle(
                  color: Color(0xFFFFD166),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(BuildContext context) {
    if (comment.isSystem) return _buildSystemLine();
    final hasAvatar =
        comment.avatarUrl != null && comment.avatarUrl!.isNotEmpty;
    final initial = comment.userName.isNotEmpty
        ? comment.userName.characters.first.toUpperCase()
        : '?';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // ✨ +3px (era 5px)
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar pequeno (20px)
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2), // ✨ +1px (era 1px)

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.braweBlue,
              image: hasAvatar
                  ? DecorationImage(
                      image: ResizeImage(NetworkImage(comment.avatarUrl!), width: context.decodePx(20)),
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
                    height: 1.35, // ✨ +0.10 line-height (era 1.25)
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  children: [
                    // 🎖️ Level pin (TikTok-style) — só aparece se Lv > 1
                    if (comment.gifterLevel > 1)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: LevelChip(
                            level: comment.gifterLevel,
                            badge: comment.gifterBadge,
                            colorHex: comment.gifterColor,
                            imageUrl: comment.gifterImageUrl,
                            height: 15,
                          ),
                        ),
                      ),
                    if (isHost)
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: _HostBadge(),
                      ),
                    TextSpan(
                      text: '${comment.userName} ',
                      style: TextStyle(
                        color: isHost
                            ? const Color(0xFFFFD166)
                            : AppColors.braweBlueSoft,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    ..._messageSpans(),
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

/// Selo "Criador" ao lado do nome do dono da live.
class _HostBadge extends StatelessWidget {
  const _HostBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3D6E),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Criador',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}
