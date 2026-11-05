import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/repositories/gift_repository.dart';
import '../../../../../data/repositories/live_repository.dart';
import '../../../../../domain/models/gift.dart';
import '../../../../../domain/models/live_event.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../core/widgets/gift_icon.dart';
import '../../../../live_feed/view_models/live_room_comments_view_model.dart';
import '../overlays/gifts_overlay.dart';
import 'gifter_ranking_sheet.dart';

/// Página do evento da sala, por cima da live (folha de ~92% da altura): a
/// live continua montada e tocando atrás; fechar volta sem recarregar.
class EventPageSheet extends ConsumerStatefulWidget {
  const EventPageSheet({
    super.key,
    required this.roomId,
    required this.streamerId,
    required this.event,
  });

  final String roomId;
  final String streamerId;
  final LiveEvent event;

  static Future<void> show(
    BuildContext context, {
    required String roomId,
    required String streamerId,
    required LiveEvent event,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.92,
        child: EventPageSheet(roomId: roomId, streamerId: streamerId, event: event),
      ),
    );
  }

  @override
  ConsumerState<EventPageSheet> createState() => _EventPageSheetState();
}

class _EventPageSheetState extends ConsumerState<EventPageSheet> {
  static const _bg = Color(0xFF0B0E14);
  static const _card = Color(0xFF141A28);
  static const _gold = Color(0xFFFFC53D);

  Timer? _tick;
  DateTime _now = DateTime.now();
  List<GifterEntry> _entries = const [];
  List<PrizeRule> _prizes = const [];
  int? _myRank;
  int? _myPoints;
  bool _loading = true;
  List<Gift> _gifts = const [];

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _load();
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await ref
          .read(liveRepositoryProvider)
          .getEventRanking(widget.event.id, limit: 20);
      final raw = res['data'];
      final me = res['me'];
      if (!mounted) return;
      setState(() {
        _entries = raw is List
            ? raw.whereType<Map>().map(GifterEntry.fromMap).whereType<GifterEntry>().toList()
            : const [];
        _myRank = me is Map ? (me['rank'] as num?)?.toInt() : null;
        _myPoints = me is Map ? (me['points'] as num?)?.toInt() : null;
        _prizes = PrizeRule.listFrom(res['prizes']);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
    final slug = widget.event.collectionSlug;
    if (slug == null) return;
    try {
      final tiers = await ref.read(giftRepositoryProvider).getGiftCatalog();
      final hit = tiers.where((t) => t.name == slug);
      if (mounted && hit.isNotEmpty) setState(() => _gifts = hit.first.gifts);
    } catch (_) {}
  }

  String _hms(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    return '${two(h)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  void _sendGift() {
    final root = Navigator.of(context, rootNavigator: true).context;
    final slug = widget.event.collectionSlug;
    Navigator.of(context).pop();
    GiftsOverlay.show(
      root,
      widget.roomId,
      widget.streamerId,
      preselectCollectionSlug: slug,
    );
  }

  void _fullRanking() {
    GifterRankingSheet.show(
      context,
      roomId: widget.roomId,
      streamerId: widget.streamerId,
      ranking: ref.read(liveRoomCommentsViewModelProvider(widget.roomId)).gifterRanking,
      openEventTab: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final e = widget.event;
    final remaining = e.remaining(_now);

    // Quanto falta para o top 10.
    String? gap;
    if (_myRank != null && _myRank! > 10 && _entries.length >= 10 && _myPoints != null) {
      final tenth = _entries[9].totalValue;
      final need = (tenth - _myPoints! + 1).clamp(1, 1 << 31);
      gap = l10n.eventPageToTop10('$need');
    } else if (_myRank != null && _myRank! <= 10) {
      gap = l10n.eventPageInTop10;
    }

    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Banner + nome
                  Stack(
                    children: [
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: e.bannerImageUrl != null
                            ? Image.network(
                                e.bannerImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const ColoredBox(color: _card),
                              )
                            : const ColoredBox(color: _card),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, _bg.withValues(alpha: 0.95)],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 56,
                        bottom: 10,
                        child: Text(
                          e.localizedName(lang),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          style: IconButton.styleFrom(backgroundColor: Colors.black38),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row(Icons.auto_awesome, l10n.eventPageGiftsWorth(e.multiplierLabel)),
                        const SizedBox(height: 8),
                        _row(Icons.timer_outlined, l10n.eventPageEndsIn(_hms(remaining))),
                        const SizedBox(height: 16),
                        // Sua posição
                        _section(l10n.eventPageYourPosition),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _myRank == null
                                      ? l10n.eventPageNoRank
                                      : l10n.eventPageRankPoints(_myRank!, '${_myPoints ?? 0}'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (gap != null)
                                Flexible(
                                  child: Text(
                                    gap,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Prêmios
                        if (_prizes.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _section(l10n.eventPagePrizes),
                          for (final p in _prizes)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 64,
                                    child: Text(
                                      p.rankFrom == p.rankTo
                                          ? l10n.eventPagePrizeOne(p.rankFrom)
                                          : l10n.eventPagePrizeRank(p.rankFrom, p.rankTo),
                                      style: TextStyle(
                                        color: p.covers(1) ? _gold : Colors.white70,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      p.label.resolve(lang),
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        // Ranking top 3
                        const SizedBox(height: 16),
                        _section(l10n.eventPageRanking),
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        else
                          for (var i = 0; i < _entries.length && i < 3; i++)
                            _rankRow(i + 1, _entries[i]),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _fullRanking,
                            child: Text(l10n.eventPageSeeFull),
                          ),
                        ),
                        // Como funciona (só com descrição)
                        if (e.description != null) ...[
                          const SizedBox(height: 8),
                          _section(l10n.eventPageHow),
                          Text(
                            e.description!.resolve(lang),
                            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Rodapé fixo: presentes do evento + Enviar presente
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                10 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: _card,
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_gifts.isNotEmpty) ...[
                    Text(
                      l10n.eventPageGifts,
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _gifts.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, i) => GiftIcon(
                          slug: _gifts[i].slug,
                          tier: widget.event.collectionSlug ?? 'basic',
                          iconUrl: _gifts[i].iconUrl,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _sendGift,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1A6DFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: const Icon(Icons.card_giftcard_rounded, size: 18),
                      label: Text(
                        l10n.eventPageSend,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 16, color: Colors.white70),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    ],
  );

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4),
    ),
  );

  Widget _rankRow(int pos, GifterEntry g) {
    final first = pos == 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$pos',
              style: TextStyle(
                color: first ? _gold : Colors.white54,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: _card,
            backgroundImage: g.avatarUrl != null ? NetworkImage(g.avatarUrl!) : null,
            child: g.avatarUrl == null
                ? Text(g.name.isNotEmpty ? g.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 12))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              g.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${g.totalValue}',
            style: TextStyle(
              color: first ? _gold : Colors.white70,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
