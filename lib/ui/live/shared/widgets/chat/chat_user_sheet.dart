import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/themes/brawe_colors.dart';

import '../../../../../domain/models/live_comment.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../core/themes/force_dark_theme.dart';
import '../level_chip.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';

/// Ação escolhida no cartão do autor de uma mensagem do chat.
enum ChatUserAction {
  reply,
  viewProfile,
  mute5,
  mute60,
  muteRest,
  pinMessage,
  makeModerator,
  removeModerator;

  bool get isModeration =>
      this != ChatUserAction.reply && this != ChatUserAction.viewProfile;
}

/// O que EU posso fazer com o autor da mensagem. Só existe quando sou o
/// criador ou moderador da live.
class ChatModerationAccess {
  const ChatModerationAccess({required this.isCreator});

  /// Criador da live (também pode promover/remover moderadores).
  final bool isCreator;
}

/// Cartão (bottom sheet) que abre ao tocar numa mensagem do chat da live —
/// estilo TikTok: avatar, nome, @username, nível e as ações
/// "Responder" (insere @menção no input) e "Ver perfil".
class ChatUserSheet extends StatelessWidget {
  const ChatUserSheet({
    super.key,
    required this.comment,
    this.allowProfile = true,
    this.moderation,
  });

  final LiveComment comment;

  /// `null` = sou espectador comum (sem ferramentas de moderação).
  final ChatModerationAccess? moderation;

  /// `false` no streamer: abrir um perfil por cima da transmissão tiraria
  /// a câmera da tela no meio da live.
  final bool allowProfile;

  /// Abre o cartão e devolve a ação escolhida (ou null se fechou).
  static Future<ChatUserAction?> show(
    BuildContext context,
    LiveComment comment, {
    bool allowProfile = true,
    ChatModerationAccess? moderation,
  }) {
    // Fecha o teclado antes: senão o Flutter devolve o foco ao input
    // quando o sheet fecha e o teclado reabre sozinho.
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<ChatUserAction>(
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      isScrollControlled: true,
      builder: (_) => ForceDarkTheme(
        child: ChatUserSheet(
          comment: comment,
          allowProfile: allowProfile,
          moderation: moderation,
        ),
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
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 32,
              backgroundColor: context.colors.accentPrimary,
              backgroundImage: hasAvatar
                  ? ResizeImage(
                      NetworkImage(c.avatarUrl!),
                      width: context.decodePx(64),
                    )
                  : null,
              child: hasAvatar
                  ? null
                  : Text(
                      c.userName.isNotEmpty
                          ? c.userName.characters.first.toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: context.colors.textPrimary,
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
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (c.isVerified) const VerifiedBadge(size: 17, gap: 5),
              ],
            ),
            if (c.username != null) ...[
              const SizedBox(height: 2),
              Text(
                '@${c.username}',
                style: TextStyle(
                  color: context.colors.textPrimary.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    icon: LucideIcons.reply,
                    label: S.of(context).chatDetailReply,
                    filled: true,
                    onTap: () => Navigator.pop(context, ChatUserAction.reply),
                  ),
                ),
                if (allowProfile) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SheetButton(
                      icon: LucideIcons.user,
                      label: S.of(context).chatDetailViewProfile,
                      onTap: () =>
                          Navigator.pop(context, ChatUserAction.viewProfile),
                    ),
                  ),
                ],
              ],
            ),
            ..._moderationRows(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _moderationRows(BuildContext context) {
    final access = moderation;
    if (access == null) return const [];
    // Moderador não age sobre outro moderador (o servidor recusa).
    final canAct = access.isCreator || !comment.isModerator;
    final s = S.of(context);
    void pop(ChatUserAction a) => Navigator.pop(context, a);
    return [
      const SizedBox(height: 14),
      Divider(
        height: 1,
        color: context.colors.textPrimary.withValues(alpha: 0.1),
      ),
      if (canAct) ...[
        _ModRow(
          icon: LucideIcons.volumeX,
          label: s.modMute5,
          onTap: () => pop(ChatUserAction.mute5),
        ),
        _ModRow(
          icon: LucideIcons.volumeX,
          label: s.modMute60,
          onTap: () => pop(ChatUserAction.mute60),
        ),
        _ModRow(
          icon: LucideIcons.volumeX,
          label: s.modMuteRest,
          onTap: () => pop(ChatUserAction.muteRest),
        ),
      ],
      _ModRow(
        icon: LucideIcons.pin,
        label: s.modPinMessage,
        onTap: () => pop(ChatUserAction.pinMessage),
      ),
      if (access.isCreator)
        _ModRow(
          icon: comment.isModerator
              ? LucideIcons.userMinus
              : LucideIcons.shield,
          label: comment.isModerator
              ? s.modRemoveModerator
              : s.modMakeModerator,
          onTap: () => pop(
            comment.isModerator
                ? ChatUserAction.removeModerator
                : ChatUserAction.makeModerator,
          ),
        ),
    ];
  }
}

class _ModRow extends StatelessWidget {
  const _ModRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.colors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
          ? context.colors.danger
          : context.colors.textPrimary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: context.colors.textPrimary, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: context.colors.textPrimary,
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
