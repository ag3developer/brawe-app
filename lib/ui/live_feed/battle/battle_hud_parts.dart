import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../domain/models/battle_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/image_decode.dart';
import '../widgets/battle_timer.dart';

/// Fundo escuro das telas de mídia (mesmo `#0B0F1A` da composição).
const Color kBattleBg = Color(0xFF0B0E14);

/// Tinta escura para texto sobre o laranja da marca.
const Color kBattleInk = Color(0xFF0B0E14);

// §16: base neutra (vidro + borda), cor só com significado.
const Color kBattleGlass = Color(0x0FFFFFFF); // rgba(255,255,255,.06)
const Color kBattleGlassBorder = Color(0x14FFFFFF); // rgba(255,255,255,.08)
const Color kBattleText = Color(0xFFF4F6FA);
const Color kBattleTextDim = Color(0xFFA3ACBD);

/// Vidro sobre o vídeo (escurece um pouco para ler em qualquer imagem).
BoxDecoration battleGlass({double radius = 14}) => BoxDecoration(
  color: const Color(0xB30B0E14),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: kBattleGlassBorder),
);

const _tab = [FontFeature.tabularFigures()];

/// Cor do lado (§18.1): o dono ([ownSide], à esquerda) é azul de ação; o
/// parceiro (à direita) é laranja da marca.
Color battleSideColor(String side, String ownSide) =>
    side == ownSide ? AppColors.braweBlueBright : AppColors.braweOrange;

/// Cor de texto legível sobre [battleSideColor] (laranja não aceita branco).
Color battleOnSide(String side, String ownSide) =>
    side == ownSide ? Colors.white : kBattleInk;

String formatBattleScore(double v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 10000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.round().toString();
}

// ─── Avatar ────────────────────────────────────────────────────────────────

class BattleAvatar extends StatelessWidget {
  const BattleAvatar({
    super.key,
    required this.url,
    required this.name,
    required this.size,
    required this.color,
    this.ring = 2,
  });

  final String? url;
  final String name;
  final double size;
  final Color color;
  final double ring;

  @override
  Widget build(BuildContext context) {
    final u = url;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: ring),
        color: Colors.white12,
        image: u != null && u.isNotEmpty
            ? DecorationImage(
                image: ResizeImage(
                  NetworkImage(u),
                  width: context.decodePx(size),
                ),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: u == null || u.isEmpty
          ? Text(
              name.isEmpty ? '?' : name.characters.first.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.42,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}

// ─── Barra de vantagem com os pontos DENTRO ─────────────────────────────────

/// Barra de ponta a ponta colada no topo do vídeo (~24 px): dono azul à esquerda
/// (texto branco), parceiro laranja à direita (texto escuro). Sem nomes/avatares.
/// A fronteira "empurra" com mola (overshoot leve) a cada mudança de pontos,
/// com a costura branca pulsando (o único brilho do HUD) e números que contam.
/// Fração da barra ocupada pelo lado da esquerda (o dono).
double battleProgressLeft(BattleState b, String ownSide) =>
    ownSide == 'b' ? 1 - b.progressA : b.progressA;

class BattleAdvantageBar extends StatefulWidget {
  const BattleAdvantageBar({
    super.key,
    required this.battle,
    this.mySide,
    this.ownSide = 'a',
  });

  final BattleState battle;

  /// Lado do criador que está vendo (marca "Você"); `null` = espectador.
  final String? mySide;

  /// Lado da sala assistida: desenhado à esquerda, em azul (§18.1).
  final String ownSide;

  @override
  State<BattleAdvantageBar> createState() => _BattleAdvantageBarState();
}

class _BattleAdvantageBarState extends State<BattleAdvantageBar>
    with TickerProviderStateMixin {
  late final AnimationController _spring = AnimationController.unbounded(
    vsync: this,
    value: battleProgressLeft(widget.battle, widget.ownSide).clamp(0.04, 0.96),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void didUpdateWidget(covariant BattleAdvantageBar old) {
    super.didUpdateWidget(old);
    final target = battleProgressLeft(
      widget.battle,
      widget.ownSide,
    ).clamp(0.04, 0.96);
    final before = battleProgressLeft(
      old.battle,
      old.ownSide,
    ).clamp(0.04, 0.96);
    if ((target - before).abs() > 0.0005) {
      _spring.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 1, stiffness: 190, damping: 13),
          _spring.value,
          target,
          _spring.velocity,
        ),
      );
    }
  }

  @override
  void dispose() {
    _spring.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final battle = widget.battle;
    final you = S.of(context).battleYou;
    Widget label(String side) {
      final isLeft = side == widget.ownSide;
      final score = _CountUp(
        value: battle.scoreOf(side),
        style: TextStyle(
          color: battleOnSide(side, widget.ownSide),
          fontSize: 13,
          fontWeight: FontWeight.w800,
          fontFeatures: _tab,
          decoration: TextDecoration.none,
        ),
      );
      final me = widget.mySide == side
          ? Text(
              you,
              style: TextStyle(
                color: battleOnSide(
                  side,
                  widget.ownSide,
                ).withValues(alpha: 0.8),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            )
          : null;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLeft && me != null) ...[me, const SizedBox(width: 4)],
          score,
          if (isLeft && me != null) ...[const SizedBox(width: 4), me],
        ],
      );
    }

    return Semantics(
      label:
          '${formatBattleScore(battle.scoreA)} x ${formatBattleScore(battle.scoreB)}',
      child: SizedBox(
        height: kBattleBarH,
        child: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (_, box) => AnimatedBuilder(
                animation: Listenable.merge([_spring, _pulse]),
                builder: (_, _) {
                  final v = _spring.value.clamp(0.0, 1.0);
                  final x = box.maxWidth * v;
                  return Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: x,
                        child: const ColoredBox(
                          color: AppColors.braweBlueBright,
                        ),
                      ),
                      Positioned(
                        left: x,
                        top: 0,
                        bottom: 0,
                        right: 0,
                        child: const ColoredBox(color: AppColors.braweOrange),
                      ),
                      // Costura branca pulsando: único brilho do HUD.
                      Positioned(
                        left: x - 1.5,
                        top: 0,
                        bottom: 0,
                        width: 3,
                        child: ColoredBox(
                          color: Colors.white.withValues(
                            alpha: 0.55 + 0.45 * _pulse.value,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  label(widget.ownSide),
                  label(widget.ownSide == 'a' ? 'b' : 'a'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Número que "conta" até o novo valor (tabular).
class _CountUp extends StatelessWidget {
  const _CountUp({required this.value, required this.style});
  final double value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text(formatBattleScore(v), style: style),
    );
  }
}

const double kBattleBarH = 24;

// ─── Cronômetro (pílula escura no alto do vídeo) + selo 2X ──────────────────

class BattleTimerOverlay extends StatelessWidget {
  const BattleTimerOverlay({
    super.key,
    required this.battle,
    this.sealMultiplier,
    this.onUrgentTick,
  });

  final BattleState battle;
  final double? sealMultiplier;

  /// Cada segundo da reta final (últimos 10 s).
  final void Function(int secondsLeft)? onUrgentTick;

  /// Últimos segundos em que o cronômetro fica laranja, pulsa e vibra.
  static const int urgentSeconds = 10;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BattleTimer(
          timeRemaining: battle.timeRemaining,
          compact: true,
          urgentSeconds: battle.phase == BattlePhase.active ? urgentSeconds : 0,
          onUrgentTick: onUrgentTick,
        ),
        if (sealMultiplier != null) ...[
          const SizedBox(width: 4),
          _PowerSeal(multiplier: sealMultiplier!),
        ],
      ],
    );
  }
}

class _PowerSeal extends StatelessWidget {
  const _PowerSeal({required this.multiplier});
  final double multiplier;

  @override
  Widget build(BuildContext context) {
    final label = multiplier % 1 == 0
        ? '${multiplier.toInt()}X'
        : '${multiplier.toStringAsFixed(1)}X';
    return Semantics(
      label: S.of(context).battleFinalStretch,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: battleGlass(radius: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.sparkles, size: 11, color: kBattleBoost),
            const SizedBox(width: 2),
            Text(
              label,
              style: const TextStyle(
                color: kBattleBoost,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                fontFeatures: _tab,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sequência de vitórias ──────────────────────────────────────────────────

class BattleStreakBadge extends StatelessWidget {
  const BattleStreakBadge({
    super.key,
    required this.side,
    required this.streak,
  });
  final String side;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: battleGlass(radius: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.trophy, size: 11, color: kBattleTextDim),
          const SizedBox(width: 3),
          Text(
            '×$streak',
            style: const TextStyle(
              color: kBattleText,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              fontFeatures: _tab,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class BattleSupporters extends StatelessWidget {
  const BattleSupporters({
    super.key,
    required this.side,
    required this.gifters,
    this.crownFirst = false,
  });

  /// Fim da batalha: coroa sobre o 1º MVP.
  final bool crownFirst;
  final String side;
  final List<BattleGifter> gifters;

  @override
  Widget build(BuildContext context) {
    final top = gifters.take(3).toList();
    return Semantics(
      label: S.of(context).battleTopSupporters,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < top.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: BattleAvatar(
                        url: top[i].avatarUrl,
                        name: top[i].name ?? '',
                        size: 30,
                        color: Colors.white.withValues(
                          alpha: i == 0 ? 0.55 : 0.25,
                        ),
                        ring: 1.5,
                      ),
                    ),
                    if (crownFirst && i == 0)
                      const Positioned(
                        top: -9,
                        left: 8,
                        child: Icon(
                          LucideIcons.crown,
                          size: 15,
                          color: kBattleGold,
                        ),
                      ),
                    // Número 1/2/3 no canto.
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 14,
                        height: 14,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kBattleBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: kBattleGlassBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: kBattleText,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Desafio relâmpago (§9) ─────────────────────────────────────────────────

String _mmss(Duration d) {
  final s = d.inSeconds < 0 ? 0 : d.inSeconds;
  return '${(s ~/ 60)}:${(s % 60).toString().padLeft(2, '0')}';
}

class BattleFlashPill extends StatefulWidget {
  const BattleFlashPill({super.key, required this.flash, this.onTap});

  final BattleFlash flash;
  final VoidCallback? onTap;

  @override
  State<BattleFlashPill> createState() => _BattleFlashPillState();
}

class _BattleFlashPillState extends State<BattleFlashPill> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final f = widget.flash;
    final end = f.isBoost ? f.boostEndsAt : f.challengeEndsAt;
    final left = end == null ? Duration.zero : end.difference(DateTime.now());
    if (end != null && left.isNegative && left.inSeconds < -1) {
      return const SizedBox.shrink();
    }
    final time = _mmss(left);
    final mult = f.multiplier % 1 == 0
        ? '${f.multiplier.toInt()}'
        : f.multiplier.toStringAsFixed(1);
    final text = f.isBoost
        ? l10n.battleFlashBoost(mult, time)
        : l10n.battleFlashChallenge(f.target, f.giftName, time);
    // Texto livre (sem cápsula): branco no desafio, laranja no bônus.
    final color = f.isBoost ? kBattleBoost : kBattleInfoWhite;
    final style = TextStyle(
      color: color,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      fontFeatures: _tab,
      decoration: TextDecoration.none,
      shadows: f.isBoost
          ? [Shadow(color: kBattleBoost.withValues(alpha: 0.55), blurRadius: 8)]
          : null,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: f.isBoost ? null : widget.onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (f.isBoost)
            Icon(LucideIcons.sparkles, size: 16, color: color)
          else
            Icon(LucideIcons.gift, size: 15, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          if (!f.isBoost) ...[
            const SizedBox(width: 6),
            Text(
              l10n.battleFlashProgress(f.progress, f.target),
              style: style.copyWith(color: kBattleBoost),
            ),
          ],
        ],
      ),
    );
  }
}

/// Aviso de regra/informação (cinza), ex.: durante a contagem.
class BattleInfoText extends StatelessWidget {
  const BattleInfoText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LucideIcons.info, size: 14, color: kBattleInfoGray),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kBattleInfoGray,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

const Color kBattleInfoWhite = kBattleText;
const Color kBattleBoost = Color(0xFFFFB366);
const Color kBattleMvpText = Color(0xFFE8C56F);
const Color kBattleInfoGray = kBattleTextDim;

// ─── Contagem 3·2·1 ─────────────────────────────────────────────────────────

/// Contagem 3·2·1 NO PALCO: só o número grande (e, pequeno, "A VS B") sobre
/// a área do vídeo — sem escurecer topo nem chat. [media] é o desenho do
/// manifesto (Lottie/imagem) por trás do número, quando já baixado.
class BattleCountdownOverlay extends StatelessWidget {
  const BattleCountdownOverlay({
    super.key,
    required this.count,
    required this.battle,
    this.media,
  });

  final int count;
  final BattleState battle;
  final Widget? media;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    const shadow = [Shadow(blurRadius: 14, color: Colors.black87)];
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (media != null)
            Positioned.fill(
              child: Padding(padding: const EdgeInsets.all(24), child: media),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                liveRegion: true,
                label: l10n.battleCountdownStarting(count),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: Tween<double>(begin: 1.8, end: 1.0).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOut),
                    ),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Text(
                    '$count',
                    key: ValueKey(count),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 120,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.none,
                      shadows: shadow,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${battle.streamerAName} ${l10n.battleVs} ${battle.streamerBName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  decoration: TextDecoration.none,
                  shadows: shadow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Chip de estado (carregando/erro) ───────────────────────────────────────

class BattleStatusChip extends StatelessWidget {
  const BattleStatusChip({
    super.key,
    required this.label,
    this.actionLabel,
    this.onAction,
  });
  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (actionLabel == null) ...[
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(color: kBattleText),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Fim da batalha: selos sobre o vídeo (§12, §15) ─────────────────────────

const Color kBattleGold = Color(0xFFE8C56F);

/// Entrada rápida (escala com leve overshoot) para os selos.
class _SealPop extends StatelessWidget {
  const _SealPop({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (_, v, c) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.scale(scale: v, child: c),
      ),
      child: child,
    );
  }
}

/// Desenho de fim de uma metade, SEM texto (a palavra vai para o narrador):
/// vencedora = coroa + confete; perdedora = escurecida. [media] é o desenho
/// do manifesto (vitória/derrota), por cima do desenho padrão.
class BattleEndSeal extends StatelessWidget {
  const BattleEndSeal({super.key, required this.win, this.media});
  final bool win;
  final Widget? media;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final label = win ? l10n.battleSealWin : l10n.battleSealLose;
    if (!win) {
      return Semantics(
        label: label,
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          alignment: Alignment.center,
          child: media == null
              ? null
              : Padding(padding: const EdgeInsets.all(20), child: media),
        ),
      );
    }
    return Semantics(
      label: label,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _Confetti(),
          Center(
            child: _SealPop(
              child: const Icon(
                LucideIcons.crown,
                color: kBattleGold,
                size: 56,
                shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
              ),
            ),
          ),
          if (media != null)
            Padding(padding: const EdgeInsets.all(20), child: media),
        ],
      ),
    );
  }
}

/// Empate atravessando as duas metades: só o desenho (balança), sem texto.
class BattleDrawSeal extends StatelessWidget {
  const BattleDrawSeal({super.key, this.media});
  final Widget? media;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: S.of(context).battleSealDraw,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _SealPop(
            child: Icon(
              LucideIcons.scale,
              color: kBattleGold,
              size: 52,
              shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
            ),
          ),
          if (media != null)
            Positioned.fill(
              child: Padding(padding: const EdgeInsets.all(24), child: media),
            ),
        ],
      ),
    );
  }
}

/// §15: batalha encerrada SEM vencedor — só escurece o vídeo (o motivo vai
/// para o narrador). Sem VITÓRIA/DERROTA e sem coroa.
class BattleEndedSeal extends StatelessWidget {
  const BattleEndedSeal({super.key, required this.reason, this.media});
  final String reason;
  final Widget? media;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${S.of(context).battleEndedTitle}. $reason',
      child: Container(
        color: Colors.black.withValues(alpha: 0.35),
        alignment: Alignment.center,
        child: media == null
            ? null
            : Padding(padding: const EdgeInsets.all(24), child: media),
      ),
    );
  }
}

/// Texto dourado "MVP <nome> · <pontos>" com coroa (sem cápsula).
class BattleMvpPill extends StatelessWidget {
  const BattleMvpPill({super.key, required this.mvp});
  final BattleGifter mvp;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LucideIcons.crown, size: 16, color: kBattleMvpText),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            S
                .of(context)
                .battleMvpPill(mvp.name ?? '', formatBattleScore(mvp.total)),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kBattleMvpText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: _tab,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// Selo "FIM" no lugar do cronômetro.
class BattleEndPill extends StatelessWidget {
  const BattleEndPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: battleGlass(radius: 20),
      child: Text(
        S.of(context).battleEndLabel,
        style: const TextStyle(
          color: kBattleText,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

/// Confete simples (retângulos coloridos caindo) sobre a metade vencedora.
class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(painter: _ConfettiPainter(_c.value)),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t;
  static const _colors = [kBattleGold, Colors.white, Color(0xFFF2DC9E)];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 28; i++) {
      final seed = (i * 7919) % 1000 / 1000.0;
      final phase = (t + seed) % 1.0;
      final x =
          ((i * 37) % 100) / 100 * size.width + 10 * (phase * 6.28).abs() % 12;
      final y = phase * size.height;
      final paint = Paint()
        ..color = _colors[i % _colors.length].withValues(
          alpha: 1 - phase * 0.6,
        );
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(phase * 9 + i);
      canvas.drawRect(const Rect.fromLTWH(-3, -2, 6, 4), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
