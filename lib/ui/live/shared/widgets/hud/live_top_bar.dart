import 'package:flutter/material.dart';

import '../../../../../domain/models/live_room.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../sheets/sheets.dart';
import 'live_likes_pill.dart';
import 'live_pill.dart';
import 'metric_pill.dart';
import 'streamer_identity_bar.dart';
import 'top_hud_circle_icon.dart';
import 'viewers_stack.dart';

/// 🎬 Top bar do viewer da live (linha 1: identidade + viewers + more;
/// linha 2: pílulas LIVE · views · likes).
///
/// Componente de composição — orquestra os átomos do `hud/` para o
/// header do `LivePlayerScreen`. Mantém-se "burro" (StatelessWidget):
/// estado de viewers/likes é injetado pelo pai.
class LiveTopBar extends StatelessWidget {
  const LiveTopBar({
    super.key,
    required this.room,
    required this.viewerCount,
    required this.likesCount,
    required this.roomId,
    required this.onBack,
    required this.onShare,
  });
  final LiveRoom room;
  final int viewerCount;
  final int likesCount;
  final String roomId;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Linha 1: identidade + viewers stack + more ───────────────
        Row(
          children: [
            // X close
            GestureDetector(
              onTap: onBack,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.close_rounded,
                    color: Colors.white, size: 26),
              ),
            ),
            const SizedBox(width: 4),
            // Identity pill (avatar + nome + verified + follow)
            Expanded(child: StreamerIdentityBar(room: room)),
            const SizedBox(width: 8),
            // Stack de avatares de viewers + total (350+ etc.)
            ViewersStack(viewerCount: viewerCount),
            const SizedBox(width: 8),
            // More menu (⋯)
            TopHudCircleIcon(
              icon: Icons.more_horiz_rounded,
              onTap: () => MoreSheet.show(context, onShare: onShare),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // ─── Linha 2: pílulas LIVE · views · likes ───────────────────
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Row(
            children: [
              LivePill(label: s.liveFeedBadgeLive),
              const SizedBox(width: 8),
              MetricPill(
                icon: Icons.visibility_rounded,
                value: MetricPill.formatCount(viewerCount),
              ),
              const SizedBox(width: 8),
              LiveLikesPill(roomId: roomId, initial: likesCount),
            ],
          ),
        ),
      ],
    );
  }
}
