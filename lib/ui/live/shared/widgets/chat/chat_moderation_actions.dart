import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/services/live_moderation_service.dart';
import '../../../../../domain/models/live_comment.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../live_feed/view_models/live_moderation_view_model.dart';
import 'chat_user_sheet.dart';

/// Eu posso moderar? Criador sempre; moderador quando o servidor já me
/// marcou (`is_moderator` no meu eco/entrada). `null` = não.
ChatModerationAccess? chatModerationAccess(
  WidgetRef ref, {
  required String roomId,
  required bool isHost,
}) {
  if (isHost) return const ChatModerationAccess(isCreator: true);
  final isMod = ref.read(liveModerationProvider(roomId)).isModerator;
  return isMod ? const ChatModerationAccess(isCreator: false) : null;
}

/// Executa a ação de moderação escolhida no cartão do autor e avisa o
/// resultado num SnackBar (403 = "sem permissão", tratado sem estourar).
Future<void> performChatModeration(
  BuildContext context,
  WidgetRef ref, {
  required String roomId,
  required LiveComment comment,
  required ChatUserAction action,
}) async {
  if (!action.isModeration || comment.userId.isEmpty) return;
  final s = S.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final vm = ref.read(liveModerationProvider(roomId).notifier);
  final svc = ref.read(liveModerationServiceProvider);

  String? okText;
  final ModerationResult result;
  switch (action) {
    case ChatUserAction.mute5:
      result = await vm.mute(comment.userId, minutes: 5);
      okText = s.modMutedToast(comment.userName);
    case ChatUserAction.mute60:
      result = await vm.mute(comment.userId, minutes: 60);
      okText = s.modMutedToast(comment.userName);
    case ChatUserAction.muteRest:
      result = await vm.mute(comment.userId);
      okText = s.modMutedToast(comment.userName);
    case ChatUserAction.pinMessage:
      result = await vm.pinMessage(
        text: comment.message,
        messageId: comment.id.startsWith('local-') ? null : comment.id,
        authorName: comment.userName,
        authorId: comment.userId,
      );
      okText = s.modPinnedToast;
    case ChatUserAction.makeModerator:
      result = await svc.addModerator(comment.userId);
      okText = s.modMadeModeratorToast(comment.userName);
    case ChatUserAction.removeModerator:
      result = await svc.removeModerator(comment.userId);
      okText = s.modRemovedModeratorToast(comment.userName);
    case ChatUserAction.reply:
    case ChatUserAction.viewProfile:
      return;
  }

  final text = switch (result) {
    ModerationResult.ok => okText,
    ModerationResult.forbidden => s.modNotAllowed,
    ModerationResult.failed => s.modActionFailed,
  };
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
}
