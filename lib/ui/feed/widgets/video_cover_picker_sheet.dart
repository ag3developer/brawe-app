import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../edit_profile/widgets/image_position_editor.dart';

/// Seletor de capa do vídeo: quadro da linha do tempo ou imagem da galeria.
/// Devolve o [File] da capa escolhida (JPEG/PNG) ou `null` se cancelado.
class VideoCoverPickerSheet extends StatefulWidget {
  const VideoCoverPickerSheet({
    super.key,
    required this.videoPath,
    required this.durationMs,
    required this.aspectRatio,
  });

  final String videoPath;
  final int durationMs;
  final double aspectRatio;

  static Future<File?> show(
    BuildContext context, {
    required String videoPath,
    required int durationMs,
    required double aspectRatio,
  }) {
    return showModalBottomSheet<File>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => VideoCoverPickerSheet(
        videoPath: videoPath,
        durationMs: durationMs,
        aspectRatio: aspectRatio,
      ),
    );
  }

  @override
  State<VideoCoverPickerSheet> createState() => _VideoCoverPickerSheetState();
}

class _VideoCoverPickerSheetState extends State<VideoCoverPickerSheet> {
  double _pos = 0; // 0..1
  Uint8List? _preview;
  bool _loading = true;
  bool _busy = false;
  int _req = 0;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  int get _timeMs =>
      (widget.durationMs * _pos).round().clamp(0, widget.durationMs);

  Future<void> _loadPreview() async {
    final req = ++_req;
    setState(() => _loading = true);
    try {
      final data = await VideoThumbnail.thumbnailData(
        video: widget.videoPath,
        imageFormat: ImageFormat.JPEG,
        timeMs: _timeMs,
        maxWidth: 540,
        quality: 70,
      );
      if (!mounted || req != _req) return;
      setState(() {
        _preview = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || req != _req) return;
      setState(() => _loading = false);
    }
  }

  void _error() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).videoPubCoverError)),
    );
  }

  Future<void> _useFrame() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final dir = await getTemporaryDirectory();
      final out =
          '${dir.path}/cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final x = await VideoThumbnail.thumbnailFile(
        video: widget.videoPath,
        thumbnailPath: out,
        imageFormat: ImageFormat.JPEG,
        timeMs: _timeMs,
        maxWidth: 1080,
        quality: 85,
      );
      final f = File(x.path);
      if (!await f.exists() || await f.length() == 0) throw Exception('empty');
      if (!mounted) return;
      Navigator.of(context).pop(f);
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
      Navigator.of(context).pop(File(cropped));
    } catch (_) {
      if (!mounted) return;
      _error();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = S.of(context);
    final maxH = MediaQuery.of(context).size.height * 0.42;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
          const SizedBox(height: 16),
          Text(
            s.videoPubCoverTitle,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: c.surfaceHighest,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_preview != null)
                          Image.memory(_preview!, fit: BoxFit.cover),
                        if (_loading)
                          const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            s.videoPubCoverFrameHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary, fontSize: 12.5),
          ),
          Slider(
            value: _pos,
            onChanged: _busy ? null : (v) => setState(() => _pos = v),
            onChangeEnd: (_) => _loadPreview(),
          ),
          const SizedBox(height: 4),
          FilledButton(
            onPressed: _busy ? null : _useFrame,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(s.videoPubCoverUse),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _pickGallery,
            icon: const Icon(LucideIcons.image, size: 18),
            label: Text(s.videoPubCoverGallery),
          ),
        ],
      ),
    );
  }
}
