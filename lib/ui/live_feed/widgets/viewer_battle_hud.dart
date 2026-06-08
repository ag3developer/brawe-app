import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/app_colors.dart';
import '../../../domain/models/battle_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/battle_view_model.dart';
import 'battle_gift_alert.dart';
import 'battle_score_bar.dart';
import 'battle_timer.dart';

/// 🥊 HUD de batalha do ESPECTADOR — sobreposto à live (não é tela separada).
///
/// Espelha o padrão do [StreamerBattleHud]: um overlay leve que vive POR CIMA
/// do `LivePlayerScreen`. O vídeo da live continua tocando atrás; chat, rosa,
/// presente e corações continuam vivos (são do `LivePlayerScreen`). Aqui só
/// renderizamos a camada de batalha:
///
/// - **Painel de placar** (topo, abaixo do top bar): os DOIS participantes
///   (avatar + nome + score) com o timer no centro e a barra de vantagem
///   roxo↔rosa embaixo. Score aparece UMA vez (sem a duplicação da tela antiga).
/// - **Gift toasts**: quem mandou o quê, caindo logo abaixo do painel.
/// - **Countdown** 3·2·1 ao iniciar.
/// - **Banner de resultado** compacto ao terminar (a live continua atrás;
///   auto-dismiss em ~8s ou toque no X).
///
/// Gamificação leve (barata): 👑 coroa + glow no líder e haptic na virada
/// de liderança — feedback tátil que deixa a disputa "viva".
///
/// `onClose` é chamado quando o resultado é dispensado → o pai faz
/// `setState(_activeBattleId = null)` e volta pra live normal.
class ViewerBattleHud extends ConsumerStatefulWidget {
  const ViewerBattleHud({
    super.key,
    required this.battleId,
    required this.onClose,
  });

  final String battleId;
  final VoidCallback onClose;

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

  // ── Momentum (🔥 rajada de presentes) ──────────────────────────────────
  // Conta gifts consecutivos do MESMO lado. Quando passa do limiar, mostra
  // o badge "EM CHAMAS xN" do lado quente. Reseta quando o outro lado pontua
  // ou após uma janela de silêncio. 100% derivado de `updated_side` (dado
  // que já chega por gift) — gamificação honesta, sem inventar número.
  static const int _momentumThreshold = 3;
  String? _momentumSide; // lado da rajada atual
  int _momentumCount = 0;
  Timer? _momentumDecay;

  // ── Lead change (💥 "VIROU!") ──────────────────────────────────────────
  // Flash rápido quando a liderança troca de lado. Acompanha o haptic.
  String? _leadFlashSide;
  Timer? _leadFlashClear;

  @override
  void dispose() {
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
          if (s.isOver && _autoCloseTimer == null) {
            HapticFeedback.heavyImpact();
            _autoCloseTimer = Timer(const Duration(seconds: 8), () {
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
            // ── Painel de placar (topo, abaixo do LiveTopBar de 2 linhas) ──
            // Quando termina, o painel some e dá lugar ao banner de resultado.
            if (!battle.isOver)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 84, 12, 0),
                    child: _ScorePanel(battle: battle),
                  ),
                ),
              ),

            // ── Gift toasts (logo abaixo do painel) ──
            if (_toasts.isNotEmpty && !battle.isOver)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 158, 12, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _toasts
                          .take(3)
                          .map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
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
                ),
              ),

            // ── Countdown 3·2·1 (IgnorePointer pra não travar a live) ──
            if (_countdown != null)
              Positioned.fill(
                child: IgnorePointer(child: _Countdown(count: _countdown!)),
              ),

            // ── 🔥 Momentum badge (rajada de presentes de um lado) ──
            // Aparece à esquerda (lado A) ou direita (lado B), abaixo do
            // painel. IgnorePointer: é só feedback, não recebe toque.
            if (_momentumActive && !battle.isOver)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 150, 12, 0),
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
                    padding: const EdgeInsets.fromLTRB(12, 196, 12, 0),
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
                    padding: const EdgeInsets.fromLTRB(12, 84, 12, 0),
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

// ─── Score panel ────────────────────────────────────────────────────────────

/// Painel glass com os dois participantes + timer central + barra de vantagem.
class _ScorePanel extends StatelessWidget {
  const _ScorePanel({required this.battle});
  final BattleState battle;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SideTag(
                      name: battle.streamerAName,
                      avatarUrl: battle.streamerAAvatarUrl,
                      score: battle.scoreA,
                      color: AppColors.electricPurple,
                      leading: battle.isLeadingA,
                      alignEnd: false,
                      // 🏅 MVP REAL: maior doador do lado A (vem do backend).
                      mvp: battle.topGifterA != null,
                      mvpLabel: l10n.battleMvp,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BattleTimer(
                      timeRemaining: battle.timeRemaining,
                      compact: true,
                    ),
                  ),
                  Expanded(
                    child: _SideTag(
                      name: battle.streamerBName,
                      avatarUrl: battle.streamerBAvatarUrl,
                      score: battle.scoreB,
                      color: AppColors.hotPink,
                      leading: battle.isLeadingB,
                      alignEnd: true,
                      // 🏅 MVP REAL: maior doador do lado B (vem do backend).
                      mvp: battle.topGifterB != null,
                      mvpLabel: l10n.battleMvp,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Barra de vantagem (compact = só a barra fina, sem labels —
              // os scores já aparecem nos _SideTag, então zero duplicação).
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
    );
  }
}

/// Avatar + nome + score de um lado. 👑 + glow quando está liderando.
/// 🏅 chip de MVP quando há um top-gifter real naquele lado (vem do backend).
class _SideTag extends StatelessWidget {
  const _SideTag({
    required this.name,
    required this.avatarUrl,
    required this.score,
    required this.color,
    required this.leading,
    required this.alignEnd,
    this.mvp = false,
    this.mvpLabel = 'MVP',
  });

  final String name;
  final String? avatarUrl;
  final double score;
  final Color color;
  final bool leading;
  final bool alignEnd;
  final bool mvp;
  final String mvpLabel;

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: leading ? color : Colors.white24,
          width: leading ? 2 : 1,
        ),
        boxShadow: leading
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
            : null,
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.person, size: 18, color: Colors.white54),
              )
            : const Icon(Icons.person, size: 18, color: Colors.white54),
      ),
    );

    final nameRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading && alignEnd) ...[
          const Text('👑', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
        ],
        Flexible(
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (leading && !alignEnd) ...[
          const SizedBox(width: 3),
          const Text('👑', style: TextStyle(fontSize: 11)),
        ],
      ],
    );

    final texts = Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        nameRow,
        const SizedBox(height: 1),
        Text(
          _fmt(score),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
          ),
        ),
        // 🏅 Chip de MVP — premia o maior doador do lado (dado REAL do backend).
        if (mvp) ...[
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: color.withValues(alpha: 0.55)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏅', style: TextStyle(fontSize: 9)),
                const SizedBox(width: 3),
                Text(
                  mvpLabel,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    final children = alignEnd
        ? [Expanded(child: texts), const SizedBox(width: 8), avatar]
        : [avatar, const SizedBox(width: 8), Expanded(child: texts)];

    return Row(mainAxisSize: MainAxisSize.min, children: children);
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

/// Banner compacto de resultado (NÃO é fullscreen — a live continua atrás).
class _ResultBanner extends StatelessWidget {
  const _ResultBanner({
    required this.battle,
    required this.l10n,
    required this.onClose,
  });

  final BattleState battle;
  final S l10n;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isDraw = battle.isDraw;
    final winnerName = battle.winnerName ??
        (battle.isLeadingA ? battle.streamerAName : battle.streamerBName);
    final winnerColor =
        battle.isLeadingA ? AppColors.electricPurple : AppColors.hotPink;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDraw
                  ? Colors.white24
                  : winnerColor.withValues(alpha: 0.6),
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
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      isDraw
                          ? l10n.battleDraw
                          : '${l10n.battleWinner}: $winnerName',
                      style: TextStyle(
                        color: isDraw ? Colors.white70 : winnerColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white70, size: 22),
                onPressed: onClose,
              ),
            ],
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
