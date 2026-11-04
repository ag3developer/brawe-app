import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../domain/models/gifter_level_journey.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../core/themes/brawe_colors.dart';
import '../../../../live_feed/view_models/gifter_level_journey_provider.dart';
import '../../../../quests/widgets/quest_visuals.dart';
import '../level_chip.dart';

/// 🎖️ "Meu nível" — jornada do presenteador: resumo do nível, carrossel das
/// faixas (passadas, atual e futuras), trilha para pular direto e o detalhe
/// da faixa escolhida. "Como ganhar XP" abre numa folha separada.
class GifterLevelScreen extends ConsumerStatefulWidget {
  const GifterLevelScreen({super.key});

  @override
  ConsumerState<GifterLevelScreen> createState() => _GifterLevelScreenState();
}

class _GifterLevelScreenState extends ConsumerState<GifterLevelScreen> {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final async = ref.watch(gifterLevelJourneyProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: QuestBackdrop()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: colors.textPrimary,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Text(
                          s.gifterLevelTitle,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: async.when(
                    skipLoadingOnRefresh: true,
                    loading: () => const _Skeleton(),
                    error: (_, _) => _ErrorView(
                      onRetry: () => ref.invalidate(gifterLevelJourneyProvider),
                    ),
                    data: (journey) => RefreshIndicator(
                      onRefresh: () => ref
                          .read(gifterLevelJourneyProvider.notifier)
                          .refresh(),
                      child: _Content(journey: journey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Utilidades

Color _hex(String? hex, [Color fallback = const Color(0xFF9AA3B2)]) {
  if (hex == null) return fallback;
  final c = hex.replaceAll('#', '').trim();
  if (c.length != 6) return fallback;
  final v = int.tryParse('FF$c', radix: 16);
  return v == null ? fallback : Color(v);
}

String _fmt(BuildContext context, int n) => NumberFormat.decimalPattern(
  Localizations.localeOf(context).toString(),
).format(n);

const _grayscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);

/// Emblema da faixa: imagem do CDN → emoji → LevelChip.
class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier, required this.size, this.gray = false});

  final GifterTier tier;
  final double size;
  final bool gray;

  @override
  Widget build(BuildContext context) {
    final color = _hex(tier.color);
    Widget fallback() {
      if (tier.badgeEmoji != null) {
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color.lerp(color, Colors.white, 0.2)!, color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Text(tier.badgeEmoji!, style: TextStyle(fontSize: size * 0.5)),
        );
      }
      return Center(
        child: LevelChip(
          level: tier.minLevel,
          colorHex: tier.color,
          height: (size * 0.5).clamp(14, 28),
        ),
      );
    }

    Widget child = tier.badgeImageUrl == null
        ? fallback()
        : Image.network(
            tier.badgeImageUrl!,
            width: size,
            height: size,
            fit: BoxFit.contain,
            cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
            errorBuilder: (_, _, _) => fallback(),
          );
    if (gray) {
      child = Opacity(
        opacity: 0.55,
        child: ColorFiltered(colorFilter: _grayscale, child: child),
      );
    }
    return SizedBox(width: size, height: size, child: child);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Conteúdo: resumo → carrossel de faixas → trilha navegável → detalhe da faixa

class _Content extends StatefulWidget {
  const _Content({required this.journey});
  final GifterLevelJourney journey;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  late final PageController _pager;
  late int _selected;

  List<GifterTier> get _tiers => widget.journey.tiers;

  int get _currentIndex {
    final i = _tiers.indexWhere((t) => t.status == GifterTierStatus.current);
    if (i >= 0) return i;
    final lastDone = _tiers.lastIndexWhere(
      (t) => t.status == GifterTierStatus.achieved,
    );
    return lastDone < 0 ? 0 : lastDone;
  }

  @override
  void initState() {
    super.initState();
    _selected = _currentIndex;
    _pager = PageController(initialPage: _selected, viewportFraction: 0.44);
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    if (i == _selected) return;
    _pager.animateToPage(
      i,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final journey = widget.journey;
    final tiers = _tiers;
    final rules = _buildRules(context, journey.xpRules);
    final done = tiers.where((t) => t.status != GifterTierStatus.locked).length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StaggerIn(
            index: 0,
            child: _Summary(
              journey: journey,
              tiersLabel: s.gifterLevelTiersCount(done, tiers.length),
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (tiers.isNotEmpty) ...[
          StaggerIn(
            index: 1,
            child: SizedBox(
              height: 196,
              child: PageView.builder(
                controller: _pager,
                itemCount: tiers.length,
                onPageChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() => _selected = i);
                },
                itemBuilder: (context, i) => _CarouselItem(
                  controller: _pager,
                  index: i,
                  tier: tiers[i],
                  onTap: () => _goTo(i),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _TierTrack(tiers: tiers, selected: _selected, onTap: _goTo),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _TierDetail(
                key: ValueKey(_selected),
                journey: journey,
                tier: tiers[_selected],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            child: _selected == _currentIndex
                ? const SizedBox(height: 12)
                : Center(
                    child: TextButton.icon(
                      onPressed: () => _goTo(_currentIndex),
                      icon: const Icon(LucideIcons.locateFixed, size: 16),
                      label: Text(s.gifterLevelBackToCurrent),
                    ),
                  ),
          ),
        ],
        if (rules.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _HowToEarnTile(rules: rules),
          ),
      ],
    );
  }

  List<_Rule> _buildRules(BuildContext context, GifterXpRules r) {
    final s = S.of(context);
    final list = <_Rule>[];
    if (r.giftMode == 'flat') {
      if (r.giftFlat > 0) {
        list.add(
          _Rule(LucideIcons.gift, s.gifterLevelRuleGiftFlat(r.giftFlat)),
        );
      }
    } else if (r.giftPerCoin > 0) {
      list.add(
        _Rule(
          LucideIcons.gift,
          r.giftCapPerSend > 0
              ? s.gifterLevelRuleGiftPerCoin(
                  r.giftPerCoin,
                  _fmt(context, r.giftCapPerSend),
                )
              : s.gifterLevelRuleGiftPerCoinNoCap(r.giftPerCoin),
        ),
      );
    }
    if (r.watchPerMin > 0) {
      list.add(
        _Rule(
          LucideIcons.eye,
          r.watchCapMin > 0
              ? s.gifterLevelRuleWatch(r.watchPerMin, r.watchCapMin)
              : s.gifterLevelRuleWatchNoCap(r.watchPerMin),
        ),
      );
    }
    if (r.join > 0) {
      list.add(_Rule(LucideIcons.logIn, s.gifterLevelRuleJoin(r.join)));
    }
    if (r.chat > 0) {
      list.add(_Rule(LucideIcons.messageCircle, s.gifterLevelRuleChat(r.chat)));
    }
    return list;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resumo compacto: nível + faixa + barra de XP

class _Summary extends StatelessWidget {
  const _Summary({required this.journey, required this.tiersLabel});
  final GifterLevelJourney journey;
  final String tiersLabel;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final lang = Localizations.localeOf(context).languageCode;
    final tier =
        journey.tier ?? (journey.tiers.isNotEmpty ? journey.tiers.first : null);
    final tierColor = _hex(tier?.color);
    final next = journey.nextLevel;
    final maxed = next == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              s.gifterLevelLevel(journey.level),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            if (tier != null)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    tier.nameFor(lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tierColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tiersLabel,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        QuestProgressBar(
          value: maxed ? 1.0 : next.progressFraction,
          colors: [Color.lerp(tierColor, Colors.white, 0.25)!, tierColor],
          background: colors.surfaceHighest,
          height: 8,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            maxed
                ? Text(s.gifterLevelMaxReached, style: _small(colors, true))
                : CountUpText(
                    value: journey.xp,
                    format: (n) => s.gifterLevelXpProgress(
                      _fmt(context, n),
                      _fmt(context, next.nextThreshold),
                    ),
                    style: _small(colors, true),
                  ),
            if (!maxed)
              Flexible(
                child: Text(
                  s.gifterLevelXpMissing(
                    _fmt(context, next.xpNeeded),
                    next.nextLevel,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: _small(colors, false),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

TextStyle _small(BraweColors colors, bool bold) => TextStyle(
  color: bold ? colors.textPrimary : colors.textSecondary,
  fontSize: 12,
  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
);

// ─────────────────────────────────────────────────────────────────────────────
// Item do carrossel: emblema grande que cresce no centro e encolhe nas bordas

class _CarouselItem extends StatelessWidget {
  const _CarouselItem({
    required this.controller,
    required this.index,
    required this.tier,
    required this.onTap,
  });

  final PageController controller;
  final int index;
  final GifterTier tier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lang = Localizations.localeOf(context).languageCode;
    final tierColor = _hex(tier.color);
    final locked = tier.status == GifterTierStatus.locked;
    final isCurrent = tier.status == GifterTierStatus.current;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double page = index.toDouble();
        if (controller.hasClients && controller.position.haveDimensions) {
          page = controller.page ?? page;
        } else if (controller.hasClients == false) {
          page = controller.initialPage.toDouble();
        }
        final dist = (page - index).abs().clamp(0.0, 1.0);
        final t = 1 - dist; // 1 = no centro
        final scale = 0.62 + 0.38 * t;
        final opacity = 0.45 + 0.55 * t;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Opacity(
            opacity: opacity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!locked)
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  tierColor.withValues(alpha: 0.42 * t),
                                  tierColor.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        isCurrent
                            ? Sparkles(
                                color: tierColor,
                                enabled: t > 0.9,
                                child: Floating(
                                  amplitude: 4,
                                  enabled: t > 0.9,
                                  child: _TierBadge(tier: tier, size: 118),
                                ),
                              )
                            : _TierBadge(tier: tier, size: 118, gray: locked),
                        if (locked)
                          Positioned(
                            right: 22,
                            bottom: 22,
                            child: _MiniDot(
                              color: colors.textTertiary,
                              icon: LucideIcons.lock,
                              size: 26,
                            ),
                          ),
                        if (tier.status == GifterTierStatus.achieved)
                          Positioned(
                            right: 22,
                            bottom: 22,
                            child: _MiniDot(
                              color: tierColor,
                              icon: Icons.check_rounded,
                              size: 26,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tier.nameFor(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: locked ? colors.textSecondary : colors.textPrimary,
                    fontSize: 13 + 3 * t,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trilha: um ponto por faixa, ligados por linha; toque para pular direto

class _TierTrack extends StatelessWidget {
  const _TierTrack({
    required this.tiers,
    required this.selected,
    required this.onTap,
  });

  final List<GifterTier> tiers;
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          for (var i = 0; i < tiers.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: tiers[i].status == GifterTierStatus.locked
                        ? colors.divider
                        : _hex(tiers[i].color).withValues(alpha: 0.75),
                  ),
                ),
              ),
            _TrackDot(
              tier: tiers[i],
              selected: i == selected,
              onTap: () => onTap(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrackDot extends StatelessWidget {
  const _TrackDot({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  final GifterTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = _hex(tier.color);
    final locked = tier.status == GifterTierStatus.locked;
    final isCurrent = tier.status == GifterTierStatus.current;
    final size = selected ? 22.0 : (isCurrent ? 16.0 : 12.0);

    Widget dot = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: locked ? colors.surfaceHighest : c,
        border: Border.all(
          color: selected
              ? colors.textPrimary
              : (locked ? colors.divider : Colors.white.withValues(alpha: 0.5)),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected && !locked
            ? [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 8)]
            : null,
      ),
      child: selected
          ? Center(
              child: Text(
                '${tier.minLevel}',
                style: TextStyle(
                  color: locked ? colors.textSecondary : Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            )
          : null,
    );
    if (isCurrent && !selected) dot = Pulse(child: dot);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(width: 24, height: 34, child: Center(child: dot)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detalhe da faixa selecionada

class _TierDetail extends StatelessWidget {
  const _TierDetail({super.key, required this.journey, required this.tier});

  final GifterLevelJourney journey;
  final GifterTier tier;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final lang = Localizations.localeOf(context).languageCode;
    final c = _hex(tier.color);
    final locked = tier.status == GifterTierStatus.locked;
    final isCurrent = tier.status == GifterTierStatus.current;

    final range = tier.maxLevel > tier.minLevel
        ? s.gifterLevelRange(tier.minLevel, tier.maxLevel)
        : s.gifterLevelRangeOpen(tier.minLevel);

    final (statusText, statusIcon, statusColor) = switch (tier.status) {
      GifterTierStatus.achieved => (
        s.gifterLevelStatusAchieved,
        LucideIcons.badgeCheck,
        c,
      ),
      GifterTierStatus.current => (
        s.gifterLevelStatusCurrent,
        LucideIcons.mapPin,
        c,
      ),
      GifterTierStatus.locked => (
        s.gifterLevelStatusLocked,
        LucideIcons.lock,
        colors.textTertiary,
      ),
    };

    Widget progress;
    if (locked) {
      final total = tier.xpRequired <= 0 ? 1 : tier.xpRequired;
      progress = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestProgressBar(
            value: (journey.xp / total).clamp(0.0, 1.0),
            colors: [Color.lerp(c, Colors.white, 0.3)!, c],
            background: colors.surfaceHighest,
            height: 7,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  s.gifterLevelTierProgress(
                    _fmt(context, journey.xp),
                    _fmt(context, tier.xpRequired),
                  ),
                  style: _small(colors, false),
                ),
              ),
              Text(
                s.gifterLevelTierXpMissing(_fmt(context, tier.xpMissing)),
                style: _small(colors, true),
              ),
            ],
          ),
        ],
      );
    } else if (isCurrent) {
      final next = journey.nextLevel;
      progress = Text(
        next == null
            ? s.gifterLevelMaxReached
            : s.gifterLevelXpMissing(
                _fmt(context, next.xpNeeded),
                next.nextLevel,
              ),
        style: _small(colors, true),
      );
    } else {
      progress = Text(
        s.gifterLevelUnlockedAt(_fmt(context, tier.xpRequired)),
        style: _small(colors, false),
      );
    }

    final benefits = <Widget>[
      if (tier.vipEntry)
        _BenefitChip(
          icon: LucideIcons.crown,
          text: s.gifterLevelBenefitVip,
          color: c,
          dim: locked,
        ),
      if (tier.hasEntryEffect)
        _BenefitChip(
          icon: LucideIcons.sparkles,
          text: s.gifterLevelBenefitEntryEffect,
          color: c,
          dim: locked,
        ),
      if (tier.announceLevelUp)
        _BenefitChip(
          icon: LucideIcons.megaphone,
          text: s.gifterLevelBenefitAnnounce,
          color: c,
          dim: locked,
        ),
      if (!tier.hasBenefits)
        _BenefitChip(
          icon: LucideIcons.award,
          text: s.gifterLevelNoBenefits,
          color: c,
          dim: locked,
        ),
    ];

    return GameTile(
      tint: locked ? colors.textTertiary : c,
      depth: 3,
      radius: 18,
      glow: isCurrent ? 0.35 : 0,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.nameFor(lang),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      range,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 13, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: locked ? colors.textSecondary : statusColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          progress,
          const SizedBox(height: 12),
          Text(
            s.gifterLevelBenefits.toUpperCase(),
            style: TextStyle(
              color: colors.textTertiary,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: benefits),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "Como ganhar XP": uma linha só; o detalhe abre numa folha por baixo

class _HowToEarnTile extends StatelessWidget {
  const _HowToEarnTile({required this.rules});
  final List<_Rule> rules;

  void _open(BuildContext context) {
    final s = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      builder: (ctx) {
        final colors = ctx.colors;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.gifterLevelHowToEarn,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < rules.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, thickness: 1, color: colors.divider),
                  _RuleRow(rule: rules[i]),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return GameTile(
      tint: colors.accentPrimary,
      depth: 3,
      radius: 16,
      onTap: () => _open(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accentPrimary.withValues(alpha: 0.14),
            ),
            child: Icon(LucideIcons.zap, size: 16, color: colors.accentPrimary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.gifterLevelHowToEarn,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    for (final r in rules.take(4))
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          r.icon,
                          size: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
        ],
      ),
    );
  }
}

class _Rule {
  final IconData icon;
  final String text;
  const _Rule(this.icon, this.text);
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.rule});
  final _Rule rule;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accentPrimary.withValues(alpha: 0.14),
            ),
            child: Icon(rule.icon, size: 15, color: colors.accentPrimary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rule.text,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniDot extends StatelessWidget {
  const _MiniDot({required this.color, required this.icon, this.size = 18});
  final Color color;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: context.colors.background, width: 1.5),
      ),
      child: Icon(icon, size: size * 0.56, color: Colors.white),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({
    required this.icon,
    required this.text,
    required this.color,
    required this.dim,
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = dim ? colors.textTertiary : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: dim ? colors.textSecondary : colors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carregando / erro

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final base = context.colors.shimmerBase;
    Widget box(double w, double h, {double r = 10}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(r),
      ),
    );
    return Pulse(
      minScale: 0.985,
      maxScale: 1.0,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Center(child: box(120, 120, r: 60)),
          const SizedBox(height: 14),
          Center(child: box(110, 26)),
          const SizedBox(height: 8),
          Center(child: box(80, 16)),
          const SizedBox(height: 16),
          box(double.infinity, 10, r: 8),
          const SizedBox(height: 22),
          box(double.infinity, 120, r: 16),
          const SizedBox(height: 22),
          for (var i = 0; i < 3; i++) ...[
            Row(
              children: [
                box(44, 44, r: 22),
                const SizedBox(width: 12),
                Expanded(child: box(double.infinity, 36)),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.wifiOff, size: 40, color: colors.textTertiary),
            const SizedBox(height: 12),
            Text(
              s.gifterLevelLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: Text(s.gifterLevelRetry),
            ),
          ],
        ),
      ),
    );
  }
}
