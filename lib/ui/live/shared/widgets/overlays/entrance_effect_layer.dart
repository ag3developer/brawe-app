import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vap_player/flutter_vap_player.dart';
import 'package:lottie/lottie.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../data/repositories/auth_state_provider.dart';
import '../../../../../data/repositories/live_repository.dart';
import '../../../../../data/services/gift_effect_cache.dart';
import '../../../../../domain/models/gift_presentation.dart';
import '../../../../../domain/models/live_viewer_event.dart';
import 'entrance_effect_queue.dart';
import 'gift_stage.dart';

/// Camada dos efeitos de entrada de viewer (VAP/Lottie) pelo [GiftStage].
///
/// Serve viewer e criador (o criador vê quem chega). Um efeito por vez,
/// nunca sobre um presente em cena, entradas velhas são descartadas e a
/// própria entrada é ignorada. O download é lazy: espera até 3 s e, se não
/// chegar, pula (o arquivo continua baixando para a próxima vez).
class EntranceEffectLayer extends ConsumerStatefulWidget {
  const EntranceEffectLayer({
    super.key,
    required this.roomId,
    this.ignoreUserId,
  });

  final String roomId;

  /// Id extra a ignorar (ex.: o próprio streamer, que o servidor ecoa).
  final String? ignoreUserId;

  @override
  ConsumerState<EntranceEffectLayer> createState() =>
      _EntranceEffectLayerState();
}

class _EntranceEffectLayerState extends ConsumerState<EntranceEffectLayer> {
  static const _fetchWait = Duration(seconds: 3);

  final EntranceEffectQueue _queue = EntranceEffectQueue();
  StreamSubscription<LiveViewerEvent>? _sub;
  Timer? _retry;
  bool _busy = false;
  _Playing? _playing;

  @override
  void initState() {
    super.initState();
    _sub = ref
        .read(liveRepositoryProvider)
        .watchViewerEvents(widget.roomId)
        .listen(_onViewer);
    GiftStage.activeGifts.addListener(_onGiftChange);
  }

  @override
  void dispose() {
    GiftStage.activeGifts.removeListener(_onGiftChange);
    _sub?.cancel();
    _retry?.cancel();
    _queue.clear();
    super.dispose();
  }

  static String _resolveUrl(String raw) {
    if (raw.startsWith('http')) return raw;
    final base = AppConstants.connectApiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    return raw.startsWith('/') ? '$base$raw' : '$base/$raw';
  }

  void _onViewer(LiveViewerEvent e) {
    final entry = e.entry;
    if (!mounted || entry == null || !e.joined) return;
    // Aquece o cache mesmo que esta entrada seja descartada (próprias,
    // velhas…): a próxima do mesmo tier já toca na hora.
    GiftEffectCache.instance.fetch(_resolveUrl(entry.url)).catchError((_) => null);
    final me = ref.read(authStateProvider).value?.id;
    if (_queue.add(e, ignoreUserIds: {me, widget.ignoreUserId})) _pump();
  }

  void _onGiftChange() {
    if (GiftStage.activeGifts.value == 0) {
      // Evita mexer no estado durante build/dispose do estágio do presente.
      _retry?.cancel();
      _retry = Timer(const Duration(milliseconds: 250), _pump);
    }
  }

  Future<void> _pump() async {
    if (_busy || !mounted) return;
    final giftPlaying = GiftStage.activeGifts.value > 0;
    final next = _queue.next(giftPlaying: giftPlaying);
    if (next == null) {
      if (giftPlaying && !_queue.isEmpty) {
        // Espera o presente; as velhas caem em dropStale.
        _retry?.cancel();
        _retry = Timer(const Duration(seconds: 1), _pump);
      }
      return;
    }
    _busy = true;
    try {
      final entry = next.event.entry!;
      final url = _resolveUrl(entry.url);
      var file = GiftEffectCache.instance.cachedFile(url);
      file ??= await GiftEffectCache.instance
          .fetch(url)
          .timeout(_fetchWait, onTimeout: () => null);
      if (!mounted) return;
      // Depois da espera um presente pode ter começado: não sobrepõe.
      if (file != null &&
          GiftStage.activeGifts.value == 0 &&
          !_queue.isStale(next)) {
        setState(() => _playing = _Playing(next.event, entry, file!));
        return; // _busy segue true até o efeito terminar
      }
      if (file == null) debugPrint('[ENTRY-FX] arquivo não chegou — pulando');
    } catch (e) {
      debugPrint('[ENTRY-FX] falhou: $e');
    }
    _busy = false;
    _pump();
  }

  void _onDone() {
    if (!mounted) return;
    setState(() => _playing = null);
    _busy = false;
    _pump();
  }

  @override
  Widget build(BuildContext context) {
    final p = _playing;
    if (p == null) return const SizedBox.shrink();
    final pr = GiftPresentation.parse(
      p.entry.presentation,
      fallback: GiftPresentation.entranceDefault,
    );
    return p.entry.isVap
        ? _EntryVap(key: ValueKey(p), file: p.file, entry: p.entry, pr: pr, onDone: _onDone)
        : _EntryLottie(key: ValueKey(p), file: p.file, pr: pr, onDone: _onDone);
  }
}

class _Playing {
  _Playing(this.event, this.entry, this.file);
  final LiveViewerEvent event;
  final ViewerEntryEffect entry;
  final File file;
}

class _EntryVap extends StatefulWidget {
  const _EntryVap({
    super.key,
    required this.file,
    required this.entry,
    required this.pr,
    required this.onDone,
  });
  final File file;
  final ViewerEntryEffect entry;
  final GiftPresentation pr;
  final VoidCallback onDone;

  @override
  State<_EntryVap> createState() => _EntryVapState();
}

class _EntryVapState extends State<_EntryVap> {
  late final VapPlayerController _ctrl;
  final GlobalKey<GiftStageState> _stageKey = GlobalKey<GiftStageState>();
  StreamSubscription<VapEvent>? _events;
  Timer? _safety;
  bool _ready = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VapPlayerController.file(
      widget.file,
      options: VapPlayerOptions(
        mute: !widget.entry.soundEnabled,
        scaleType: VapScaleType.fitCenter,
      ),
    );
    _events = _ctrl.events.listen((e) {
      if (e is VapCompletedEvent) {
        final stage = _stageKey.currentState;
        stage == null ? _finish() : stage.requestExit();
      } else if (e is VapErrorEvent) {
        _finish();
      }
    }, onError: (_) => _finish());
    _safety = Timer(
      Duration(milliseconds: (widget.pr.holdMs ?? 10000) + 5000),
      _finish,
    );
    _start();
  }

  Future<void> _start() async {
    try {
      await _ctrl.initialize();
      if (!mounted || _done) return;
      setState(() => _ready = true);
      await _ctrl.play();
    } catch (e) {
      debugPrint('[ENTRY-FX] VAP falhou: $e');
      _finish();
    }
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _safety?.cancel();
    // Fora do build/dispose em curso.
    scheduleMicrotask(widget.onDone);
  }

  @override
  void dispose() {
    _done = true;
    _events?.cancel();
    _safety?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();
    return GiftStage(
      key: _stageKey,
      presentation: widget.pr,
      holdMs: widget.pr.holdMs,
      countsAsGift: false,
      onDone: _finish,
      builder: (context, size) => VapPlayer(_ctrl),
    );
  }
}

class _EntryLottie extends StatefulWidget {
  const _EntryLottie({
    super.key,
    required this.file,
    required this.pr,
    required this.onDone,
  });
  final File file;
  final GiftPresentation pr;
  final VoidCallback onDone;

  @override
  State<_EntryLottie> createState() => _EntryLottieState();
}

class _EntryLottieState extends State<_EntryLottie> {
  final GlobalKey<GiftStageState> _stageKey = GlobalKey<GiftStageState>();
  Timer? _end;
  Timer? _safety;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _safety = Timer(
      Duration(milliseconds: (widget.pr.holdMs ?? 6000) + 6000),
      _finish,
    );
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _end?.cancel();
    _safety?.cancel();
    scheduleMicrotask(widget.onDone);
  }

  @override
  void dispose() {
    _done = true;
    _end?.cancel();
    _safety?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GiftStage(
      key: _stageKey,
      presentation: widget.pr,
      holdMs: widget.pr.holdMs,
      countsAsGift: false,
      onDone: _finish,
      builder: (context, size) => Lottie.file(
        widget.file,
        width: size.width,
        height: size.height,
        fit: BoxFit.contain,
        repeat: false,
        errorBuilder: (_, _, _) {
          _finish();
          return const SizedBox.shrink();
        },
        onLoaded: (comp) {
          // Sem hold_ms: sai quando a animação termina.
          if (widget.pr.holdMs == null) {
            _end = Timer(comp.duration, () => _stageKey.currentState?.requestExit());
          }
        },
      ),
    );
  }
}
