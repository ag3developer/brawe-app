import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../../data/services/analytics_service.dart';
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
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF8B5CF6),
              ),
            )
          : GestureDetector(
              onTap: _fetchReplay,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.refreshCw,
                      size: 10,
                      color: Color(0xFF8B5CF6),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Ver replay',
                      style: TextStyle(
                        color: Color(0xFF8B5CF6),
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
            : const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDownloadSheet(BuildContext context, LiveHistoryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DownloadSheet(item: item),
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
          playedColor: AppColors.electricPurple,
          handleColor: AppColors.electricPurple,
          bufferedColor: AppColors.electricPurple.withValues(alpha: 0.3),
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
        actions: [
          // Copiar URL para debug
          IconButton(
            icon: const Icon(LucideIcons.copy, color: Colors.white54, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.overrideUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('URL copiada'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
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

class _DownloadSheetState extends ConsumerState<_DownloadSheet> {
  bool _loading = false;
  String? _status;

  Future<void> _download(String quality) async {
    setState(() {
      _loading = true;
      _status = 'Preparando download...';
    });
    try {
      final service = ref.read(analyticsServiceProvider);
      final result = await service.getLiveDownload(
        widget.item.id,
        quality: quality,
      );
      if (!mounted) return;

      final success = result['success'] == true;
      final data = result['data'] as Map<String, dynamic>?;

      if (success && data != null) {
        final url = data['download_url']?.toString() ?? '';
        final filename = data['filename']?.toString() ?? 'live.mp4';
        if (url.isNotEmpty) {
          // Copiar URL para área de transferência — o usuário pode baixar no browser
          await Clipboard.setData(ClipboardData(text: url));
          setState(
            () => _status =
                '✅ URL copiada! Abra no browser para baixar "$filename"',
          );
        }
      } else {
        setState(() => _status = '❌ Download não disponível para esta live');
      }
    } catch (e) {
      if (mounted) setState(() => _status = '❌ Erro: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSec = isDark ? Colors.white54 : Colors.black45;

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
              const Icon(
                LucideIcons.download,
                color: Color(0xFF10B981),
                size: 20,
              ),
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

          if (_loading)
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF10B981),
              ),
            )
          else if (_status != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _status!,
                style: TextStyle(color: textPrimary, fontSize: 13),
              ),
            ),
          ] else ...[
            Text(
              'Selecione a qualidade:',
              style: TextStyle(color: textSec, fontSize: 12),
            ),
            const SizedBox(height: 10),
            _QualityButton(
              label: '1080p (Alta qualidade)',
              icon: LucideIcons.video,
              color: const Color(0xFF8B5CF6),
              onTap: () => _download('high'),
            ),
            const SizedBox(height: 8),
            _QualityButton(
              label: '720p (Média qualidade)',
              icon: LucideIcons.video,
              color: const Color(0xFF3B82F6),
              onTap: () => _download('medium'),
            ),
            const SizedBox(height: 8),
            _QualityButton(
              label: '480p (Menor tamanho)',
              icon: LucideIcons.video,
              color: const Color(0xFF10B981),
              onTap: () => _download('low'),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'O link será copiado para a área de transferência.',
            style: TextStyle(color: textSec, fontSize: 11),
          ),
        ],
      ),
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
