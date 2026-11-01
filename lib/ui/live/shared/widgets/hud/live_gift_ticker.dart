import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/repositories/live_repository.dart';
import '../../../../../gen/l10n/app_localizations.dart';

/// 📰 Faixa de notícia ao lado das metas: "Fulano enviou Universo para
/// Criador" correndo na horizontal, só texto. Chega de QUALQUER live (Luxo e
/// Lendário) — não cobre o presente nem o rosto do criador. Notícia de outra
/// live: toque leva até ela.
class LiveGiftTicker extends ConsumerStatefulWidget {
  const LiveGiftTicker({super.key, required this.currentRoomId});

  final String currentRoomId;

  @override
  ConsumerState<LiveGiftTicker> createState() => _LiveGiftTickerState();
}

class _LiveGiftTickerState extends ConsumerState<LiveGiftTicker>
    with SingleTickerProviderStateMixin {
  static const _maxQueue = 6;
  static const _speed = 55.0; // px por segundo — dá para ler

  late final AnimationController _ctrl = AnimationController(vsync: this);
  StreamSubscription<Map<String, dynamic>>? _sub;
  final List<Map<String, dynamic>> _queue = [];
  Map<String, dynamic>? _current;
  double _textWidth = 0;
  double _boxWidth = 0;

  @override
  void initState() {
    super.initState();
    _sub = ref.read(liveRepositoryProvider).watchGlobalGiftTicker().listen((e) {
      _queue.add(e);
      while (_queue.length > _maxQueue) {
        _queue.removeAt(0);
      }
      _next();
    });
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _current = null);
        _next();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  String _text(Map<String, dynamic> e) {
    final s = S.of(context);
    final qty = (e['quantity'] as num?)?.toInt() ?? 1;
    final gift = qty > 1 ? '${qty}x ${e['gift_name'] ?? ''}' : '${e['gift_name'] ?? ''}';
    return s.giftTickerText(
      e['sender_name']?.toString() ?? '',
      gift.trim(),
      e['streamer_name']?.toString() ?? '',
    );
  }

  void _next() {
    if (!mounted || _current != null || _queue.isEmpty || _boxWidth <= 0) return;
    final e = _queue.removeAt(0);
    final painter = TextPainter(
      text: TextSpan(text: _text(e), style: _style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    _textWidth = painter.width;
    final distance = _boxWidth + _textWidth;
    _ctrl.duration = Duration(milliseconds: (distance / _speed * 1000).round());
    setState(() => _current = e);
    _ctrl.forward(from: 0);
  }

  static const _style = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
  );

  void _onTap() {
    final e = _current;
    final roomId = e?['room_id']?.toString();
    if (roomId == null || roomId.isEmpty || roomId == widget.currentRoomId) return;
    context.push('/live/$roomId');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;
        if (width != _boxWidth) {
          _boxWidth = width;
          WidgetsBinding.instance.addPostFrameCallback((_) => _next());
        }
        final e = _current;
        if (e == null) return const SizedBox(height: 22);
        final text = _text(e);
        return GestureDetector(
          onTap: _onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 22,
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, child) => Transform.translate(
                  offset: Offset(_boxWidth - (_boxWidth + _textWidth) * _ctrl.value, 0),
                  child: child,
                ),
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  maxWidth: double.infinity,
                  child: Text(text, maxLines: 1, softWrap: false, style: _style),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
