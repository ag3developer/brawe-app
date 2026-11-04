import '../../../gen/l10n/app_localizations.dart';

/// Traduz o erro guardado no estado do chat. Os view models gravam um código
/// (`chat.err.*`) porque não têm acesso ao idioma; mensagens vindas do
/// servidor (já traduzidas) passam direto.
String chatErrorText(S s, String raw) => switch (raw) {
      'chat.err.loadMessages' => s.chatErrLoadMessages,
      'chat.err.send' => s.chatErrSend,
      'chat.err.react' => s.chatErrReact,
      'chat.err.audio' => s.chatErrAudio,
      'chat.err.image' => s.chatErrImage,
      'chat.err.delete' => s.chatErrDelete,
      'chat.err.loadConversations' => s.chatErrLoadConversations,
      'chat.err.archive' => s.chatErrArchive,
      'chat.err.unarchive' => s.chatErrUnarchive,
      'chat.err.deleteConversation' => s.chatErrDeleteConversation,
      'chat.err.start' => s.chatErrStart,
      'chat.err.edit' => s.chatErrEdit,
      'chat.err.openGift' => s.chatErrOpenGift,
      'chat.err.file' => s.chatErrFile,
      _ => raw,
    };
