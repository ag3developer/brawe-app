import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/themes/app_colors.dart';

/// 🎬 Player dual (split-screen vertical 50/50) usado pelo viewer durante
/// uma BATTLE — renderiza as 2 lives lado a lado, exatamente como TikTok/Bigo.
///
/// **Arquitetura:**
/// - Cria 2 `VideoPlayerController` independentes (1 por streamer).
/// - Cada metade ocupa exatamente 50% da tela com `BoxFit.cover`.
/// - Apenas um lado emite áudio por vez (default: A) — o outro fica mudo
///   pra não gerar eco. Um botão de speaker em cada metade alterna qual
///   streamer emite áudio.
/// - Quando os URLs mudam (ex.: batalha começa depois do init), os
///   controllers velhos são descartados e recriados — evita memory leak.
/// - Se um dos URLs for `null`, mostra placeholder (sala provisionando).
///
/// **Performance:**
/// - `fvp` (registrado no `main.dart`) ativa decodificação por hardware
///   no Android via FFmpeg — sem isso, 2 HLS simultâneos derrubam a CPU.
/// - `mixWithOthers: true` permite SFX de gifts tocarem por cima.
/// - `setLooping(false)` — HLS de live nunca deve loopar.
///
/// **Não trata:**
/// - Pinch-to-zoom (overkill pra MVP).
/// - Picture-in-picture (já existe em outra layer).
/// - Reconexão automática em caso de queda do stream — o `VideoPlayer`
///   tenta sozinho via HLS.js; perda de conexão completa cai pro
///   placeholder no próximo frame inválido.
class DualHlsPlayer extends StatefulWidget {
  const DualHlsPlayer({
    super.key,
    required this.streamUrlA,
    required this.streamUrlB,
    this.streamerAName,
    this.streamerBName,
  });

  /// HLS URL do streamer da esquerda. `null` enquanto não provisionado.
  final String? streamUrlA;

  /// HLS URL do streamer da direita. `null` enquanto não provisionado.
  final String? streamUrlB;

  /// Nome opcional para exibir no placeholder.
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
    return Container(
      // Fundo preto: aparece nos instantes de loading e nas bordas do
      // vídeo (letterbox/pillarbox) antes do BoxFit.cover entrar.
      color: Colors.black,
      child: ClipRect(
        // ClipRect garante que nada vaze pra fora da faixa do SizedBox pai.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _HalfStream(
                controller: _controllerA,
                isInitialized: _initializedA,
                streamerName: widget.streamerAName,
                audioActive: _audioSide == 'A',
                onTapAudio: () => _toggleAudio('A'),
                // Lado esquerdo: borda direita arredondada (divide do
                // separador central).
                cornerRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
            ),
            // ── Divisor central roxo↔rosa (Bigo PK style) ──
            Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.braweBlue.withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.95),
                    AppColors.hotPink.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.braweBlue.withValues(alpha: 0.45),
                    blurRadius: 6,
                    offset: const Offset(-1, 0),
                  ),
                  BoxShadow(
                    color: AppColors.hotPink.withValues(alpha: 0.45),
                    blurRadius: 6,
                    offset: const Offset(1, 0),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _HalfStream(
                controller: _controllerB,
                isInitialized: _initializedB,
                streamerName: widget.streamerBName,
                audioActive: _audioSide == 'B',
                onTapAudio: () => _toggleAudio('B'),
                // Lado direito: borda esquerda arredondada.
                cornerRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HalfStream extends StatelessWidget {
  const _HalfStream({
    required this.controller,
    required this.isInitialized,
    required this.streamerName,
    required this.audioActive,
    required this.onTapAudio,
    required this.cornerRadius,
  });

  final VideoPlayerController? controller;
  final bool isInitialized;
  final String? streamerName;
  final bool audioActive;
  final VoidCallback onTapAudio;
  final BorderRadius cornerRadius;

  @override
  Widget build(BuildContext context) {
    if (controller == null || !isInitialized) {
      return _Placeholder(streamerName: streamerName);
    }

    return ClipRRect(
      borderRadius: cornerRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller!.value.size.width,
              height: controller!.value.size.height,
              child: VideoPlayer(controller!),
            ),
          ),
          // Ícone de áudio no canto superior interno — tocar alterna qual
          // lado emite som. Tamanho compacto pra não competir com o HUD.
          Positioned(
            top: 12,
            left: 12,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTapAudio,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    audioActive ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                    size: 18,
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

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.streamerName});
  final String? streamerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.white54,
            strokeWidth: 2,
          ),
          if (streamerName != null) ...[
            const SizedBox(height: 12),
            Text(
              streamerName!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
