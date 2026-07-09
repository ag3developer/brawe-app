import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/creator_analytics_view_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS — HISTÓRICO DE LIVES
// GET /analytics/live-history?page=1&limit=20
// GET /profile/:userId/lives  → playback_url (Mux HLS, válido 30 dias)
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsLivesScreen extends ConsumerStatefulWidget {
  const AnalyticsLivesScreen({super.key});

  @override
  ConsumerState<AnalyticsLivesScreen> createState() =>
      _AnalyticsLivesScreenState();
}

class _AnalyticsLivesScreenState extends ConsumerState<AnalyticsLivesScreen> {
  int _page = 1;
  final List<LiveHistoryItem> _items = [];
  bool _hasMore = true;
  bool _loadingMore = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final next = await ref.read(liveHistoryPageProvider(_page + 1).future);
    setState(() {
      _page++;
      _items.addAll(next.items);
      _hasMore = _items.length < next.total;
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstPageAsync = ref.watch(liveHistoryPageProvider(1));

    return Scaffold(
      backgroundColor: context.colors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: context.colors.background.withValues(alpha: 0.88),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: const SizedBox.expand(),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            size: 20,
            color: context.colors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context).analyticsLivesTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
      body: firstPageAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.alertCircle,
                color: context.colors.textTertiary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context).analyticsLivesErrorLoad,
                style: TextStyle(color: context.colors.textSecondary),
              ),
              TextButton(
                onPressed: () => ref.invalidate(liveHistoryPageProvider),
                child: Text(S.of(context).analyticsLivesRetry),
              ),
            ],
          ),
        ),
        data: (page1) {
          final allItems = _items.isEmpty ? page1.items : _items;
          if (allItems.isEmpty) {
            return _EmptyLives();
          }

          return RefreshIndicator(
            color: AppColors.electricPurple,
            onRefresh: () async {
              ref.invalidate(liveHistoryPageProvider);
              setState(() {
                _page = 1;
                _items.clear();
                _hasMore = true;
              });
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header com KPIs
                SliverPadding(
                  padding: EdgeInsets.only(
                    top:
                        MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        16,
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _LivesKpiRow(items: allItems),
                  ),
                ),

                // Lista de lives
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      if (i == allItems.length) {
                        return _loadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      }
                      return _LiveTile(item: allItems[i]);
                    }, childCount: allItems.length + 1),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── KPIs do histórico ─────────────────────────────────────────────────────────

class _LivesKpiRow extends StatelessWidget {
  final List<LiveHistoryItem> items;
  const _LivesKpiRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final total = items.length;
    final totalViewers = items.fold(0, (s, e) => s + e.viewerCount);
    final avgViewers = total > 0 ? totalViewers ~/ total : 0;
    final totalGifts = items.fold(0.0, (s, e) => s + e.giftsValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final s = S.of(context);
    final stats = [
      (
        LucideIcons.radio,
        s.analyticsLivesKpiTotal,
        '$total',
        const Color(0xFFEC4899),
      ),
      (
        LucideIcons.eye,
        s.analyticsLivesKpiAvgViewers,
        '$avgViewers',
        const Color(0xFF3B82F6),
      ),
      (
        LucideIcons.gift,
        s.analyticsLivesKpiGifts,
        totalGifts.toStringAsFixed(1),
        const Color(0xFFF59E0B),
      ),
    ];

    return Row(
      children: stats.asMap().entries.map((e) {
        final s = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: e.key < stats.length - 1 ? 8 : 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: s.$4.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(s.$1, color: s.$4, size: 16),
                const SizedBox(height: 4),
                Text(
                  s.$3,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  s.$2,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Tile de uma live ──────────────────────────────────────────────────────────

class _LiveTile extends StatelessWidget {
  final LiveHistoryItem item;
  const _LiveTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);
    final months = s.analyticsLivesMonthsShort.split(',');
    final date = item.startedAt != null
        ? '${item.startedAt!.day} ${months[item.startedAt!.month - 1]} ${item.startedAt!.year}'
        : '—';
    final dur = s.analyticsLivesDuration(
      item.durationMinutes.toStringAsFixed(0),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.radio,
                    size: 15,
                    color: Color(0xFFEC4899),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.isEmpty
                            ? s.analyticsLivesNoTitle
                            : item.title,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$date · $dur',
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Replay badge
                if (item.hasReplay && item.isReplayAvailable)
                  _ReplayBadge(item: item),
              ],
            ),
          ),

          // Métricas
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                _MetricChip(
                  icon: LucideIcons.eye,
                  value: '${item.viewerCount}',
                  label: s.analyticsLivesMetricViewers,
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  icon: LucideIcons.trendingUp,
                  value: '${item.peakViewers}',
                  label: s.analyticsLivesMetricPeak,
                ),
                const SizedBox(width: 8),
                if (item.giftsValue > 0)
                  _MetricChip(
                    icon: LucideIcons.gift,
                    value: item.giftsValue.toStringAsFixed(1),
                    label: s.analyticsLivesMetricUsdt,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: context.colors.textTertiary),
        const SizedBox(width: 3),
        Text(
          '$value $label',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

class _ReplayBadge extends StatelessWidget {
  final LiveHistoryItem item;
  const _ReplayBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openReplay(context, item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.play, size: 10, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              S.of(context).analyticsLivesReplayLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReplay(BuildContext context, LiveHistoryItem item) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => _LiveReplayPlayer(item: item),
        fullscreenDialog: true,
      ),
    );
  }
}

// ── Replay player (fullscreen) ────────────────────────────────────────────────

class _LiveReplayPlayer extends StatefulWidget {
  final LiveHistoryItem item;
  const _LiveReplayPlayer({required this.item});

  @override
  State<_LiveReplayPlayer> createState() => _LiveReplayPlayerState();
}

class _LiveReplayPlayerState extends State<_LiveReplayPlayer> {
  VideoPlayerController? _vpc;
  ChewieController? _chewie;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _vpc = VideoPlayerController.networkUrl(
        Uri.parse(widget.item.playbackUrl!),
      );
      await _vpc!.initialize();
      _chewie = ChewieController(
        videoPlayerController: _vpc!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.electricPurple,
          handleColor: AppColors.electricPurple,
          bufferedColor: AppColors.electricPurple.withValues(alpha: 0.3),
        ),
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _vpc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.item.title.isEmpty
              ? S.of(context).analyticsLivesReplayLabel
              : widget.item.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: _error
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.videoOff,
                    color: Colors.white54,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    S.of(context).analyticsLivesReplayExpired,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).analyticsLivesReplayExpiredSub,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              )
            : _chewie == null
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : AspectRatio(
                aspectRatio: 9 / 16,
                child: Chewie(controller: _chewie!),
              ),
      ),
    );
  }
}

// ── Estado vazio ──────────────────────────────────────────────────────────────

class _EmptyLives extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.radio,
              color: Color(0xFFEC4899),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).analyticsLivesEmptyTitle,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            S.of(context).analyticsLivesEmptySubtitle,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
