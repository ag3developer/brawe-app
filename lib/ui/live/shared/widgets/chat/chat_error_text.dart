import 'package:intl/intl.dart';

import '../../../../../domain/models/live_moderation.dart';
import '../../../../../gen/l10n/app_localizations.dart';

/// Texto curto (no idioma do app) para uma rejeição do chat. Nunca usa o
/// `message` do servidor, que vem em pt.
String chatErrorText(S s, ChatError e, {DateTime? now}) {
  switch (e.kind) {
    case ChatErrorKind.muted:
      final until = e.until;
      if (until == null) return s.chatErrorMutedLiveEnd;
      return s.chatErrorMutedUntil(DateFormat('HH:mm').format(until.toLocal()));
    case ChatErrorKind.link:
      return s.chatErrorLink;
    case ChatErrorKind.phone:
      return s.chatErrorPhone;
    case ChatErrorKind.slowMode:
      final until = e.until;
      if (until == null) return s.chatErrorSlowGeneric;
      final ms = until.difference(now ?? DateTime.now()).inMilliseconds;
      if (ms <= 0) return s.chatErrorSlowGeneric;
      return s.chatErrorSlowWait((ms / 1000).ceil());
    case ChatErrorKind.blockedWord:
    case ChatErrorKind.unknown:
      return s.chatErrorNotSent;
  }
}
