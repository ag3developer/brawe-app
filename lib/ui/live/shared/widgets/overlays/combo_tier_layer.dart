import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vap_player/flutter_vap_player.dart';
import 'package:lottie/lottie.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/remote_config/remote_flags.dart';
import '../../../../../data/repositories/gift_repository.dart';
import '../../../../../data/repositories/live_repository.dart';
import '../../../../../data/services/gift_effect_cache.dart';
import '../../../../../data/services/sfx_player.dart';
import '../../../../../domain/models/combo_tier.dart';
import '../../../../../domain/models/gift_presentation.dart';
import '../../../../../domain/models/live_room_event.dart';
import '../fx/particle_field.dart';
import 'combo_tier_queue.dart';
import 'gift_stage.dart';

/// Háptico dos degraus: leve/médio/forte e o "duplo" (dois impactos com
/// 90 ms) dos degraus com `announce`.
class ComboHaptics {
  ComboHaptics._();

  static const Duration doubleGap = Duration(milliseconds: 90);

  static Future<void> fire(GiftHaptic haptic, {bool announce = false}) async {
    try {
      if (announce) {
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(doubleGap);
        await HapticFeedback.heavyImpact();
        return;
      }
      switch (haptic) {
        case GiftHaptic.none:
          break;
        case GiftHaptic.light:
          await HapticFeedback.lightImpact();
        case GiftHaptic.medium:
          await HapticFeedback.mediumImpact();
        case GiftHaptic.heavy:
          await HapticFeedback.heavyImpact();
      }
    } catch (_) {}
  }
}

/// Camada dos degraus de combo (`gift_combo_tier`).
///
/// - Partículas tocam pelo [GiftStage] como conteúdo; sobrepõem presente em
///   cena só se a camada for `under_chat` — senão esperam na fila.
/// - Lottie/VAP entram numa fila de prioridade menor que a dos presentes e
///   são descartados após 6 s.
/// - Som pelo [SfxPlayer] (baixa latência); háptico por [ComboHaptics].
class ComboTierLayer extends ConsumerStatefulWidget {
  const ComboTierLayer({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<ComboTierLayer> createState() => _ComboTierLayerState();
}

class _ComboTierLayerState extends ConsumerState<ComboTierLayer> {
  static const _fetchWait = Duration(seconds: 3);

  final ComboTierQueue _queue = ComboTierQueue();
  final List<QueuedTier> _heldParticles = [];
  StreamSubscription<LiveRoomEvent>? _sub;
  Timer? _retry;
  bool _busy = false;
  _MediaPlaying? _media;
  _ParticlePlaying? _particles;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _sub = ref
        .read(liveRepositoryProvider)
        .watchRoomEvents(widget.roomId)
        .listen(_onRoomEvent);
    GiftStage.activeGifts.addListener(_onGiftChange);
    _preloadCatalogSounds();
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

  /// Ao entrar na live, aquece (sem pressa) os sons dos degraus do catálogo.
  /// Servidor sem `combo_tiers` no catálogo: nada a fazer — o 1º degrau
  /// recebido baixa o som na hora.
  Future<void> _preloadCatalogSounds() async {
    try {
      final tiers = await ref.read(giftRepositoryProvider).getGiftCatalog();
      for (final t in tiers) {
        for (final g in t.gifts) {
          for (final raw in g.comboTiers ?? const <Map<String, dynamic>>[]) {
            final url = raw['sound_url']?.toString();
            if (url == null || url.isEmpty) continue;
            if (!mounted) return;
            await SfxPlayer.instance.preload(_resolveUrl(url));
          }
        }
      }
    } catch (e) {
      debugPrint('[COMBO-FX] preload falhou: $e');
    }
  }

  void _onRoomEvent(LiveRoomEvent e) {
    if (!mounted || e.type != LiveRoomEvent.giftComboTier) return;
    // Interruptor remoto (`feature_combos`): sem efeitos de degrau.
    if (!RemoteFlags.current.featureCombos) return;
    final ev = ComboTierEvent.tryParse(e.data);
    if (ev == null) return;
    // Aquece arquivo e som do degrau mesmo que ele seja descartado depois.
    final url = ev.tier.effectUrl;
    if (url != null) {
      GiftEffectCache.instance.fetch(_resolveUrl(url)).catchError((_) => null);
    }
    final snd = ev.tier.soundUrl;
    if (snd != null) SfxPlayer.instance.preload(_resolveUrl(snd));

    if (ev.tier.type == ComboEffectType.particles) {
      final pr = ev.tier.resolvedPresentation;
      if (GiftStage.activeGifts.value > 0 && pr.layer == GiftLayer.overChat) {
        _heldParticles
          ..clear()
          ..add(QueuedTier(ev, DateTime.now()));
        return;
      }
      _playParticles(ev);
    } else {
      _queue.add(ev);
      _pump();
    }
  }

  void _playSound(ComboTierEvent ev) {
    final snd = ev.tier.soundUrl;
    if (snd != null) SfxPlayer.instance.play(_resolveUrl(snd));
  }

  void _playParticles(ComboTierEvent ev) {
    ComboHaptics.fire(ev.tier.haptic, announce: ev.tier.announce);
    _playSound(ev);
    setState(() => _particles = _ParticlePlaying(++_seq, ev));
  }

  void _onGiftChange() {
    if (GiftStage.activeGifts.value == 0) {
      _retry?.cancel();
      _retry = Timer(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        _releaseHeldParticles();
        _pump();
      });
    }
  }

  void _releaseHeldParticles() {
    if (_heldParticles.isEmpty) return;
    final q = _heldParticles.removeLast();
    _heldParticles.clear();
    if (DateTime.now().difference(q.at) <= _queue.maxAge) {
      _playParticles(q.event);
    }
  }

  Future<void> _pump() async {
    if (_busy || !mounted) return;
    final giftPlaying = GiftStage.activeGifts.value > 0;
    final next = _queue.next(giftPlaying: giftPlaying);
    if (next == null) {
      if (giftPlaying && !_queue.isEmpty) {
        _retry?.cancel();
        _retry = Timer(const Duration(seconds: 1), _pump);
      }
      return;
    }
    _busy = true;
    try {
      final url = _resolveUrl(next.event.tier.effectUrl!);
      var file = GiftEffectCache.instance.cachedFile(url);
      file ??= await GiftEffectCache.instance
          .fetch(url)
          .timeout(_fetchWait, onTimeout: () => null);
      if (!mounted) return;
      if (file != null &&
          GiftStage.activeGifts.value == 0 &&
          !_queue.isStale(next)) {
        ComboHaptics.fire(
          next.event.tier.haptic,
          announce: next.event.tier.announce,
        );
        _playSound(next.event);
        setState(() => _media = _MediaPlaying(++_seq, next.event, file!));
        return; // _busy segue true até o efeito terminar
      }
      if (file == null) debugPrint('[COMBO-FX] arquivo não chegou — pulando');
    } catch (e) {
      debugPrint('[COMBO-FX] falhou: $e');
    }
    _busy = false;
    _pump();
  }

  void _onMediaDone() {
    if (!mounted) return;
    setState(() => _media = null);
    _busy = false;
    _pump();
  }

  void _onParticlesDone(int id) {
    if (!mounted || _particles?.id != id) return;
    setState(() => _particles = null);
  }

  /// Háptico é disparado aqui (com o "duplo" do announce), não no estágio.
  static GiftPresentation _quiet(GiftPresentation p) =>
      p.copyWith(haptic: GiftHaptic.none);

  @override
  Widget build(BuildContext context) {
    final m = _media;
    final p = _particles;
    if (m == null && p == null) return const SizedBox.shrink();
    return Stack(
      fit: StackFit.expand,
      children: [
        if (p != null)
          _TierParticles(
            key: ValueKey('p${p.id}'),
            event: p.event,
            pr: _quiet(p.event.tier.resolvedPresentation),
            onDone: () => _onParticlesDone(p.id),
          ),
        if (m != null)
          m.event.tier.type == ComboEffectType.vap
              ? _TierVap(
                  key: ValueKey('m${m.id}'),
                  file: m.file,
                  pr: _quiet(m.event.tier.resolvedPresentation),
                  onDone: _onMediaDone,
                )
              : _TierLottie(
                  key: ValueKey('m${m.id}'),
                  file: m.file,
                  pr: _quiet(m.event.tier.resolvedPresentation),
                  onDone: _onMediaDone,
                ),
      ],
    );
  }
}

class _MediaPlaying {
  _MediaPlaying(this.id, this.event, this.file);
  final int id;
  final ComboTierEvent event;
  final File file;
}

class _ParticlePlaying {
  _ParticlePlaying(this.id, this.event);
  final int id;
  final ComboTierEvent event;
}

class _TierParticles extends StatefulWidget {
  const _TierParticles({
    super.key,
    required this.event,
    required this.pr,
    required this.onDone,
  });
  final ComboTierEvent event;
  final GiftPresentation pr;
  final VoidCallback onDone;

  @override
  State<_TierParticles> createState() => _TierParticlesState();
}

class _TierParticlesState extends State<_TierParticles> {
  bool _done = false;

  void _finish() {
    if (_done) return;
    _done = true;
    scheduleMicrotask(widget.onDone);
  }

  @override
  void dispose() {
    _done = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GiftStage(
      presentation: widget.pr,
      holdMs: widget.pr.holdMs ?? 2500,
      // Partículas não bloqueiam presentes nem entradas de viewer.
      countsAsGift: false,
      onDone: _finish,
      builder: (context, size) => ParticleField(preset: widget.event.tier.preset!),
    );
  }
}

class _TierVap extends StatefulWidget {
  const _TierVap({
    super.key,
    required this.file,
    required this.pr,
    required this.onDone,
  });
  final File file;
  final GiftPresentation pr;
  final VoidCallback onDone;

  @override
  State<_TierVap> createState() => _TierVapState();
}

class _TierVapState extends State<_TierVap> {
  late final VapPlayerController _ctrl;
  final GlobalKey<GiftStageState> _stageKey = GlobalKey<GiftStageState>();
  StreamSubscription<VapEvent>? _events;
  Timer? _safety;
  bool _ready = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // O som do degrau toca pelo SfxPlayer; o do vídeo fica mudo para não
    // dobrar.
    _ctrl = VapPlayerController.file(
      widget.file,
      options: VapPlayerOptions(mute: true, scaleType: VapScaleType.fitCenter),
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
      debugPrint('[COMBO-FX] VAP falhou: $e');
      _finish();
    }
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _safety?.cancel();
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
      onDone: _finish,
      builder: (context, size) => VapPlayer(_ctrl),
    );
  }
}

class _TierLottie extends StatefulWidget {
  const _TierLottie({
    super.key,
    required this.file,
    required this.pr,
    required this.onDone,
  });
  final File file;
  final GiftPresentation pr;
  final VoidCallback onDone;

  @override
  State<_TierLottie> createState() => _TierLottieState();
}

class _TierLottieState extends State<_TierLottie> {
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
          if (widget.pr.holdMs == null) {
            _end = Timer(comp.duration, () => _stageKey.currentState?.requestExit());
          }
        },
      ),
    );
  }
}
