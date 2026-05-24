import 'package:flutter/material.dart';

import 'metric_pill.dart';

/// Pílula de likes (ícone coração rosa + contador).
///
/// Wrapper sobre [MetricPill] que fixa o ícone de coração com a cor rosa
/// característica da live. O contador deve ser atualizado pelo widget pai
/// (ex.: `_LivePlayerScreenState` que escuta socket de reactions).
class LiveLikesPill extends StatelessWidget {
  const LiveLikesPill({
    super.key,
    required this.roomId,
    required this.initial,
  });
  final String roomId;
  final int initial;

  @override
  Widget build(BuildContext context) {
    return MetricPill(
      icon: Icons.favorite_rounded,
      iconColor: const Color(0xFFFF3D6E),
      value: MetricPill.formatCount(initial),
    );
  }
}
