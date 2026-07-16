import 'package:flutter/material.dart';

import '../../../../../domain/models/live_comment.dart';
import '../../../../../domain/models/live_gift.dart';
import 'chat_line.dart';
import 'gift_chat_line.dart';
import 'ticker_item.dart';

/// Ticker do chat da live: mescla comentários + presentes em uma única
/// timeline ordenada por timestamp e mostra as últimas 6 entradas, com
/// fade-out no topo via `ShaderMask`.
///
/// ⚠️ LAYOUT: Último item sempre visível no topo (mais recente).
/// Quando atinge max (6 items), a coluna faz scroll automático.
class ChatTicker extends StatefulWidget {
  const ChatTicker({super.key, required this.comments, required this.gifts});
  final List<LiveComment> comments;
  final List<LiveGift> gifts;

  @override
  State<ChatTicker> createState() => _ChatTickerState();
}

class _ChatTickerState extends State<ChatTicker> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Agendá scroll para o final quando widget renderizar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void didUpdateWidget(ChatTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Quando há novos itens, scroll automático para o final
    if (oldWidget.comments.length != widget.comments.length ||
        oldWidget.gifts.length != widget.gifts.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = <TickerItem>[
      for (final c in widget.comments)
        TickerItem(timestamp: c.timestamp, comment: c),
      // 🎁 CHAT IMEDIATO (Fase 11): TODO presente aparece no chat assim
      // que chega, em paralelo com a animação (se houver) — não espera
      // `isAnimating` virar false. Isso elimina o atraso histórico onde
      // a mensagem só surgia depois de ~3s de animação.
      // `showInChat` respeita o campo vindo do backend (default true —
      // praticamente todo presente aparece no chat; existe só para casos
      // excepcionais futuros).
      for (final g in widget.gifts.where((g) => g.showInChat))
        TickerItem(timestamp: g.timestamp, gift: g),
    ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (items.isEmpty) return const SizedBox.shrink();
    final visible = items.length > 6 ? items.sublist(items.length - 6) : items;

    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        colors: [Colors.transparent, Colors.black, Colors.black],
        stops: [0, 0.05, 1], // 🔧 Reduzido de 0.25 (60px fade → 12px suave)
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: SizedBox(
        height: 240, // ✨ Otimizado: ~5-6 itens visíveis (era 200px)
        child: SingleChildScrollView(
          controller: _scrollController,
          reverse: false, // Items crescem de cima para baixo
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final it in visible)
                if (it.comment != null)
                  ChatLine(comment: it.comment!)
                else if (it.gift != null)
                  GiftChatLine(gift: it.gift!),
            ],
          ),
        ),
      ),
    );
  }
}
