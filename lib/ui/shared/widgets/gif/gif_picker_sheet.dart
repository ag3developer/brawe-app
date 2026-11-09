import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../data/services/gif_service.dart';
import '../../../../domain/models/gif_item.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/brawe_colors.dart';

/// Abre o seletor de GIFs (GIPHY) e devolve o GIF escolhido (ou null).
Future<GifAttachment?> showGifPicker(BuildContext context) {
  return showModalBottomSheet<GifAttachment>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const GifPickerSheet(),
  );
}

enum _GifError { none, unavailable, generic }

class GifPickerSheet extends ConsumerStatefulWidget {
  const GifPickerSheet({
    super.key,
    this.debounce = const Duration(milliseconds: 350),
  });

  final Duration debounce;

  @override
  ConsumerState<GifPickerSheet> createState() => _GifPickerSheetState();
}

class _GifPickerSheetState extends ConsumerState<GifPickerSheet> {
  static const _pageSize = 24;

  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _timer;

  final List<GifItem> _items = [];
  int? _nextOffset;
  String _query = '';
  bool _loading = true;
  bool _loadingMore = false;
  _GifError _error = _GifError.none;
  int _req = 0; // descarta respostas de buscas antigas
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _load(reset: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String get _lang => Localizations.localeOf(context).languageCode;

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    if (p.pixels > p.maxScrollExtent - 400) _load(reset: false);
  }

  void _onChanged(String value) {
    setState(() {}); // botão de limpar
    _timer?.cancel();
    _timer = Timer(widget.debounce, () {
      final q = value.trim();
      if (q == _query) return;
      _query = q;
      _load(reset: true);
    });
  }

  Future<void> _load({required bool reset}) async {
    if (!reset &&
        (_loading ||
            _loadingMore ||
            _nextOffset == null ||
            _error != _GifError.none))
      return;
    final id = ++_req;
    final service = ref.read(gifServiceProvider);
    final offset = reset ? 0 : _nextOffset!;
    final q = _query;
    final lang = _lang;
    setState(() {
      _error = _GifError.none;
      if (reset) {
        _loading = true;
        _loadingMore = false;
        _items.clear();
        _nextOffset = null;
      } else {
        _loadingMore = true;
      }
    });
    try {
      final page = q.isEmpty
          ? await service.trending(limit: _pageSize, offset: offset, lang: lang)
          : await service.search(
              q,
              limit: _pageSize,
              offset: offset,
              lang: lang,
            );
      if (!mounted || id != _req) return;
      setState(() {
        final seen = _items.map((e) => e.id).toSet();
        _items.addAll(page.items.where((e) => seen.add(e.id)));
        _nextOffset = page.nextOffset;
        _loading = false;
        _loadingMore = false;
      });
    } on GifsUnavailableException {
      if (!mounted || id != _req) return;
      setState(() {
        _error = _GifError.unavailable;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted || id != _req) return;
      setState(() {
        _error = _GifError.generic;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = S.of(context);
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: c.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: TextField(
                    key: const Key('gif_search_field'),
                    controller: _search,
                    onChanged: _onChanged,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(color: c.textPrimary),
                    decoration: InputDecoration(
                      hintText: s.gifSearchHint,
                      hintStyle: TextStyle(
                        color: c.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        LucideIcons.search,
                        size: 18,
                        color: c.textSecondary,
                      ),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: s.gifClearSearch,
                              icon: Icon(
                                LucideIcons.x,
                                size: 18,
                                color: c.textSecondary,
                              ),
                              onPressed: () {
                                _search.clear();
                                _onChanged('');
                              },
                            ),
                      filled: true,
                      fillColor: c.surfaceHighest,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Flexible(child: _body(context)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Text(
                    // Atribuição exigida pelo GIPHY (nome da marca, não traduzir).
                    s.gifPoweredBy,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: c.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final s = S.of(context);
    if (_error != _GifError.none && _items.isEmpty) {
      final unavailable = _error == _GifError.unavailable;
      return _Message(
        icon: unavailable ? LucideIcons.imageOff : LucideIcons.wifiOff,
        title: unavailable ? s.gifUnavailable : s.gifErrorGeneric,
        actionLabel: unavailable ? null : s.gifRetry,
        onAction: unavailable ? null : () => _load(reset: true),
      );
    }
    if (_loading) return const _Skeleton();
    if (_items.isEmpty) {
      return _Message(
        icon: LucideIcons.searchX,
        title: s.gifEmptyTitle,
        subtitle: s.gifEmptyHint,
      );
    }
    return CustomScrollView(
      key: const Key('gif_grid'),
      controller: _scroll,
      shrinkWrap: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.15,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _Tile(
                item: _items[i],
                onTap: () => Navigator.of(ctx).pop(_items[i].toAttachment()),
              ),
              childCount: _items.length,
            ),
          ),
        ),
        if (_loadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.braweBlue,
                  ),
                ),
              ),
            ),
          ),
        if (_error != _GifError.none)
          SliverToBoxAdapter(
            child: TextButton(
              onPressed: () => _load(reset: false),
              child: Text(s.gifRetry),
            ),
          ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item, required this.onTap});
  final GifItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: item.title.isEmpty ? S.of(context).gifSemantics : item.title,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColoredBox(
            color: c.shimmerBase,
            child: Image.network(
              item.previewUrl,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => Center(
                child: Icon(
                  LucideIcons.imageOff,
                  size: 20,
                  color: c.textTertiary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GridView.builder(
      key: const Key('gif_skeleton'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.15,
      ),
      itemCount: 8,
      itemBuilder: (_, i) => DecoratedBox(
        decoration: BoxDecoration(
          color: c.shimmerBase,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: c.textTertiary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
