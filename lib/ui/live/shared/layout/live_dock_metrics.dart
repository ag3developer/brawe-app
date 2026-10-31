import 'package:flutter/widgets.dart';

/// Onde começa (em Y global) a coluna de baixo da live — painel de avisos,
/// chat e barra de ações. Os combos de presente (OverlayEntry, fora da
/// árvore) se encaixam logo acima dela, então nada fica um em cima do outro
/// por mais que o chat ou o painel mudem de altura. `null` = tela sem dock
/// medida (ex.: tela do criador) → combos usam a posição calculada antiga.
class LiveDockMetrics {
  LiveDockMetrics._();

  static final ValueNotifier<double?> top = ValueNotifier<double?>(null);
}

/// Mede o topo do filho e publica em [LiveDockMetrics.top] a cada mudança de
/// tamanho/posição (chat crescendo, aviso entrando, teclado abrindo).
class LiveDockTopReporter extends StatefulWidget {
  const LiveDockTopReporter({super.key, required this.child});

  final Widget child;

  @override
  State<LiveDockTopReporter> createState() => _LiveDockTopReporterState();
}

class _LiveDockTopReporterState extends State<LiveDockTopReporter> {
  void _measure() {
    if (!mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return;
    final y = box.localToGlobal(Offset.zero).dy;
    final cur = LiveDockMetrics.top.value;
    if (cur == null || (cur - y).abs() > 0.5) LiveDockMetrics.top.value = y;
  }

  void _schedule() => WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

  @override
  void dispose() {
    LiveDockMetrics.top.value = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _schedule();
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        _schedule();
        return false;
      },
      child: SizeChangedLayoutNotifier(child: widget.child),
    );
  }
}
