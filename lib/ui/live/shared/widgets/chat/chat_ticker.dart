import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../domain/models/live_comment.dart';
import '../../../../../domain/models/live_gift.dart';
import 'chat_line.dart';
import 'gift_chat_line.dart';
import '../../../../live_feed/view_models/live_room_comments_view_model.dart' show GiftChatPart;
import 'ticker_item.dart';

/// Ticker do chat da live: mescla comentários + presentes em uma única
/// timeline ordenada por timestamp — usado pelo espectador E pelo streamer.
///
/// Comportamento (TikTok Live):
/// - Ancorado na BASE: a mensagem mais recente fica colada no input; a
///   altura cresce conforme chegam mensagens, até [maxHeight].
/// - Rolável: o usuário pode subir para ler o histórico. Enquanto estiver
///   lendo, novas mensagens não "puxam" a lista — aparece a pílula
///   "N novas mensagens" que volta para o fim.
/// - Fade suave no topo via `ShaderMask`.
class ChatTicker extends StatefulWidget {
  const ChatTicker({
    super.key,
    required this.comments,
    required this.gifts,
    this.giftParts = const {},
    this.maxHeight = 240,
    this.hostUserId,
    this.myUserId,
    this.myUsername,
    this.onCommentTap,
  });

  final List<LiveComment> comments;
  final List<LiveGift> gifts;

  /// Linhas de presente agrupadas ("50× Rosa + 1× Dragão"), por id.
  final Map<String, List<GiftChatPart>> giftParts;

  /// Altura máxima da faixa do chat. Quem chama reduz esse valor quando o
  /// teclado está aberto (sobra menos tela).
  final double maxHeight;

  /// `userId` do dono da live — mensagens dele ganham o selo "Criador".
  final String? hostUserId;

  /// Eu: minhas mensagens não abrem o cartão; menções a mim são destacadas.
  final String? myUserId;
  final String? myUsername;

  /// Toque numa mensagem de outra pessoa (abre Responder / Ver perfil).
  final ValueChanged<LiveComment>? onCommentTap;

  bool _mentionsMe(LiveComment c) {
    final me = myUsername;
    if (me == null || me.isEmpty || c.userId == myUserId) return false;
    return c.message.toLowerCase().contains('@${me.toLowerCase()}');
  }

  @override
  State<ChatTicker> createState() => _ChatTickerState();
}

class _ChatTickerState extends State<ChatTicker> {
  /// Teto de itens renderizados (o view model já limita comentários a 30).
  static const _maxItems = 50;

  /// Distância do fim (px) a partir da qual consideramos "lendo histórico".
  static const _readingThreshold = 24.0;

  final ScrollController _scrollController = ScrollController();
  int _unread = 0;

  // ── Ritmo do chat (live cheia) ─────────────────────────────────────────
  // Mensagens de outras pessoas entram numa fila e aparecem num ritmo que
  // dá para ler (mais rápido quando a fila cresce). As MINHAS, as do
  // criador, as que me mencionam e as linhas de presente entram na hora —
  // e depois da minha o chat segura os outros por um instante para ela não
  // ser atropelada. Fila grande demais: descarta as mais antigas comuns.
  static const _maxPending = 24;
  static const _myMessageHold = Duration(milliseconds: 1400);
  final Set<String> _revealed = {};
  final List<String> _pending = [];
  Timer? _paceTimer;
  DateTime _holdUntil = DateTime.fromMillisecondsSinceEpoch(0);
  bool _primed = false;

  String _keyOf(TickerItem it) => it.comment != null ? 'c:${it.comment!.id}' : 'g:${it.gift!.id}';

  bool _isPriority(TickerItem it) {
    final c = it.comment;
    if (c == null) return true; // linha de presente (já agrupada)
    return c.isSystem ||
        c.isPending ||
        c.userId == widget.myUserId ||
        (widget.hostUserId != null && c.userId == widget.hostUserId) ||
        widget._mentionsMe(c);
  }

  bool _isMine(TickerItem it) {
    final c = it.comment;
    return c != null && (c.isPending || c.userId == widget.myUserId);
  }

  List<TickerItem> _allItems() => <TickerItem>[
    for (final c in widget.comments) TickerItem(timestamp: c.timestamp, comment: c),
    for (final g in widget.gifts.where((g) => g.showInChat)) TickerItem(timestamp: g.timestamp, gift: g),
  ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  /// Separa o que é novo: prioridade aparece já; o resto vai para a fila.
  void _ingest() {
    final items = _allItems();
    if (!_primed) {
      // Histórico ao entrar na live: tudo de uma vez.
      _primed = true;
      _revealed.addAll(items.map(_keyOf));
      return;
    }
    var revealedNow = 0;
    for (final it in items) {
      final k = _keyOf(it);
      if (_revealed.contains(k) || _pending.contains(k)) continue;
      if (_isPriority(it)) {
        _revealed.add(k);
        revealedNow++;
        if (_isMine(it)) _holdUntil = DateTime.now().add(_myMessageHold);
      } else {
        _pending.add(k);
      }
    }
    while (_pending.length > _maxPending) {
      _pending.removeAt(0);
    }
    // O view model só guarda as últimas mensagens: esquece chaves antigas.
    final alive = items.map(_keyOf).toSet();
    _revealed.retainAll(alive);
    _pending.retainWhere(alive.contains);
    if (revealedNow > 0 && _isReadingHistory) _unread += revealedNow;
    _schedulePace();
  }

  void _schedulePace() {
    if (_paceTimer != null || _pending.isEmpty) return;
    final backlog = _pending.length;
    var wait = Duration(milliseconds: backlog <= 3 ? 320 : (backlog <= 8 ? 190 : 120));
    final hold = _holdUntil.difference(DateTime.now());
    if (hold > wait) wait = hold;
    _paceTimer = Timer(wait, () {
      _paceTimer = null;
      if (!mounted || _pending.isEmpty) return;
      setState(() {
        _revealed.add(_pending.removeAt(0));
        if (_isReadingHistory) _unread++;
      });
      _schedulePace();
    });
  }

  bool get _isReadingHistory =>
      _scrollController.hasClients &&
      _scrollController.offset > _readingThreshold;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _ingest();
  }

  @override
  void didUpdateWidget(ChatTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ingest();
  }

  void _onScroll() {
    if (_unread > 0 && !_isReadingHistory) {
      setState(() => _unread = 0);
    }
  }

  void _jumpToLatest() {
    setState(() => _unread = 0);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _paceTimer?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Só o que já foi liberado pelo ritmo do chat; repetições da mesma
    // pessoa com o mesmo texto (spam, "kkkk" em sequência) viram ×N.
    final items = <TickerItem>[];
    final repeats = <String, int>{};
    final lastIndexBySpam = <String, int>{};
    for (final it in _allItems()) {
      if (!_revealed.contains(_keyOf(it))) continue;
      final c = it.comment;
      if (c != null && !c.isSystem) {
        final spamKey = '${c.userId}|${c.message.trim().toLowerCase()}';
        final prev = lastIndexBySpam[spamKey];
        if (prev != null &&
            it.timestamp.difference(items[prev].timestamp).inSeconds.abs() <= 20) {
          repeats[_keyOf(items[prev])] = (repeats[_keyOf(items[prev])] ?? 1) + 1;
          continue;
        }
        lastIndexBySpam[spamKey] = items.length;
      }
      items.add(it);
    }

    if (items.isEmpty) return const SizedBox.shrink();
    final visible = items.length > _maxItems
        ? items.sublist(items.length - _maxItems)
        : items;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [Colors.transparent, Colors.black, Colors.black],
            stops: [0, 0.08, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            // reverse + shrinkWrap: índice 0 = mais recente, desenhado na
            // base. Com poucas mensagens a lista fica curta e colada no
            // input (antes ficava no topo de uma caixa fixa de 240px).
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 12),
              physics: const ClampingScrollPhysics(),
              itemCount: visible.length,
              itemBuilder: (_, i) {
                final it = visible[visible.length - 1 - i];
                final c = it.comment;
                if (c != null) {
                  final isMine = c.isSystem || c.userId == widget.myUserId || c.isPending;
                  final times = repeats[_keyOf(it)] ?? 1;
                  final line = ChatLine(
                    comment: c,
                    isHost:
                        widget.hostUserId != null &&
                        c.userId == widget.hostUserId,
                    mentionsMe: widget._mentionsMe(c),
                    onTap: isMine || widget.onCommentTap == null
                        ? null
                        : () => widget.onCommentTap!(c),
                  );
                  if (times <= 1) return line;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: line),
                      Container(
                        margin: const EdgeInsets.only(left: 4, top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '×$times',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  );
                }
                return GiftChatLine(
                  gift: it.gift!,
                  parts: widget.giftParts[it.gift!.id],
                );
              },
            ),
          ),
        ),
        if (_unread > 0)
          Positioned(
            left: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _jumpToLatest,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 6),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _unread == 1
                          ? '1 nova mensagem'
                          : '$_unread novas mensagens',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.black87,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
