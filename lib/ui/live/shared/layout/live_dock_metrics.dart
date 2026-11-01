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

/// Efeito premium em cena (vídeo VAP, animação grande ou tela cheia).
/// Enquanto > 0, o chat e o painel de avisos esmaecem: o presente é o
/// protagonista por alguns segundos e o texto não briga com a animação.
class LiveStageFocus {
  LiveStageFocus._();

  static final ValueNotifier<int> active = ValueNotifier<int>(0);

  static void enter() => active.value = active.value + 1;

  static void leave() {
    if (active.value > 0) active.value = active.value - 1;
  }
}

/// Esmaece o filho enquanto um efeito premium está na tela.
class StageFocusDimmer extends StatelessWidget {
  const StageFocusDimmer({super.key, required this.child, this.dimmedOpacity = 0.12});

  final Widget child;
  final double dimmedOpacity;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LiveStageFocus.active,
      builder: (_, active, child) => AnimatedOpacity(
        opacity: active > 0 ? dimmedOpacity : 1,
        duration: Duration(milliseconds: active > 0 ? 250 : 450),
        curve: Curves.easeOut,
        child: child,
      ),
      child: child,
    );
  }
}
