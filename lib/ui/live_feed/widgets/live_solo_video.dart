import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../home/widgets/views/landscape_video_page.dart';

/// Vídeo da live solo que se adapta ao formato do sinal.
///
/// - Sinal em pé (app, OBS 1080×1920): preenche a tela, como sempre.
/// - Sinal deitado (OBS 1920×1080, jogo, tela do PC): o vídeo aparece
///   INTEIRO no centro, com o próprio vídeo ampliado e desfocado ao fundo,
///   e um botão para assistir deitado em tela cheia. Antes o `cover`
///   cortava ~70% da largura e o criador tinha que remontar a cena no OBS.
///
/// Escuta o controller: se o criador trocar a resolução no meio da live,
/// o layout acompanha.
class LiveSoloVideo extends StatefulWidget {
  const LiveSoloVideo({super.key, required this.controller});

  final VideoPlayerController controller;

  /// Proporção a partir da qual o sinal é tratado como deitado.
  static const double landscapeRatio = 1.1;

  @override
  State<LiveSoloVideo> createState() => _LiveSoloVideoState();
}

class _LiveSoloVideoState extends State<LiveSoloVideo> {
  late Size _size = widget.controller.value.size;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onValue);
  }

  @override
  void didUpdateWidget(LiveSoloVideo old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onValue);
      widget.controller.addListener(_onValue);
      _size = widget.controller.value.size;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onValue);
    super.dispose();
  }

  // Só reconstrói quando o tamanho muda (não a cada posição do vídeo).
  void _onValue() {
    final size = widget.controller.value.size;
    if (size != _size && mounted) setState(() => _size = size);
  }

  @override
  Widget build(BuildContext context) =>
      _SizedFrame(controller: widget.controller, size: _size);
}

class _SizedFrame extends StatelessWidget {
  const _SizedFrame({required this.controller, required this.size});

  final VideoPlayerController controller;
  final Size size;

  Widget _cover() => FittedBox(
    fit: BoxFit.cover,
    clipBehavior: Clip.hardEdge,
    child: SizedBox(
      width: size.width,
      height: size.height,
      child: VideoPlayer(controller),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ratio = size.height > 0 ? size.width / size.height : 0.0;
    if (ratio <= LiveSoloVideo.landscapeRatio) {
      return SizedBox.expand(child: _cover());
    }

    return LayoutBuilder(
      builder: (context, box) {
        final videoH = box.maxWidth / ratio;
        final top = (box.maxHeight - videoH) / 2;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Fundo: o próprio vídeo ampliado e desfocado (estilo feed).
            ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: _cover(),
              ),
            ),
            const ColoredBox(color: Color(0x66000000)),
            // Vídeo inteiro, centralizado.
            Positioned(
              left: 0,
              right: 0,
              top: top,
              height: videoH,
              child: VideoPlayer(controller),
            ),
            // Assistir deitado em tela cheia.
            Positioned(
              top: top + 8,
              right: 8,
              child: _FullscreenButton(
                onTap: () =>
                    LandscapeVideoPage.open(context, controller, live: true),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FullscreenButton extends StatelessWidget {
  const _FullscreenButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = S.of(context).videoFullscreen;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.maximize, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
