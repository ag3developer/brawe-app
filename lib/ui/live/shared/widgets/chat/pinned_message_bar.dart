import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../domain/models/live_moderation.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../live_feed/view_models/live_moderation_view_model.dart';

/// Barra compacta da mensagem fixada, acima do chat: ícone de pino, autor e
/// texto numa linha; toque expande/recolhe. Criador e moderadores veem o botão
/// de desafixar.
///
/// Assina só o `pin` (e `isModerator`) do estado de moderação — mensagens
/// novas no chat não reconstroem esta barra.
class PinnedMessageBar extends ConsumerStatefulWidget {
  const PinnedMessageBar({
    super.key,
    required this.roomId,
    required this.isHost,
  });

  final String roomId;

  /// Eu sou o criador desta live.
  final bool isHost;

  @override
  ConsumerState<PinnedMessageBar> createState() => _PinnedMessageBarState();
}

class _PinnedMessageBarState extends ConsumerState<PinnedMessageBar> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = liveModerationProvider(widget.roomId);
    final pin = ref.watch(provider.select((s) => s.pin));
    final canUnpin =
        widget.isHost || ref.watch(provider.select((s) => s.isModerator));
    if (pin == null) return const SizedBox.shrink();
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 160),
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 5, 4, 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFD166).withValues(alpha: 0.55),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: _expanded
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: _expanded ? 2 : 0),
                    child: const Icon(
                      LucideIcons.pin,
                      size: 13,
                      color: Color(0xFFFFD166),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(child: _PinText(pin: pin, expanded: _expanded)),
                  if (canUnpin)
                    SizedBox(
                      width: 28,
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: s.chatPinnedUnpin,
                        iconSize: 14,
                        icon: const Icon(LucideIcons.x, color: Colors.white70),
                        onPressed: () => ref
                            .read(provider.notifier)
                            .unpin(),
                      ),
                    )
                  else
                    const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinText extends StatelessWidget {
  const _PinText({required this.pin, required this.expanded});

  final ChatPin pin;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          if (pin.authorName.isNotEmpty)
            TextSpan(
              text: '${pin.authorName}  ',
              style: const TextStyle(
                color: Color(0xFFFFD166),
                fontWeight: FontWeight.w800,
              ),
            ),
          TextSpan(text: pin.text),
        ],
      ),
      maxLines: expanded ? 8 : 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        height: 1.3,
        decoration: TextDecoration.none,
        shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
      ),
    );
  }
}

/// Mensagem fixada em cima do chat: [child] (o ticker) com a barra acima.
class PinnedAboveChat extends StatelessWidget {
  const PinnedAboveChat({
    super.key,
    required this.roomId,
    required this.isHost,
    required this.child,
  });

  final String roomId;
  final bool isHost;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PinnedMessageBar(roomId: roomId, isHost: isHost),
        child,
      ],
    );
  }
}
