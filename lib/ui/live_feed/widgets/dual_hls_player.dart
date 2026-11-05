import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../battle/battle_hud_parts.dart';
import '../battle/battle_layout.dart';

/// Player dual (fallback `dual_hls` da Batalha v2): renderiza as 2 lives
/// dentro da MESMA faixa dividida da composição (A à esquerda, B à direita,
/// divisor de 4 px no frame), calculada por [BattleLayout].
///
/// - 2 `VideoPlayerController` (1 por criador), `BoxFit.cover` em cada metade.
/// - Só um lado emite áudio por vez (padrão: A) para não criar eco; o botão
///   de alto-falante no canto inferior EXTERNO de cada metade alterna.
/// - Nome do criador em pílula no canto inferior INTERNO de cada metade.
/// - URLs mudando recriam os controllers.
class DualHlsPlayer extends StatefulWidget {
  const DualHlsPlayer({
    super.key,
    required this.layout,
    required this.streamUrlA,
    required this.streamUrlB,
    this.streamerAName,
    this.streamerBName,
  });

  final BattleLayout layout;

  /// HLS URL do streamer da esquerda. `null` enquanto não provisionado.
  final String? streamUrlA;

  /// HLS URL do streamer da direita. `null` enquanto não provisionado.
  final String? streamUrlB;

  final String? streamerAName;
  final String? streamerBName;

  @override
  State<DualHlsPlayer> createState() => _DualHlsPlayerState();
}

class _DualHlsPlayerState extends State<DualHlsPlayer> {
  VideoPlayerController? _controllerA;
  VideoPlayerController? _controllerB;
  bool _initializedA = false;
  bool _initializedB = false;

  /// Qual lado está com áudio ativo: 'A' ou 'B'. Default 'A'.
  /// Em batalha NUNCA os 2 ficam com áudio simultâneo (cria eco horrendo).
  String _audioSide = 'A';

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  @override
  void didUpdateWidget(covariant DualHlsPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recriar quando os URLs mudam (ex.: REST sync trouxe URLs depois do
    // primeiro render com null). Comparação simples de strings basta.
    if (oldWidget.streamUrlA != widget.streamUrlA ||
        oldWidget.streamUrlB != widget.streamUrlB) {
      _disposeControllers();
      _initializedA = false;
      _initializedB = false;
      _setupControllers();
    }
  }

  void _setupControllers() {
    if (widget.streamUrlA != null && widget.streamUrlA!.isNotEmpty) {
      _controllerA = _buildController(widget.streamUrlA!);
      _initController(_controllerA!, isA: true);
    }
    if (widget.streamUrlB != null && widget.streamUrlB!.isNotEmpty) {
      _controllerB = _buildController(widget.streamUrlB!);
      _initController(_controllerB!, isA: false);
    }
  }

  VideoPlayerController _buildController(String url) {
    return VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
      httpHeaders: const {
        'User-Agent': 'BraweApp/1.0 (HLS-Battle-Dual)',
      },
    );
  }

  Future<void> _initController(
    VideoPlayerController controller, {
    required bool isA,
  }) async {
    try {
      await controller.initialize();
      if (!mounted) return;
      controller
        ..play()
        ..setLooping(false)
        // Áudio: lado ativo = 1.0, outro = 0.0
        ..setVolume(_audioSide == (isA ? 'A' : 'B') ? 1.0 : 0.0);
      setState(() {
        if (isA) {
          _initializedA = true;
        } else {
          _initializedB = true;
        }
      });
      WakelockPlus.enable();
    } catch (e) {
      debugPrint('DualHlsPlayer: init error (${isA ? "A" : "B"}): $e');
    }
  }

  void _toggleAudio(String newSide) {
    if (newSide == _audioSide) return;
    setState(() => _audioSide = newSide);
    _controllerA?.setVolume(newSide == 'A' ? 1.0 : 0.0);
    _controllerB?.setVolume(newSide == 'B' ? 1.0 : 0.0);
  }

  void _disposeControllers() {
    _controllerA?.dispose();
    _controllerB?.dispose();
    _controllerA = null;
    _controllerB = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.layout;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fromRect(
          rect: l.halfA,
          child: _HalfStream(
            controller: _controllerA,
            isInitialized: _initializedA,
            side: 'a',
            streamerName: widget.streamerAName,
            audioActive: _audioSide == 'A',
            onTapAudio: () => _toggleAudio('A'),
          ),
        ),
        Positioned.fromRect(
          rect: l.halfB,
          child: _HalfStream(
            controller: _controllerB,
            isInitialized: _initializedB,
            side: 'b',
            streamerName: widget.streamerBName,
            audioActive: _audioSide == 'B',
            onTapAudio: () => _toggleAudio('B'),
          ),
        ),
        // Divisor central (4 px do frame).
        Positioned.fromRect(
          rect: l.divider,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x24FFFFFF),
            ),
          ),
        ),
      ],
    );
  }
}

class _HalfStream extends StatelessWidget {
  const _HalfStream({
    required this.controller,
    required this.isInitialized,
    required this.side,
    required this.streamerName,
    required this.audioActive,
    required this.onTapAudio,
  });

  final VideoPlayerController? controller;
  final bool isInitialized;
  final String side;
  final String? streamerName;
  final bool audioActive;
  final VoidCallback onTapAudio;

  @override
  Widget build(BuildContext context) {
    final isA = side == 'a';
    final ready = controller != null && isInitialized;
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (ready)
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: controller!.value.size.width,
                height: controller!.value.size.height,
                child: VideoPlayer(controller!),
              ),
            )
          else
            const ColoredBox(
              color: Colors.black,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white54,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          // Nome: canto inferior INTERNO (junto ao divisor).
          if (streamerName != null && streamerName!.isNotEmpty)
            Positioned(
              bottom: 8,
              left: isA ? null : 6,
              right: isA ? 6 : null,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (MediaQuery.sizeOf(context).width / 2) - 70,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kBattleBg.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    streamerName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          // Alto-falante: canto inferior EXTERNO — alterna qual lado soa.
          if (ready)
            Positioned(
              bottom: 6,
              left: isA ? 6 : null,
              right: isA ? null : 6,
              child: Tooltip(
                message: S.of(context).battleListenTo(streamerName ?? ''),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTapAudio,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: audioActive
                            ? Colors.white.withValues(alpha: 0.22)
                            : const Color(0xB30B0E14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        audioActive ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        color: kBattleText,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
