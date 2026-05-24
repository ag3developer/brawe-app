import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/themes/app_colors.dart';
import '../../core/ui/app_snackbar.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/stories_view_model.dart';

/// Brawe "Pulse" Composer — substitui o antigo bottom sheet.
///
/// Fluxo:
/// 1. Picker em tela cheia → câmera (foto/vídeo) ou galeria.
/// 2. Editor em tela cheia: imagem/vídeo de fundo, camadas de texto
///    draggable, paleta de cores, caption, botão publicar.
class StoryComposerScreen extends ConsumerStatefulWidget {
  const StoryComposerScreen({
    super.key,
    this.initialRemoteUrl,
    this.initialOriginPostId,
  });

  /// Se fornecido, abre direto no editor com a mídia remota (compartilhar
  /// post como story).
  final String? initialRemoteUrl;

  /// ID do post original quando este story é um repost. Mantém o link
  /// para que o viewer possa abrir o post original.
  final String? initialOriginPostId;

  @override
  ConsumerState<StoryComposerScreen> createState() =>
      _StoryComposerScreenState();
}

class _StoryComposerScreenState extends ConsumerState<StoryComposerScreen> {
  File? _file;
  bool _isVideo = false;
  bool _isLoading = false;
  bool _isPublishing = false;
  VideoPlayerController? _videoCtrl;

  // ── Live camera preview (background of picker) ──────────────────────
  CameraController? _camCtrl;
  Future<void>? _camInitFuture;
  bool _camAvailable = false;

  // ── Inline capture state (foto/vídeo direto na tela) ────────────────
  static const Duration _kSegmentMax = Duration(seconds: 15);
  static const Duration _kTotalMax = Duration(seconds: 60);

  bool _isRecording = false;
  final List<File> _videoSegments = [];
  DateTime? _segmentStartedAt;
  Duration _previousSegmentsTotal = Duration.zero;
  Timer? _recordTicker;
  Duration _currentSegmentElapsed = Duration.zero;
  bool _flashOn = false;

  // ── Repost de post remoto (initialRemoteUrl) ────────────────────────
  /// True enquanto a tela está em modo "repost" (mídia remota baixando).
  /// Nesse modo NÃO mostramos o picker da câmera — só um loader dedicado.
  bool _isRepostMode = false;
  String? _remoteError;

  @override
  void initState() {
    super.initState();
    final remote = widget.initialRemoteUrl;
    if (remote != null && remote.isNotEmpty) {
      _isRepostMode = true;
      _prefetchRemote(remote);
    } else {
      _initCameraPreview();
    }
  }

  @override
  void dispose() {
    _recordTicker?.cancel();
    _videoCtrl?.dispose();
    _camCtrl?.dispose();
    super.dispose();
  }

  Future<void> _initCameraPreview() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      // Prefer front camera (selfie) for stories
      final cam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _camInitFuture = ctrl.initialize();
      await _camInitFuture;
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _camCtrl = ctrl;
        _camAvailable = true;
      });
    } catch (_) {
      // Sem permissão / sem câmera (simulador) → fallback gradiente
      if (mounted) setState(() => _camAvailable = false);
    }
  }

  Future<void> _stopCameraPreview() async {
    final c = _camCtrl;
    _camCtrl = null;
    _camAvailable = false;
    await c?.dispose();
  }

  Future<void> _prefetchRemote(String url) async {
    setState(() {
      _isLoading = true;
      _remoteError = null;
    });
    try {
      final dir = await getTemporaryDirectory();
      final isVid = _looksLikeVideo(url);
      final ext = isVid ? 'mp4' : 'jpg';
      final tmpPath =
          '${dir.path}/story_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await Dio().download(url, tmpPath);
      if (!mounted) return;
      await _setSelected(File(tmpPath), isVideo: isVid);
    } catch (e, st) {
      debugPrint('[StoryComposer] Falha ao baixar mídia remota: $e\n$st');
      if (!mounted) return;
      setState(() => _remoteError = S.of(context).composerMediaLoadError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _looksLikeVideo(String url) =>
      url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.webm');

  Future<void> _setSelected(File file, {required bool isVideo}) async {
    await _stopCameraPreview();
    await _videoCtrl?.dispose();
    _videoCtrl = null;
    if (isVideo) {
      final ctrl = VideoPlayerController.file(file);
      try {
        await ctrl.initialize();
        ctrl
          ..setLooping(true)
          ..setVolume(0)
          ..play();
        _videoCtrl = ctrl;
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _file = file;
      _isVideo = isVideo;
    });
  }

  // ── Captura inline: foto ─────────────────────────────────────────────
  Future<void> _capturePhoto() async {
    final ctrl = _camCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (_isRecording) return;
    try {
      HapticFeedback.lightImpact();
      final shot = await ctrl.takePicture();
      // Move o arquivo temporário pra um local previsível.
      final dir = await getTemporaryDirectory();
      final dst = File(
        '${dir.path}/story_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await File(shot.path).copy(dst.path);
      await _setSelected(dst, isVideo: false);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, S.of(context).composerPhotoError);
    }
  }

  // ── Captura inline: vídeo (longPress) ────────────────────────────────
  Future<void> _startRecording() async {
    final ctrl = _camCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (_isRecording) return;
    try {
      await ctrl.startVideoRecording();
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _segmentStartedAt = DateTime.now();
        _currentSegmentElapsed = Duration.zero;
      });
      _recordTicker = Timer.periodic(const Duration(milliseconds: 80), (_) {
        _onRecordTick();
      });
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(context, S.of(context).composerRecordStartError);
    }
  }

  void _onRecordTick() {
    if (!mounted || !_isRecording) return;
    final start = _segmentStartedAt;
    if (start == null) return;
    final elapsed = DateTime.now().difference(start);
    setState(() => _currentSegmentElapsed = elapsed);

    // Total = segments anteriores + segmento atual
    final total = _previousSegmentsTotal + elapsed;
    if (total >= _kTotalMax) {
      _stopRecording(autoEnd: true);
      return;
    }
    if (elapsed >= _kSegmentMax) {
      _rotateSegment();
    }
  }

  Future<void> _rotateSegment() async {
    final ctrl = _camCtrl;
    if (ctrl == null || !_isRecording) return;
    try {
      HapticFeedback.selectionClick();
      final file = await ctrl.stopVideoRecording();
      final dir = await getTemporaryDirectory();
      final dst = File(
        '${dir.path}/story_seg_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      await File(file.path).copy(dst.path);
      _videoSegments.add(dst);
      _previousSegmentsTotal += _currentSegmentElapsed;

      // Inicia o próximo segmento imediatamente
      await ctrl.startVideoRecording();
      if (!mounted) return;
      setState(() {
        _segmentStartedAt = DateTime.now();
        _currentSegmentElapsed = Duration.zero;
      });
    } catch (_) {
      await _stopRecording();
    }
  }

  Future<void> _stopRecording({bool autoEnd = false}) async {
    if (!_isRecording) return;
    _recordTicker?.cancel();
    _recordTicker = null;
    final ctrl = _camCtrl;
    if (ctrl == null) {
      setState(() => _isRecording = false);
      return;
    }
    try {
      final file = await ctrl.stopVideoRecording();
      final segDuration = _currentSegmentElapsed;
      setState(() => _isRecording = false);

      // Ignora segmentos muito curtos (< 800ms) — provável long-press acidental.
      if (segDuration < const Duration(milliseconds: 800) &&
          _videoSegments.isEmpty) {
        await File(file.path).delete().catchError((_) => File(file.path));
        setState(() {
          _previousSegmentsTotal = Duration.zero;
          _segmentStartedAt = null;
        });
        return;
      }

      final dir = await getTemporaryDirectory();
      final dst = File(
        '${dir.path}/story_seg_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      await File(file.path).copy(dst.path);
      _videoSegments.add(dst);
      _previousSegmentsTotal += segDuration;

      if (autoEnd) HapticFeedback.heavyImpact();

      // Abre o editor com o primeiro segmento; o publish irá iterar.
      await _setSelected(_videoSegments.first, isVideo: true);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, S.of(context).composerRecordStopError);
      setState(() {
        _isRecording = false;
        _previousSegmentsTotal = Duration.zero;
        _segmentStartedAt = null;
        _videoSegments.clear();
      });
    }
  }

  Future<void> _toggleFlash() async {
    final ctrl = _camCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    try {
      final next = !_flashOn;
      await ctrl.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (!mounted) return;
      setState(() => _flashOn = next);
    } catch (_) {}
  }

  Future<void> _flipCamera() async {
    final cameras = await availableCameras();
    if (cameras.length < 2 || _camCtrl == null) return;
    final current = _camCtrl!.description.lensDirection;
    final next = cameras.firstWhere(
      (c) => c.lensDirection != current,
      orElse: () => cameras.first,
    );
    await _camCtrl?.dispose();
    final ctrl = CameraController(
      next,
      ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _camCtrl = ctrl;
        _flashOn = false;
      });
    } catch (_) {
      if (mounted) setState(() => _camAvailable = false);
    }
  }

  Future<void> _pickFromGallery() async {
    // Foto ou vídeo: ImagePicker não tem combinado; usamos pickMedia.
    final x = await ImagePicker().pickMedia();
    if (x == null) return;
    final isVid = _looksLikeVideo(x.path);
    await _setSelected(File(x.path), isVideo: isVid);
  }

  Future<void> _publish({
    required String? caption,
    File? flattenedImage,
  }) async {
    if (_file == null) return;
    setState(() => _isPublishing = true);
    try {
      final notifier = ref.read(storiesViewModelProvider.notifier);
      // Publica multi-segmento (cada parte vira 1 story sequencial)
      if (_isVideo && _videoSegments.length > 1) {
        // ⚠️ TODO(video-flatten): hoje vídeos ignoram textos/transform.
        // Pra renderizar overlays em vídeo precisaria ffmpeg_kit_flutter.
        for (int i = 0; i < _videoSegments.length; i++) {
          await notifier.createStory(
            localFilePath: _videoSegments[i].path,
            // Caption apenas no primeiro segmento (padrão Instagram)
            caption: i == 0 ? caption : null,
            originPostId: widget.initialOriginPostId,
          );
        }
      } else {
        // Foto: usa o PNG renderizado (com transform + textos) se disponível.
        final pathToUpload = flattenedImage?.path ?? _file!.path;
        await notifier.createStory(
          localFilePath: pathToUpload,
          caption: caption,
          originPostId: widget.initialOriginPostId,
        );
      }
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        _videoSegments.length > 1
            ? S.of(context).composerMultipleStoriesPublished(_videoSegments.length)
            : S.of(context).composerStoryPublished,
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(context, S.of(context).composerPublishError);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        child: _file != null
            ? _buildEditor()
            : (_isRepostMode ? _buildRepostLoader() : _buildPicker()),
      ),
    );
  }

  /// Tela exibida enquanto a mídia remota (repost) está sendo baixada.
  /// Evita confundir o usuário com a UI do picker/câmera.
  Widget _buildRepostLoader() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B0F1A), Color(0xFF1A1240), Color(0xFF0B0F1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: 48,
          left: 16,
          child: _CircleIconBtn(
            icon: Icons.close,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        Center(
          child: _remoteError != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white70, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _remoteError!,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        final url = widget.initialRemoteUrl;
                        if (url != null) _prefetchRemote(url);
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text(S.of(context).composerRetry,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                        color: AppColors.electricPurple),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).composerPreparing,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildPicker() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background: gradiente como fallback
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B0F1A), Color(0xFF1A1240), Color(0xFF0B0F1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Prévia ao vivo da câmera (selfie por padrão)
        if (_camAvailable && _camCtrl != null && _camCtrl!.value.isInitialized)
          Positioned.fill(
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _camCtrl!.value.previewSize?.height ?? 1,
                  height: _camCtrl!.value.previewSize?.width ?? 1,
                  child: CameraPreview(_camCtrl!),
                ),
              ),
            ),
          ),
        // Vinheta para destacar controles
        if (_camAvailable)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),
        // Conteúdo
        Column(
          children: [
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _CircleIconBtn(
                    icon: Icons.close,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    S.of(context).composerCreateStory,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const Spacer(),
                  if (_camAvailable && !_isRecording) ...[
                    _CircleIconBtn(
                      icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                      onTap: _toggleFlash,
                    ),
                    const SizedBox(width: 8),
                    _CircleIconBtn(
                      icon: Icons.flip_camera_ios_outlined,
                      onTap: _flipCamera,
                    ),
                  ] else
                    const SizedBox(width: 40),
                ],
              ),
            ),
            const Spacer(),
            if (_isLoading)
              const CircularProgressIndicator(color: AppColors.electricPurple)
            else
              _CaptureRing(
                isRecording: _isRecording,
                segmentProgress: (_currentSegmentElapsed.inMilliseconds /
                        _kSegmentMax.inMilliseconds)
                    .clamp(0.0, 1.0),
                totalProgress: ((_previousSegmentsTotal + _currentSegmentElapsed)
                            .inMilliseconds /
                        _kTotalMax.inMilliseconds)
                    .clamp(0.0, 1.0),
                segmentBreaks: _videoSegments.isEmpty
                    ? const []
                    : List<double>.generate(
                        _videoSegments.length,
                        (i) {
                          // posição cumulativa de cada break sobre 60s
                          double acc = 0;
                          for (int k = 0; k <= i; k++) {
                            // Aproxima usando _kSegmentMax (15s) por segmento
                            // — em casos de rotate manual ficaria diferente,
                            // mas no fluxo normal cada seg = 15s.
                            acc += _kSegmentMax.inMilliseconds.toDouble();
                          }
                          return (acc / _kTotalMax.inMilliseconds)
                              .clamp(0.0, 1.0);
                        },
                      ),
                onTap: _capturePhoto,
                onLongPressStart: _startRecording,
                onLongPressEnd: () => _stopRecording(),
              ),
            const SizedBox(height: 12),
            // Timer + hint
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isRecording
                  ? Text(
                      _formatRecordTime(
                        _previousSegmentsTotal + _currentSegmentElapsed,
                      ),
                      key: const ValueKey('rec-timer'),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    )
                  : Text(
                      S.of(context).composerCaptureHint,
                      key: const ValueKey('rec-hint'),
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PickerOption(
                    icon: Icons.photo_library_outlined,
                    label: S.of(context).composerGallery,
                    onTap: _pickFromGallery,
                  ),
                  _PickerOption(
                    icon: Icons.text_fields,
                    label: S.of(context).composerTextOnly,
                    onTap: _createTextOnly,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ],
    );
  }

  Future<void> _createTextOnly() async {
    // Gera uma "imagem" 9:16 a partir de gradiente colocando o texto como
    // overlay. Aqui simplificamos: abre editor com fundo gradiente "virtual"
    // — o publish renderiza o canvas e envia como imagem.
    // Pra MVP: cria um arquivo placeholder transparente 1080x1920 e deixa
    // o editor tratar como imagem.
    final dir = await getTemporaryDirectory();
    final tmp = File(
      '${dir.path}/story_text_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    // Escreve PNG mínimo 1x1 (Flutter aceita; o editor mostra gradient).
    await tmp.writeAsBytes(_kTransparentPngBytes);
    await _setSelected(tmp, isVideo: false);
  }

  Widget _buildEditor() {
    return _StoryEditor(
      file: _file!,
      isVideo: _isVideo,
      videoCtrl: _videoCtrl,
      isPublishing: _isPublishing,
      isRepost: _isRepostMode,
      onBack: () async {
        await _videoCtrl?.dispose();
        _videoCtrl = null;
        // Reseta estado de captura para um próximo take.
        _videoSegments.clear();
        _previousSegmentsTotal = Duration.zero;
        _segmentStartedAt = null;
        _currentSegmentElapsed = Duration.zero;
        if (!mounted) return;
        setState(() {
          _file = null;
          _isVideo = false;
        });
        // Reinicializa a câmera para o próximo take (foi parada no _setSelected).
        if (!_isRepostMode) {
          await _initCameraPreview();
        }
      },
      onPublish: _publish,
    );
  }
}

// ─── Helper: format MM:SS / 0:0X ─────────────────────────────────────────────

String _formatRecordTime(Duration d) {
  final s = d.inSeconds;
  final ms = (d.inMilliseconds % 1000) ~/ 100;
  return '0:${s.toString().padLeft(2, '0')}.$ms';
}

// ─── Captura inline com anel de progresso (estilo Instagram/TikTok) ─────────

class _CaptureRing extends StatelessWidget {
  const _CaptureRing({
    required this.isRecording,
    required this.segmentProgress,
    required this.totalProgress,
    required this.segmentBreaks,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  final bool isRecording;
  final double segmentProgress; // 0..1 do segmento atual (visual menor)
  final double totalProgress; // 0..1 do tempo total (anel principal)
  final List<double> segmentBreaks; // ticks no anel para cada segmento gravado
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    const size = 92.0;
    const innerSize = 72.0;
    return GestureDetector(
      onTap: isRecording ? null : onTap,
      onLongPressStart: isRecording ? null : (_) => onLongPressStart(),
      onLongPressEnd: (_) {
        if (isRecording) onLongPressEnd();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Anel de progresso (60s totais)
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _RingProgressPainter(
                  progress: isRecording ? totalProgress : 0.0,
                  breaks: segmentBreaks,
                ),
              ),
            ),
            // Botão interno (anima entre círculo grande e quadrado pequeno)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              width: isRecording ? innerSize * 0.55 : innerSize,
              height: isRecording ? innerSize * 0.55 : innerSize,
              decoration: BoxDecoration(
                shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                borderRadius:
                    isRecording ? BorderRadius.circular(10) : null,
                gradient: LinearGradient(
                  colors: isRecording
                      ? const [Colors.redAccent, Color(0xFFFF3D6E)]
                      : const [AppColors.electricPurple, AppColors.coolCyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isRecording
                            ? Colors.redAccent
                            : AppColors.electricPurple)
                        .withValues(alpha: 0.55),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Borda externa branca (sempre)
            if (!isRecording)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RingProgressPainter extends CustomPainter {
  _RingProgressPainter({required this.progress, required this.breaks});
  final double progress;
  final List<double> breaks;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;
    // Track de fundo
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Colors.white.withValues(alpha: 0.18);
    canvas.drawCircle(center, radius, trackPaint);

    // Progresso (gradient sweep)
    if (progress > 0) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          colors: [
            AppColors.electricPurple,
            AppColors.coolCyan,
            AppColors.electricPurple,
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      final sweep = 2 * 3.141592653589793 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.141592653589793 / 2, // 12 o'clock
        sweep,
        false,
        progressPaint,
      );
    }

    // Ticks (breaks de segmentos)
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white;
    for (final b in breaks) {
      final angle = -3.141592653589793 / 2 + 2 * 3.141592653589793 * b;
      final p1 = Offset(
        center.dx + (radius - 5) * math.cos(angle),
        center.dy + (radius - 5) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius + 5) * math.cos(angle),
        center.dy + (radius + 5) * math.sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingProgressPainter old) =>
      old.progress != progress || old.breaks.length != breaks.length;
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  const _CircleIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─── Editor pós-captura ──────────────────────────────────────────────────────

class _StoryEditor extends StatefulWidget {
  const _StoryEditor({
    required this.file,
    required this.isVideo,
    required this.videoCtrl,
    required this.isPublishing,
    required this.onBack,
    required this.onPublish,
    this.isRepost = false,
  });

  final File file;
  final bool isVideo;
  final VideoPlayerController? videoCtrl;
  final bool isPublishing;
  final bool isRepost;
  final VoidCallback onBack;
  final Future<void> Function({
    required String? caption,
    File? flattenedImage,
  }) onPublish;

  @override
  State<_StoryEditor> createState() => _StoryEditorState();
}

class _StoryEditorState extends State<_StoryEditor> {
  final TextEditingController _captionCtrl = TextEditingController();
  final List<_TextLayer> _layers = [];
  Color _currentColor = Colors.white;
  bool _composingText = false;
  final TextEditingController _composeCtrl = TextEditingController();

  // Estilo de fundo do texto sendo composto (cicla com botão "A").
  // 0 = sem fundo, 1 = preto translúcido, 2 = branco sólido (cor invertida).
  int _composeBgStyle = 0;

  // ── Drag para lixeira ───────────────────────────────────────────────
  int? _draggingLayerIdx;
  bool _hoverTrash = false;

  // ── Flatten/Capture (fidelidade ao publicar) ────────────────────────
  // Envolvemos a tela em RepaintBoundary e renderizamos um PNG com o
  // que o usuário vê (mídia + transformação + textos). Os controles são
  // escondidos durante a captura via [_capturing].
  final GlobalKey _captureKey = GlobalKey();
  bool _capturing = false;

  // Pinch-zoom / pan da mídia (estilo Instagram).
  final TransformationController _transformCtrl = TransformationController();
  bool _showGuides = false;
  Timer? _guidesTimer;

  // ── Moldura (frame) — double-tap cicla pelas opções ─────────────────
  // 0=nenhuma, 1=polaroid branca, 2=gradiente brawe
  int _frameStyle = 0;

  String _frameLabel(BuildContext context) {
    final s = S.of(context);
    switch (_frameStyle) {
      case 1:
        return s.composerFramePolaroid;
      case 2:
        return s.composerFrameBrawe;
      default:
        return s.composerFrameNone;
    }
  }

  void _cycleFrame() {
    setState(() => _frameStyle = (_frameStyle + 1) % 3);
    HapticFeedback.selectionClick();
  }

  void _onInteractionStart(ScaleStartDetails _) {
    _guidesTimer?.cancel();
    if (!_showGuides) setState(() => _showGuides = true);
  }

  void _onInteractionEnd(ScaleEndDetails _) {
    _guidesTimer?.cancel();
    _guidesTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showGuides = false);
    });
  }

  void _resetTransform() {
    _transformCtrl.value = Matrix4.identity();
    HapticFeedback.selectionClick();
  }

  static const _palette = <Color>[
    Colors.white,
    Color(0xFF6E4DFF), // electric purple
    Color(0xFF3BB8FF), // cool cyan
    Color(0xFFFF5A6B), // muted red
    Color(0xFFFFD54F), // amber
    Color(0xFF66BB6A), // green
    Colors.black,
  ];

  @override
  void dispose() {
    _captionCtrl.dispose();
    _composeCtrl.dispose();
    _transformCtrl.dispose();
    _guidesTimer?.cancel();
    super.dispose();
  }

  void _startTextCompose() {
    _composeCtrl.clear();
    _composeBgStyle = 0;
    setState(() => _composingText = true);
  }

  void _commitTextLayer() {
    final txt = _composeCtrl.text.trim();
    if (txt.isNotEmpty) {
      _layers.add(_TextLayer(
        text: txt,
        color: _currentColor,
        offset: const Offset(80, 200),
        scale: 1.0,
        bgStyle: _composeBgStyle,
      ));
    }
    setState(() => _composingText = false);
  }

  /// Renderiza a tela inteira (mídia transformada + textos) em um PNG
  /// e dispara o [onPublish] com esse arquivo. Vídeos pulam o flatten
  /// (não dá pra rasterizar — usam o arquivo original + caption).
  Future<void> _flattenAndPublish() async {
    final caption =
        _captionCtrl.text.trim().isEmpty ? null : _captionCtrl.text.trim();

    // Vídeo: publica direto, sem flatten.
    if (widget.isVideo) {
      await widget.onPublish(caption: caption);
      return;
    }

    File? flat;
    try {
      // 1) Esconde controles (top bar, lixeira, guias, chip etc.)
      setState(() => _capturing = true);
      // Garante que a UI ocultou antes do snapshot.
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 16));

      // 2) Captura PNG via RepaintBoundary.
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        // pixelRatio 3.0 ~= 1080p em devices comuns. Limita o teto para
        // evitar uploads gigantes em iPads/devices grandes.
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final ratio = math.min(3.0, dpr * 1.5);
        final uiImage = await boundary.toImage(pixelRatio: ratio);
        final bytes =
            await uiImage.toByteData(format: ui.ImageByteFormat.png);
        uiImage.dispose();
        if (bytes != null) {
          final dir = await getTemporaryDirectory();
          flat = File(
            '${dir.path}/story_flat_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          await flat.writeAsBytes(bytes.buffer.asUint8List());
        }
      }
    } catch (e, st) {
      // Falha no flatten — publica o original com aviso silencioso (debug).
      debugPrint('[StoryComposer] Flatten falhou: $e\n$st');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }

    await widget.onPublish(caption: caption, flattenedImage: flat);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return RepaintBoundary(
      key: _captureKey,
      child: Stack(
      fit: StackFit.expand,
      children: [
        // Fundo: blur da própria mídia (evita laterais pretas quando cabe inteira).
        if (!widget.isVideo)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Image.file(
                widget.file,
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.55),
              ),
            ),
          ),
        // Mídia com pinch-zoom / pan / 1 dedo (estilo Instagram Stories):
        // permite mover livremente, diminuir e até sair dos limites da tela.
        // Double-tap cicla pelas molduras antes de publicar.
        Positioned.fill(
          child: GestureDetector(
            onDoubleTap: _cycleFrame,
            child: InteractiveViewer(
              transformationController: _transformCtrl,
              minScale: 0.2,
              maxScale: 5.0,
              panEnabled: true,
              scaleEnabled: true,
              // Permite arrastar pra fora da tela (igual Instagram).
              boundaryMargin: const EdgeInsets.all(double.infinity),
              // Sem clip: a mídia pode "vazar" pra fora durante o ajuste.
              clipBehavior: Clip.none,
              onInteractionStart: _onInteractionStart,
              onInteractionEnd: _onInteractionEnd,
              child: Center(child: _buildFramedMedia()),
            ),
          ),
        ),

        // Linhas guia (área de segurança 9:16) — aparecem durante o gesto.
        if (!_capturing)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _showGuides ? 1.0 : 0.0,
                child: const _SafeAreaGuides(),
              ),
            ),
          ),

        // Chip "Toque 2x para trocar moldura" (dica + label da moldura atual).
        if (!_capturing)
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: Container(
                    key: ValueKey(_frameStyle),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Text(
                      _frameStyle == 0
                          ? S.of(context).composerFrameHint
                          : S.of(context).composerFrameLabel(_frameLabel(context)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Camadas de texto draggable
        ..._layers.asMap().entries.map((entry) {
          final idx = entry.key;
          final layer = entry.value;
          return Positioned(
            left: layer.offset.dx,
            top: layer.offset.dy,
            child: GestureDetector(
              onPanStart: (_) {
                setState(() {
                  _draggingLayerIdx = idx;
                  _hoverTrash = false;
                });
                HapticFeedback.selectionClick();
              },
              onPanUpdate: (d) {
                final newOffset = Offset(
                  layer.offset.dx + d.delta.dx,
                  layer.offset.dy + d.delta.dy,
                );
                // Detecta hover sobre a lixeira (área inferior central).
                final trashY = size.height - 110;
                final trashCenterX = size.width / 2;
                final onTrash = (newOffset.dy > trashY) &&
                    ((newOffset.dx - trashCenterX).abs() < 80);
                if (onTrash != _hoverTrash) {
                  HapticFeedback.mediumImpact();
                }
                setState(() {
                  _hoverTrash = onTrash;
                  _layers[idx] = layer.copyWith(offset: newOffset);
                });
              },
              onPanEnd: (_) {
                if (_hoverTrash) {
                  setState(() {
                    _layers.removeAt(idx);
                    _draggingLayerIdx = null;
                    _hoverTrash = false;
                  });
                  HapticFeedback.heavyImpact();
                } else {
                  // Clamp dentro da tela ao soltar (se não foi pra lixeira).
                  final clamped = Offset(
                    _layers[idx]
                        .offset
                        .dx
                        .clamp(0.0, size.width - 40),
                    _layers[idx]
                        .offset
                        .dy
                        .clamp(0.0, size.height - 60),
                  );
                  setState(() {
                    _layers[idx] = _layers[idx].copyWith(offset: clamped);
                    _draggingLayerIdx = null;
                    _hoverTrash = false;
                  });
                }
              },
              child: _TextLayerView(layer: layer),
            ),
          );
        }),

        // Top bar
        if (!_capturing)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _CircleIconBtn(icon: Icons.arrow_back, onTap: widget.onBack),
                const Spacer(),
                // Reset zoom — só aparece se houver transformação aplicada.
                AnimatedBuilder(
                  animation: _transformCtrl,
                  builder: (_, __) {
                    final isIdentity =
                        _transformCtrl.value == Matrix4.identity();
                    if (isIdentity) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CircleIconBtn(
                        icon: Icons.center_focus_strong,
                        onTap: _resetTransform,
                      ),
                    );
                  },
                ),
                _CircleIconBtn(
                    icon: Icons.text_fields, onTap: _startTextCompose),
                const SizedBox(width: 8),
                _CircleIconBtn(
                  icon: _frameStyle == 0
                      ? Icons.crop_din
                      : (_frameStyle == 1
                          ? Icons.filter_frames
                          : Icons.auto_awesome),
                  onTap: _cycleFrame,
                ),
                const SizedBox(width: 8),
                _CircleIconBtn(
                  icon: Icons.color_lens_outlined,
                  onTap: () => _showColorPicker(),
                ),
              ],
            ),
          ),

        // Bottom bar (caption + publish)
        if (!_capturing)
          Positioned(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: TextField(
                      controller: _captionCtrl,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: S.of(context).composerCaptionHint,
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _PublishFab(
                  loading: widget.isPublishing,
                  onPressed: _flattenAndPublish,
                ),
              ],
            ),
          ),

        // Overlay de composição de texto
        if (_composingText && !_capturing)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _commitTextLayer,
              child: Container(
                color: Colors.black.withValues(alpha: 0.55),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: _ComposeTextField(
                          controller: _composeCtrl,
                          color: _currentColor,
                          bgStyle: _composeBgStyle,
                          onSubmitted: (_) => _commitTextLayer(),
                        ),
                      ),
                    ),
                    // Botão "A" (cicla fundo do texto) — canto superior direito.
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      right: 12,
                      child: _CircleIconBtn(
                        icon: _composeBgStyle == 0
                            ? Icons.format_color_text
                            : (_composeBgStyle == 1
                                ? Icons.title
                                : Icons.text_format),
                        onTap: () {
                          setState(() =>
                              _composeBgStyle = (_composeBgStyle + 1) % 3);
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ),
                    // Dica
                    Positioned(
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Center(
                          child: Text(
                            S.of(context).composerTapOutsideHint,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Lixeira (aparece enquanto arrasta uma camada de texto).
        if (_draggingLayerIdx != null && !_capturing)
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 32,
            child: IgnorePointer(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: _hoverTrash ? 84 : 64,
                  height: _hoverTrash ? 84 : 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hoverTrash
                        ? Colors.redAccent.withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.5),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.7),
                      width: 2,
                    ),
                    boxShadow: [
                      if (_hoverTrash)
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.5),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: _hoverTrash ? 36 : 28,
                  ),
                ),
              ),
            ),
          ),
      ],
      ),
    );
  }

  Widget _buildFramedMedia() {
    // Padrão Instagram Stories: a mídia entra na tela com BoxFit.contain
    // — ou seja, cabe INTEIRA dentro da viewport (sem cortar nada).
    // O usuário decide se quer aumentar/posicionar com 2 dedos.
    //
    // ⚠️ Não usar BoxFit.cover aqui: se a foto tem texto/elemento perto da
    // borda (ex.: print de WhatsApp), o cover esconderia esse conteúdo.
    //
    // TODO(publish-fidelity): hoje o backend recebe o arquivo original, então
    // a transformação aplicada (zoom/pan) NÃO é refletida no story publicado.
    // Pra preservar 100% do que o usuário vê, será preciso renderizar a Stack
    // inteira (mídia transformada + camadas de texto) em PNG via RepaintBoundary
    // antes de chamar createStory.
    final fit = BoxFit.contain;
    final Widget inner;
    if (widget.isVideo && widget.videoCtrl != null) {
      final ctrl = widget.videoCtrl!;
      inner = FittedBox(
        fit: fit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: ctrl.value.size.width,
          height: ctrl.value.size.height,
          child: VideoPlayer(ctrl),
        ),
      );
    } else {
      inner = Image.file(widget.file, fit: fit);
    }
    return _applyFrame(inner);
  }

  Widget _applyFrame(Widget child) {
    switch (_frameStyle) {
      case 1: // Polaroid branca
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 64),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 56),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: AspectRatio(aspectRatio: 1, child: child),
            ),
          ),
        );
      case 2: // Gradiente Brawe
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [AppColors.electricPurple, AppColors.coolCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricPurple.withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: child,
            ),
          ),
        );
      case 0:
      default:
        return child;
    }
  }

  Widget _buildMedia() {
    if (widget.isVideo && widget.videoCtrl != null) {
      final ctrl = widget.videoCtrl!;
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: ctrl.value.size.width,
          height: ctrl.value.size.height,
          child: VideoPlayer(ctrl),
        ),
      );
    }
    return Image.file(widget.file, fit: BoxFit.cover);
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF15192A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: _palette.map((c) {
            final selected = c.toARGB32() == _currentColor.toARGB32();
            return GestureDetector(
              onTap: () {
                setState(() => _currentColor = c);
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PublishFab extends StatelessWidget {
  const _PublishFab({required this.loading, required this.onPressed});
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.electricPurple, AppColors.coolCyan],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricPurple.withValues(alpha: 0.5),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

class _TextLayer {
  _TextLayer({
    required this.text,
    required this.color,
    required this.offset,
    required this.scale,
    this.bgStyle = 0,
  });

  final String text;
  final Color color;
  final Offset offset;
  final double scale;

  /// 0 = sem fundo (com sombra)
  /// 1 = fundo preto translúcido (plaquinha)
  /// 2 = fundo branco sólido (texto inverte pra cor)
  final int bgStyle;

  _TextLayer copyWith({
    Offset? offset,
    double? scale,
    Color? color,
    int? bgStyle,
  }) =>
      _TextLayer(
        text: text,
        color: color ?? this.color,
        offset: offset ?? this.offset,
        scale: scale ?? this.scale,
        bgStyle: bgStyle ?? this.bgStyle,
      );
}

/// Renderiza uma camada de texto com 3 estilos:
/// 0 = sem fundo, sombra para legibilidade
/// 1 = "plaquinha" preta translúcida
/// 2 = fundo branco sólido com cor do texto invertida
class _TextLayerView extends StatelessWidget {
  const _TextLayerView({required this.layer});
  final _TextLayer layer;

  @override
  Widget build(BuildContext context) {
    final fontSize = 28 * layer.scale;
    final txtStyle = TextStyle(
      color: layer.bgStyle == 2 ? _invertOnWhite(layer.color) : layer.color,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.15,
      shadows: layer.bgStyle == 0
          ? const [Shadow(blurRadius: 6, color: Colors.black54)]
          : null,
    );

    final text = Text(layer.text, style: txtStyle);

    switch (layer.bgStyle) {
      case 1:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(6),
          ),
          child: text,
        );
      case 2:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: text,
        );
      case 0:
      default:
        return text;
    }
  }

  /// Se a cor escolhida é muito clara, no fundo branco usamos preto;
  /// se é escura, mantém a própria cor.
  static Color _invertOnWhite(Color c) {
    final luminance = c.computeLuminance();
    return luminance > 0.7 ? Colors.black : c;
  }
}

/// TextField do overlay de composição com fundo (plaquinha) opcional.
class _ComposeTextField extends StatelessWidget {
  const _ComposeTextField({
    required this.controller,
    required this.color,
    required this.bgStyle,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final Color color;
  final int bgStyle;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final textColor = bgStyle == 2 ? _TextLayerView._invertOnWhite(color) : color;
    final field = TextField(
      controller: controller,
      autofocus: true,
      textAlign: TextAlign.center,
      maxLines: null,
      style: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        shadows: bgStyle == 0
            ? const [Shadow(blurRadius: 6, color: Colors.black54)]
            : null,
      ),
      decoration: InputDecoration(
        hintText: S.of(context).composerTextHint,
        hintStyle: TextStyle(
          color: bgStyle == 2 ? Colors.black38 : Colors.white54,
        ),
        border: InputBorder.none,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
      ),
      onSubmitted: onSubmitted,
    );

    switch (bgStyle) {
      case 1:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
          ),
          child: field,
        );
      case 2:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: field,
        );
      case 0:
      default:
        return field;
    }
  }
}

// PNG 1x1 transparente (mínimo para criar um arquivo válido).
final List<int> _kTransparentPngBytes = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

// Suppress unused-warning shim
// ignore: unused_element
void _keepMathImport() => math.pi;

/// Linhas guia tipo Instagram: mostra a "área de segurança" (top/bottom)
/// para o usuário enquadrar bem a publicação durante o pinch-zoom.
class _SafeAreaGuides extends StatelessWidget {
  const _SafeAreaGuides();

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    // Área de segurança aproximada do Instagram Stories:
    // ~14% do topo (status bar + header) e ~20% inferior (caption + ações).
    final topGuide = padding.top + 72;
    final bottomGuide = padding.bottom + 140;

    return Stack(
      children: [
        // Linha superior
        Positioned(
          left: 0,
          right: 0,
          top: topGuide,
          child: _GuideLine(label: S.of(context).composerGuideTop),
        ),
        // Linha inferior
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomGuide,
          child: _GuideLine(label: S.of(context).composerGuideBottom, alignEnd: true),
        ),
      ],
    );
  }
}

class _GuideLine extends StatelessWidget {
  const _GuideLine({required this.label, this.alignEnd = false});
  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!alignEnd)
          Padding(
            padding: const EdgeInsets.only(left: 14, bottom: 4),
            child: _GuideTag(text: label),
          ),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.85),
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        if (alignEnd)
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 4),
            child: _GuideTag(text: label),
          ),
      ],
    );
  }
}

class _GuideTag extends StatelessWidget {
  const _GuideTag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
