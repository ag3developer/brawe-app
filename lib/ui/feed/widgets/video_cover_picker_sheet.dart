import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../edit_profile/widgets/image_position_editor.dart';
import 'video_cover_timeline.dart';

/// Resultado do seletor: [file] == null significa "capa automática".
class CoverPickResult {
  const CoverPickResult(this.file);
  final File? file;
}

/// Gera a miniatura (bytes JPEG) do quadro em [timeMs].
typedef CoverThumbLoader = Future<Uint8List?> Function(int timeMs);

/// Exporta o quadro em [timeMs] como arquivo de capa em alta resolução.
typedef CoverFrameExporter = Future<File?> Function(int timeMs);

/// Seletor de capa do vídeo: filmstrip de miniaturas com seletor arrastável.
/// Enquanto arrasta, o preview grande acompanha o quadro (o vídeo é
/// posicionado via [onSeek], com throttle). Devolve [CoverPickResult] ou
/// `null` se cancelado.
class VideoCoverPickerSheet extends StatefulWidget {
  const VideoCoverPickerSheet({
    super.key,
    required this.videoPath,
    required this.durationMs,
    required this.aspectRatio,
    required this.previewBuilder,
    required this.onSeek,
    this.initialMs = 0,
    this.thumbLoader,
    this.frameExporter,
  });

  final String videoPath;
  final int durationMs;
  final double aspectRatio;

  /// Widget do preview grande (ex.: `VideoPlayer(controller)`), já posicionado
  /// no quadro atual por [onSeek].
  final WidgetBuilder previewBuilder;

  /// Posiciona o vídeo (pausado) em [ms]. Chamado com throttle.
  final Future<void> Function(int ms) onSeek;
  final int initialMs;
  final CoverThumbLoader? thumbLoader;
  final CoverFrameExporter? frameExporter;

  static Future<CoverPickResult?> show(
    BuildContext context, {
    required String videoPath,
    required int durationMs,
    required double aspectRatio,
    required WidgetBuilder previewBuilder,
    required Future<void> Function(int ms) onSeek,
    int initialMs = 0,
  }) {
    return showModalBottomSheet<CoverPickResult>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => VideoCoverPickerSheet(
        videoPath: videoPath,
        durationMs: durationMs,
        aspectRatio: aspectRatio,
        previewBuilder: previewBuilder,
        onSeek: onSeek,
        initialMs: initialMs,
      ),
    );
  }

  @override
  State<VideoCoverPickerSheet> createState() => _VideoCoverPickerSheetState();
}

class _VideoCoverPickerSheetState extends State<VideoCoverPickerSheet> {
  static const double _tileH = 56;
  static const double _handleW = 46;
  static const double _handleH = 68;

  late final VideoCoverTimeline _tl = VideoCoverTimeline(
    durationMs: widget.durationMs,
  );
  late double _frac = widget.durationMs <= 0
      ? 0
      : (widget.initialMs / widget.durationMs).clamp(0.0, 1.0);
  bool _busy = false;

  List<Uint8List?> _thumbs = const [];
  int _thumbCount = 0;
  int _genId = 0;

  // Throttle do seek: um seek por vez; o último pedido pendente roda ao fim.
  bool _seeking = false;
  int? _pendingSeek;

  int get _timeMs => _tl.timeForFraction(_frac);

  CoverThumbLoader get _loader =>
      widget.thumbLoader ??
      (ms) => VideoThumbnail.thumbnailData(
        video: widget.videoPath,
        imageFormat: ImageFormat.JPEG,
        timeMs: ms,
        maxWidth: 200,
        quality: 60,
      );

  @override
  void initState() {
    super.initState();
    _requestSeek(_timeMs);
  }

  @override
  void dispose() {
    _genId++;
    super.dispose();
  }

  void _requestSeek(int ms) {
    if (_seeking) {
      _pendingSeek = ms;
      return;
    }
    _seeking = true;
    unawaited(() async {
      try {
        await widget.onSeek(ms);
      } catch (_) {}
      _seeking = false;
      final next = _pendingSeek;
      _pendingSeek = null;
      if (next != null && mounted) _requestSeek(next);
    }());
  }

  void _ensureThumbs(int count) {
    if (count == _thumbCount || widget.durationMs <= 0) return;
    _thumbCount = count;
    final id = ++_genId;
    final times = _tl.thumbTimes(count);
    final list = List<Uint8List?>.filled(count, null);
    _thumbs = list;
    unawaited(() async {
      for (var i = 0; i < times.length; i++) {
        if (!mounted || id != _genId) return;
        try {
          final data = await _loader(times[i]);
          if (!mounted || id != _genId) return;
          list[i] = data;
          setState(() {});
        } catch (_) {}
      }
    }());
  }

  void _dragTo(double dx, double width) {
    final track = width - _handleW;
    final f = VideoCoverTimeline.fractionForDx(dx - _handleW / 2, track);
    if ((f - _frac).abs() < 0.0005) return;
    final prevTile = VideoCoverTimeline.nearestTile(_frac, _thumbCount);
    setState(() => _frac = f);
    if (VideoCoverTimeline.nearestTile(f, _thumbCount) != prevTile) {
      HapticFeedback.selectionClick();
    }
    _requestSeek(_timeMs);
  }

  void _error() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.of(context).videoPubCoverError)));
  }

  Future<File?> _exportFrame(int ms) async {
    final custom = widget.frameExporter;
    if (custom != null) return custom(ms);
    final dir = await getTemporaryDirectory();
    final out =
        '${dir.path}/cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final x = await VideoThumbnail.thumbnailFile(
      video: widget.videoPath,
      thumbnailPath: out,
      imageFormat: ImageFormat.JPEG,
      timeMs: ms,
      maxWidth: 1080,
      quality: 85,
    );
    return File(x.path);
  }

  Future<void> _useFrame() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final f = await _exportFrame(_timeMs);
      if (f == null || !await f.exists() || await f.length() == 0) {
        throw Exception('empty');
      }
      if (!mounted) return;
      Navigator.of(context).pop(CoverPickResult(f));
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _error();
    }
  }

  Future<void> _pickGallery() async {
    if (_busy) return;
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90, // força saída JPEG
        maxWidth: 2160,
      );
      if (picked == null || !mounted) return;
      final cropped = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ImagePositionEditor(
            sourcePath: picked.path,
            aspectRatio: widget.aspectRatio,
            circle: false,
            title: S.of(context).videoPubCoverCrop,
            outputWidth: 1080,
          ),
        ),
      );
      if (cropped == null || !mounted) return;
      Navigator.of(context).pop(CoverPickResult(File(cropped)));
    } catch (_) {
      if (!mounted) return;
      _error();
    }
  }

  Widget _preview(BuildContext context) {
    final c = context.colors;
    return Center(
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.surfaceHighest,
              border: Border.all(color: c.border),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                widget.previewBuilder(context),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      S
                          .of(context)
                          .videoPubCoverAt(VideoCoverTimeline.format(_timeMs)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filmstrip(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final tileW = _tileH * 0.62;
        final count = VideoCoverTimeline.tileCountFor(w, tileW);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _ensureThumbs(count);
        });
        final n = _thumbs.length;
        final track = w - _handleW;
        final left = (_frac * track).clamp(0.0, track);
        final nearest = VideoCoverTimeline.nearestTile(_frac, n);
        final handleImg = n > 0 ? _thumbs[nearest] : null;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _dragTo(d.localPosition.dx, w),
          onHorizontalDragUpdate: (d) => _dragTo(d.localPosition.dx, w),
          child: SizedBox(
            height: _handleH + 8,
            width: w,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: (_handleH + 8 - _tileH) / 2,
                  height: _tileH,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: c.surfaceHighest),
                      child: Row(
                        children: [
                          for (var i = 0; i < n; i++)
                            Expanded(
                              child: _thumbs[i] == null
                                  ? const SizedBox.expand()
                                  : Image.memory(
                                      _thumbs[i]!,
                                      fit: BoxFit.cover,
                                      height: _tileH,
                                      gaplessPlayback: true,
                                    ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: left,
                  top: 4,
                  width: _handleW,
                  height: _handleH,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: c.accentPrimary.withValues(alpha: 0.55),
                            blurRadius: 12,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        color: c.surfaceHighest,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: handleImg == null
                            ? const SizedBox.expand()
                            : Image.memory(
                                handleImg,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = S.of(context);
    final mq = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mq.size.height * 0.92),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                s.videoPubCoverTitle,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(child: _preview(context)),
              const SizedBox(height: 14),
              Text(
                s.videoPubCoverFrameHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: c.textSecondary, fontSize: 12.5),
              ),
              const SizedBox(height: 6),
              _filmstrip(context),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: c.accentPrimary,
                    foregroundColor: c.textOnAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _busy ? null : _useFrame,
                  child: _busy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: c.textOnAccent,
                          ),
                        )
                      : Text(
                          s.videoPubCoverUse,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.textPrimary,
                        side: BorderSide(color: c.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _busy ? null : _pickGallery,
                      icon: const Icon(LucideIcons.image, size: 16),
                      label: Text(
                        s.videoPubCoverGallery,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.textPrimary,
                        side: BorderSide(color: c.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pop(const CoverPickResult(null)),
                      icon: const Icon(LucideIcons.sparkles, size: 16),
                      label: Text(
                        s.videoPubCoverRemove,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
