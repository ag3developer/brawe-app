import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/battle_assets_repository.dart';
import '../../../domain/models/battle_assets.dart';
import '../../../domain/models/battle_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/battle_view_model.dart';
import 'battle_bar_effects.dart';
import 'battle_hud_parts.dart';
import 'battle_layout.dart';
import 'battle_media.dart';
import 'battle_narrator.dart';
import 'battle_narrator_view.dart';
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
BattleLayout battleLayoutOf(
  BuildContext context, {
  double? splitTop,
  String ownSide = 'a',
}) =>
    BattleLayout.compute(
      ownSide: ownSide,
      screen: MediaQuery.sizeOf(context),
      splitTop: splitTop ?? battleViewerSplitTop(context),
      stripH: kBattleStripH,
    );

/// HUD de batalha COMPARTILHADO (espectador e criador).
///
/// Camadas (todas posicionadas pelo [BattleLayout]):
/// - faixa superior: avatar+nome+placar | cronômetro | placar+nome+avatar,
///   com a barra de vantagem logo abaixo (dono à esquerda, parceiro à direita);
/// - faixa preta do jogo abaixo do vídeo: apoiadores (top 3) / desafio
///   relâmpago / MVP + a linha do NARRADOR (uma frase por vez);
/// - toasts de presente dentro da metade que recebeu;
/// - contagem 3·2·1 só como número no palco (sem escurecer nada);
/// - efeitos do manifesto sobre a barra e momentos (Lottie/imagem/som);
/// - fim: coroa + confete / lado perdedor escurecido (sem texto no vídeo).
///
/// Zonas (§19.1): NENHUMA frase sobre o vídeo — "VIROU!", "PEGANDO FOGO",
/// VITÓRIA/DERROTA, avisos de silenciar... vão para o narrador.
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
  bool _endNarrated = false;
  bool _final10Fired = false;
  Timer? _endTimer;
  late final BattleNarratorController _narrator;

  // Momentum (rajada de presentes do mesmo lado).
  static const int _momentumThreshold = 3;
  String? _momentumSide;
  int _momentumCount = 0;
  DateTime? _momentumSince;
  Timer? _momentumDecay;

  // Gatilhos dos efeitos da barra.
  String? _leadSide;
  DateTime? _leadSince;
  Timer? _leadClear;
  DateTime? _multSince;
  DateTime? _finalSince;
  final DateTime _hudSince = DateTime.now();

  // Rajadas curtas de mídia do manifesto (costura da barra / linha do narrador).
  _Burst? _seamBurst;
  _Burst? _narratorBurst;
  int _burstSeq = 0;

  static const _stageKeys = {'countdown', 'victory', 'defeat', 'draw', 'ended'};
  static const _seamKeys = {'lead_change', 'momentum'};

  @override
  void initState() {
    super.initState();
    _narrator = ref.read(battleNarratorProvider)
      ..clear()
      ..active = true;
    BattleRoomScope.set(widget.battleId, widget.ownRoomId ?? widget.myRoomId);
    // Manifesto de mídia: baixa/atualiza durante a contagem (nunca bloqueia).
    unawaited(ref.read(battleAssetsProvider.notifier).ensure(null));
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
    _leadClear?.cancel();
    _momentumSide = null;
    _momentumCount = 0;
    _momentumSince = null;
    _leadSide = null;
    _leadSince = null;
    _multSince = null;
    _finalSince = null;
    _seamBurst = null;
    _narratorBurst = null;
    _lastLeader = null;
    _endHapticDone = false;
    _closedForCancel = false;
    _endNarrated = false;
    _final10Fired = false;
    _endTimer?.cancel();
    _endTimer = null;
    _narrator.clear();
  }

  @override
  void dispose() {
    _momentumDecay?.cancel();
    _leadClear?.cancel();
    _endTimer?.cancel();
    _narrator
      ..active = false
      ..clear();
    BattleGiftRegions.clear();
    super.dispose();
  }

  // ── Manifesto: narrador, sons e momentos ────────────────────────────────

  BattleManifest? get _manifest => ref.read(battleAssetsProvider);

  void _say(String key, [Map<String, String> vars = const {}, String? suffix]) {
    final line = resolveNarratorLine(
      manifest: _manifest,
      l10n: S.of(context),
      lang: Localizations.localeOf(context).languageCode,
      key: key,
      vars: vars,
    );
    if (line == null) return;
    _narrator.push(
      suffix == null || suffix.isEmpty
          ? line
          : NarratorLine(
              key: line.key,
              text: '${line.text} · $suffix',
              priority: line.priority,
              ttl: line.ttl,
              style: line.style,
            ),
    );
  }

  /// Som do momento (se o servidor mandou e o aparelho não está mudo).
  void _sound(String key) => BattleMedia.play(_manifest?.moment(key)?.soundUrl);

  /// Momento: som + (fora do palco) uma rajada curta na costura da barra ou
  /// ao lado da frase do narrador. Palco (contagem/fim) é desenhado no build.
  void _moment(String key) {
    final m = _manifest?.moment(key);
    if (m == null) return;
    BattleMedia.play(m.soundUrl);
    if (_stageKeys.contains(key) || !BattleMedia.momentReady(m)) return;
    final burst = _Burst(++_burstSeq, m);
    setState(() {
      if (_seamKeys.contains(key)) {
        _seamBurst = burst;
      } else {
        _narratorBurst = burst;
      }
    });
  }

  void _endBurst(_Burst b) {
    if (!mounted) return;
    setState(() {
      if (_seamBurst?.id == b.id) _seamBurst = null;
      if (_narratorBurst?.id == b.id) _narratorBurst = null;
    });
  }

  /// Desenho do manifesto para o PALCO (contagem/vitória/derrota/empate/fim).
  Widget? _stageMedia(String key) {
    final m = _manifest?.moment(key);
    if (!BattleMedia.momentReady(m)) return null;
    return BattleMediaView(
      key: ValueKey('stage-$key'),
      lottieUrl: m!.lottieUrl,
      imageUrl: m.imageUrl,
      loop: m.loop,
    );
  }

  static String _mult(double m) =>
      m % 1 == 0 ? '${m.toInt()}X' : '${m.toStringAsFixed(1)}X';

  static String _left(DateTime? end) {
    if (end == null) return '';
    final s = end.difference(DateTime.now()).inSeconds.clamp(0, 5999);
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  // ── Eventos ─────────────────────────────────────────────────────────────

  void _onNewGift(BattleGiftEvent g) {
    // Dedupe por `seq` (não por remetente+nome). Os toasts/combos de presente
    // são do GiftAnimationOverlay (ancorado na metade que recebeu); aqui só
    // alimentamos o "pegando fogo".
    if (!_seenSeq.add(g.seq)) return;
    var fired = false;
    setState(() {
      if (_momentumSide == g.side) {
        _momentumCount++;
      } else {
        _momentumSide = g.side;
        _momentumCount = 1;
        _momentumSince = null;
      }
      if (_momentumCount >= _momentumThreshold && _momentumSince == null) {
        _momentumSince = DateTime.now();
        fired = true;
      }
    });
    if (fired) {
      HapticFeedback.selectionClick();
      final cur = ref.read(battleViewModelProvider(widget.battleId)).asData?.value;
      _say('momentum', {'time': cur?.nameOf(g.side) ?? ''});
      _moment('momentum');
    }
    _momentumDecay?.cancel();
    _momentumDecay = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _momentumSide = null;
          _momentumCount = 0;
          _momentumSince = null;
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
          left: layout.isLeft(opp) ? h.left + 2 : null,
          right: !layout.isLeft(opp) ? layout.screen.width - h.right + 2 : null,
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
    if (leader != null &&
        _lastLeader != null &&
        leader != _lastLeader &&
        s.phase == BattlePhase.active) {
      HapticFeedback.mediumImpact();
      setState(() {
        _leadSide = leader;
        _leadSince = DateTime.now();
      });
      _leadClear?.cancel();
      _leadClear = Timer(const Duration(milliseconds: 3000), () {
        if (mounted) setState(() => _leadSide = null);
      });
      final own = _ownSideOf(s);
      _say(own != null && own == leader ? 'lead_change_own' : 'lead_change_other', {
        'time': s.nameOf(leader),
      });
      _moment('lead_change');
    }
    _lastLeader = leader;
  }

  void _onBattle(BattleState? prev, BattleState s) {
    final g = s.lastGift;
    if (g != null &&
        g.seq != prev?.lastGift?.seq &&
        g.side == _ownSideOf(s)) {
      _onNewGift(g);
    }
    if (prev == null || s.assetsVersion != prev.assetsVersion) {
      unawaited(
        ref.read(battleAssetsProvider.notifier).ensure(s.assetsVersion),
      );
    }
    // Contagem: som a cada número.
    if (s.countdown != null && s.countdown != prev?.countdown) {
      _sound('countdown');
    }
    // Início.
    if (prev != null &&
        prev.phase != BattlePhase.active &&
        s.phase == BattlePhase.active) {
      _say('start');
      _moment('start');
    }
    _maybeLeadChange(s);

    // Reta final (2X) e multiplicadores ativos.
    final active = s.phase == BattlePhase.active && !s.isOver;
    final finalNow = active && s.powerMoment;
    if (finalNow && _finalSince == null) {
      _finalSince = DateTime.now();
      _moment('final_window');
    } else if (!finalNow && _finalSince != null) {
      _finalSince = null;
    }
    final multNow = active && (s.powerMoment || (s.flash?.isBoost ?? false));
    if (multNow && _multSince == null) {
      _multSince = DateTime.now();
    } else if (!multNow && _multSince != null) {
      _multSince = null;
    }
    // Últimos 10 s.
    final secs = s.timeRemaining.inSeconds;
    if (active && secs > 0 && secs <= BattleTimerOverlay.urgentSeconds) {
      if (!_final10Fired) {
        _final10Fired = true;
        final m = s.multiplier > 1
            ? s.multiplier
            : (s.flash?.isBoost ?? false ? s.flash!.multiplier : 2.0);
        _say('final_10s', {'mult': _mult(m)});
      }
    } else if (secs > BattleTimerOverlay.urgentSeconds) {
      _final10Fired = false;
    }
    // Desafio relâmpago.
    final f = s.flash;
    if (active && f != null && f.phase != prev?.flash?.phase) {
      if (f.phase == 'challenge') {
        _say('flash_start', {
          'pontos': '${f.target}',
          'nome': f.giftName,
          'tempo': _left(f.challengeEndsAt),
        });
        _moment('flash_start');
      } else if (f.isBoost && prev?.flash?.phase == 'challenge') {
        _say('flash_done', {
          'mult': _mult(f.multiplier),
          'tempo': _left(f.boostEndsAt),
        });
        _moment('flash_done');
      }
    }
    // Silenciar (criador): as frases saíram do vídeo e vão para o narrador.
    final mine = s.sideOf(userId: widget.myUserId, roomId: widget.myRoomId);
    if (mine != null && prev != null && s.isComposite) {
      final opp = mine == 'a' ? 'b' : 'a';
      if (!prev.mutedOf(mine) && s.mutedOf(mine)) {
        _say('muted_by_you', {'nome': s.nameOf(opp)});
      }
      if (!prev.mutedOf(opp) && s.mutedOf(opp)) {
        _say('muted_you', {'nome': s.nameOf(opp)});
      }
    }

    if (s.isOver && !_endHapticDone) {
      _endHapticDone = true;
      HapticFeedback.heavyImpact();
    }
    if (s.isOver && !_endNarrated) {
      _endNarrated = true;
      _narrateEnd(s);
    }
    if (s.isCancelled && !_closedForCancel) {
      _closedForCancel = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onClose();
      });
    }
  }

  /// Fim: a palavra (VITÓRIA/DERROTA/EMPATE/ENCERRADA), o motivo e o MVP vão
  /// para o narrador; no vídeo ficam só os desenhos.
  void _narrateEnd(BattleState s) {
    final own = _ownSideOf(s);
    final winner = s.winnerSide;
    final l10n = S.of(context);
    BattleGifter? mvp;
    if (s.endedWithoutWinner) {
      _say('ended', const {}, _endedReason(s, l10n));
      _moment('ended');
    } else if (winner == null) {
      _say('draw');
      _moment('draw');
      mvp = s.mvp ?? (own != null ? s.mvpOf(own) : null);
    } else {
      final won = own == null || own == winner;
      _say(won ? 'victory' : 'defeat', {'time': s.nameOf(winner)});
      _moment(won ? 'victory' : 'defeat');
      mvp = s.mvp ?? (own != null ? s.mvpOf(own) : null);
    }
    if (mvp != null) {
      _say('mvp', {'nome': mvp.name ?? '', 'pontos': formatBattleScore(mvp.total)});
      _moment('mvp');
    }
    // Selos de fim por ~5 s (+4 s se há MVP para ler); depois volta à tela
    // dupla (ou ao solo).
    _endTimer ??= Timer(Duration(seconds: mvp != null ? 9 : 5), () {
      if (mounted) widget.onClose();
    });
  }

  // ── Efeitos da barra ────────────────────────────────────────────────────

  Map<String, BarTrigger> _triggers(BattleState battle, bool over, String? ownSide) {
    final m = <String, BarTrigger>{};
    if (over) return m;
    if (_leadSide != null && _leadSince != null) {
      m['lead_change'] = BarTrigger(startedAt: _leadSince!, side: _leadSide);
    }
    if (_momentumSince != null && _momentumSide == ownSide) {
      m['momentum'] = BarTrigger(startedAt: _momentumSince!, side: _momentumSide);
    }
    if (_multSince != null) m['multiplier'] = BarTrigger(startedAt: _multSince!);
    if (_finalSince != null) m['final_window'] = BarTrigger(startedAt: _finalSince!);
    // Tema ativo no servidor: efeitos "event" valem o tempo todo.
    if (_manifest?.themeId != null) m['event'] = BarTrigger(startedAt: _hudSince);
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final provider = battleViewModelProvider(widget.battleId);
    final async = ref.watch(provider);
    // Recarrega a tela quando o manifesto muda (novos arquivos/textos).
    ref.watch(battleAssetsProvider);

    ref.listen<AsyncValue<BattleState>>(provider, (prev, next) {
      final s = next.asData?.value;
      if (s == null) return;
      _onBattle(prev?.asData?.value, s);
    });

    // §18.1: com `owner_left`, o dono da sala assistida fica à esquerda (azul).
    final cur = async.asData?.value;
    final layout = battleLayoutOf(
      context,
      splitTop: widget.splitTop,
      ownSide: (cur != null && cur.ownerLeft ? _ownSideOf(cur) : null) ?? 'a',
    );
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
    final topY = layout.split.top + kBattleBarH + 6;

    final manifest = _manifest;
    final triggers = _triggers(battle, over, ownSide);
    // Sem efeito de virada no manifesto e sem desenho próprio: brilho padrão
    // na metade de quem virou (substitui o antigo "VIROU!").
    final hasLeadFx = manifest?.barEffects.any((e) => e.trigger == 'lead_change') ?? false;
    final hasLeadMoment = BattleMedia.momentReady(manifest?.moment('lead_change'));
    final effects = <BattleBarEffect>[
      ...?manifest?.barEffects,
      if (!hasLeadFx && !hasLeadMoment)
        const BattleBarEffect(
          id: 'builtin-lead-shine',
          trigger: 'lead_change',
          anchor: 'side',
          durationMs: 1400,
        ),
    ];

    // Posição da costura (para a rajada de virada/pegando fogo).
    final seamX = layout.strip.left +
        layout.strip.width *
            battleProgressLeft(battle, layout.ownSide).clamp(0.04, 0.96);

    return Stack(
      children: [
        // ── Barra de vantagem (pontos dentro), colada no topo do vídeo ──
        Positioned.fromRect(
          rect: layout.strip,
          child: BattleAdvantageBar(
            battle: battle,
            mySide: mySide,
            ownSide: layout.ownSide,
          ),
        ),

        // ── Efeitos do manifesto sobre a barra + encaixes das pontas ──
        Positioned.fromRect(
          rect: layout.strip,
          child: BattleBarEffectsLayer(
            effects: effects,
            triggers: triggers,
            leftFraction: battleProgressLeft(battle, layout.ownSide),
            layout: layout,
            barHeight: kBattleBarH,
          ),
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
                      onUrgentTick: (_) => _sound('final_tick'),
                    ),
            ),
          ),
        ),

        // ── Selo de vitórias: canto superior EXTERNO de cada metade ──
        if ((battle.winStreakA ?? 0) > 0)
          Positioned(
            left: layout.isLeft('a') ? layout.halfA.left + 6 : null,
            right: layout.isLeft('a')
                ? null
                : layout.screen.width - layout.halfA.right + 6,
            top: topY,
            child: IgnorePointer(
              child: BattleStreakBadge(side: 'a', streak: battle.winStreakA!),
            ),
          ),
        if ((battle.winStreakB ?? 0) > 0)
          Positioned(
            left: layout.isLeft('b') ? layout.halfB.left + 6 : null,
            right: layout.isLeft('b')
                ? null
                : layout.screen.width - layout.halfB.right + 6,
            top: topY,
            child: IgnorePointer(
              child: BattleStreakBadge(side: 'b', streak: battle.winStreakB!),
            ),
          ),

        // ── Faixa do jogo (preta, abaixo do vídeo) ──
        // Fileira do time: 3 MVPs do PRÓPRIO lado (embaixo da metade dele) e,
        // no meio, o desafio relâmpago / MVP.
        if (ownSide == 'a' && battle.topGiftersA.isNotEmpty)
          Positioned(
            left: layout.isLeft('a') ? layout.halfA.left + 6 : null,
            right: layout.isLeft('a')
                ? null
                : layout.screen.width - layout.halfA.right + 6,
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
            left: layout.isLeft('b') ? layout.halfB.left + 6 : null,
            right: layout.isLeft('b')
                ? null
                : layout.screen.width - layout.halfB.right + 6,
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

        // Narrador: uma frase por vez, abaixo da fileira do time.
        Positioned(
          left: 8,
          right: 8,
          top: layout.narratorTop,
          height: kBattleNarratorH,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _narrator,
              builder: (_, _) => BattleNarratorBar(
                line: _narrator.current,
                leading: _narratorBurst == null
                    ? null
                    : BattleMediaBurst(
                        key: ValueKey('nb-${_narratorBurst!.id}'),
                        moment: _narratorBurst!.moment,
                        onDone: () => _endBurst(_narratorBurst!),
                      ),
              ),
            ),
          ),
        ),

        // ── Metade do adversário: toque abre a live dele ──
        if (ownSide != null)
          Positioned.fill(
            child: _opponentTap(context, battle, layout, ownSide),
          ),

        // ── Controles sobre as metades (silenciar / áudio) ──
        if (widget.halfOverlays != null)
          widget.halfOverlays!(context, battle, layout),

        // ── Rajada na costura da barra (virada / pegando fogo) ──
        if (_seamBurst != null && !over)
          Positioned(
            left: seamX - 36,
            top: layout.strip.top + (kBattleBarH - 72) / 2,
            width: 72,
            height: 72,
            child: BattleMediaBurst(
              key: ValueKey('sb-${_seamBurst!.id}'),
              moment: _seamBurst!.moment,
              onDone: () => _endBurst(_seamBurst!),
            ),
          ),

        // ── Fim: só desenhos sobre o vídeo (coroa/confete/escurecido) ──
        if (over) ...[
          if (noWinner)
            Positioned.fromRect(
              rect: layout.split,
              child: IgnorePointer(
                child: BattleEndedSeal(
                  reason: _endedReason(battle, l10n),
                  media: _stageMedia('ended'),
                ),
              ),
            )
          else if (winner == null)
            Positioned.fromRect(
              rect: layout.split,
              child: IgnorePointer(
                child: BattleDrawSeal(media: _stageMedia('draw')),
              ),
            )
          else
            for (final side in const ['a', 'b'])
              Positioned.fromRect(
                rect: layout.half(side),
                child: IgnorePointer(
                  child: BattleEndSeal(
                    win: winner == side,
                    media: _stageMedia(winner == side ? 'victory' : 'defeat'),
                  ),
                ),
              ),
        ],

        // ── Contagem 3·2·1: só o número, sobre o vídeo (não cobre barra/chat) ──
        if (battle.countdown != null)
          Positioned.fromRect(
            rect: layout.split,
            child: BattleCountdownOverlay(
              count: battle.countdown!,
              battle: battle,
              media: _countdownMedia(battle.countdown!),
            ),
          ),
      ],
    );
  }

  /// Desenho da contagem: reinicia a cada número.
  Widget? _countdownMedia(int count) {
    final m = _manifest?.moment('countdown');
    if (!BattleMedia.momentReady(m)) return null;
    return BattleMediaView(
      key: ValueKey('stage-countdown-$count'),
      lottieUrl: m!.lottieUrl,
      imageUrl: m.imageUrl,
      loop: m.loop,
    );
  }
}

class _Burst {
  const _Burst(this.id, this.moment);
  final int id;
  final BattleMoment moment;
}
