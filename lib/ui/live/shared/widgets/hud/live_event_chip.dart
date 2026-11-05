import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/remote_config/remote_flags.dart';
import '../../../../../domain/models/live_event.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../live_feed/view_models/live_room_comments_view_model.dart';

/// Evento com prazo da sala: "{nome} 2×" + "termina em 05:12:30".
///
/// Compacto (nome e contagem em reticências, nunca estoura em tela estreita),
/// some quando o evento acaba ou o servidor manda `event_update` vazio.
/// O estado do evento vem do view model da sala (`event_update` + releitura
/// ao reconectar); o chip só desenha e conta o tempo.
/// Servidor antigo (sem `event`) = não renderiza nada.
class LiveEventChip extends ConsumerStatefulWidget {
  const LiveEventChip({
    super.key,
    required this.roomId,
    required this.initialEvent,
    required this.onTap,
    this.expand = false,
  });

  /// Pílula de largura total (linha de 3 pílulas iguais), altura 30.
  final bool expand;
  final String roomId;
  final LiveEvent? initialEvent;

  /// Abre o ranking na aba "Evento", com o evento atual.
  final void Function(LiveEvent event) onTap;

  @override
  ConsumerState<LiveEventChip> createState() => _LiveEventChipState();
}

class _LiveEventChipState extends ConsumerState<LiveEventChip> {
  static const _gold = Color(0xFFFFC53D);

  Timer? _tick;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // Um tick por segundo só enquanto há evento em andamento.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final active = _current();
      if (active == null && !_wasActive) return;
      _wasActive = active != null;
      setState(() => _now = DateTime.now());
    });
  }

  bool _wasActive = true;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  /// Evento da sala: o do servidor (VM) quando já informado; antes disso, o
  /// que veio junto com a sala.
  LiveEvent? _current() {
    final st = ref.read(liveRoomCommentsViewModelProvider(widget.roomId));
    final e = st.eventLoaded ? st.event : widget.initialEvent;
    return (e == null || e.isEnded(DateTime.now())) ? null : e;
  }

  @override
  Widget build(BuildContext context) {
    // Interruptor remoto (`feature_events`).
    if (!ref.watch(remoteFlagsProvider.select((f) => f.featureEvents))) {
      return const SizedBox.shrink();
    }
    final st = ref.watch(liveRoomCommentsViewModelProvider(widget.roomId));
    final e = st.eventLoaded ? st.event : widget.initialEvent;
    if (e == null || e.isEnded(_now)) return const SizedBox.shrink();
    final s = S.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final maxW = (MediaQuery.sizeOf(context).width * 0.32).clamp(92.0, 150.0);
    if (widget.expand) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onTap(e),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _gold.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.calendarDays, size: 14, color: _gold),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  e.localizedName(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 16, color: _gold),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onTap(e),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Container(
            padding: const EdgeInsets.fromLTRB(7, 4, 9, 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _gold.withValues(alpha: 0.7)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.calendarDays, size: 14, color: _gold),
                const SizedBox(width: 6),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.localizedName(lang),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        s.eventChipEndsIn(formatEventCountdown(e.remaining(_now))),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
