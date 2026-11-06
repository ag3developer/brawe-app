import 'package:flutter/material.dart';

import '../../core/themes/brawe_colors.dart';
import '../view_models/unread_chats_provider.dart';

/// Selo de não lidas sobre um ícone: oculto em 0, "1".."99", "99+".
/// Cor da marca com texto de contraste; anel com a cor da superfície para
/// destacar sobre qualquer fundo (claro/escuro).
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({
    super.key,
    required this.count,
    required this.child,
    this.semanticsLabel,
  });

  final int count;
  final Widget child;

  /// Ex.: "Chat, 3 conversas não lidas". Se nulo, só o ícone é anunciado.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final label = UnreadChatsLogic.label(count);
    if (label == null) return child;
    final colors = context.colors;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          PositionedDirectional(
            top: -4,
            end: -9,
            child: Container(
              key: const ValueKey('unread-badge'),
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.accentPrimary,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: colors.surface, width: 1.5),
              ),
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: colors.textOnAccent,
                  fontSize: 10,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
