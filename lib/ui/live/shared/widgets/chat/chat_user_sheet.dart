import 'package:flutter/material.dart';

import '../../../../../domain/models/live_comment.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/force_dark_theme.dart';
import '../level_chip.dart';

/// Ação escolhida no cartão do autor de uma mensagem do chat.
enum ChatUserAction { reply, viewProfile }

/// Cartão (bottom sheet) que abre ao tocar numa mensagem do chat da live —
/// estilo TikTok: avatar, nome, @username, nível e as ações
/// "Responder" (insere @menção no input) e "Ver perfil".
class ChatUserSheet extends StatelessWidget {
  const ChatUserSheet({
    super.key,
    required this.comment,
    this.allowProfile = true,
  });

  final LiveComment comment;

  /// `false` no streamer: abrir um perfil por cima da transmissão tiraria
  /// a câmera da tela no meio da live.
  final bool allowProfile;

  /// Abre o cartão e devolve a ação escolhida (ou null se fechou).
  static Future<ChatUserAction?> show(
    BuildContext context,
    LiveComment comment, {
    bool allowProfile = true,
  }) {
    // Fecha o teclado antes: senão o Flutter devolve o foco ao input
    // quando o sheet fecha e o teclado reabre sozinho.
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<ChatUserAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => ForceDarkTheme(
        child: ChatUserSheet(comment: comment, allowProfile: allowProfile),
      ),
    );
  }

  /// Texto da menção para [comment]: `@username ` quando o servidor envia o
  /// username; senão `@Nome Exibido ` (fallback, como o TikTok faz com
  /// apelidos).
  static String mentionFor(LiveComment comment) {
    final username = comment.username;
    if (username != null && username.isNotEmpty) return '@$username ';
    return '@${comment.userName.trim()} ';
  }

  /// Insere a menção no início do input. Se o texto já começa com uma
  /// menção (resposta anterior), troca pela nova em vez de acumular.
  static void insertMention(
    TextEditingController controller,
    LiveComment comment,
  ) {
    final mention = mentionFor(comment);
    var rest = controller.text;
    final previous = RegExp(r'^@\S+\s').firstMatch(rest);
    if (previous != null) rest = rest.substring(previous.end);
    final text = '$mention$rest';
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = comment;
    final hasAvatar = c.avatarUrl != null && c.avatarUrl!.isNotEmpty;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16161D),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.braweBlue,
              backgroundImage: hasAvatar ? NetworkImage(c.avatarUrl!) : null,
              child: hasAvatar
                  ? null
                  : Text(
                      c.userName.isNotEmpty
                          ? c.userName.characters.first.toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (c.gifterLevel > 1) ...[
                  LevelChip(
                    level: c.gifterLevel,
                    badge: c.gifterBadge,
                    colorHex: c.gifterColor,
                    imageUrl: c.gifterImageUrl,
                    height: 18,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    c.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (c.username != null) ...[
              const SizedBox(height: 2),
              Text(
                '@${c.username}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    icon: Icons.reply_rounded,
                    label: 'Responder',
                    filled: true,
                    onTap: () => Navigator.pop(context, ChatUserAction.reply),
                  ),
                ),
                if (allowProfile) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SheetButton(
                      icon: Icons.person_outline_rounded,
                      label: 'Ver perfil',
                      onTap: () =>
                          Navigator.pop(context, ChatUserAction.viewProfile),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled
          ? const Color(0xFFFF3D6E)
          : Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
