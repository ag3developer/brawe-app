import '../../../data/services/privacy_ux_service.dart';
import '../../../data/services/battle_service.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Mensagem traduzida e amigável para um erro de batalha. Nunca expõe o
/// texto cru da exceção nem o `detail` do servidor (que vem só em PT).
/// Aviso de saída no meio de uma batalha: ninguém vence e a sequência de
/// vitórias (se houver) é perdida. `null` = sem batalha ativa.
String battleLeaveWarning(S l10n, int? streak) => (streak ?? 0) > 0
    ? l10n.battleLeaveBodyStreak(streak!)
    : l10n.battleLeaveBodyNoStreak;

String battleErrorText(S l10n, Object error, {String? fallback}) {
  // Privacidade: a pessoa não recebe convites de batalha (403).
  final privacyMsg = PrivacyApiError.messageFor(error, {
    'battle_invites_not_allowed',
  });
  if (privacyMsg != null) return privacyMsg;
  final info = BattleService.classifyError(error);
  switch (info.kind) {
    case BattleErrorKind.network:
      return l10n.battleErrNetwork;
    case BattleErrorKind.cooldown:
      final s = info.retryAfter;
      return s != null && s > 0
          ? l10n.battleErrCooldown(s)
          : (fallback ?? l10n.battleErrGeneric);
    case BattleErrorKind.blocked:
      return l10n.battleErrBlocked;
    case BattleErrorKind.notEligible:
      return l10n.battleErrNotEligible;
    case BattleErrorKind.expired:
      return l10n.battleErrExpired;
    case BattleErrorKind.answered:
      return l10n.battleErrAnswered;
    case BattleErrorKind.busy:
      return l10n.battleErrBusy;
    case BattleErrorKind.generic:
      return fallback ?? l10n.battleErrGeneric;
  }
}
