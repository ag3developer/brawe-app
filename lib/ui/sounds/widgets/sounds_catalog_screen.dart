import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../domain/models/sound.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/sound_player_view_model.dart';
import '../view_models/sounds_view_model.dart';
import 'sound_player_bottom_sheet.dart';
import 'sounds_header_premium.dart';

class SoundsCatalogScreen extends ConsumerStatefulWidget {
  const SoundsCatalogScreen({super.key});

  @override
  ConsumerState<SoundsCatalogScreen> createState() =>
      _SoundsCatalogScreenState();
}

class _SoundsCatalogScreenState extends ConsumerState<SoundsCatalogScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _scrollCtrl.addListener(_onScroll);
    // Carrega catálogo ao entrar
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _reload());
  }

  void _reload() {
    ref.read(soundsCatalogViewModelProvider.notifier).load(reset: true);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(soundsCatalogViewModelProvider.notifier).load();
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _openPlayer(BuildContext context, Sound sound) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SoundPlayerBottomSheet(sound: sound),
    );
    // Inicia playback imediatamente
    ref.read(soundPlayerViewModelProvider.notifier).play(sound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          SoundsPremiumHeader(
            tabs: _tabs,
            searchCtrl: _searchCtrl,
            onSearch: (q) {
              _searchDebounce?.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 400), () {
                ref
                    .read(soundsCatalogViewModelProvider.notifier)
                    .setSearch(q);
              });
            },
            onClearSearch: () {
              _searchCtrl.clear();
              ref.read(soundsCatalogViewModelProvider.notifier).clearSearch();
            },
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            // Tab 0 — Trending
            _TrendingTab(onTap: _openPlayer),
            // Tab 1 — Catálogo
            _CatalogTab(
              scrollCtrl: _scrollCtrl,
              onTap: _openPlayer,
            ),
          ],
        ),
      ),
      // Mini-player persistente no fundo quando há música carregada
      bottomSheet: const _MiniPlayer(),
    );
  }
}

// ── Tab Trending ──────────────────────────────────────────────────────────────
class _TrendingTab extends ConsumerWidget {
  const _TrendingTab({required this.onTap});
  final void Function(BuildContext, Sound) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(soundsTrendingProvider);
    final s = S.of(context);

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.mutedRed),
      ),
      error: (_, _) => Center(
        child: Text(s.soundsEmptyTrending,
            style: TextStyle(color: context.colors.textSecondary)),
      ),
      data: (sounds) {
        if (sounds.isEmpty) {
          return _EmptyState(message: s.soundsEmptyTrending);
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 120),
          itemCount: sounds.length,
          itemBuilder: (ctx, i) => _SoundTile(
            sound: sounds[i],
            rank: i + 1,
            onTap: () => onTap(ctx, sounds[i]),
          ),
        );
      },
    );
  }
}

// ── Tab Catálogo ──────────────────────────────────────────────────────────────
class _CatalogTab extends ConsumerWidget {
  const _CatalogTab({required this.scrollCtrl, required this.onTap});
  final ScrollController scrollCtrl;
  final void Function(BuildContext, Sound) onTap;

  // Gêneros para o filtro
  static const _genreKeys = [
    null, 'funk', 'sertanejo', 'pagode', 'forró',
    'pop', 'rap', 'eletrônico', 'gospel', 'rock', 'mpb',
  ];

  String _genreLabel(S s, String? key) {
    if (key == null) return s.soundsGenreAll;
    switch (key) {
      case 'funk':       return s.soundsGenreFunk;
      case 'sertanejo':  return s.soundsGenreSertanejo;
      case 'pagode':     return s.soundsGenrePagode;
      case 'forró':      return s.soundsGenreForro;
      case 'pop':        return s.soundsGenrePop;
      case 'rap':        return s.soundsGenreRap;
      case 'eletrônico': return s.soundsGenreElectro;
      case 'gospel':     return s.soundsGenreGospel;
      case 'rock':       return s.soundsGenreRock;
      case 'mpb':        return s.soundsGenreMpb;
      default:           return key;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(soundsCatalogViewModelProvider);
    final s = S.of(context);

    return Column(
      children: [
        // Chips de gênero
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: _genreKeys.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final key = _genreKeys[i];
              final selected = state.genre == key;
              return FilterChip(
                label: Text(_genreLabel(s, key)),
                selected: selected,
                onSelected: (_) => ref
                    .read(soundsCatalogViewModelProvider.notifier)
                    .setGenre(key),
                selectedColor: AppColors.mutedRed,
                checkmarkColor: Colors.white,
                backgroundColor:
                    context.colors.surfaceHighest.withValues(alpha: 0.08),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : context.colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                    color: selected
                        ? AppColors.mutedRed
                        : context.colors.border.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            },
          ),
        ),

        // Lista
        Expanded(
          child: state.items.isEmpty && !state.isLoading
              ? _EmptyState(
                  message: state.searchQuery != null
                      ? s.soundsEmptySearch(state.searchQuery!)
                      : s.soundsEmptyCatalog,
                )
              : ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.only(top: 4, bottom: 120),
                  itemCount: state.items.length + (state.isLoading ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i == state.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.mutedRed, strokeWidth: 2),
                        ),
                      );
                    }
                    final sound = state.items[i];
                    return _SoundTile(
                      sound: sound,
                      onTap: () => onTap(ctx, sound),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Sound Tile ────────────────────────────────────────────────────────────────
class _SoundTile extends ConsumerWidget {
  const _SoundTile({required this.sound, required this.onTap, this.rank});
  final Sound sound;
  final VoidCallback onTap;
  final int? rank;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(soundPlayerViewModelProvider);
    final isCurrent = playerState.sound?.id == sound.id;
    final isPlaying = isCurrent && playerState.isPlaying;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 50,
              child: sound.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: sound.coverUrl!, fit: BoxFit.cover)
                  : Container(
                      color: context.colors.surfaceHighest,
                      child: Icon(LucideIcons.music,
                          color: context.colors.textSecondary, size: 20),
                    ),
            ),
          ),
          if (isCurrent)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPlaying ? LucideIcons.pause : LucideIcons.play,
                color: Colors.white,
                size: 20,
              ),
            ),
          if (rank != null && !isCurrent)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        sound.title,
        style: TextStyle(
          color: isCurrent
              ? AppColors.mutedRed
              : context.colors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (sound.artist != null) ...[
            Text(
              sound.artist!.artistName,
              style: TextStyle(
                  color: context.colors.textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (sound.genre != null) ...[
            Text(' · ',
                style: TextStyle(color: context.colors.textTertiary, fontSize: 12)),
            Text(
              sound.genre!,
              style: TextStyle(
                  color: context.colors.textTertiary, fontSize: 12),
            ),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(LucideIcons.share2, size: 11, color: context.colors.textTertiary),
            const SizedBox(width: 3),
            Text(_fmtCount(sound.usageCount),
                style: TextStyle(
                    color: context.colors.textTertiary, fontSize: 11)),
          ]),
          const SizedBox(height: 4),
          Text(
            _fmtDuration(sound.durationMs),
            style: TextStyle(color: context.colors.textTertiary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _fmtCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  String _fmtDuration(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ── Mini Player (persiste enquanto toca) ─────────────────────────────────────
class _MiniPlayer extends ConsumerWidget {
  const _MiniPlayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(soundPlayerViewModelProvider);
    final sound = playerState.sound;
    if (sound == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SoundPlayerBottomSheet(sound: sound),
      ),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          border: Border(top: BorderSide(color: context.colors.border.withValues(alpha: 0.3))),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 40,
                height: 40,
                child: sound.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: sound.coverUrl!, fit: BoxFit.cover)
                    : Container(
                        color: context.colors.surfaceHighest,
                        child: Icon(LucideIcons.music,
                            color: context.colors.textSecondary, size: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sound.title,
                      style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (sound.artist != null)
                    Text(sound.artist!.artistName,
                        style: TextStyle(
                            color: context.colors.textSecondary, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // Progress mini bar
            SizedBox(
              width: 60,
              child: LinearProgressIndicator(
                value: playerState.progress,
                backgroundColor:
                    context.colors.border.withValues(alpha: 0.3),
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.mutedRed),
                minHeight: 2,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                playerState.isPlaying ? LucideIcons.pause : LucideIcons.play,
                color: context.colors.textPrimary,
              ),
              onPressed: () =>
                  ref.read(soundPlayerViewModelProvider.notifier).play(sound),
            ),
            IconButton(
              icon: Icon(Icons.close,
                  size: 18, color: context.colors.textSecondary),
              onPressed: () =>
                  ref.read(soundPlayerViewModelProvider.notifier).stop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.music,
              size: 56,
              color: context.colors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  color: context.colors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
