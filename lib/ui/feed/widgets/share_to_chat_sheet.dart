import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../gen/l10n/app_localizations.dart';
import 'share_sheet.dart';

/// Atalho para compartilhar um POST/vídeo: monta o [ShareTarget] e abre o
/// [ShareSheet] unificado ("Enviar para"). Mantido para os chamadores
/// existentes (feed, vídeos, visor de imagem, perfil, chat).
class ShareToChatSheet {
  const ShareToChatSheet._();

  static Future<void> show(
    BuildContext context, {
    required String postId,
    required String postCaption,
    String? postImageUrl,
    String? authorName,
    String? authorId,
    String? storyMediaUrl,
    bool isReposted = false,
    ValueChanged<bool>? onRepostChanged,
  }) {
    final url = AppConstants.postUrl(postId);
    final caption = postCaption.trim();
    return ShareSheet.show(
      context,
      ShareTarget(
        kind: ShareKind.post,
        url: url,
        shareText: caption.isNotEmpty
            ? '$caption\n\n$url'
            : '${S.of(context).shareCheckBraweConnect}\n\n$url',
        postId: postId,
        authorId: authorId,
        storyMediaUrl: storyMediaUrl,
        isReposted: isReposted,
        onRepostChanged: onRepostChanged,
      ),
    );
  }
}
