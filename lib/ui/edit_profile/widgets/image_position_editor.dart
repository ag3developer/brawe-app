import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/themes/app_colors.dart';

/// Tela fullscreen que permite ao usuário arrastar e dar zoom em uma imagem
/// antes do upload, dentro de uma máscara fixa (círculo para avatar,
/// retângulo wide para banner). Retorna o `path` do arquivo recortado em
/// PNG dentro do diretório temporário, ou `null` se cancelado.
class ImagePositionEditor extends StatefulWidget {
  const ImagePositionEditor({
    super.key,
    required this.sourcePath,
    required this.aspectRatio,
    required this.circle,
    required this.title,
    this.outputWidth = 1024,
  });

  /// Caminho do arquivo de origem (vindo do `image_picker`).
  final String sourcePath;

  /// Proporção da área de crop (largura / altura). Use `1.0` para avatar,
  /// `3.0` para banner.
  final double aspectRatio;

  /// Se `true`, a máscara mostra um círculo (mas o PNG final é exportado
  /// em PNG com canal alfa circular). Se `false`, retângulo arredondado.
  final bool circle;

  /// Título exibido na top bar.
  final String title;

  /// Largura desejada do arquivo final em pixels. Altura é derivada do
  /// `aspectRatio`.
  final int outputWidth;

  @override
  State<ImagePositionEditor> createState() => _ImagePositionEditorState();
}

class _ImagePositionEditorState extends State<ImagePositionEditor> {
  ui.Image? _image;
  bool _exporting = false;

  // Transformação aplicada sobre o "cover scale" base.
  double _userScale = 1.0; // >= 1.0
  Offset _userOffset = Offset.zero;

  // Estado do gesto em curso.
  double _gestureStartScale = 1.0;
  Offset _gestureStartOffset = Offset.zero;
  Offset _gestureStartFocal = Offset.zero;

  static const double _minScale = 1.0;
  static const double _maxScale = 4.0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await File(widget.sourcePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() => _image = frame.image);
  }

  // ── Crop math ──────────────────────────────────────────────────────────
  // O viewport tem tamanho (vw, vh) com vw/vh == aspectRatio.
  // A imagem é desenhada com cover scale base = max(vw/iw, vh/ih).
  // O usuário aplica um zoom multiplicador `_userScale` e translação
  // `_userOffset` em coordenadas de viewport.
  //
  // O pixel (x, y) da viewport vê o pixel da imagem original em:
  //   srcX = (x - cx - dx) / effectiveScale + iw/2
  //   srcY = (y - cy - dy) / effectiveScale + ih/2
  // onde (cx, cy) é o centro do viewport, (dx, dy) é o offset do usuário,
  // e effectiveScale = coverScale * userScale.

  double _coverScale(Size viewport) {
    final img = _image!;
    return math.max(
      viewport.width / img.width,
      viewport.height / img.height,
    );
  }

  /// Clampa o offset para que a imagem nunca mostre "espaço vazio" dentro
  /// da máscara — borda da imagem nunca passa do centro do viewport.
  Offset _clampOffset(Offset offset, Size viewport) {
    final img = _image!;
    final effective = _coverScale(viewport) * _userScale;
    final renderedW = img.width * effective;
    final renderedH = img.height * effective;
    final maxDx = math.max(0.0, (renderedW - viewport.width) / 2);
    final maxDy = math.max(0.0, (renderedH - viewport.height) / 2);
    return Offset(
      offset.dx.clamp(-maxDx, maxDx),
      offset.dy.clamp(-maxDy, maxDy),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gestureStartScale = _userScale;
    _gestureStartOffset = _userOffset;
    _gestureStartFocal = details.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size viewport) {
    final newScale =
        (_gestureStartScale * details.scale).clamp(_minScale, _maxScale);
    // Mantém o ponto focal estável sob o dedo durante o zoom.
    final scaleRatio = newScale / _gestureStartScale;
    final focalDelta = details.localFocalPoint - _gestureStartFocal;
    final newOffset = Offset(
      _gestureStartOffset.dx * scaleRatio + focalDelta.dx,
      _gestureStartOffset.dy * scaleRatio + focalDelta.dy,
    );
    setState(() {
      _userScale = newScale;
      _userOffset = _clampOffset(newOffset, viewport);
    });
  }

  Future<void> _confirm(Size viewport) async {
    if (_image == null || _exporting) return;
    setState(() => _exporting = true);
    try {
      final outW = widget.outputWidth.toDouble();
      final outH = outW / widget.aspectRatio;

      final coverScale = _coverScale(viewport);
      final effective = coverScale * _userScale;
      final img = _image!;

      // Topo-esquerdo da imagem renderizada em coords de viewport.
      final renderedW = img.width * effective;
      final renderedH = img.height * effective;
      final imgLeft = viewport.width / 2 - renderedW / 2 + _userOffset.dx;
      final imgTop = viewport.height / 2 - renderedH / 2 + _userOffset.dy;

      // Região da imagem original visível no viewport.
      final srcRect = Rect.fromLTWH(
        -imgLeft / effective,
        -imgTop / effective,
        viewport.width / effective,
        viewport.height / effective,
      );
      final dstRect = Rect.fromLTWH(0, 0, outW, outH);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Para avatar (circle=true) recorta em círculo no PNG final.
      if (widget.circle) {
        canvas.clipPath(
          Path()..addOval(dstRect),
        );
      }
      canvas.drawImageRect(img, srcRect, dstRect, Paint()..isAntiAlias = true);

      final picture = recorder.endRecording();
      final cropped = await picture.toImage(outW.round(), outH.round());
      final bytes = await cropped.toByteData(format: ui.ImageByteFormat.png);

      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${dir.path}/crop_$stamp.png';
      await File(path).writeAsBytes(bytes!.buffer.asUint8List());

      if (!mounted) return;
      Navigator.of(context).pop(path);
    } catch (_) {
      if (!mounted) return;
      setState(() => _exporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível processar a imagem.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exporting ? null : () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _exporting || _image == null
                ? null
                : () {
                    // viewport size é fornecido pelo LayoutBuilder no body
                    final size = _viewportKey.currentContext?.size;
                    if (size != null) _confirm(size);
                  },
            child: _exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Concluir',
                    style: TextStyle(
                      color: AppColors.mutedRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: _image == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.mutedRed),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // Calcula viewport mantendo aspect ratio dentro da tela.
                final maxW = constraints.maxWidth - 32;
                final maxH = constraints.maxHeight - 120;
                double vw = maxW;
                double vh = vw / widget.aspectRatio;
                if (vh > maxH) {
                  vh = maxH;
                  vw = vh * widget.aspectRatio;
                }
                final viewport = Size(vw, vh);

                return Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        key: _viewportKey,
                        width: vw,
                        height: vh,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onScaleStart: _onScaleStart,
                          onScaleUpdate: (d) => _onScaleUpdate(d, viewport),
                          child: ClipRect(
                            child: Stack(
                              children: [
                                // Imagem com transform.
                                Positioned.fill(
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..translateByDouble(
                                          _userOffset.dx, _userOffset.dy, 0, 1)
                                      ..scaleByDouble(
                                          _userScale, _userScale, 1, 1),
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: RawImage(image: _image),
                                    ),
                                  ),
                                ),
                                // Máscara escura com "buraco".
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: _MaskPainter(
                                        circle: widget.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Center(
                        child: Text(
                          'Arraste para reposicionar · Pinch para dar zoom',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  final GlobalKey _viewportKey = GlobalKey();
}

class _MaskPainter extends CustomPainter {
  _MaskPainter({required this.circle});
  final bool circle;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final inner = Path()..fillType = PathFillType.evenOdd;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    if (circle) {
      inner.addOval(rect);
    } else {
      inner.addRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      );
    }
    final cutout = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(
      cutout,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    // Linha sutil de borda do crop.
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.5);
    if (circle) {
      canvas.drawOval(rect.deflate(0.5), border);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(0.5), const Radius.circular(8)),
        border,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MaskPainter oldDelegate) =>
      oldDelegate.circle != circle;
}
