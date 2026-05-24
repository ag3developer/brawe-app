import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/app_colors.dart';
import '../../../domain/models/battle_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/battle_view_model.dart';
import 'battle_gift_alert.dart';
import 'battle_score_bar.dart';
import 'battle_timer.dart';

/// HUD compacto da batalha para o streamer.
///
/// O streamer continua vendo o preview da câmera (gerenciado pelo BroadcasterScreen).
/// Este widget é sobreposto como um HUD — não bloqueia a câmera, não roda
/// overlays pesados, não cobre a tela inteira.
///
/// Uso: sobreponha sobre o BroadcasterScreen via Stack.
class StreamerBattleHud extends ConsumerStatefulWidget {
  const StreamerBattleHud({
    super.key,
    required this.battleId,
    required this.myStreamerId,
  });

  final String battleId;
  final String myStreamerId;

  @override
  ConsumerState<StreamerBattleHud> createState() => _StreamerBattleHudState();
}

class _StreamerBattleHudState extends ConsumerState<StreamerBattleHud> {
  final List<_ToastAlert> _toasts = [];

  @override
  void dispose() {
    super.dispose();
  }

  void _addToast(BattleState s) {
    if (s.lastGiftSender == null || s.lastGiftName == null) return;
    final toast = _ToastAlert(
      sender: s.lastGiftSender!,
      gift: s.lastGiftName!,
      side: s.lastUpdatedSide ?? 'a',
    );
    setState(() => _toasts.add(toast));
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toasts.remove(toast));
    });
  }

  String _formatScore(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final asyncState = ref.watch(battleViewModelProvider(widget.battleId));

    ref.listen<AsyncValue<BattleState>>(
      battleViewModelProvider(widget.battleId),
      (prev, next) {
        next.whenData((s) {
          final prevState = prev?.asData?.value;
          if (prevState?.lastGiftSender != s.lastGiftSender ||
              prevState?.lastGiftName != s.lastGiftName) {
            _addToast(s);
          }
        });
      },
    );

    return asyncState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (battle) {
        if (battle.isOver) {
          return _ResultBanner(battle: battle, l10n: l10n);
        }

        final iAmA = battle.streamerAId == widget.myStreamerId;
        final myScore = iAmA ? battle.scoreA : battle.scoreB;
        final rivalScore = iAmA ? battle.scoreB : battle.scoreA;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top HUD bar ───────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Score row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.battleYouScore(_formatScore(myScore)),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            BattleTimer(
                              timeRemaining: battle.timeRemaining,
                              compact: true,
                            ),
                            Expanded(
                              child: Text(
                                l10n.battleRivalScore(_formatScore(rivalScore)),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Mini score bar
                        BattleScoreBar(
                          progressA: battle.progressA,
                          scoreA: battle.scoreA,
                          scoreB: battle.scoreB,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Gift toasts ────────────────────────────────────────────
              if (_toasts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _toasts
                        .take(2)
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: BattleGiftAlert(
                                senderName: t.sender,
                                giftName: t.gift,
                                side: t.side,
                                mode: GiftAlertMode.toast,
                              ),
                            ))
                        .toList(),
                  ),
                ),

              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

// ─── Result Banner (streamer) ─────────────────────────────────────────────────

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.battle, required this.l10n});
  final BattleState battle;
  final S l10n;

  @override
  Widget build(BuildContext context) {
    final isDraw = battle.isDraw;
    final winnerName = battle.winnerName ??
        (battle.isLeadingA ? battle.streamerAName : battle.streamerBName);
    final winnerColor =
        battle.isLeadingA ? AppColors.electricPurple : AppColors.hotPink;

    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDraw ? Colors.white24 : winnerColor.withValues(alpha: 0.6),
              ),
            ),
        child: Row(
          children: [
            Icon(
              isDraw ? Icons.handshake_outlined : Icons.workspace_premium,
              color: isDraw ? Colors.white54 : winnerColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.battleEnded,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  Text(
                    isDraw ? l10n.battleDraw : '${l10n.battleWinner}: $winnerName',
                    style: TextStyle(
                      color: isDraw ? Colors.white70 : winnerColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
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

// ─── Internal model ────────────────────────────────────────────────────────────

class _ToastAlert {
  _ToastAlert({required this.sender, required this.gift, required this.side});
  final String sender;
  final String gift;
  final String side;
}
