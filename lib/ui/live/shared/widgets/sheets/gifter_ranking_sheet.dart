import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../data/repositories/auth_state_provider.dart';
import '../../../../../data/repositories/live_repository.dart';
import '../../../../../domain/models/live_event.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../../ui/live_feed/view_models/live_room_comments_view_model.dart';
import '../../../../core/themes/brawe_colors.dart';
import '../award_badge.dart';
import '../competition/medal_colors.dart';
import '../overlays/gifts_overlay.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';

enum _Board { gifts, likes, event }

/// Gaveta do ranking da live — mesmo padrão da gaveta de compartilhar
/// (tema do app, alça, título central com fechar).
///
/// Abas: **Presentes** (moedas gastas — pagos e grátis; com filtro
/// "Esta live | Semana do criador") e **Curtidas** (curtidas válidas
/// contadas no servidor). Pódio dos 3 primeiros, lista até o 10º e a minha
/// posição fixa no rodapé com quanto falta para passar quem está à frente.
/// Durante um evento com prazo surge a aba **Evento** (ranking só do evento),
/// e acima do pódio vai o prêmio do 1º lugar quando há regra cadastrada.
class GifterRankingSheet extends ConsumerStatefulWidget {
  const GifterRankingSheet._({
    required this.roomId,
    required this.streamerId,
    required this.fallbackRanking,
    required this.openEventTab,
  });

  final bool openEventTab;
  final String roomId;
  final String streamerId;
  final List<GifterEntry> fallbackRanking;

  static Future<void> show(
    BuildContext context, {
    required String roomId,
    required String streamerId,
    List<GifterEntry> ranking = const [],
    bool openEventTab = false,
  }) {
    // Raiz do navigator: a gaveta herda o tema do APP (claro/escuro), como a
    // de compartilhar, e não o escuro forçado da live.
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    return showModalBottomSheet<void>(
      useRootNavigator: true,
      context: rootContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GifterRankingSheet._(
        roomId: roomId,
        streamerId: streamerId,
        fallbackRanking: ranking,
        openEventTab: openEventTab,
      ),
    );
  }

  @override
  ConsumerState<GifterRankingSheet> createState() => _GifterRankingSheetState();
}

class _GifterRankingSheetState extends ConsumerState<GifterRankingSheet> {
  late _Board _board = widget.openEventTab ? _Board.event : _Board.gifts;

  // Prêmio do 1º lugar por aba (vem em `prizes` das respostas de ranking).
  List<PrizeRule> _livePrizes = const [];
  List<PrizeRule> _likePrizes = const [];
  List<PrizeRule> _weekPrizes = const [];
  bool _likePrizesLoaded = false;

  // Ranking do evento
  bool _eventLoading = false;
  String? _eventLoadedFor;
  List<GifterEntry> _eventEntries = const [];
  int? _eventMyRank;
  int? _eventMyPoints;
  List<PrizeRule> _eventPrizes = const [];

  bool _week = false;
  bool _weekLoading = false;
  bool _weekLoaded = false;
  List<GifterEntry> _weekEntries = const [];
  int? _weekMyRank;
  int? _weekMyPoints;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLivePrizes();
      if (_board == _Board.event) _loadEvent();
    });
  }

  LiveEvent? get _event {
    final e = ref.read(liveRoomCommentsViewModelProvider(widget.roomId)).event;
    return (e == null || e.isEnded(DateTime.now())) ? null : e;
  }

  Future<void> _loadLivePrizes() async {
    final res = await ref
        .read(liveRepositoryProvider)
        .getTopGiftersFull(widget.roomId, limit: 1);
    if (!mounted) return;
    setState(() => _livePrizes = PrizeRule.listFrom(res['prizes']));
  }

  Future<void> _loadLikePrizes() async {
    if (_likePrizesLoaded) return;
    _likePrizesLoaded = true;
    final res = await ref
        .read(liveRepositoryProvider)
        .getTopLikers(widget.roomId, limit: 1);
    if (!mounted) return;
    setState(() => _likePrizes = PrizeRule.listFrom(res['prizes']));
  }

  Future<void> _loadEvent() async {
    final event = _event;
    if (event == null || _eventLoading) return;
    setState(() => _eventLoading = true);
    final res = await ref
        .read(liveRepositoryProvider)
        .getEventRanking(event.id, limit: 20);
    if (!mounted) return;
    final raw = res['data'];
    final me = res['me'];
    setState(() {
      _eventEntries = raw is List
          ? raw
                .whereType<Map>()
                .map(GifterEntry.fromMap)
                .whereType<GifterEntry>()
                .take(10)
                .toList()
          : const [];
      _eventMyRank = me is Map ? (me['rank'] as num?)?.toInt() : null;
      _eventMyPoints = me is Map ? (me['points'] as num?)?.toInt() : null;
      _eventPrizes = PrizeRule.listFrom(res['prizes']);
      _eventLoading = false;
      _eventLoadedFor = event.id;
    });
  }

  void _selectBoard(_Board b) {
    setState(() => _board = b);
    if (b == _Board.likes) _loadLikePrizes();
    if (b == _Board.event) _loadEvent();
  }

  Future<void> _loadWeek() async {
    if (_weekLoaded || _weekLoading) return;
    setState(() => _weekLoading = true);
    final res = await ref
        .read(liveRepositoryProvider)
        .getCreatorRanking(widget.streamerId, period: 'week', limit: 20);
    if (!mounted) return;
    final raw = res['data'];
    final me = res['me'];
    setState(() {
      _weekEntries = raw is List
          ? raw
                .whereType<Map>()
                .map(GifterEntry.fromMap)
                .whereType<GifterEntry>()
                .take(10)
                .toList()
          : const [];
      _weekMyRank = me is Map ? (me['rank'] as num?)?.toInt() : null;
      _weekMyPoints = me is Map ? (me['points'] as num?)?.toInt() : null;
      _weekPrizes = PrizeRule.listFrom(res['prizes']);
      _weekLoading = false;
      _weekLoaded = true;
    });
  }

  void _sendGift(int? needPoints) {
    // O contexto da gaveta morre no pop — abre a sacola pelo navigator raiz.
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    Navigator.of(context).pop();
    GiftsOverlay.show(
      rootContext,
      widget.roomId,
      widget.streamerId,
      needPoints: needPoints,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final st = ref.watch(liveRoomCommentsViewModelProvider(widget.roomId));
    final myId = ref.watch(authStateProvider).value?.id;
    final liveEvent = st.event == null || st.event!.isEnded(DateTime.now())
        ? null
        : st.event;
    // Sem evento em vigor a aba "Evento" não existe (caiu no meio da gaveta).
    final board = (_board == _Board.event && liveEvent == null)
        ? _Board.gifts
        : _board;
    final likes = board == _Board.likes;
    final isEvent = board == _Board.event;

    final List<GifterEntry> entries;
    final int? myRank;
    final int? myValue;
    final List<PrizeRule> prizes;
    if (isEvent) {
      entries = _eventEntries;
      myRank = _eventMyRank;
      myValue = _eventMyPoints;
      prizes = _eventPrizes;
    } else if (likes) {
      entries = st.likerRanking;
      myRank = st.myLikeRank;
      myValue = st.myLikes;
      prizes = _likePrizes;
    } else if (_week) {
      entries = _weekEntries;
      myRank = _weekMyRank;
      myValue = _weekMyPoints;
      prizes = _weekPrizes;
    } else {
      entries = st.gifterRanking.isNotEmpty
          ? st.gifterRanking
          : widget.fallbackRanking;
      myRank = st.myRank;
      myValue = st.myPoints;
      prizes = _livePrizes;
    }
    final top = entries.take(10).toList();
    final loading = isEvent
        ? _eventLoadedFor == null
        : (!likes && _week && _weekLoading);
    final prize = PrizeRule.firstPlace(prizes);
    final lang = Localizations.localeOf(context).languageCode;
    // Pontos valem em dobro etc. enquanto o evento está no ar (live e evento).
    final multiplier = (!likes && !(_week && !isEvent))
        ? liveEvent?.multiplier
        : null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.86,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _header(colors, s),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _BoardTabs(
                board: board,
                boards: [
                  _Board.gifts,
                  _Board.likes,
                  if (liveEvent != null) _Board.event,
                ],
                onChanged: _selectBoard,
              ),
            ),
            const SizedBox(height: 10),
            _summary(
              colors,
              s,
              st,
              likes,
              isEvent ? liveEvent : null,
              multiplier,
              lang,
            ),
            Divider(height: 20, color: colors.divider),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey('${board.name}-$_week-${top.length}'),
                  child: loading
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      : top.isEmpty
                      ? _Empty(likes: likes)
                      : ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 8),
                          children: [
                            if (prize != null)
                              _PrizeLine(
                                text: s.rankingPrizeFirst(
                                  prize.label.resolve(lang),
                                ),
                              ),
                            _Podium(
                              entries: top.take(3).toList(),
                              likes: likes,
                              myId: myId,
                            ),
                            for (var i = 3; i < top.length; i++)
                              _Row(
                                position: i + 1,
                                entry: top[i],
                                likes: likes,
                                isMe: top[i].userId == myId,
                              ),
                          ],
                        ),
                ),
              ),
            ),
            Divider(height: 1, color: colors.divider),
            _Footer(
              likes: likes,
              entries: top,
              myRank: myRank,
              myValue: myValue,
              onSendGift: _sendGift,
              onLike: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BraweColors colors, S s) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            s.rankingSheetTitle,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Positioned(
            right: 4,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(LucideIcons.x, color: colors.textSecondary),
              iconSize: 22,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  /// Linha de resumo: total da live (ou filtro da semana) / total de curtidas.
  Widget _summary(
    BraweColors colors,
    S s,
    LiveRoomCommentsState st,
    bool likes,
    LiveEvent? eventBoard,
    double? multiplier,
    String lang,
  ) {
    final style = TextStyle(
      color: colors.textSecondary,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
    );
    if (likes) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(LucideIcons.heart, size: 14, color: Color(0xFFFF3D7F)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                s.likesRoomTotal(compactPoints(st.likeCount), st.uniqueLikers),
                style: style,
              ),
            ),
          ],
        ),
      );
    }
    if (eventBoard != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(
              LucideIcons.calendarDays,
              size: 14,
              color: Color(0xFFFFC53D),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                eventBoard.localizedName(lang),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
            const SizedBox(width: 8),
            _MultiplierTag(multiplier: eventBoard.multiplier),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Chip(
            label: s.rankingTabLive,
            selected: !_week,
            onTap: () => setState(() => _week = false),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: s.rankingTabWeek,
            selected: _week,
            onTap: () {
              setState(() => _week = true);
              _loadWeek();
            },
          ),
          const Spacer(),
          if (!_week && st.rankingTotalPoints > 0) ...[
            const CoinIcon(size: 14),
            const SizedBox(width: 4),
            Text(compactPoints(st.rankingTotalPoints), style: style),
          ],
          if (!_week && multiplier != null) ...[
            const SizedBox(width: 8),
            _MultiplierTag(multiplier: multiplier),
          ],
        ],
      ),
    );
  }
}

// ─── Abas Presentes | Curtidas ──────────────────────────────────────────────

class _BoardTabs extends StatelessWidget {
  const _BoardTabs({
    required this.board,
    required this.boards,
    required this.onChanged,
  });

  final _Board board;
  final List<_Board> boards;
  final ValueChanged<_Board> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        final n = boards.length;
        final w = (c.maxWidth - 8) / n;
        final index = boards.indexOf(board).clamp(0, n - 1);
        return Container(
          height: 42,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.surfaceHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: index * w,
                top: 0,
                bottom: 0,
                width: w,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final b in boards)
                    switch (b) {
                      _Board.gifts => _tab(
                        context,
                        b,
                        LucideIcons.gift,
                        s.rankingTabGifts,
                        const Color(0xFFFFB800),
                      ),
                      _Board.likes => _tab(
                        context,
                        b,
                        LucideIcons.heart,
                        s.rankingTabLikes,
                        const Color(0xFFFF3D7F),
                      ),
                      _Board.event => _tab(
                        context,
                        b,
                        LucideIcons.calendarDays,
                        s.rankingTabEvent,
                        const Color(0xFFFFC53D),
                      ),
                    },
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tab(
    BuildContext context,
    _Board b,
    IconData icon,
    String label,
    Color accent,
  ) {
    final colors = context.colors;
    final selected = board == b;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(b),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? accent : colors.textTertiary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? colors.textPrimary : colors.textSecondary,
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "2×" ao lado dos pontos enquanto um evento multiplica o ranking.
class _MultiplierTag extends StatelessWidget {
  const _MultiplierTag({required this.multiplier});

  final double multiplier;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFC53D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: gold.withValues(alpha: 0.7)),
      ),
      child: Text(
        formatMultiplier(multiplier),
        style: const TextStyle(
          color: gold,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// "Prêmio do 1º lugar: …" acima do pódio.
class _PrizeLine extends StatelessWidget {
  const _PrizeLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const gold = Color(0xFFFFC53D);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.award, size: 16, color: gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? colors.accentPrimary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colors.accentPrimary : colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.accentPrimary : colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Pódio (1º no centro, 2º à esquerda, 3º à direita) ─────────────────────

class _Podium extends StatelessWidget {
  const _Podium({
    required this.entries,
    required this.likes,
    required this.myId,
  });

  final List<GifterEntry> entries;
  final bool likes;
  final String? myId;

  @override
  Widget build(BuildContext context) {
    GifterEntry? at(int i) => i < entries.length ? entries[i] : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _PodiumSeat(
              position: 2,
              entry: at(1),
              likes: likes,
              myId: myId,
            ),
          ),
          Expanded(
            child: _PodiumSeat(
              position: 1,
              entry: at(0),
              likes: likes,
              myId: myId,
            ),
          ),
          Expanded(
            child: _PodiumSeat(
              position: 3,
              entry: at(2),
              likes: likes,
              myId: myId,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumSeat extends StatelessWidget {
  const _PodiumSeat({
    required this.position,
    required this.entry,
    required this.likes,
    required this.myId,
  });

  final int position;
  final GifterEntry? entry;
  final bool likes;
  final String? myId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final e = entry;
    final medal = medalColor(position);
    final size = position == 1 ? 76.0 : 58.0;
    if (e == null) return SizedBox(height: size + 60);
    final isMe = e.userId == myId;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (position == 1)
          Icon(LucideIcons.crown, size: 22, color: medal)
        else
          const SizedBox(height: 22),
        const SizedBox(height: 4),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            AvatarFrame(
              size: size,
              frameUrl: e.award?.frameUrl,
              child: Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [medal, medal.withValues(alpha: 0.45), medal],
                  ),
                  boxShadow: position == 1
                      ? [
                          BoxShadow(
                            color: medal.withValues(alpha: 0.45),
                            blurRadius: 18,
                          ),
                        ]
                      : null,
                ),
                child: _Avatar(entry: e, size: size - 6),
              ),
            ),
            Positioned(
              bottom: -8,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: medal,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surfaceElevated, width: 2),
                ),
                child: Text(
                  '$position',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  isMe ? S.of(context).rankingYouBadge : e.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isMe ? colors.accentPrimary : colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (e.isVerified) const VerifiedBadge(size: 12, gap: 3),
            ],
          ),
        ),
        const SizedBox(height: 3),
        _Value(value: e.totalValue, likes: likes, strong: true),
      ],
    );
  }
}

// ─── Linhas 4º–10º ──────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  const _Row({
    required this.position,
    required this.entry,
    required this.likes,
    required this.isMe,
  });

  final int position;
  final GifterEntry entry;
  final bool likes;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isMe
            ? colors.accentPrimary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: colors.accentPrimary.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$position',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _Avatar(entry: entry, size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isMe ? s.rankingYouBadge : entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (entry.isVerified) const VerifiedBadge(size: 13, gap: 3),
                  ],
                ),
                if (!likes && entry.giftCount > 0)
                  Text(
                    s.rankingGiftCount(entry.giftCount),
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
          ),
          _Value(value: entry.totalValue, likes: likes),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({required this.value, required this.likes, this.strong = false});

  final int value;
  final bool likes;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (likes)
          const Icon(LucideIcons.heart, size: 13, color: Color(0xFFFF3D7F))
        else
          const CoinIcon(size: 14),
        const SizedBox(width: 4),
        Text(
          compactPoints(value),
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: strong ? 13.5 : 13,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.entry, required this.size});

  final GifterEntry entry;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = entry.avatarUrl;
    final initial = entry.name.trim().isEmpty
        ? '?'
        : entry.name.trim()[0].toUpperCase();
    final fallback = Container(
      color: colors.surfaceHighest,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null || url.isEmpty
            ? fallback
            : Image.network(
                url,
                cacheWidth: context.decodePx(size),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

// ─── Rodapé: minha posição + ação ──────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({
    required this.likes,
    required this.entries,
    required this.myRank,
    required this.myValue,
    required this.onSendGift,
    required this.onLike,
  });

  final bool likes;
  final List<GifterEntry> entries;
  final int? myRank;
  final int? myValue;
  final void Function(int? needPoints) onSendGift;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final rank = myRank;
    int? gap;
    String text;
    if (rank == null) {
      text = likes ? s.likesFooterJoin : s.rankingFooterJoin;
    } else if (rank == 1) {
      text = likes ? s.likesFooterLeader : s.rankingFooterLeader;
    } else if (rank - 2 < entries.length && myValue != null) {
      final ahead = entries[rank - 2];
      gap = ahead.totalValue - myValue! + 1;
      text = likes
          ? s.likesFooterGap(rank, compactPoints(gap), ahead.name)
          : s.rankingFooterGap(rank, compactPoints(gap), ahead.name);
    } else {
      text = likes ? s.likesFooterOnly(rank) : s.rankingFooterOnly(rank);
    }

    final accent = likes ? const Color(0xFFFF3D7F) : const Color(0xFFFFB800);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Text(
              rank == null ? '–' : '#$rank',
              style: TextStyle(
                color: accent,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (likes)
                  Text(
                    s.likesNote,
                    style: TextStyle(color: colors.textTertiary, fontSize: 11),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: likes ? onLike : () => onSendGift(gap),
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              visualDensity: VisualDensity.compact,
            ),
            icon: Icon(likes ? LucideIcons.heart : LucideIcons.gift, size: 16),
            label: Text(
              likes ? s.rankingLikeNow : s.rankingSendGift,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.likes});

  final bool likes;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            likes ? LucideIcons.heart : LucideIcons.trophy,
            size: 40,
            color: colors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            likes ? s.likesEmpty : s.rankingEmpty,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            likes ? s.likesEmptyHint : s.rankingEmptyHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
