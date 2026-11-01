import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../live_feed/view_models/live_moderation_view_model.dart';
import 'chat_error_text.dart';

/// Aviso curto perto do input quando o servidor recusa uma mensagem
/// (`chat_error`). Some sozinho (o view model limpa após alguns segundos).
class ChatErrorBanner extends ConsumerWidget {
  const ChatErrorBanner({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(
      liveModerationProvider(roomId).select((s) => s.error),
    );
    return AnimatedSize(
      duration: const Duration(milliseconds: 160),
      alignment: Alignment.bottomLeft,
      child: error == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3261E).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.circleAlert,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          chatErrorText(S.of(context), error),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/// [child] (a barra de input) com o aviso de erro de envio logo acima.
class ChatErrorAbove extends StatelessWidget {
  const ChatErrorAbove({super.key, required this.roomId, required this.child});

  final String roomId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [ChatErrorBanner(roomId: roomId), child],
    );
  }
}
