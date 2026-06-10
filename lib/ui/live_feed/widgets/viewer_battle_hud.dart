import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/socket_service.dart';
import '../../../domain/models/battle_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/battle_view_model.dart';
import 'battle_gift_alert.dart';
import 'battle_score_bar.dart';
import 'battle_timer.dart';

// ─── Layout constants ─────────────────────────────────────────────────────
// Faixas verticais do HUD, medidas a partir do SafeArea top do
// `LivePlayerScreen`. Manter centralizado aqui evita "magic numbers" e
// dependência implícita de mudanças no `LiveTopBar`.
//
// `LiveTopBar` (lib/ui/live/shared/widgets/hud/live_top_bar.dart) tem
// 2 linhas:
//   • Linha 1 (close + identidade + viewers + ⋯) ≈ 36px
//   • Gap                                          8px
//   • Linha 2 (pílulas LIVE · views · likes)      ≈ 28px
//   • Padding superior do container                8px
//   ───────────────────────────────────────────────────
//   Total                                         ≈ 80px (abaixo do SafeArea)
//
// O painel de battle ENCOSTA na borda inferior do top bar (com 8px de
// respiro) — igual ao TikTok PK, onde o placar fica colado ao header.
const double _kLiveTopBarHeight = 80;
const double _kPanelTopOffset = _kLiveTopBarHeight + 8; // 88
// Altura estimada do `_ScorePanel`: padding (8+8) + nameRow (~16) + gap (2)
// + scoreText (~18) + gap (8) + BattleScoreBar compact (~12) ≈ 72.
// Se mudar o painel, ajustar aqui.
const double _kPanelHeight = 72;
const double _kTimerTopOffset = _kPanelTopOffset + _kPanelHeight + 6; // 166
const double _kTimerHeight = 32; // BattleTimer não-compact (fontSize 18 + pad)
// Power Moment vem LOGO abaixo do timer central (banner de urgência —
// precisa estar visível). Os toasts vêm depois, pra não roubar atenção.
const double _kPowerMomentTopOffset = _kTimerTopOffset + _kTimerHeight + 8; // 206
const double _kPowerMomentHeight = 50;
const double _kToastsTopOffset =
    _kPowerMomentTopOffset + _kPowerMomentHeight + 8; // 264
// Momentum: empurrado pra abaixo do timer central pra não competir visualmente
// (antes ficava na mesma faixa — riscava na borda em telas estreitas).
const double _kMomentumTopOffset = _kTimerTopOffset + _kTimerHeight + 8; // 206

/// 🥊 HUD de batalha do ESPECTADOR — sobreposto à live (não é tela separada).
///
/// Espelha o padrão do [StreamerBattleHud]: um overlay leve que vive POR CIMA
/// do `LivePlayerScreen`. O vídeo da live continua tocando atrás; chat, rosa,
/// presente e corações continuam vivos (são do `LivePlayerScreen`). Aqui só
/// renderizamos a camada de batalha:
///
/// - **Painel de placar** (topo, abaixo do top bar): os DOIS participantes
///   com o timer no centro e a barra de vantagem roxo↔rosa embaixo.
/// - **Gift toasts**: quem mandou o quê, caindo logo abaixo do painel.
/// - **Countdown** 3·2·1 ao iniciar.
/// - **Banner de resultado** com score final ao terminar (auto-dismiss 12s).
///
/// `onClose` → pai faz `_activeBattleId = null` e volta pra live normal.
/// `onRematch(newBattleId)` → pai troca `_activeBattleId` pela revanche.
class ViewerBattleHud extends ConsumerStatefulWidget {
  const ViewerBattleHud({
    super.key,
    required this.battleId,
    required this.roomId,
    required this.onClose,
    this.onRematch,
  });

  final String battleId;
  /// ID da sala que o viewer está assistindo — usado para detectar revanche.
  final String roomId;
  final VoidCallback onClose;
  /// Chamado quando uma revanche começa: `newBattleId` é o novo ID.
  final void Function(String newBattleId)? onRematch;

  @override
  ConsumerState<ViewerBattleHud> createState() => _ViewerBattleHudState();
}

class _ViewerBattleHudState extends ConsumerState<ViewerBattleHud> {
  final List<_Toast> _toasts = [];
  int? _countdown;
  Timer? _countdownClear;
  Timer? _autoCloseTimer;

  /// 'a' | 'b' | null — usado pra disparar haptic só na MUDANÇA de líder.
  String? _lastLeader;

  // ── Momentum ────────────────────────────────────────────────────────────
  static const int _momentumThreshold = 3;
  String? _momentumSide;
  int _momentumCount = 0;
  Timer? _momentumDecay;

  // ── Lead change ─────────────────────────────────────────────────────────
  String? _leadFlashSide;
  Timer? _leadFlashClear;

  @override
  void initState() {
    super.initState();
    // Ouvir nova batalha (revanche) que envolva esta sala.
    // Quando os streamers aceitam revanche, `connect:battle:started` chega
    // com `room_a_id` ou `room_b_id` = widget.roomId e um novo `battle_id`.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final socket = ref.read(socketServiceProvider);
      socket.on(AppConstants.eventBattleStarted, _onRematchStarted);
    });
  }

  void _onRematchStarted(dynamic raw) {
    if (!mounted) return;
    try {
      Map<String, dynamic> data;
      if (raw is Map<String, dynamic>) {
        data = raw;
      } else if (raw is String) {
        data = Map<String, dynamic>.from(
            const JsonDecoder().convert(raw) as Map);
      } else {
        return;
      }
      final newBattleId = data['battle_id'] as String?;
      if (newBattleId == null || newBattleId == widget.battleId) return;
      final roomA = data['room_a_id'] as String? ?? '';
      final roomB = data['room_b_id'] as String? ?? '';
      // Só nos importa se esta sala está na nova batalha
      if (roomA != widget.roomId && roomB != widget.roomId) return;
      // Cancelar auto-close do resultado anterior
      _autoCloseTimer?.cancel();
      _autoCloseTimer = null;
      widget.onRematch?.call(newBattleId);
    } catch (_) {}
  }

  @override
  void dispose() {
    // Remover handler de revanche — evita processar evento após dispose
    try {
      final socket = ref.read(socketServiceProvider);
      socket.off(AppConstants.eventBattleStarted);
    } catch (_) {}
    _countdownClear?.cancel();
    _autoCloseTimer?.cancel();
    _momentumDecay?.cancel();
    _leadFlashClear?.cancel();
    super.dispose();
  }

  void _onNewGift(BattleState s) {
    if (s.lastGiftSender == null || s.lastGiftName == null) return;
    final side = s.lastUpdatedSide ?? 'a';
    final t = _Toast(
      sender: s.lastGiftSender!,
      gift: s.lastGiftName!,
      side: side,
    );
    setState(() {
      _toasts.add(t);
      // Momentum: mesmo lado acumula; lado diferente reinicia.
      if (_momentumSide == side) {
        _momentumCount++;
      } else {
        _momentumSide = side;
        _momentumCount = 1;
      }
    });
    // Decay: se ninguém pontua nesse lado em 6s, esfria a rajada.
    _momentumDecay?.cancel();
    _momentumDecay = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _momentumSide = null;
          _momentumCount = 0;
        });
      }
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _toasts.remove(t));
    });
  }

  /// Vibra (médio) + flash "VIROU!" quando a liderança troca de lado — só na
  /// virada, nunca na entrada (1º update tem `_lastLeader == null`).
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

  /// `true` quando há rajada quente o suficiente pra exibir o badge.
  bool get _momentumActive =>
      _momentumSide != null && _momentumCount >= _momentumThreshold;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final async = ref.watch(battleViewModelProvider(widget.battleId));

    ref.listen<AsyncValue<BattleState>>(
      battleViewModelProvider(widget.battleId),
      (prev, next) {
        next.whenData((s) {
          final prevS = prev?.asData?.value;
          // Novo gift → toast
          if (prevS?.lastGiftSender != s.lastGiftSender ||
              prevS?.lastGiftName != s.lastGiftName) {
            _onNewGift(s);
          }
          // Countdown phase → 3·2·1
          if (s.phase == BattlePhase.countdown && _countdown == null) {
            setState(() => _countdown = 3);
            _countdownClear?.cancel();
            _countdownClear = Timer(const Duration(seconds: 4), () {
              if (mounted) setState(() => _countdown = null);
            });
          }
          _maybeLeadChange(s);
          // Terminou → agenda auto-close (uma vez só).
          // Se vier uma revanche (novo battleId), o pai vai trocar o widget
          // inteiro — este timer cancela no dispose. Não é problema.
          if (s.isOver && _autoCloseTimer == null) {
            HapticFeedback.heavyImpact();
            // Auto-close de 12s para dar tempo de ver o resultado
            _autoCloseTimer = Timer(const Duration(seconds: 12), () {
              if (mounted) widget.onClose();
            });
          }
        });
      },
    );

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (battle) {
        return Stack(
          children: [
            // ── Barra de vantagem colada no topo do vídeo (TikTok PK style) ──
            // Apenas a barra roxo↔rosa de fora a fora — sem painel escuro,
            // sem nomes, sem scores no HUD. Os nomes já aparecem diretamente
            // sobre o vídeo de cada streamer (live_top_bar / streamer_identity).
            if (!battle.isOver)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.only(top: _kPanelTopOffset),
                    child: BattleScoreBar(
                      progressA: battle.progressA,
                      scoreA: battle.scoreA,
                      scoreB: battle.scoreB,
                      compact: true,
                    ),
                  ),
                ),
              ),

            // ── ⏱️ Timer central flutuante (sobre a divisória do split-screen) ──
            // Centralizado horizontalmente — assina visualmente o "centro" da
            // batalha (Bigo/TikTok style). Posicionado logo abaixo do
            // `_ScorePanel`. Pulsa vermelho nos últimos 30s (lógica do próprio
            // `BattleTimer`).
            if (!battle.isOver)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0, _kTimerTopOffset, 0, 0),
                    child: IgnorePointer(
                      child: Center(
                        child: BattleTimer(
                          timeRemaining: battle.timeRemaining,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Gift toasts (Bigo/TikTok PK style) ──
            // Estratégia: gift pro lado A → toast renderiza no lado B (e
            // vice-versa). Cria a sensação "o presente está passando do
            // público para o destinatário" + não cobre a cara do streamer
            // que recebeu. IgnorePointer pra não bloquear toque no vídeo.
            if (_toasts.isNotEmpty && !battle.isOver)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0, _kToastsTopOffset, 0, 0),
                    child: IgnorePointer(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Coluna esquerda: toasts dos gifts que foram pro
                          // streamer B (B está no vídeo direito → toast
                          // aparece na esquerda, "voando" em direção a ele).
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _toasts
                                  .where((t) => t.side == 'b')
                                  .take(2)
                                  .map((t) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 4),
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
                          // Coluna direita: gifts pro lado A.
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: _toasts
                                  .where((t) => t.side == 'a')
                                  .take(2)
                                  .map((t) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 4),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── Countdown 3·2·1 (IgnorePointer pra não travar a live) ──
            if (_countdown != null)
              Positioned.fill(
                child: IgnorePointer(child: _Countdown(count: _countdown!)),
              ),

            // ── 🔥 Momentum badge (rajada de presentes de um lado) ──
            // Aparece à esquerda (lado A) ou direita (lado B), na mesma faixa
            // vertical do timer central (mas nas bordas). IgnorePointer: é só
            // feedback, não recebe toque.
            if (_momentumActive && !battle.isOver)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        12, _kMomentumTopOffset, 12, 0),
                    child: IgnorePointer(
                      child: Align(
                        alignment: _momentumSide == 'a'
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: _MomentumBadge(
                          count: _momentumCount,
                          side: _momentumSide!,
                          label: l10n.battleMomentum,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── ⏱️ Reta final / 🔥 Power Moment (2x REAL do backend) ──
            // Banner pulsante quando o backend sinaliza `powerMoment` (últimos
            // 30s). Aqui o "2x" não é enfeite: o backend multiplica o score de
            // verdade. Fallback: se o socket ainda não mandou a flag mas o
            // timer local já está ≤30s, mostramos mesmo assim (UX consistente).
            if (!battle.isOver &&
                (battle.powerMoment ||
                    (battle.timeRemaining.inSeconds > 0 &&
                        battle.timeRemaining.inSeconds <= 30)))
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        12, _kPowerMomentTopOffset, 12, 0),
                    child: IgnorePointer(
                      child: Center(
                        child: _FinalStretchBanner(
                          title: l10n.battleFinalStretch,
                          subtitle: l10n.battleSendToWin,
                          // Mostra o selo "2x" só quando o bônus está REALMENTE
                          // ativo (backend confirmou via powerMoment).
                          multiplier: battle.powerMoment ? battle.multiplier : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── 💥 Flash "VIROU!" na virada de liderança ──
            if (_leadFlashSide != null && !battle.isOver)
              Positioned.fill(
                child: IgnorePointer(
                  child: _LeadChangeFlash(
                    side: _leadFlashSide!,
                    label: l10n.battleLeadChange,
                  ),
                ),
              ),

            // ── Banner de resultado (compacto, topo — live continua atrás) ──
            if (battle.isOver)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        12, _kPanelTopOffset, 12, 0),
                    child: _ResultBanner(
                      battle: battle,
                      l10n: l10n,
                      onClose: widget.onClose,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Countdown ──────────────────────────────────────────────────────────────

class _Countdown extends StatefulWidget {
  const _Countdown({required this.count});
  final int count;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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
    return Container(
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
    );
  }
}

// ─── Result banner ──────────────────────────────────────────────────────────

/// Banner de resultado do ESPECTADOR (a live continua atrás).
/// Mostra vencedor + score final + botão fechar. Auto-fecha em 12s.
class _ResultBanner extends StatefulWidget {
  const _ResultBanner({
    required this.battle,
    required this.l10n,
    required this.onClose,
  });

  final BattleState battle;
  final S l10n;
  final VoidCallback onClose;

  @override
  State<_ResultBanner> createState() => _ResultBannerState();
}

class _ResultBannerState extends State<_ResultBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    final battle = widget.battle;
    final isDraw = battle.isDraw;
    final winnerName = battle.winnerName ??
        (battle.isLeadingA ? battle.streamerAName : battle.streamerBName);
    final winnerColor =
        battle.isLeadingA ? AppColors.electricPurple : AppColors.hotPink;
    final aColor = AppColors.electricPurple;
    final bColor = AppColors.hotPink;

    return ScaleTransition(
      scale: _scale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDraw
                    ? Colors.white24
                    : winnerColor.withValues(alpha: 0.7),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Título ──
                Row(
                  children: [
                    Text(
                      isDraw ? '🤝' : '🏆',
                      style: const TextStyle(fontSize: 26),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.l10n.battleEnded,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11),
                          ),
                          Text(
                            isDraw
                                ? widget.l10n.battleDraw
                                : '${widget.l10n.battleWinner}: $winnerName',
                            style: TextStyle(
                              color: isDraw ? Colors.white70 : winnerColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white54, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── Score final ──
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            battle.streamerAName,
                            style: TextStyle(
                              color: aColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fmt(battle.scoreA),
                            style: TextStyle(
                              color: isDraw ? Colors.white70 : (battle.isLeadingA ? aColor : Colors.white38),
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            '${battle.giftsCountA} presentes',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white12,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            battle.streamerBName,
                            style: TextStyle(
                              color: bColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fmt(battle.scoreB),
                            style: TextStyle(
                              color: isDraw ? Colors.white70 : (battle.isLeadingB ? bColor : Colors.white38),
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            '${battle.giftsCountB} presentes',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── Botão fechar ──
                OutlinedButton.icon(
                  onPressed: widget.onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Fechar', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Momentum badge ─────────────────────────────────────────────────────────

/// 🔥 Badge de rajada: "EM CHAMAS xN". Pulsa suave (escala) pra chamar
/// atenção. Cor segue o lado quente (roxo A / rosa B).
class _MomentumBadge extends StatefulWidget {
  const _MomentumBadge({
    required this.count,
    required this.side,
    required this.label,
  });
  final int count;
  final String side;
  final String label;

  @override
  State<_MomentumBadge> createState() => _MomentumBadgeState();
}

class _MomentumBadgeState extends State<_MomentumBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.side == 'a' ? AppColors.electricPurple : AppColors.hotPink;
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.95),
              color.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              '${widget.label} x${widget.count}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 0.4,
                shadows: [Shadow(blurRadius: 3, color: Colors.black54)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Final stretch banner ───────────────────────────────────────────────────

/// ⏱️ Banner pulsante de reta final (últimos 30s). Cria urgência/escassez
/// pra puxar o pico de presentes no fim da batalha. Quando `multiplier` é
/// fornecido (Power Moment ativo), exibe o selo "Nx" — bônus REAL aplicado
/// pelo backend no score.
class _FinalStretchBanner extends StatefulWidget {
  const _FinalStretchBanner({
    required this.title,
    required this.subtitle,
    this.multiplier,
  });
  final String title;
  final String subtitle;
  final double? multiplier;

  @override
  State<_FinalStretchBanner> createState() => _FinalStretchBannerState();
}

class _FinalStretchBannerState extends State<_FinalStretchBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.35, end: 0.85)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mult = widget.multiplier;
    // Formata "2x" sem casa decimal quando inteiro (2.0 → "2x").
    final multLabel = mult == null
        ? null
        : (mult % 1 == 0 ? '${mult.toInt()}x' : '${mult.toStringAsFixed(1)}x');
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.mutedRed, AppColors.hotPink],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.mutedRed.withValues(alpha: _glow.value),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⏱️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.6,
                      shadows: [Shadow(blurRadius: 3, color: Colors.black54)],
                    ),
                  ),
                  // 🔥 Selo "2x" — só aparece quando o bônus está ativo.
                  if (multLabel != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🔥 $multLabel',
                        style: const TextStyle(
                          color: AppColors.mutedRed,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 1),
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w600,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Lead change flash ──────────────────────────────────────────────────────

/// 💥 Flash rápido "VIROU!" quando a liderança troca de lado. Entra com
/// scale+fade e some sozinho (o pai limpa `_leadFlashSide` em ~1.4s).
class _LeadChangeFlash extends StatefulWidget {
  const _LeadChangeFlash({required this.side, required this.label});
  final String side;
  final String label;

  @override
  State<_LeadChangeFlash> createState() => _LeadChangeFlashState();
}

class _LeadChangeFlashState extends State<_LeadChangeFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(1.1), weight: 70),
    ]).animate(_ctrl);
    _fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 18),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 52),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.side == 'a' ? AppColors.electricPurple : AppColors.hotPink;
    return Center(
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 22),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💥', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 1,
                    shadows: const [Shadow(blurRadius: 6, color: Colors.black)],
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

// ─── Internal model ─────────────────────────────────────────────────────────

class _Toast {
  _Toast({required this.sender, required this.gift, required this.side});
  final String sender;
  final String gift;
  final String side;
}
