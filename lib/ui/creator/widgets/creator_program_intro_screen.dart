import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../domain/models/creator_network.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_network_view_model.dart';
import '../widgets/creator_state_views.dart';

/// Guia do Criador: cabeçalho, sumário tocável e seções curtas.
class CreatorProgramIntroScreen extends ConsumerStatefulWidget {
  const CreatorProgramIntroScreen({super.key});

  @override
  ConsumerState<CreatorProgramIntroScreen> createState() =>
      _CreatorProgramIntroScreenState();
}

class _CreatorProgramIntroScreenState
    extends ConsumerState<CreatorProgramIntroScreen> {
  // Uma chave por seção do sumário (what, benefits, levels, how, rules, faq).
  final _keys = List.generate(6, (_) => GlobalKey());

  void _scrollTo(int i) {
    final ctx = _keys[i].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final overviewAsync = ref.watch(networkOverviewProvider);
    final applicationAsync = ref.watch(myCreatorApplicationProvider);
    final creatorAsync = ref.watch(myCreatorProfileProvider);

    final toc = <(IconData, String)>[
      (LucideIcons.info, s.creatorGuideSecWhat),
      (LucideIcons.gift, s.creatorGuideSecBenefits),
      (LucideIcons.layers, s.creatorGuideSecLevels),
      (LucideIcons.route, s.creatorGuideSecHow),
      (LucideIcons.shieldCheck, s.creatorGuideSecRules),
      (LucideIcons.circleHelp, s.creatorGuideSecFaq),
    ];

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(s.creatorGuideTitle),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: c.background,
            border: Border(top: BorderSide(color: c.border)),
          ),
          child: FilledButton.icon(
            onPressed: () => _onCta(context, applicationAsync, creatorAsync),
            icon: Icon(_ctaIcon(applicationAsync, creatorAsync), size: 18),
            label: Text(_ctaLabel(s, applicationAsync, creatorAsync)),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: c.accentPrimary,
              foregroundColor: c.textOnAccent,
            ),
          ),
        ),
      ),
      body: overviewAsync.when(
        loading: () => const CreatorLoadingView(),
        error: (e, _) => CreatorErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(networkOverviewProvider),
        ),
        data: (overview) {
          final byTier = {for (final t in overview.tiers) t.slug: t};
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(networkOverviewProvider);
              ref.invalidate(myCreatorApplicationProvider);
              ref.invalidate(myCreatorProfileProvider);
              await ref.read(networkOverviewProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                // ── Cabeçalho ──
                Text(
                  s.creatorProgramTitle,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.creatorGuideIntro,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                if (overview.totalCreators > 0) ...[
                  const SizedBox(height: 12),
                  _StatPill(label: s.creatorTotalCreators(overview.totalCreators)),
                ],
                const SizedBox(height: 20),

                // ── Sumário ──
                _Label(s.creatorGuideToc),
                const SizedBox(height: 8),
                _Card(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < toc.length; i++) ...[
                        InkWell(
                          onTap: () => _scrollTo(i),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Icon(toc[i].$1,
                                    size: 18, color: c.accentPrimary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    toc[i].$2,
                                    style: TextStyle(
                                      color: c.textPrimary,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(LucideIcons.chevronRight,
                                    size: 16, color: c.textTertiary),
                              ],
                            ),
                          ),
                        ),
                        if (i != toc.length - 1)
                          Divider(height: 1, indent: 44, color: c.border),
                      ],
                    ],
                  ),
                ),

                // ── O que é ──
                _Section(
                  key: _keys[0],
                  icon: LucideIcons.info,
                  title: s.creatorGuideSecWhat,
                  child: _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.creatorGuideWhatBody,
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 13.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Check(s.creatorGuideWhatPoint1),
                        _Check(s.creatorGuideWhatPoint2),
                        _Check(s.creatorGuideWhatPoint3),
                      ],
                    ),
                  ),
                ),

                // ── Benefícios ──
                _Section(
                  key: _keys[1],
                  icon: LucideIcons.gift,
                  title: s.creatorGuideSecBenefits,
                  child: _Card(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        _IconRow(LucideIcons.eye, s.creatorBenefit1),
                        _IconRow(LucideIcons.userRound, s.creatorBenefit2),
                        _IconRow(LucideIcons.badgeCheck, s.creatorBenefit3),
                        _IconRow(LucideIcons.radio, s.creatorBenefit4),
                        _IconRow(LucideIcons.users, s.creatorBenefit5),
                      ],
                    ),
                  ),
                ),

                // ── Níveis ──
                _Section(
                  key: _keys[2],
                  icon: LucideIcons.layers,
                  title: s.creatorGuideSecLevels,
                  child: Column(
                    children: [
                      for (final t in kCreatorTiersOrder.reversed)
                        _TierTile(
                          tier: t,
                          title: byTier[t]?.name.isNotEmpty == true
                              ? byTier[t]!.name
                              : t.title(s),
                          body: byTier[t]?.description.isNotEmpty == true
                              ? byTier[t]!.description
                              : t.body(s),
                          perks: byTier[t]?.perks ?? const [],
                        ),
                    ],
                  ),
                ),

                // ── Como entrar ──
                _Section(
                  key: _keys[3],
                  icon: LucideIcons.route,
                  title: s.creatorGuideSecHow,
                  child: _Card(
                    child: Column(
                      children: [
                        _Step(1, s.creatorGuideHowStep1, last: false),
                        _Step(2, s.creatorGuideHowStep2, last: false),
                        _Step(3, s.creatorGuideHowStep3, last: false),
                        _Step(4, s.creatorGuideHowStep4, last: true),
                      ],
                    ),
                  ),
                ),

                // ── Diretrizes ──
                _Section(
                  key: _keys[4],
                  icon: LucideIcons.shieldCheck,
                  title: s.creatorGuideSecRules,
                  child: _Card(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        _IconRow(LucideIcons.copyCheck, s.creatorGuideRule1),
                        _IconRow(LucideIcons.heartHandshake, s.creatorGuideRule2),
                        _IconRow(LucideIcons.userX, s.creatorGuideRule3),
                        _IconRow(LucideIcons.baby, s.creatorGuideRule4),
                        _IconRow(LucideIcons.fileText, s.creatorGuideRule5),
                      ],
                    ),
                  ),
                ),

                // ── Perguntas frequentes ──
                _Section(
                  key: _keys[5],
                  icon: LucideIcons.circleHelp,
                  title: s.creatorGuideSecFaq,
                  child: Column(
                    children: [
                      _Faq(s.creatorGuideFaq1Q, s.creatorGuideFaq1A),
                      _Faq(s.creatorGuideFaq2Q, s.creatorGuideFaq2A),
                      _Faq(s.creatorGuideFaq3Q, s.creatorGuideFaq3A),
                      _Faq(s.creatorGuideFaq4Q, s.creatorGuideFaq4A),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Ícone acompanha a ação: preencher a inscrição, acompanhar o status ou
  /// abrir o painel de criador.
  IconData _ctaIcon(
    AsyncValue<CreatorApplication?> appAsync,
    AsyncValue<CreatorProfile?> creatorAsync,
  ) {
    if (creatorAsync.value != null) return LucideIcons.layoutDashboard;
    if (appAsync.value != null) return LucideIcons.clipboardCheck;
    return LucideIcons.clipboardPenLine;
  }

  String _ctaLabel(
    S s,
    AsyncValue<CreatorApplication?> appAsync,
    AsyncValue<CreatorProfile?> creatorAsync,
  ) {
    if (creatorAsync.value != null) return s.creatorDashboardTitle;
    if (appAsync.value != null) return s.creatorActionCheckStatus;
    return s.creatorActionApplyNow;
  }

  void _onCta(
    BuildContext context,
    AsyncValue<CreatorApplication?> appAsync,
    AsyncValue<CreatorProfile?> creatorAsync,
  ) {
    if (creatorAsync.value != null) {
      context.push('/creator/dashboard');
    } else if (appAsync.value != null) {
      context.push('/creator/status');
    } else {
      context.push('/creator/apply');
    }
  }
}

// ── Componentes compactos do guia ─────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
          color: context.colors.textTertiary,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(14)});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: child,
      );
}

class _Section extends StatelessWidget {
  const _Section({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });
  final IconData icon;
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: c.accentPrimary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(LucideIcons.check, size: 16, color: context.colors.accentPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: context.colors.textPrimary, fontSize: 13.5)),
            ),
          ],
        ),
      );
}

class _IconRow extends StatelessWidget {
  const _IconRow(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c.accentPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: c.accentPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: c.textPrimary, fontSize: 14, height: 1.3)),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.n, this.text, {required this.last});
  final int n;
  final String text;
  final bool last;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.accentPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Text('$n',
                      style: TextStyle(
                        color: c.textOnAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      )),
                ),
                if (!last)
                  Expanded(child: Container(width: 2, color: c.border)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2, bottom: last ? 0 : 16),
              child: Text(text,
                  style: TextStyle(
                      color: c.textPrimary, fontSize: 14, height: 1.3)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nível: linha compacta que expande para mostrar descrição e vantagens.
class _TierTile extends StatefulWidget {
  const _TierTile({
    required this.tier,
    required this.title,
    required this.body,
    required this.perks,
  });
  final CreatorTier tier;
  final String title;
  final String body;
  final List<String> perks;
  @override
  State<_TierTile> createState() => _TierTileState();
}

class _TierTileState extends State<_TierTile> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = widget.tier;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _open = !_open),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: CreatorTierL10n(t).gradient),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(CreatorTierL10n(t).icon, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(widget.title,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                    Icon(_open ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                        size: 18, color: c.textTertiary),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _open
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.body,
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 13,
                                    height: 1.4,
                                  )),
                              for (final p in widget.perks)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2),
                                        child: Icon(LucideIcons.check,
                                            size: 14, color: CreatorTierL10n(t).color),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(p,
                                            style: TextStyle(
                                              color: c.textPrimary,
                                              fontSize: 13,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq(this.q, this.a);
  final String q;
  final String a;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            iconColor: c.textTertiary,
            collapsedIconColor: c.textTertiary,
            title: Text(q,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
            children: [
              Text(a,
                  style: TextStyle(
                      color: c.textSecondary, fontSize: 13.5, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.users, size: 14, color: c.accentPrimary),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
