import 'package:flutter/material.dart';

import '../../../../../domain/models/live_comment.dart';
import '../../../../../domain/models/live_gift.dart';
import 'chat_line.dart';
import 'gift_chat_line.dart';
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
    this.maxHeight = 240,
    this.hostUserId,
    this.myUserId,
    this.myUsername,
    this.onCommentTap,
  });

  final List<LiveComment> comments;
  final List<LiveGift> gifts;

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

  bool get _isReadingHistory =>
      _scrollController.hasClients &&
      _scrollController.offset > _readingThreshold;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(ChatTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final added =
        (widget.comments.length - oldWidget.comments.length) +
        (widget.gifts.length - oldWidget.gifts.length);
    if (added > 0 && _isReadingHistory) {
      _unread += added;
    }
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
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = <TickerItem>[
      for (final c in widget.comments)
        TickerItem(timestamp: c.timestamp, comment: c),
      // 🎁 CHAT IMEDIATO (Fase 11): TODO presente aparece no chat assim
      // que chega, em paralelo com a animação (se houver).
      for (final g in widget.gifts.where((g) => g.showInChat))
        TickerItem(timestamp: g.timestamp, gift: g),
    ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

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
                  final isMine = c.userId == widget.myUserId || c.isPending;
                  return ChatLine(
                    comment: c,
                    isHost:
                        widget.hostUserId != null &&
                        c.userId == widget.hostUserId,
                    mentionsMe: widget._mentionsMe(c),
                    onTap: isMine || widget.onCommentTap == null
                        ? null
                        : () => widget.onCommentTap!(c),
                  );
                }
                return GiftChatLine(gift: it.gift!);
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
