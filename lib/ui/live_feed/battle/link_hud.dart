import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/link_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/view_models/follow_view_model.dart';
import 'battle_hud_parts.dart';
import 'battle_layout.dart';
import 'partner_sheet.dart';

/// HUD da TELA DUPLA sem batalha (conexão entre criadores, §8.4):
/// indicador de áudio no alto da divisória, nome + "+ seguir" do parceiro no
/// canto inferior da metade dele e (criador) silenciar / Batalha / Desconectar.
/// Sem placar, cronômetro, selo 2X ou top 3.
class LinkHudOverlay extends ConsumerWidget {
  const LinkHudOverlay({
    super.key,
    required this.link,
    required this.layout,
    required this.ownSide,
    this.isCreator = false,
    this.onOpenPartner,
    this.onToggleMute,
    this.onBattle,
    this.onDisconnect,
    this.busy = false,
  });

  final LinkState link;
  final BattleLayout layout;

  /// Lado da minha sala/meu lado ('a'|'b').
  final String ownSide;
  final bool isCreator;

  /// "Ver a live" do parceiro (espectador); o toque na metade abre a gaveta.
  final void Function(String roomId)? onOpenPartner;
  final VoidCallback? onToggleMute;
  final VoidCallback? onBattle;
  final VoidCallback? onDisconnect;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final partnerSide = ownSide == 'a' ? 'b' : 'a';
    final partner = link.peer(partnerSide);
    final half = layout.half(partnerSide);
    final following = partner.id.isEmpty
        ? null
        : ref.watch(followViewModelProvider(partner.id));
    final iMuted = link.mutedOf(ownSide);

    Widget audioDot(String side) {
      // Quem está silenciado do ponto de vista de QUEM VÊ:
      // - o parceiro, se eu (ou a minha sala) silenciei o adversário;
      // - eu, só para o criador (o parceiro me silenciou).
      final bool silenced;
      if (side == ownSide) {
        silenced = isCreator && link.mutedOf(partnerSide);
      } else {
        silenced = link.mutedOf(ownSide);
      }
      return Icon(
        silenced ? Icons.mic_off_rounded : Icons.mic_rounded,
        size: 13,
        color: silenced ? kBattleTextDim : kBattleText,
      );
    }

    return _RegionPublisher(
      layout: layout,
      child: Stack(
        children: [
          // Toque na metade do parceiro (espectador).
          Positioned.fromRect(
            rect: Rect.fromLTRB(half.left, half.top, half.right, half.bottom - 48),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => showPartnerSheet(
                context,
                ref,
                userId: partner.id,
                name: partner.name,
                avatarUrl: partner.avatarUrl,
                roomId: partner.roomId,
                onViewLive: onOpenPartner == null || (partner.roomId ?? '').isEmpty
                    ? null
                    : () => onOpenPartner!(partner.roomId!),
              ),
            ),
          ),
          // Indicador de áudio no alto da divisória.
          Positioned(
            left: 0,
            right: 0,
            top: layout.split.top + 6,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kBattleBg.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      audioDot('a'),
                      const SizedBox(width: 6),
                      audioDot('b'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Nome + "+ seguir" do parceiro (canto inferior da metade dele).
          Positioned(
            left: half.left + 6,
            width: half.width - 12,
            bottom: layout.screen.height - half.bottom + 6,
            child: Align(
              alignment: partnerSide == 'a'
                  ? Alignment.bottomLeft
                  : Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                decoration: BoxDecoration(
                  color: kBattleBg.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        partner.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: following == null || (following.value ?? true)
                            ? null
                            : () => ref
                                  .read(
                                    followViewModelProvider(
                                      partner.id,
                                    ).notifier,
                                  )
                                  .toggleFollow(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (following?.value ?? false)
                                ? Colors.white12
                                : battleSideColor(partnerSide),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            (following?.value ?? false)
                                ? l10n.battleFollowing
                                : l10n.linkFollowAction,
                            style: TextStyle(
                              color: (following?.value ?? false)
                                  ? Colors.white70
                                  : kBattleText,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Controles do criador.
          if (isCreator) ...[
            // Silenciar: canto inferior INTERNO da metade do parceiro.
            Positioned(
              left: partnerSide == 'b' ? half.left + 6 : null,
              right: partnerSide == 'a'
                  ? layout.screen.width - half.right + 6
                  : null,
              top: half.top + 34,
              child: GestureDetector(
                onTap: onToggleMute,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iMuted
                        ? AppColors.braweOrange
                        : kBattleBg.withValues(alpha: 0.78),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(
                    iMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    size: 16,
                    color: iMuted ? kBattleInk : Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: layout.chat.top + 4,
              child: Row(
                children: [
                  if (onBattle != null)
                    _pill(
                      icon: Icons.sports_kabaddi_rounded,
                      label: l10n.battleActionLabel,
                      color: AppColors.braweBlueBright,
                      fg: Colors.white,
                      onTap: busy ? null : onBattle,
                    ),
                  const SizedBox(width: 6),
                  _pill(
                    icon: Icons.link_off_rounded,
                    label: l10n.linkDisconnect,
                    color: kBattleBg.withValues(alpha: 0.7),
                    fg: Colors.white70,
                    onTap: busy ? null : onDisconnect,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required Color color,
    required Color fg,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
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
