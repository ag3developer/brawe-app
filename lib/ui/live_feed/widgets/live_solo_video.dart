import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../home/widgets/views/landscape_video_page.dart';

/// Cores do Modo Gamer (tokens escuros da marca Brawe).
const kGamerSurface = Color(0xFF0B0E14);
const kGamerRaised = Color(0xFF161B26);
const kGamerBorder = Color(0xFF262D3B);
const kGamerInk = Color(0xFFF4F6FA);
const kGamerMuted = Color(0xFFA3ACBD);

/// Geometria do Modo Gamer, na proporção da prévia aprovada (390×844):
/// câmera 318/844 da altura, faixa da marca de 48 e o jogo em 16:9 na
/// largura toda. O chat começa em [chatTop].
class GamerGeometry {
  const GamerGeometry({
    required this.camH,
    required this.stripH,
    required this.gameH,
  });

  factory GamerGeometry.of(Size screen, {double videoAspect = 16 / 9}) {
    final aspect = videoAspect > 0 ? videoAspect : 16 / 9;
    return GamerGeometry(
      camH: screen.height * (318 / 844),
      stripH: 48,
      gameH: screen.width / aspect,
    );
  }

  final double camH;
  final double stripH;
  final double gameH;

  double get gameTop => camH + stripH;
  double get chatTop => camH + stripH + gameH;
}

/// Vídeo da live solo que se adapta ao formato do sinal e ao visual
/// escolhido pelo criador na web (tema + câmera marcada na cena do OBS).
///
/// - `gamer`: câmera recortada em cima, faixa da marca ([gamerStrip]) e o
///   jogo 16:9 inteiro embaixo. O chat fica abaixo do jogo.
/// - `screen`: tela do PC grande e a câmera numa bolinha.
/// - `talk` / sinal deitado: o quadro inteiro com fundo desfocado.
/// - `camera` (padrão): sinal em pé da câmera do app preenche a tela; sinal
///   do OBS ([keepEdges]) nunca corta as bordas.
///
/// Escuta o controller: se o criador trocar a resolução no meio da live,
/// o layout acompanha.
class LiveSoloVideo extends StatefulWidget {
  const LiveSoloVideo({
    super.key,
    required this.controller,
    this.keepEdges = false,
    this.theme,
    this.cam,
    this.gamerStrip,
  });

  final VideoPlayerController controller;

  /// Mostrar o quadro inteiro (sem cortar bordas) mesmo em pé. Ligado para
  /// lives vindas de encoder externo (`ingest_source == 'web'`).
  final bool keepEdges;

  /// Tema escolhido pelo criador: camera | gamer | screen | talk.
  final String? theme;

  /// Onde está a câmera na cena: [x, y, w, h] normalizado (0–1).
  final List<double>? cam;

  /// Conteúdo da faixa da marca no Modo Gamer.
  final Widget? gamerStrip;

  /// Proporção a partir da qual o sinal é tratado como deitado.
  static const double landscapeRatio = 1.1;

  /// O Modo Gamer só monta com tema, câmera marcada e a cena DEITADA (16:9).
  /// Cena em pé (o criador já montou câmera + jogo no OBS) aparece como vem.
  static bool gamerActive(String? theme, List<double>? cam, Size video) =>
      theme == 'gamer' &&
      cam != null &&
      cam.length == 4 &&
      video.height > 0 &&
      video.width / video.height > landscapeRatio;

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
  Widget build(BuildContext context) {
    final c = widget.controller;
    final cam = widget.cam;
    final hasSize = _size.width > 0 && _size.height > 0;
    if (hasSize && LiveSoloVideo.gamerActive(widget.theme, cam, _size)) {
      return _GamerFrame(
        controller: c,
        size: _size,
        cam: cam!,
        strip: widget.gamerStrip,
      );
    }
    if (hasSize &&
        widget.theme == 'screen' &&
        cam != null &&
        cam.length == 4 &&
        _size.width / _size.height > LiveSoloVideo.landscapeRatio) {
      return _ScreenFrame(controller: c, size: _size, cam: cam);
    }
    return _SizedFrame(
      controller: c,
      size: _size,
      keepEdges: widget.keepEdges || widget.theme == 'talk',
    );
  }
}

// ── Peças comuns ────────────────────────────────────────────────────────────

/// O vídeo inteiro cobrindo a caixa (corta o que sobrar).
Widget _coverVideo(VideoPlayerController controller, Size size) => FittedBox(
  fit: BoxFit.cover,
  clipBehavior: Clip.hardEdge,
  child: SizedBox(
    width: size.width,
    height: size.height,
    child: VideoPlayer(controller),
  ),
);

/// Fundo: o próprio vídeo ampliado e desfocado.
Widget _blurredBackground(VideoPlayerController controller, Size size) => Stack(
  fit: StackFit.expand,
  children: [
    ClipRect(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: _coverVideo(controller, size),
      ),
    ),
    const ColoredBox(color: Color(0x66000000)),
  ],
);

/// Mostra só o retângulo [cam] do vídeo, cobrindo a caixa (mesma conta da
/// prévia da web).
class _CropVideo extends StatelessWidget {
  const _CropVideo({
    required this.controller,
    required this.size,
    required this.cam,
  });

  final VideoPlayerController controller;
  final Size size;
  final List<double> cam;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final bw = box.maxWidth;
        final bh = box.maxHeight;
        final cw = cam[2] * size.width;
        final ch = cam[3] * size.height;
        if (cw <= 0 || ch <= 0) return const SizedBox.shrink();
        final s = (bw / cw) > (bh / ch) ? bw / cw : bh / ch;
        return ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: -cam[0] * size.width * s + (bw - cw * s) / 2,
                top: -cam[1] * size.height * s + (bh - ch * s) / 2,
                width: size.width * s,
                height: size.height * s,
                child: VideoPlayer(controller),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FullscreenButton extends StatelessWidget {
  const _FullscreenButton({
    required this.onTap,
    this.semanticLabel,
    this.compact = false,
  });

  final VoidCallback onTap;
  final String? semanticLabel;

  /// Só o ícone (44×44), para caber no canto da câmera.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = S.of(context).videoFullscreen;
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: Material(
        color: kGamerSurface.withValues(alpha: 0.65),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 44,
            constraints: const BoxConstraints(minWidth: 44),
            padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.maximize,
                  size: compact ? 18 : 16,
                  color: kGamerInk,
                ),
                if (!compact) const SizedBox(width: 6),
                if (!compact)
                  Text(
                    label,
                    style: const TextStyle(
                      color: kGamerInk,
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

// ── Modo Gamer ──────────────────────────────────────────────────────────────

class _GamerFrame extends StatelessWidget {
  const _GamerFrame({
    required this.controller,
    required this.size,
    required this.cam,
    this.strip,
  });

  final VideoPlayerController controller;
  final Size size;
  final List<double> cam;
  final Widget? strip;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final g = GamerGeometry.of(
          Size(box.maxWidth, box.maxHeight),
          videoAspect: size.width / size.height,
        );
        void openFullscreen() =>
            LandscapeVideoPage.open(context, controller, live: true);
        // O botão só com o ícone (44×44) cabe dentro do canto da câmera?
        final fsInMask = cam[2] * box.maxWidth >= 52 && cam[3] * g.gameH >= 52;
        final fullscreen = _FullscreenButton(
          semanticLabel: s.liveWatchGameFullscreen,
          compact: fsInMask,
          onTap: openFullscreen,
        );
        return ColoredBox(
          color: kGamerSurface,
          child: Stack(
            children: [
              // Câmera (recorte da cena do OBS)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: g.camH,
                child: ColoredBox(
                  color: kGamerRaised,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _CropVideo(controller: controller, size: size, cam: cam),
                      const Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: 64,
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Color(0x8C0B0E14), Color(0x000B0E14)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kGamerSurface.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.video,
                                size: 14,
                                color: kGamerInk,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                s.liveCameraLabel,
                                style: const TextStyle(
                                  color: kGamerInk,
                                  fontSize: 12,
                                  height: 16 / 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Faixa da marca
              Positioned(
                left: 0,
                right: 0,
                top: g.camH,
                height: g.stripH,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(
                    color: kGamerSurface,
                    border: Border.symmetric(
                      horizontal: BorderSide(color: kGamerBorder),
                    ),
                  ),
                  child: strip ?? const SizedBox.shrink(),
                ),
              ),
              // Jogo inteiro, sem cortar o HUD
              Positioned(
                left: 0,
                right: 0,
                top: g.gameTop,
                height: g.gameH,
                child: ColoredBox(
                  color: Colors.black,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VideoPlayer(controller),
                      // A câmera já aparece em cima: no jogo, o canto dela
                      // vira um vidro desfocado (sem câmera dupla) e abriga o
                      // botão de tela cheia, sem cobrir outra parte do jogo.
                      Positioned(
                        left: cam[0] * box.maxWidth,
                        top: cam[1] * g.gameH,
                        width: cam[2] * box.maxWidth,
                        height: cam[3] * g.gameH,
                        child: _CamMask(
                          showMark: !fsInMask,
                          child: fsInMask ? fullscreen : null,
                        ),
                      ),
                      if (!fsInMask)
                        Positioned(right: 8, bottom: 8, child: fullscreen),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Cobre o canto da câmera dentro do quadro do jogo: vidro desfocado com o
/// símbolo da Brawe.
class _CamMask extends StatelessWidget {
  const _CamMask({this.showMark = true, this.child});

  final bool showMark;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: ColoredBox(
          color: kGamerSurface.withValues(alpha: 0.55),
          child: Center(
            child:
                child ??
                (showMark
                    ? Opacity(
                        opacity: 0.9,
                        child: Image.asset(
                          'assets/images/brawe_mark.png',
                          width: 22,
                          height: 22,
                          excludeFromSemantics: true,
                        ),
                      )
                    : null),
          ),
        ),
      ),
    );
  }
}

/// Faixa da marca do Modo Gamer: símbolo, título da live, "Modo Gamer" e a
/// meta (quando houver).
class GamerBrandStrip extends StatelessWidget {
  const GamerBrandStrip({super.key, required this.title, this.goal});

  final String title;
  final Widget? goal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/brawe_mark.png',
          width: 26,
          height: 26,
          semanticLabel: 'Brawe',
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kGamerInk,
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    LucideIcons.gamepad2,
                    size: 12,
                    color: kGamerMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    S.of(context).liveModeGamer,
                    style: const TextStyle(
                      color: kGamerMuted,
                      fontSize: 11,
                      height: 14 / 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (goal != null) ...[const SizedBox(width: 10), goal!],
      ],
    );
  }
}

// ── Tela / Aula ─────────────────────────────────────────────────────────────

class _ScreenFrame extends StatelessWidget {
  const _ScreenFrame({
    required this.controller,
    required this.size,
    required this.cam,
  });

  final VideoPlayerController controller;
  final Size size;
  final List<double> cam;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top + 72;
    return LayoutBuilder(
      builder: (context, box) {
        final frameH = box.maxWidth / (size.width / size.height);
        final d = box.maxWidth * 0.32;
        return Stack(
          fit: StackFit.expand,
          children: [
            _blurredBackground(controller, size),
            Positioned(
              left: 0,
              right: 0,
              top: topPad,
              height: frameH,
              child: VideoPlayer(controller),
            ),
            Positioned(
              right: 12,
              top: topPad + frameH - d * 0.45,
              width: d,
              height: d,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kGamerSurface, width: 3),
                  color: kGamerRaised,
                ),
                child: ClipOval(
                  child: _CropVideo(
                    controller: controller,
                    size: size,
                    cam: cam,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: topPad + 8,
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

// ── Câmera / Conversa / sinal deitado ───────────────────────────────────────

class _SizedFrame extends StatelessWidget {
  const _SizedFrame({
    required this.controller,
    required this.size,
    required this.keepEdges,
  });

  final VideoPlayerController controller;
  final Size size;
  final bool keepEdges;

  @override
  Widget build(BuildContext context) {
    final ratio = size.height > 0 ? size.width / size.height : 0.0;
    final landscape = ratio > LiveSoloVideo.landscapeRatio;
    if (ratio <= 0 || (!landscape && !keepEdges)) {
      return SizedBox.expand(child: _coverVideo(controller, size));
    }

    return LayoutBuilder(
      builder: (context, box) {
        final boxRatio = box.maxWidth / box.maxHeight;
        // Quase do mesmo formato da tela: preencher não corta nada visível.
        if (!landscape && (ratio - boxRatio).abs() < 0.02) {
          return SizedBox.expand(child: _coverVideo(controller, size));
        }
        // Quadro inteiro: cabe pela largura (mais largo que a tela) ou pela
        // altura (mais estreito), centralizado.
        final fitWidth = ratio >= boxRatio;
        final videoW = fitWidth ? box.maxWidth : box.maxHeight * ratio;
        final videoH = fitWidth ? box.maxWidth / ratio : box.maxHeight;
        final top = (box.maxHeight - videoH) / 2;
        final left = (box.maxWidth - videoW) / 2;
        return Stack(
          fit: StackFit.expand,
          children: [
            _blurredBackground(controller, size),
            Positioned(
              left: left,
              top: top,
              width: videoW,
              height: videoH,
              child: VideoPlayer(controller),
            ),
            // Assistir deitado em tela cheia (só faz sentido com vídeo deitado).
            if (landscape)
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
