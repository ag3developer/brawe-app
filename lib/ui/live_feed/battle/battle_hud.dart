import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/battle_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/battle_view_model.dart';
import 'battle_hud_parts.dart';
import 'battle_layout.dart';
import 'partner_sheet.dart';

/// Altura da barra de vantagem (pontos dentro), colada no topo do vídeo.
const double kBattleStripH = 24;

/// `splitTop` do ESPECTADOR: LiveTopBar (8 + 80) + linha de eventos/metas/
/// ticker (~30), a partir da safe area. A barra de vantagem já fica sobre o
/// topo do vídeo (o vídeo ganha a altura da antiga faixa de placar).
double battleViewerSplitTop(BuildContext context) =>
    MediaQuery.paddingOf(context).top + 70 + 30 + 16;

/// Faixa escura acima do vídeo do criador para o "silenciar" do parceiro.
const double kLinkControlBandH = 32;

/// `splitTop` do CRIADOR: BroadcasterTopBar (~46) + linha de eventos (~30) +
/// faixa de controle ([kLinkControlBandH]) acima do vídeo.
double battleCreatorSplitTop(BuildContext context) =>
    MediaQuery.paddingOf(context).top + 46 + 6 + 30 + 8 + kLinkControlBandH;

/// Layout da batalha para a tela atual (mesma conta do vídeo e do HUD).
BattleLayout battleLayoutOf(BuildContext context, {double? splitTop}) =>
    BattleLayout.compute(
      screen: MediaQuery.sizeOf(context),
      splitTop: splitTop ?? battleViewerSplitTop(context),
      stripH: kBattleStripH,
    );

/// HUD de batalha COMPARTILHADO (espectador e criador).
///
/// Camadas (todas posicionadas pelo [BattleLayout]):
/// - faixa superior: avatar+nome+placar | cronômetro | placar+nome+avatar,
///   com a barra de vantagem logo abaixo (A à esquerda, B à direita);
/// - apoiadores (top 3) sob cada metade, na região do chat;
/// - toasts de presente dentro da metade que recebeu;
/// - contagem 3·2·1 dirigida pelo servidor;
/// - reta final (sem sobrepor o "pegando fogo"), virada de liderança;
/// - tela de resultado completa.
class BattleHudOverlay extends ConsumerStatefulWidget {
  const BattleHudOverlay({
    super.key,
    required this.battleId,
    required this.onClose,
    this.splitTop,
    this.myUserId,
    this.myRoomId,
    this.ownRoomId,
    this.onFlashTap,
    this.onOpenOpponent,
    this.initialCountdown,
    this.halfOverlays,
  });

  final String battleId;
  final VoidCallback onClose;

  /// Y da faixa dividida (ver [battleViewerSplitTop]/[battleCreatorSplitTop]).
  final double? splitTop;

  /// Identificam o criador que está vendo (nulos para espectadores).
  final String? myUserId;
  final String? myRoomId;

  /// Sala em que o espectador está (define o "lado fechado"). Criadores
  /// usam [myRoomId]/[myUserId].
  final String? ownRoomId;

  /// Toque na pílula do desafio relâmpago (espectador abre a sacola).
  final void Function(BattleFlash flash)? onFlashTap;

  /// Toque na metade do adversário → abre a live dele (só espectador).
  final void Function(String roomId, String name)? onOpenOpponent;
  final Map<String, dynamic>? initialCountdown;

  /// Controles sobre as metades (silenciar / áudio), no canto inferior interno.
  final Widget Function(BuildContext, BattleState, BattleLayout)? halfOverlays;

  @override
  ConsumerState<BattleHudOverlay> createState() => _BattleHudOverlayState();
}

class _BattleHudOverlayState extends ConsumerState<BattleHudOverlay> {
  final Set<int> _seenSeq = <int>{};
  String? _lastLeader;
  bool _endHapticDone = false;
  bool _closedForCancel = false;
  Timer? _endTimer;

  // Momentum (rajada de presentes do mesmo lado).
  static const int _momentumThreshold = 3;
  String? _momentumSide;
  int _momentumCount = 0;
  Timer? _momentumDecay;

  String? _leadFlashSide;
  Timer? _leadFlashClear;

  @override
  void initState() {
    super.initState();
    BattleRoomScope.set(widget.battleId, widget.ownRoomId ?? widget.myRoomId);
    final c = widget.initialCountdown;
    if (c != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(battleViewModelProvider(widget.battleId).notifier)
            .handleCountdown(c);
      });
    }
  }

  @override
  void didUpdateWidget(covariant BattleHudOverlay old) {
    super.didUpdateWidget(old);
    if (old.battleId != widget.battleId) {
      _resetTransient();
      BattleRoomScope.set(widget.battleId, widget.ownRoomId ?? widget.myRoomId);
    }
  }

  void _resetTransient() {
    _seenSeq.clear();
    _momentumDecay?.cancel();
    _leadFlashClear?.cancel();
    _momentumSide = null;
    _momentumCount = 0;
    _leadFlashSide = null;
    _lastLeader = null;
    _endHapticDone = false;
    _closedForCancel = false;
    _endTimer?.cancel();
    _endTimer = null;
  }

  @override
  void dispose() {
    _momentumDecay?.cancel();
    _leadFlashClear?.cancel();
    _endTimer?.cancel();
    BattleGiftRegions.clear();
    super.dispose();
  }

  void _onNewGift(BattleGiftEvent g) {
    // Dedupe por `seq` (não por remetente+nome). Os toasts/combos de presente
    // são do GiftAnimationOverlay (ancorado na metade que recebeu); aqui só
    // alimentamos o "pegando fogo".
    if (!_seenSeq.add(g.seq)) return;
    setState(() {
      if (_momentumSide == g.side) {
        _momentumCount++;
      } else {
        _momentumSide = g.side;
        _momentumCount = 1;
      }
    });
    _momentumDecay?.cancel();
    _momentumDecay = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _momentumSide = null;
          _momentumCount = 0;
        });
      }
    });
  }

  String _endedReason(BattleState b, S l10n) {
    final by = b.forfeitBy;
    final name = by == 'a' || by == 'b' ? b.nameOf(by!) : '';
    switch (b.endReason) {
      case 'live_ended':
        return name.isEmpty ? l10n.battleEndedLiveAnon : l10n.battleEndedLive(name);
      case 'rtc_failed':
        return l10n.battleEndedRtc;
      default:
        return name.isEmpty ? l10n.battleEndedLeftAnon : l10n.battleEndedLeft(name);
    }
  }

  String? _ownSideOf(BattleState s) =>
      s.sideOf(userId: widget.myUserId, roomId: widget.myRoomId) ??
      s.sideOf(roomId: widget.ownRoomId);

  Widget _opponentTap(
    BuildContext context,
    BattleState battle,
    BattleLayout layout,
    String ownSide,
  ) {
    final opp = ownSide == 'a' ? 'b' : 'a';
    final roomId = battle.roomIdOf(opp);
    if (roomId == null || roomId.isEmpty) return const SizedBox.shrink();
    final name = battle.nameOf(opp);
    void open() => showPartnerSheet(
      context,
      ref,
      userId: battle.sideOf(roomId: roomId) == null
          ? ''
          : (opp == 'a' ? battle.streamerAId : battle.streamerBId),
      name: name,
      avatarUrl: battle.avatarOf(opp),
      roomId: roomId,
      onViewLive: widget.onOpenOpponent == null
          ? null
          : () => widget.onOpenOpponent!(roomId, name),
    );
    // Toque na metade do adversário abre a gaveta (sem nada desenhado por
    // cima do vídeo). A área termina 48 px acima da base: canto livre para o
    // alto-falante do dual_hls.
    final h = layout.half(opp);
    return Stack(
      children: [
        Positioned.fromRect(
          rect: Rect.fromLTRB(h.left, h.top, h.right, h.bottom - 48),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: open,
          ),
        ),
        // Foto redonda do adversário na faixa escura ABAIXO da metade dele.
        Positioned(
          top: layout.chat.top + 2,
          left: opp == 'a' ? h.left + 2 : null,
          right: opp == 'b' ? layout.screen.width - h.right + 2 : null,
          child: PartnerAvatarButton(
            name: name,
            avatarUrl: battle.avatarOf(opp),
            onTap: open,
          ),
        ),
      ],
    );
  }

  void _maybeLeadChange(BattleState s) {
    final leader = s.isLeadingA ? 'a' : (s.isLeadingB ? 'b' : null);
    if (leader != null && _lastLeader != null && leader != _lastLeader) {
      HapticFeedback.mediumImpact();
      setState(() => _leadFlashSide = leader);
      _leadFlashClear?.cancel();
      _leadFlashClear = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) setState(() => _leadFlashSide = null);
      });
    }
    _lastLeader = leader;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final provider = battleViewModelProvider(widget.battleId);
    final async = ref.watch(provider);

    ref.listen<AsyncValue<BattleState>>(provider, (prev, next) {
      final s = next.asData?.value;
      if (s == null) return;
      final g = s.lastGift;
      if (g != null &&
          g.seq != prev?.asData?.value.lastGift?.seq &&
          g.side == _ownSideOf(s)) {
        _onNewGift(g);
      }
      _maybeLeadChange(s);
      if (s.isOver && !_endHapticDone) {
        _endHapticDone = true;
        HapticFeedback.heavyImpact();
        // Selos de fim por ~5 s; depois volta à tela dupla (ou ao solo).
        _endTimer ??= Timer(const Duration(seconds: 5), () {
          if (mounted) widget.onClose();
        });
      }
      if (s.isCancelled && !_closedForCancel) {
        _closedForCancel = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onClose();
        });
      }
    });

    final layout = battleLayoutOf(context, splitTop: widget.splitTop);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) BattleGiftRegions.publish(layout);
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        async.when(
          loading: () => Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: layout.strip.top + 8),
              child: BattleStatusChip(label: l10n.battleLoading),
            ),
          ),
          error: (_, _) => Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: layout.strip.top + 8),
              child: BattleStatusChip(
                label: l10n.battleError,
                actionLabel: l10n.battleClose,
                onAction: widget.onClose,
              ),
            ),
          ),
          data: (battle) => _buildData(context, battle, layout, l10n),
        ),
      ],
    );
  }

  Widget _buildData(
    BuildContext context,
    BattleState battle,
    BattleLayout layout,
    S l10n,
  ) {
    final mySide = battle.sideOf(
      userId: widget.myUserId,
      roomId: widget.myRoomId,
    );
    // Regra do lado fechado: só o lado da PRÓPRIA sala mostra presentes e
    // apoiadores; do adversário, só o placar.
    final ownSide = mySide ?? battle.sideOf(roomId: widget.ownRoomId);

    final over = battle.isOver;
    final winner = battle.winnerSide;
    final noWinner = battle.endedWithoutWinner;
    final mvp = noWinner
        ? null
        : (battle.mvp ?? (ownSide != null ? battle.mvpOf(ownSide) : null));

    final showSeal =
        !over && battle.phase == BattlePhase.active && battle.powerMoment;
    final momentumActive =
        !over &&
        _momentumSide != null &&
        _momentumSide == ownSide &&
        _momentumCount >= _momentumThreshold;
    final topY = layout.split.top + kBattleBarH + 6;

    return Stack(
      children: [
        // ── Barra de vantagem (pontos dentro), colada no topo do vídeo ──
        Positioned.fromRect(
          rect: layout.strip,
          child: BattleAdvantageBar(battle: battle, mySide: mySide),
        ),

        // ── Cronômetro (ou FIM): pílula escura no alto do vídeo ──
        Positioned(
          left: 0,
          right: 0,
          top: layout.split.top + kBattleBarH + 4,
          child: IgnorePointer(
            child: Center(
              child: over
                  ? const BattleEndPill()
                  : BattleTimerOverlay(
                      battle: battle,
                      sealMultiplier: showSeal ? battle.multiplier : null,
                    ),
            ),
          ),
        ),

        // ── Selo de vitórias: canto superior EXTERNO de cada metade ──
        if ((battle.winStreakA ?? 0) > 0)
          Positioned(
            left: layout.halfA.left + 6,
            top: topY,
            child: IgnorePointer(
              child: BattleStreakBadge(side: 'a', streak: battle.winStreakA!),
            ),
          ),
        if ((battle.winStreakB ?? 0) > 0)
          Positioned(
            right: layout.screen.width - layout.halfB.right + 6,
            top: topY,
            child: IgnorePointer(
              child: BattleStreakBadge(side: 'b', streak: battle.winStreakB!),
            ),
          ),

        // ── Fileira logo ABAIXO do vídeo: 3 MVPs do PRÓPRIO lado (embaixo da
        // metade dele) e, no meio, o desafio relâmpago. ──
        if (ownSide == 'a' && battle.topGiftersA.isNotEmpty)
          Positioned(
            left: layout.halfA.left + 6,
            top: layout.chat.top + 6,
            child: IgnorePointer(
              child: BattleSupporters(
                side: 'a',
                gifters: battle.topGiftersA,
                crownFirst: over && !noWinner,
              ),
            ),
          ),
        if (ownSide == 'b' && battle.topGiftersB.isNotEmpty)
          Positioned(
            right: layout.screen.width - layout.halfB.right + 6,
            top: layout.chat.top + 6,
            child: IgnorePointer(
              child: BattleSupporters(
                side: 'b',
                gifters: battle.topGiftersB,
                crownFirst: over && !noWinner,
              ),
            ),
          ),
        if (over && mvp != null)
          Positioned(
            left: 110,
            right: 110,
            top: layout.chat.top + 8,
            child: IgnorePointer(
              child: Center(child: BattleMvpPill(mvp: mvp)),
            ),
          ),
        if (!over && battle.countdown != null)
          Positioned(
            left: 110,
            right: 110,
            top: layout.chat.top + 8,
            child: IgnorePointer(
              child: Center(child: BattleInfoText(text: l10n.battleRuleHint)),
            ),
          ),
        if (!over && battle.flash != null && battle.phase == BattlePhase.active)
          Positioned(
            left: 110,
            right: 110,
            top: layout.chat.top + 8,
            child: Center(
              child: BattleFlashPill(
                key: ValueKey('flash-${battle.flash!.phase}'),
                flash: battle.flash!,
                onTap: widget.onFlashTap == null
                    ? null
                    : () => widget.onFlashTap!(battle.flash!),
              ),
            ),
          ),

        // ── Metade do adversário: toque abre a live dele ──
        if (ownSide != null)
          Positioned.fill(
            child: _opponentTap(context, battle, layout, ownSide),
          ),

        // ── Pegando fogo: abaixo do cronômetro, lado interno da metade quente ──
        if (momentumActive)
          Positioned(
            left: _momentumSide == 'b' ? layout.halfB.left + 6 : null,
            right: _momentumSide == 'a'
                ? layout.screen.width - layout.halfA.right + 6
                : null,
            top: layout.split.top + kBattleBarH + 38,
            child: IgnorePointer(
              child: BattleMomentumBadge(
                key: ValueKey('mom-$_momentumSide'),
                count: _momentumCount,
                side: _momentumSide!,
              ),
            ),
          ),

        // ── Controles sobre as metades (silenciar / áudio) ──
        if (widget.halfOverlays != null)
          widget.halfOverlays!(context, battle, layout),

        // ── Fim: selos sobre o vídeo ──
        if (over) ...[
          if (noWinner)
            Positioned.fromRect(
              rect: layout.split,
              child: IgnorePointer(
                child: BattleEndedSeal(reason: _endedReason(battle, l10n)),
              ),
            )
          else if (winner == null)
            Positioned.fromRect(
              rect: layout.split,
              child: const IgnorePointer(child: BattleDrawSeal()),
            )
          else
            for (final side in const ['a', 'b'])
              Positioned.fromRect(
                rect: layout.half(side),
                child: IgnorePointer(child: BattleEndSeal(win: winner == side)),
              ),
        ],

        // ── Virada de liderança (pílula curta sobre o divisor, no topo) ──
        if (!over && _leadFlashSide != null)
          Positioned(
            left: 0,
            right: 0,
            top: layout.split.top + kBattleBarH + 70,
            child: IgnorePointer(child: BattleLeadFlash(side: _leadFlashSide!)),
          ),

        // ── Contagem 3·2·1 ──
        if (battle.countdown != null)
          Positioned.fill(
            child: BattleCountdownOverlay(
              count: battle.countdown!,
              battle: battle,
            ),
          ),
      ],
    );
  }
}
