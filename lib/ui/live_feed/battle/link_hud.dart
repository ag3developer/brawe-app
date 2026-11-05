import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/link_state.dart';
import 'battle_hud_parts.dart';
import 'battle_layout.dart';
import 'partner_sheet.dart';

/// HUD da TELA DUPLA sem batalha (conexão entre criadores, §8.4).
/// Minimalista: nada por cima do vídeo — só a foto redonda do parceiro na
/// faixa escura abaixo da metade dele (toque → Seguir / Ver a live). O
/// "silenciar" do criador fica na faixa escura do topo ([LinkMuteButton]) e
/// Batalha / Desconectar ficam só na barra de ações.
class LinkHudOverlay extends ConsumerWidget {
  const LinkHudOverlay({
    super.key,
    required this.link,
    required this.layout,
    required this.ownSide,
    this.isCreator = false,
    this.onOpenPartner,
  });

  final LinkState link;
  final BattleLayout layout;

  /// Lado da minha sala/meu lado ('a'|'b').
  final String ownSide;
  final bool isCreator;

  /// "Ver a live" do parceiro (espectador); o toque na metade abre a gaveta.
  final void Function(String roomId)? onOpenPartner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnerSide = ownSide == 'a' ? 'b' : 'a';
    final partner = link.peer(partnerSide);
    final half = layout.half(partnerSide);
    void openPartner() => showPartnerSheet(
      context,
      ref,
      userId: partner.id,
      name: partner.name,
      avatarUrl: partner.avatarUrl,
      roomId: partner.roomId,
      onViewLive: onOpenPartner == null || (partner.roomId ?? '').isEmpty
          ? null
          : () => onOpenPartner!(partner.roomId!),
    );

    return _RegionPublisher(
      layout: layout,
      child: Stack(
        children: [
          // Toque na metade do parceiro (espectador).
          Positioned.fromRect(
            rect: Rect.fromLTRB(half.left, half.top, half.right, half.bottom - 48),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: openPartner,
            ),
          ),
          // Foto redonda do parceiro na faixa escura ABAIXO da metade dele
          // (fora do vídeo, sem nome): o toque abre a gaveta Seguir / Ver a live.
          Positioned(
            top: layout.chat.top + 2,
            left: partnerSide == 'a' ? half.left + 2 : null,
            right: partnerSide == 'b'
                ? layout.screen.width - half.right + 2
                : null,
            child: PartnerAvatarButton(
              name: partner.name,
              avatarUrl: partner.avatarUrl,
              onTap: openPartner,
              // Espectador: o criador desta live silenciou o parceiro.
              muted: !isCreator && link.mutedOf(ownSide),
            ),
          ),
        ],
      ),
    );
  }
}

/// Publica as áreas da tela dupla (efeitos de presente na área de baixo) e
/// limpa ao sair.
class _RegionPublisher extends StatefulWidget {
  const _RegionPublisher({required this.layout, required this.child});
  final BattleLayout layout;
  final Widget child;

  @override
  State<_RegionPublisher> createState() => _RegionPublisherState();
}

class _RegionPublisherState extends State<_RegionPublisher> {
  @override
  void dispose() {
    BattleGiftRegions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) BattleGiftRegions.publish(widget.layout);
    });
    return widget.child;
  }
}


/// Silenciar o parceiro (só o criador): botão discreto na faixa escura do
/// topo, acima da metade do parceiro — vale na conexão e na batalha.
class LinkMuteButton extends StatelessWidget {
  const LinkMuteButton({super.key, required this.muted, required this.onTap});

  final bool muted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: muted,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: kBattleGlass,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: kBattleGlassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                size: 15,
                color: muted ? kBattleTextDim : kBattleText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
