import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tipos de reação suportados pelo backend.
/// Espelha `VALID_POST_REACTIONS` em `posts.py` e `VALID_REACTIONS` em
/// `interactions.py`.
enum BraweReaction {
  like('like', '👍'),
  love('love', '❤️'),
  fire('fire', '🔥'),
  laugh('laugh', '😂'),
  wow('wow', '😮'),
  sad('sad', '😢');

  const BraweReaction(this.key, this.emoji);
  final String key;
  final String emoji;
}

/// Mostra uma barra flutuante (TikTok/Facebook style) com 6 emojis
/// para o usuário escolher a reação. Retorna a [BraweReaction] escolhida
/// ou `null` se o usuário cancelar (tap fora / back).
///
/// O `anchor` é o RenderBox do botão de like — usado para posicionar a
/// barra logo acima dele.
Future<BraweReaction?> showReactionsBar(
  BuildContext context, {
  required Offset globalPosition,
  BraweReaction? current,
}) {
  return showGeneralDialog<BraweReaction>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'reactions',
    barrierColor: Colors.black.withValues(alpha: 0.18),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (ctx, anim, _) {
      return _ReactionsOverlay(
        anchor: globalPosition,
        current: current,
        onPick: (r) => Navigator.of(ctx).pop(r),
      );
    },
    transitionBuilder: (ctx, anim, _, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

class _ReactionsOverlay extends StatefulWidget {
  const _ReactionsOverlay({
    required this.anchor,
    required this.onPick,
    this.current,
  });
  final Offset anchor;
  final ValueChanged<BraweReaction> onPick;
  final BraweReaction? current;

  @override
  State<_ReactionsOverlay> createState() => _ReactionsOverlayState();
}

class _ReactionsOverlayState extends State<_ReactionsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();
  int? _hoverIndex;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _setHover(int? i) {
    if (_hoverIndex == i) return;
    setState(() => _hoverIndex = i);
    if (i != null) HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final reactions = BraweReaction.values;
    final mq = MediaQuery.of(context);
    const barWidth = 6 * 52.0 + 16;
    const barHeight = 64.0;

    // Posiciona a barra acima do ponto tocado, sem sair da tela.
    double left = widget.anchor.dx - barWidth / 2;
    left = left.clamp(12.0, mq.size.width - barWidth - 12);
    double top = widget.anchor.dy - barHeight - 24;
    if (top < mq.padding.top + 16) {
      top = widget.anchor.dy + 24; // se não cabe acima, vai abaixo
    }

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _ctrl,
              curve: Curves.easeOutBack,
            ),
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: barWidth,
                height: barHeight,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < reactions.length; i++)
                      _ReactionBubble(
                        emoji: reactions[i].emoji,
                        hovered: _hoverIndex == i,
                        selected: widget.current == reactions[i],
                        onEnter: () => _setHover(i),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onPick(reactions[i]);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReactionBubble extends StatelessWidget {
  const _ReactionBubble({
    required this.emoji,
    required this.hovered,
    required this.selected,
    required this.onEnter,
    required this.onTap,
  });
  final String emoji;
  final bool hovered;
  final bool selected;
  final VoidCallback onEnter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onEnter(),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: hovered ? 56 : 44,
          height: hovered ? 56 : 44,
          alignment: Alignment.center,
          margin: EdgeInsets.only(bottom: hovered ? 12 : 0),
          decoration: selected
              ? BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                )
              : null,
          child: Text(
            emoji,
            style: TextStyle(fontSize: hovered ? 36 : 28),
          ),
        ),
      ),
    );
  }
}
