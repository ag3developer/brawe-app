// Peças compartilhadas das telas de Privacidade.

import 'package:flutter/material.dart';

import '../../../data/repositories/privacy_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';

/// Mensagem do servidor como está (422 etc.); sem resposta, o texto genérico.
String privacyErrorText(BuildContext context, Object e) {
  if (e is PrivacyFailure && e.message.isNotEmpty) return e.message;
  return S.of(context).privacyErrorGeneric;
}

void showPrivacyError(ScaffoldMessengerState m, String text, Color bg) {
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(content: Text(text), backgroundColor: bg));
}

/// Mostra o erro na tela atual (captura o messenger antes de qualquer pop).
void reportPrivacyError(BuildContext context, Object e) {
  showPrivacyError(
    ScaffoldMessenger.of(context),
    privacyErrorText(context, e),
    context.colors.danger,
  );
}

String whoLabel(S s, String v) => switch (v) {
  Who.followers => s.privacyWhoFollowers,
  Who.following => s.privacyWhoFollowing,
  Who.none => s.privacyWhoNobody,
  _ => s.privacyWhoEveryone,
};

/// Interruptor para linha agrupada.
class PrivacySwitch extends StatelessWidget {
  const PrivacySwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Switch.adaptive(
    value: value,
    activeTrackColor: context.colors.accentPrimary,
    onChanged: onChanged,
  );
}

/// Folha padrão (alça, título, conteúdo).
Future<T?> showPrivacySheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext) builder,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: true,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (ctx) => SafeArea(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: builder(ctx),
    ),
  ),
);

class PrivacySheetHeader extends StatelessWidget {
  const PrivacySheetHeader({super.key, required this.title, this.body});
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(
              body!,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
