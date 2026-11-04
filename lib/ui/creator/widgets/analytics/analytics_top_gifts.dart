import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/utils/gift_names.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../../core/widgets/gift_icon.dart';
import '../../../quests/widgets/quest_visuals.dart';
import 'analytics_data.dart';
import 'analytics_format.dart';
import 'analytics_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top presentes: cartão de destaque para o nº 1 e lista para os demais.
// ─────────────────────────────────────────────────────────────────────────────

class _GiftRow {
  final String slug;
  final String tier;
  final String? iconUrl;
  final String name;
  final int count;
  final double usd;
  final double sharePct;
  _GiftRow(BuildContext context, Map<String, dynamic> j)
    : slug = (j['gift_slug'] ?? '').toString(),
      tier = (j['gift_tier'] ?? '').toString(),
      iconUrl = j['icon_url']?.toString(),
      count = ((j['quantity'] ?? j['count']) as num?)?.toInt() ?? 0,
      usd =
          ((j['earnings_usdt'] ?? j['total_usdt']) as num?)?.toDouble() ?? 0,
      sharePct = (j['share_pct'] as num?)?.toDouble() ?? 0,
      name = GiftNames.of(
        context,
        (j['gift_slug'] ?? '').toString(),
        fallback: (j['gift_name'] ?? '').toString(),
      );
}

class AnalyticsTopGifts extends ConsumerWidget {
  final String period;
  const AnalyticsTopGifts({super.key, required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final async = ref.watch(topGiftsByPeriodProvider(period));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyticsSectionTitle(
          title: s.analyticsTopGiftsTitle,
          subtitle: s.analyticsTopGiftsSubtitle,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: KeyedSubtree(
            key: ValueKey('${async.isLoading}-$period'),
            child: async.when(
              loading: () => const Column(
                children: [
                  AnalyticsSkeleton(height: 190, radius: 24),
                  SizedBox(height: 10),
                  AnalyticsSkeleton(height: 64, radius: 16),
                  SizedBox(height: 8),
                  AnalyticsSkeleton(height: 64, radius: 16),
                ],
              ),
              error: (_, _) => AnalyticsErrorView(
                height: 160,
                onRetry: () => ref.invalidate(topGiftsByPeriodProvider(period)),
              ),
              data: (raw) {
                if (raw.isEmpty) return const _NoGifts();
                final rows = [for (final j in raw) _GiftRow(context, j)];
                return Column(
                  children: [
                    _FeaturedGift(row: rows.first),
                    for (var i = 1; i < rows.length; i++) ...[
                      const SizedBox(height: 8),
                      _GiftTile(rank: i + 1, row: rows[i]),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _NoGifts extends StatelessWidget {
  const _NoGifts();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnalyticsCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            Icon(LucideIcons.gift, size: 30, color: colors.textTertiary),
            const SizedBox(height: 10),
            Text(
              S.of(context).analyticsTopGiftsEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedGift extends StatelessWidget {
  final _GiftRow row;
  const _FeaturedGift({required this.row});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final fmt = AnalyticsFmt.of(context);
    return GameTile(
      tint: AppColors.gold,
      radius: 24,
      depth: 5,
      glow: 0.25,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Floating(
            amplitude: 3,
            child: GiftIcon(
              slug: row.slug,
              tier: row.tier,
              iconUrl: row.iconUrl,
              size: 96,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.crown,
                        size: 11,
                        color: AppColors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        s.analyticsTopGiftsBest,
                        style: const TextStyle(
                          color: AppColors.amber,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  row.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.analyticsTopGiftsReceived(fmt.integer(row.count)),
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  fmt.money(row.usd),
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                _ShareBar(pct: row.sharePct, color: AppColors.amber),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftTile extends StatelessWidget {
  final int rank;
  final _GiftRow row;
  const _GiftTile({required this.rank, required this.row});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final fmt = AnalyticsFmt.of(context);
    return AnalyticsCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: colors.textTertiary,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
          GiftIcon(
            slug: row.slug,
            tier: row.tier,
            iconUrl: row.iconUrl,
            size: 48,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  s.analyticsTopGiftsReceived(fmt.integer(row.count)),
                  style: TextStyle(color: colors.textSecondary, fontSize: 11.5),
                ),
                const SizedBox(height: 6),
                _ShareBar(pct: row.sharePct, color: AppColors.braweBlue),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            fmt.money(row.usd),
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de participação com o % ao lado.
class _ShareBar extends StatelessWidget {
  final double pct;
  final Color color;
  const _ShareBar({required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fmt = AnalyticsFmt.of(context);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: (pct / 100).clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          fmt.percent(pct),
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
