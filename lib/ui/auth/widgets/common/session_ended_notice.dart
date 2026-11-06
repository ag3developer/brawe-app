import 'package:flutter/widgets.dart';

import '../../../../core/network/session_ended.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/ui/app_snackbar.dart';

/// Se a sessão foi encerrada pelo servidor, mostra uma única vez "Sua sessão
/// foi encerrada. Entre novamente." (login ou boas-vindas, o que abrir antes).
void showSessionEndedNoticeIfPending(State state) {
  if (!SessionEnded.instance.takeMessage()) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (state.mounted) {
      AppSnackBar.showError(
        state.context,
        S.of(state.context).sessionEndedMessage,
      );
    }
  });
}
