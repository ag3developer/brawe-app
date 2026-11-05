import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../live/shared/widgets/overlays/gifts_overlay.dart';
import '../battle/battle_hud.dart';

/// 🥊 HUD de batalha do ESPECTADOR — sobreposto à live (não é tela separada).
///
/// Fino: toda a UI (faixa de placar, apoiadores, toasts, contagem, reta final
/// e tela de resultado) vive em [BattleHudOverlay], compartilhado com o
/// criador. Aqui só entra o "seguir o vencedor" do espectador.
///
/// `onClose` é chamado quando o resultado é dispensado (ou a batalha é
/// cancelada) → o pai volta para a live normal.
class ViewerBattleHud extends ConsumerWidget {
  const ViewerBattleHud({
    super.key,
    required this.battleId,
    required this.onClose,
    this.initialCountdown,
    this.roomId,
    this.streamerId,
  });

  final String battleId;
  final VoidCallback onClose;

  /// Sala em que o espectador está (lado fechado).
  final String? roomId;
  final String? streamerId;

  /// Payload do `connect:battle:countdown` que fez a batalha aparecer (o VM
  /// é criado depois dele; sem isso o "3" se perderia).
  final Map<String, dynamic>? initialCountdown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BattleHudOverlay(
      key: ValueKey('battle-hud-$battleId'),
      battleId: battleId,
      onClose: onClose,
      initialCountdown: initialCountdown,
      ownRoomId: roomId,
      onFlashTap: (f) {
        if (roomId == null || streamerId == null) return;
        GiftsOverlay.show(
          context,
          roomId!,
          streamerId!,
          battleId: battleId,
          preselectGiftSlug: f.giftSlug.isEmpty ? null : f.giftSlug,
        );
      },
      onOpenOpponent: (id, _) => context.push('/live/$id'),
    );
  }
}
