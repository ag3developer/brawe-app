import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../domain/models/battle_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../live_feed/battle/battle_hud_parts.dart';
import '../../live_feed/battle/battle_layout.dart';
import 'battle_rtc_session.dart';

/// Camada de vídeo do CRIADOR com tempo real (`composite`): a própria
/// câmera (pré-visualização local) na metade do próprio lado e o vídeo do
/// adversário (LiveKit) na outra — mesmo layout da composição (§1/§18.1):
/// o criador à esquerda, o parceiro à direita (via [BattleLayout.half]).
class BattleCreatorStage extends StatelessWidget {
  const BattleCreatorStage({
    super.key,
    required this.layout,
    required this.session,
    required this.mySide,
    this.battle,
  });

  final BattleLayout layout;
  final BattleRtcSession session;
  final String mySide;
  final BattleState? battle;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kBattleBg,
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final local = session.localVideo;
          final remote = session.remoteVideo;
          Widget half(String side) {
            final mine = side == mySide;
            final track = mine ? local : remote;
            final name = battle?.nameOf(side) ?? '';
            return Positioned.fromRect(
              rect: layout.half(side),
              child: ClipRect(
                child: track != null
                    ? VideoTrackRenderer(
                        track,
                        fit: VideoViewFit.cover,
                        mirrorMode: mine
                            ? VideoViewMirrorMode.auto
                            : VideoViewMirrorMode.off,
                      )
                    : _Waiting(
                        text: mine
                            ? S.of(context).battleRtcConnecting
                            : S.of(context).battleOpponentCamera,
                        name: name,
                        color: kBattleTextDim,
                      ),
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              half('a'),
              half('b'),
              Positioned.fromRect(
                rect: layout.divider,
                child: const ColoredBox(color: Color(0x24FFFFFF)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({required this.text, required this.name, required this.color});
  final String text;
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
          const SizedBox(height: 10),
          if (name.isNotEmpty)
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10.5,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
