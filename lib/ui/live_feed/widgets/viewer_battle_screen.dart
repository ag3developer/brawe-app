import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/themes/app_colors.dart';
import '../../../domain/models/battle_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/battle_view_model.dart';
import 'battle_gift_alert.dart';
import '../../live/shared/widgets/overlays/gifts_overlay.dart';
import 'battle_score_bar.dart';
import 'battle_timer.dart';

/// Tela do espectador para batalhas 1v1.
///
/// Layout:
/// - Cabeçalho: timer + barra de vantagem
/// - Conteúdo central: dois vídeos lado a lado (placeholders com avatar)
/// - Alerta de gift via overlay (não fullscreen, mas proeminente)
/// - Rodapé: botão "Enviar presente"
class ViewerBattleScreen extends ConsumerStatefulWidget {
  const ViewerBattleScreen({super.key, required this.battleId});

  final String battleId;

  @override
  ConsumerState<ViewerBattleScreen> createState() =>
      _ViewerBattleScreenState();
}

class _ViewerBattleScreenState extends ConsumerState<ViewerBattleScreen>
    with SingleTickerProviderStateMixin {
  // Gift alert queue
  final List<_GiftAlert> _alerts = [];
  StreamSubscription<void>? _alertSub;

  // Countdown overlay
  int? _countdownValue;
  Timer? _countdownClearTimer;

  // Shake animation for score takeover
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _alertSub?.cancel();
    _countdownClearTimer?.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onNewGift(BattleState s) {
    if (s.lastGiftSender == null || s.lastGiftName == null) return;
    final alert = _GiftAlert(
      sender: s.lastGiftSender!,
      gift: s.lastGiftName!,
      side: s.lastUpdatedSide ?? 'a',
    );
    setState(() => _alerts.add(alert));
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _alerts.remove(alert));
    });
    // Shake when takeover
    if ((s.lastUpdatedSide == 'b' && s.isLeadingB) ||
        (s.lastUpdatedSide == 'a' && s.isLeadingA)) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final asyncState = ref.watch(battleViewModelProvider(widget.battleId));

    // Listen to state changes for gift alerts + countdown
    ref.listen<AsyncValue<BattleState>>(
      battleViewModelProvider(widget.battleId),
      (prev, next) {
        next.whenData((s) {
          // Gift alert
          final prevState = prev?.asData?.value;
          if (prevState?.lastGiftSender != s.lastGiftSender ||
              prevState?.lastGiftName != s.lastGiftName) {
            _onNewGift(s);
          }
          // Countdown phase
          if (s.phase == BattlePhase.countdown) {
            setState(() => _countdownValue = 3);
            _countdownClearTimer?.cancel();
            _countdownClearTimer = Timer(const Duration(seconds: 4), () {
              if (mounted) setState(() => _countdownValue = null);
            });
          }
        });
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: asyncState.when(
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.electricPurple),
              const SizedBox(height: 16),
              Text(l10n.battleLoading,
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(l10n.battleError,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white54),
                label: Text('Voltar',
                    style: const TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
        data: (battle) => _BattleContent(
          battle: battle,
          alerts: _alerts,
          countdownValue: _countdownValue,
          shakeAnim: _shakeAnim,
          onBack: () => context.pop(),
          l10n: l10n,
        ),
      ),
    );
  }
}

// ─── Main Content ─────────────────────────────────────────────────────────────

class _BattleContent extends StatelessWidget {
  const _BattleContent({
    required this.battle,
    required this.alerts,
    required this.countdownValue,
    required this.shakeAnim,
    required this.onBack,
    required this.l10n,
  });

  final BattleState battle;
  final List<_GiftAlert> alerts;
  final int? countdownValue;
  final Animation<double> shakeAnim;
  final VoidCallback onBack;
  final S l10n;

  @override
  Widget build(BuildContext context) {
    // Show result screen when battle is over
    if (battle.isOver) {
      return _BattleResultOverlay(battle: battle, onClose: onBack, l10n: l10n);
    }

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              _Header(battle: battle, onBack: onBack, l10n: l10n),
              Expanded(child: _VideoSection(battle: battle, shakeAnim: shakeAnim, l10n: l10n)),
              _GiftAlertStack(alerts: alerts),
              _Footer(l10n: l10n, battle: battle),
            ],
          ),

          // Countdown overlay
          if (countdownValue != null)
            _CountdownOverlay(count: countdownValue!, l10n: l10n),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.battle, required this.onBack, required this.l10n});

  final BattleState battle;
  final VoidCallback onBack;
  final S l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: onBack,
              ),
              Expanded(
                child: BattleScoreBar(
                  progressA: battle.progressA,
                  scoreA: battle.scoreA,
                  scoreB: battle.scoreB,
                  nameA: battle.streamerAName,
                  nameB: battle.streamerBName,
                  compact: false,
                ),
              ),
              const SizedBox(width: 8),
              BattleTimer(timeRemaining: battle.timeRemaining),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Video Section ─────────────────────────────────────────────────────────────

class _VideoSection extends StatelessWidget {
  const _VideoSection({required this.battle, required this.shakeAnim, required this.l10n});

  final BattleState battle;
  final Animation<double> shakeAnim;
  final S l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StreamerPanel(
            name: battle.streamerAName,
            avatarUrl: battle.streamerAAvatarUrl,
            score: battle.scoreA,
            isLeading: battle.isLeadingA,
            side: 'a',
            shakeAnim: shakeAnim,
            l10n: l10n,
          ),
        ),
        Container(width: 2, color: Colors.black),
        Expanded(
          child: _StreamerPanel(
            name: battle.streamerBName,
            avatarUrl: battle.streamerBAvatarUrl,
            score: battle.scoreB,
            isLeading: battle.isLeadingB,
            side: 'b',
            shakeAnim: shakeAnim,
            l10n: l10n,
          ),
        ),
      ],
    );
  }
}

class _StreamerPanel extends StatelessWidget {
  const _StreamerPanel({
    required this.name,
    required this.avatarUrl,
    required this.score,
    required this.isLeading,
    required this.side,
    required this.shakeAnim,
    required this.l10n,
  });

  final String name;
  final String? avatarUrl;
  final double score;
  final bool isLeading;
  final String side;
  final Animation<double> shakeAnim;
  final S l10n;

  String _formatScore(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final color = side == 'a' ? AppColors.electricPurple : AppColors.hotPink;
    return AnimatedBuilder(
      animation: shakeAnim,
      builder: (_, child) {
        final offset = (side == 'a' && isLeading) || (side == 'b' && isLeading)
            ? shakeAnim.value
            : 0.0;
        return Transform.translate(
          offset: Offset(0, offset * 0.3),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: isLeading
              ? Border.all(color: color.withValues(alpha: 0.6), width: 1.5)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Avatar / video placeholder
            if (avatarUrl != null)
              Image.network(avatarUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity)
            else
              Center(
                child: Icon(Icons.person, size: 64, color: Colors.white24),
              ),

            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                ),
              ),
            ),

            // Name + score at bottom
            Positioned(
              bottom: 12,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: color, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _formatScore(score),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Leading crown
            if (isLeading)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.workspace_premium, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Gift Alert Stack ──────────────────────────────────────────────────────────

class _GiftAlertStack extends StatelessWidget {
  const _GiftAlertStack({required this.alerts});
  final List<_GiftAlert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: alerts
            .take(3)
            .map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: BattleGiftAlert(
                    senderName: a.sender,
                    giftName: a.gift,
                    side: a.side,
                    mode: GiftAlertMode.overlay,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({required this.l10n, required this.battle});
  final S l10n;
  final BattleState battle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () {
            final roomId = battle.roomAId ?? '';
            if (roomId.isEmpty) return;
            GiftsOverlay.show(
              context,
              roomId,
              battle.streamerAId,
              battleId: battle.battleId,
            );
          },
          icon: const Icon(Icons.card_giftcard_rounded, size: 18),
          label: Text(l10n.battleSendGift),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.electricPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

// ─── Countdown Overlay ────────────────────────────────────────────────────────

class _CountdownOverlay extends StatefulWidget {
  const _CountdownOverlay({required this.count, required this.l10n});
  final int count;
  final S l10n;

  @override
  State<_CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<_CountdownOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scale = Tween<double>(begin: 2.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Text(
              '${widget.count}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 96,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Battle Result Overlay ────────────────────────────────────────────────────

class _BattleResultOverlay extends StatelessWidget {
  const _BattleResultOverlay({required this.battle, required this.onClose, required this.l10n});

  final BattleState battle;
  final VoidCallback onClose;
  final S l10n;

  String _formatScore(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final isDraw = battle.isDraw;
    final winnerName = battle.winnerName ??
        (battle.isLeadingA ? battle.streamerAName : battle.streamerBName);
    final winnerColor =
        battle.isLeadingA ? AppColors.electricPurple : AppColors.hotPink;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey[900]!],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.battleResultTitle,
                style: const TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              // Winner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: isDraw ? Colors.white24 : winnerColor, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                  color: (isDraw ? Colors.white : winnerColor).withValues(alpha: 0.08),
                ),
                child: Column(
                  children: [
                    Icon(
                      isDraw ? Icons.handshake_outlined : Icons.workspace_premium,
                      color: isDraw ? Colors.white54 : winnerColor,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDraw ? l10n.battleDraw : l10n.battleWinner,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    if (!isDraw) ...[
                      const SizedBox(height: 4),
                      Text(
                        winnerName,
                        style: TextStyle(
                          color: winnerColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Score row
              Row(
                children: [
                  Expanded(child: _ScoreCard(
                    name: battle.streamerAName,
                    score: battle.scoreA,
                    color: AppColors.electricPurple,
                    isWinner: battle.isLeadingA && !isDraw,
                    l10n: l10n,
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('VS',
                        style: const TextStyle(
                            color: Colors.white38,
                            fontWeight: FontWeight.w900,
                            fontSize: 18)),
                  ),
                  Expanded(child: _ScoreCard(
                    name: battle.streamerBName,
                    score: battle.scoreB,
                    color: AppColors.hotPink,
                    isWinner: battle.isLeadingB && !isDraw,
                    l10n: l10n,
                  )),
                ],
              ),
              const Spacer(),
              // Actions
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 18),
                  label: Text(l10n.battleResultWatchAgain),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.name,
    required this.score,
    required this.color,
    required this.isWinner,
    required this.l10n,
  });

  final String name;
  final double score;
  final Color color;
  final bool isWinner;
  final S l10n;

  String _formatScore(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? color.withValues(alpha: 0.5) : Colors.white12,
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _formatScore(score),
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 20),
          ),
          Text(
            'pts',
            style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── Internal models ──────────────────────────────────────────────────────────

class _GiftAlert {
  _GiftAlert({required this.sender, required this.gift, required this.side});
  final String sender;
  final String gift;
  final String side;
}
