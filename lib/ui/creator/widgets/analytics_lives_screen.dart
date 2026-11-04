import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../../data/services/analytics_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../feed/widgets/story_video_trim_screen.dart';
import '../../quests/widgets/quest_visuals.dart';
import '../view_models/creator_analytics_view_model.dart';
import 'analytics/analytics_async_chart.dart';
import 'analytics/analytics_data.dart';
import 'analytics/analytics_format.dart';
import 'analytics/analytics_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS — LIVES
// GET /analytics/lives-series  → lives/minutos/espectadores por dia + anterior
// GET /analytics/live-history?page=1&limit=20 → histórico paginado
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
  int _metric = 0; // 0 = lives (barras), 1 = minutos (linha)
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
    try {
      final next = await ref.read(liveHistoryPageProvider(_page + 1).future);
      if (!mounted) return;
      setState(() {
        _page++;
        _items.addAll(next.items);
        _hasMore = _items.length < next.total;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _refresh(String period) async {
    ref.invalidate(liveHistoryPageProvider);
    ref.invalidate(livesSeriesProvider(period));
    setState(() {
      _page = 1;
      _items.clear();
      _hasMore = true;
    });
    await ref
        .read(livesSeriesProvider(period).future)
        .then((_) {}, onError: (_) {});
  }

  /// "2h 05min" / "45 min"
  String _duration(S s, double minutes) {
    final t = minutes.round();
    if (t < 60) return s.analyticsMinutesShort(t.toString());
    return s.analyticsHoursMinutes((t ~/ 60).toString(), (t % 60).toString());
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final fmt = AnalyticsFmt.of(context);
    final period = ref.watch(analyticsPeriodProvider);
    final seriesAsync = ref.watch(livesSeriesProvider(period));
    final firstPageAsync = ref.watch(liveHistoryPageProvider(1));
    const livesColor = AppColors.hotPink;
    const minColor = AppColors.braweOrange;

    List<AnalyticsKpi>? kpis;
    final d = seriesAsync.value;
    if (d != null) {
      kpis = [
        AnalyticsKpi(
          icon: LucideIcons.radio,
          color: livesColor,
          label: s.analyticsLivesKpiTotal,
          value: d.val('lives'),
          format: fmt.integer,
          deltaPct: d.pct('lives_change_pct'),
        ),
        AnalyticsKpi(
          icon: LucideIcons.clock,
          color: minColor,
          label: s.analyticsLivesMinutesLabel,
          value: d.val('minutes'),
          format: (v) => _duration(s, v),
          deltaPct: d.pct('minutes_change_pct'),
        ),
        AnalyticsKpi(
          icon: LucideIcons.eye,
          color: AppColors.braweBlue,
          label: s.analyticsViewersTotalViewers,
          value: d.val('viewers'),
          format: fmt.compact,
          deltaPct: d.pct('viewers_change_pct'),
        ),
        AnalyticsKpi(
          icon: LucideIcons.gift,
          color: AppColors.success,
          label: s.analyticsEarningsLabel,
          value: d.val('gifts_usdt'),
          format: fmt.moneyCompact,
          deltaPct: d.pct('gifts_change_pct'),
        ),
      ];
    }

    final isLives = _metric == 0;
    final label = isLives ? s.analyticsLivesChartLives : s.analyticsLivesChartMinutes;
    final color = isLives ? livesColor : minColor;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, size: 20, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          s.analyticsLivesTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.braweBlue,
        onRefresh: () => _refresh(period),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 14),
                    child: AnalyticsPeriodSegment(),
                  ),
                  AnalyticsKpiGrid(kpis: kpis, skeletonCount: 4),
                  const SizedBox(height: 16),
                  AnalyticsChartPanel(
                    title: label,
                    toolbar: AnalyticsChipToggle(
                      labels: [
                        s.analyticsLivesChartLives,
                        s.analyticsLivesChartMinutes,
                      ],
                      selected: _metric,
                      color: color,
                      onChanged: (i) => setState(() => _metric = i),
                    ),
                    builder: (compare) => AnalyticsAsyncChart(
                      async: seriesAsync,
                      onRetry: () => ref.invalidate(livesSeriesProvider(period)),
                      builder: (series) => isLives
                          ? seriesBarChart(
                              context,
                              series,
                              label: label,
                              color: color,
                              compare: compare,
                              format: fmt.integer,
                            )
                          : seriesLineChart(
                              context,
                              series,
                              label: label,
                              color: color,
                              useSecond: true,
                              compare: compare,
                              format: (v) => _duration(s, v),
                            ),
                    ),
                    legendBuilder: (compare) =>
                        seriesLegend(context, [(color: color, label: label)], compare),
                  ),
                  AnalyticsSectionTitle(title: s.analyticsLivesHistoryTitle),
                ]),
              ),
            ),
            ..._historySlivers(firstPageAsync),
          ],
        ),
      ),
    );
  }

  List<Widget> _historySlivers(
    AsyncValue<({List<LiveHistoryItem> items, int total})> firstPageAsync,
  ) {
    return firstPageAsync.when(
      loading: () => [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                AnalyticsSkeleton(height: 96, radius: 16),
                SizedBox(height: 10),
                AnalyticsSkeleton(height: 96, radius: 16),
              ],
            ),
          ),
        ),
      ],
      error: (e, _) => [
        SliverToBoxAdapter(
          child: AnalyticsErrorView(
            height: 180,
            onRetry: () => ref.invalidate(liveHistoryPageProvider),
          ),
        ),
      ],
      data: (page1) {
        final allItems = _items.isEmpty ? page1.items : _items;
        if (allItems.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: SizedBox(height: 320, child: _EmptyLives()),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                if (i == allItems.length) {
                  return _loadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const SizedBox.shrink();
                }
                return StaggerIn(index: i.clamp(0, 6), child: _LiveTile(item: allItems[i]));
              }, childCount: allItems.length + 1),
            ),
          ),
        ];
      },
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
                // Replay badge — mostra para lives com replay pronto OU pendente de processamento
                if ((item.hasReplay && item.isReplayAvailable) ||
                    item.replayMayBePending)
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
                  value: AnalyticsFmt.of(context).integer(item.viewerCount),
                  label: s.analyticsLivesMetricViewers,
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  icon: LucideIcons.trendingUp,
                  value: AnalyticsFmt.of(context).integer(item.peakViewers),
                  label: s.analyticsLivesMetricPeak,
                ),
                const SizedBox(width: 8),
                if (item.giftsValue > 0)
                  _MetricChip(
                    icon: LucideIcons.gift,
                    value: AnalyticsFmt.of(context).money(item.giftsValue),
                    label: s.analyticsLivesMetricEarned,
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

class _ReplayBadge extends ConsumerStatefulWidget {
  final LiveHistoryItem item;
  const _ReplayBadge({required this.item});

  @override
  ConsumerState<_ReplayBadge> createState() => _ReplayBadgeState();
}

class _ReplayBadgeState extends ConsumerState<_ReplayBadge> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    // ── Tem URL direto → botão de Play imediato ─────────────────────
    if (item.hasReplay && item.isReplayAvailable) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlayButton(context, item.replayUrl!, loading: false),
          const SizedBox(width: 6),
          _buildDownloadButton(context, item),
        ],
      );
    }

    // ── Replay pode estar sendo processado → botão "Carregar" ────────
    if (item.replayMayBePending) {
      return _loading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.accentPrimary,
              ),
            )
          : GestureDetector(
              onTap: _fetchReplay,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.accentPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: context.colors.accentPrimary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.refreshCw,
                      size: 10,
                      color: context.colors.accentPrimary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Ver replay',
                      style: TextStyle(
                        color: context.colors.accentPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPlayButton(
    BuildContext context,
    String url, {
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: loading ? null : () => _openPlayer(context, url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.braweBlue, AppColors.braweSky],
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

  Widget _buildDownloadButton(BuildContext context, LiveHistoryItem item) {
    return GestureDetector(
      onTap: () => _showDownloadSheet(context, item),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.4),
          ),
        ),
        child: const Icon(
          LucideIcons.download,
          size: 12,
          color: Color(0xFF10B981),
        ),
      ),
    );
  }

  Future<void> _fetchReplay() async {
    setState(() => _loading = true);
    try {
      final service = ref.read(analyticsServiceProvider);
      final result = await service.getLiveReplay(widget.item.id);
      if (!mounted) return;

      final success = result['success'] == true;
      final data = result['data'] as Map<String, dynamic>?;
      final error = result['error']?.toString();

      if (success && data != null) {
        final url = data['recording_url']?.toString() ?? '';
        if (url.isNotEmpty) {
          _openPlayer(context, url);
        }
      } else if (error == 'replay_expired') {
        _showSnack(
          context,
          S.of(context).analyticsLivesReplayExpired,
          isError: true,
        );
      } else {
        _showSnack(
          context,
          S.of(context).analyticsLivesReplayExpiredSub,
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) _showSnack(context, 'Erro ao buscar replay', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openPlayer(BuildContext context, String url) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => _LiveReplayPlayer(item: widget.item, overrideUrl: url),
        fullscreenDialog: true,
      ),
    );
  }

  void _showSnack(BuildContext context, String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? Colors.red.shade700
            : context.colors.accentPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDownloadSheet(BuildContext context, LiveHistoryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // SafeArea(bottom): botões acima da barra de navegação (edge-to-edge).
      builder: (_) => SafeArea(top: false, child: _DownloadSheet(item: item)),
    );
  }
}

// ── Replay player (fullscreen) ────────────────────────────────────────────────

class _LiveReplayPlayer extends StatefulWidget {
  final LiveHistoryItem item;
  final String overrideUrl; // URL já resolvida (do endpoint /replay ou direto)

  const _LiveReplayPlayer({required this.item, required this.overrideUrl});

  @override
  State<_LiveReplayPlayer> createState() => _LiveReplayPlayerState();
}

class _LiveReplayPlayerState extends State<_LiveReplayPlayer> {
  VideoPlayerController? _vpc;
  ChewieController? _chewie;
  bool _error = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _vpc = VideoPlayerController.networkUrl(Uri.parse(widget.overrideUrl));
      await _vpc!.initialize();
      _chewie = ChewieController(
        videoPlayerController: _vpc!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.braweBlue,
          handleColor: AppColors.braweBlue,
          bufferedColor: AppColors.braweBlue.withValues(alpha: 0.3),
        ),
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted)
        setState(() {
          _error = true;
          _errorMsg = e.toString();
        });
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
    final s = S.of(context);
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
              ? s.analyticsLivesReplayLabel
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
                    s.analyticsLivesReplayExpired,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.analyticsLivesReplayExpiredSub,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _errorMsg!,
                        style: const TextStyle(
                          color: Colors.white24,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
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

// ── Download sheet ────────────────────────────────────────────────────────────

class _DownloadSheet extends ConsumerStatefulWidget {
  final LiveHistoryItem item;
  const _DownloadSheet({required this.item});

  @override
  ConsumerState<_DownloadSheet> createState() => _DownloadSheetState();
}

/// Fases do fluxo de download.
enum _DlPhase { idle, downloading, converting, done, error }

class _DownloadSheetState extends ConsumerState<_DownloadSheet> {
  static const _green = Color(0xFF10B981);

  _DlPhase _phase = _DlPhase.idle;
  double _progress = 0.0;
  String? _errorMsg;
  String _selectedQuality = 'high';
  File? _downloadedFile;
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _cancelToken?.cancel('sheet_closed');
    super.dispose();
  }

  Future<void> _startDownload(String quality) async {
    _selectedQuality = quality;
    _cancelToken = CancelToken();
    setState(() {
      _phase = _DlPhase.downloading;
      _progress = 0.0;
      _errorMsg = null;
    });

    try {
      final service = ref.read(analyticsServiceProvider);
      final dir = await getTemporaryDirectory();
      final safeName =
          'live_${widget.item.id}_${quality}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savePath = '${dir.path}/$safeName';

      final result = await service.downloadLiveFile(
        widget.item.id,
        quality: quality,
        savePath: savePath,
        cancelToken: _cancelToken,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p.clamp(0.0, 1.0));
        },
      );

      if (!mounted) return;
      final file = File(savePath);
      if (!await file.exists()) {
        throw Exception('file_missing');
      }

      _downloadedFile = file;
      assert(result.isNotEmpty);

      await _saveToGallery(file);
    } catch (e) {
      if (!mounted) return;
      if (e is DioException && CancelToken.isCancel(e)) return;
      setState(() {
        _phase = _DlPhase.error;
        _errorMsg = _friendlyError(e);
      });
    }
  }

  Future<void> _editAndConvert() async {
    final file = _downloadedFile;
    if (file == null) return;

    final edited = await StoryVideoTrimScreen.push(
      context,
      file: file,
      maxDuration: const Duration(hours: 2),
    );

    if (!mounted || edited == null) return;
    setState(() => _phase = _DlPhase.converting);
    await _saveToGallery(edited);
  }

  Future<void> _saveToGallery(File file) async {
    setState(() => _phase = _DlPhase.converting);
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: false);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: false);
        if (!granted) {
          if (!mounted) return;
          setState(() {
            _phase = _DlPhase.error;
            _errorMsg = S.of(context).composerSavePermissionDenied;
          });
          return;
        }
      }

      await Gal.putVideo(file.path, album: 'Brawe');
      if (!mounted) return;
      setState(() => _phase = _DlPhase.done);
    } on GalException catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _DlPhase.error;
        _errorMsg = e.type == GalExceptionType.accessDenied
            ? S.of(context).composerSavePermissionDenied
            : S.of(context).composerSaveError;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _DlPhase.error;
        _errorMsg = _friendlyError(e);
      });
    }
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      if (code == 404) {
        return 'O arquivo ainda está sendo preparado pelo servidor. '
            'Tente novamente em alguns minutos.';
      }
      if (code == 410) {
        return 'O replay expirou (disponível por 30 dias após a live).';
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Conexão lenta. Verifique sua internet e tente novamente.';
      }
    }
    final msg = e.toString();
    if (msg.contains('download_processing')) {
      return 'O vídeo está sendo preparado para download. '
          'Isso leva alguns minutos após a live. Tente novamente em breve.';
    }
    if (msg.contains('download_unavailable')) {
      return 'Download não disponível para esta live.';
    }
    return 'Não foi possível concluir. Tente novamente.';
  }

  void _reset() {
    setState(() {
      _phase = _DlPhase.idle;
      _progress = 0.0;
      _errorMsg = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = context.colors.textPrimary;
    final textSec = context.colors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(LucideIcons.download, color: _green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Baixar Live',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.item.title.isEmpty ? 'Live sem título' : widget.item.title,
            style: TextStyle(color: textSec, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          switch (_phase) {
            _DlPhase.idle => _buildQualityPicker(textSec),
            _DlPhase.downloading => _buildProgress(textPrimary, textSec),
            _DlPhase.converting => _buildConverting(textPrimary, textSec),
            _DlPhase.done => _buildDone(textPrimary, textSec),
            _DlPhase.error => _buildError(textPrimary),
          },
        ],
      ),
    );
  }

  Widget _buildQualityPicker(Color textSec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione a qualidade:',
          style: TextStyle(color: textSec, fontSize: 12),
        ),
        const SizedBox(height: 10),
        _QualityButton(
          label: '1080p (Alta qualidade)',
          icon: LucideIcons.video,
          color: context.colors.accentPrimary,
          onTap: () => _startDownload('high'),
        ),
        const SizedBox(height: 8),
        _QualityButton(
          label: '720p (Média qualidade)',
          icon: LucideIcons.video,
          color: const Color(0xFF3B82F6),
          onTap: () => _startDownload('medium'),
        ),
        const SizedBox(height: 8),
        _QualityButton(
          label: '480p (Menor tamanho)',
          icon: LucideIcons.video,
          color: _green,
          onTap: () => _startDownload('low'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(LucideIcons.smartphone, size: 13, color: textSec),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'O vídeo será baixado e salvo direto na galeria.',
                style: TextStyle(color: textSec, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgress(Color textPrimary, Color textSec) {
    final pct = (_progress * 100).clamp(0, 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Baixando…',
              style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$pct%',
              style: const TextStyle(
                color: _green,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress > 0 ? _progress : null,
            minHeight: 8,
            backgroundColor: _green.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation(_green),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton.icon(
            onPressed: () {
              _cancelToken?.cancel('user_cancelled');
              _reset();
            },
            icon: const Icon(LucideIcons.x, size: 14),
            label: const Text('Cancelar'),
            style: TextButton.styleFrom(foregroundColor: textSec),
          ),
        ),
      ],
    );
  }

  Widget _buildConverting(Color textPrimary, Color textSec) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const CircularProgressIndicator(strokeWidth: 2.5, color: _green),
        const SizedBox(height: 16),
        Text(
          'Preparando para a galeria…',
          style: TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Convertendo para o formato do dispositivo.',
          style: TextStyle(color: textSec, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDone(Color textPrimary, Color textSec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.checkCircle2, color: _green, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Salvo na galeria (álbum “Brawe”).',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_downloadedFile != null)
          OutlinedButton.icon(
            onPressed: _editAndConvert,
            icon: const Icon(LucideIcons.scissors, size: 16),
            label: const Text('Cortar / editar vídeo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.braweBlue,
              side: BorderSide(
                color: AppColors.braweBlue.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Concluir'),
        ),
      ],
    );
  }

  Widget _buildError(Color textPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.alertTriangle,
                color: Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _errorMsg ?? 'Falha ao baixar.',
                  style: TextStyle(color: textPrimary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => _startDownload(_selectedQuality),
          icon: const Icon(LucideIcons.refreshCw, size: 16),
          label: const Text('Tentar novamente'),
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _QualityButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QualityButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(
              LucideIcons.chevronRight,
              color: color.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
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
