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
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../core/themes/app_colors.dart';
import '../../core/ui/app_snackbar.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/stories_view_model.dart';
import 'story_video_trim_screen.dart';

/// Brawe "Pulse" Composer — substitui o antigo bottom sheet.
///
/// Fluxo:
/// 1. Picker em tela cheia → câmera (foto/vídeo) ou galeria.
/// 2. Editor em tela cheia: imagem/vídeo de fundo, camadas de texto
///    draggable, paleta de cores, caption, botão publicar.
/// 3. (Opcional, só vídeo) Trim → tela `StoryVideoTrimScreen` aberta
///    pelo botão "scissors" da top bar. Permite cortar o trecho que
///    quiser dentro do limite de 15s. Usa APIs nativas (sem ffmpeg).
///
/// TODO(video-overlays): textos/transformações em vídeo ainda não são
/// renderizados no arquivo final (somente em fotos via flatten PNG).
/// Seria preciso ffmpeg_kit_flutter pra rasterizar overlays na timeline,
/// o que custa ~25MB no APK + licenciamento LGPL/GPL — fora de escopo
/// do MVP. Por ora vídeos publicam o arquivo original (cortado se passar
/// pelo trim), e os overlays vivem só na composição.
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

  // ── Anti double-publish ───────────────────────────────────────────────
  /// Lock SÍNCRONO (sem esperar setState/build) que impede que o usuário
  /// dispare múltiplos POST /stories/upload em sequência rápida.
  ///
  /// Por que existe além de `_isPublishing`?
  ///   Em conexões 4G/Wi-Fi instáveis o upload demora 5–30s. O usuário
  ///   toca "Compartilhar", o setState() agenda re-build assíncrono,
  ///   mas o botão visualmente continua "tocável" por alguns frames até
  ///   o build com loading. Se o usuário tocar 2-3x nesse intervalo
  ///   acabamos disparando vários POSTs idênticos. O backend cria 3
  ///   stories e o app recebe 3 sucessos (ou 1 timeout + 2 sucessos).
  ///   Resultado: stories duplicados no feed + mensagem de "falha"
  ///   intermitente.
  ///
  /// Este flag síncrono trava IMEDIATAMENTE no primeiro toque, antes
  /// mesmo do setState; futuros toques na mesma sessão são no-op.
  bool _publishInFlight = false;

  /// Idempotency-Key compartilhada entre todos os retries da mesma
  /// composição. Backend persiste em `stories.idempotency_key` (UNIQUE).
  /// Se chegar 2 requests com a mesma key, o backend devolve o registro
  /// que já existe em vez de criar duplicata.
  ///
  /// Gerada UMA VEZ por instância do composer (initState), usada em todos
  /// os segmentos do mesmo upload e descartada quando a tela é fechada.
  final String _idempotencyKey = const Uuid().v4();

  // ── Live camera preview (background of picker) ──────────────────────
  CameraController? _camCtrl;
  Future<void>? _camInitFuture;
  bool _camAvailable = false;

  /// Resolução-alvo da câmera (foto + vídeo do composer).
  ///
  /// `veryHigh` = 1920×1080 (Full HD), o sweet spot para Stories 9:16:
  ///   • Cobre 100% da resolução nativa do formato do story.
  ///   • Não desperdiça banda/storage com 4K que ninguém percebe num feed.
  ///   • Compatível com a quase totalidade dos devices Android/iOS de
  ///     2020+ (o package camera faz fallback automático se o device não
  ///     suportar — vai para o mais próximo abaixo).
  ///
  /// Antes estava em `medium` (640×480) — fotos saiam serrilhadas e o
  /// vídeo gravava em 480p mesmo num iPhone 15 Pro. Bug 09-jun.
  static const ResolutionPreset _kCameraResolution = ResolutionPreset.veryHigh;

  // ── Inline capture state (foto/vídeo direto na tela) ────────────────
  //
  // 09-jun (refactor "Opção B"): UNIFICAMOS `_kSegmentMax` e `_kTotalMax`
  // em 60s. Antes era 15s por segmento + 60s total (modelo Instagram 2018
  // multi-segmento → N stories de 15s). O backend (`stories.py::create_story`
  // com `Form(ge=1, le=60)`) sempre aceitou até 60s, mas o app cortava
  // o vídeo em pedaços e fazia upload sequencial de N stories. Mudamos
  // pro modelo TikTok/Instagram 2024+: 1 vídeo único contínuo de até 60s
  // = 1 story. O multi-segmento ainda funciona porque o publish itera
  // `_videoSegments`, mas no fluxo padrão a gravação não rotaciona mais
  // automaticamente — só o `_kTotalMax` é hit, gerando 1 segmento só.
  //
  // ⚠️ Backend storage_service.py precisa de `MAX_VIDEO_SIZE = 100MB`
  // pra acomodar 60s @ 1080p H.264 (~50-80MB típico, margem para HEVC).
  static const Duration _kSegmentMax = Duration(seconds: 60);
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
        _kCameraResolution,
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
        // 🔊 Áudio ATIVO no preview (volume cheio).
        // Antes estava em 0 — usuário não conseguia ouvir o áudio do
        // próprio vídeo antes de publicar (ver bug reportado em 09-jun).
        // Mudo só durante captura ao vivo (loop com tela cheia da câmera),
        // não durante o preview do que já foi gravado.
        ctrl
          ..setLooping(true)
          ..setVolume(1.0)
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
      _kCameraResolution,
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

    // ⚠️ Trava SÍNCRONA: rejeita o 2º+ toque imediatamente, sem esperar
    // pelo próximo build com `_isPublishing=true`. Resolve o bug de
    // stories duplicados quando o usuário toca "Compartilhar" várias
    // vezes em redes lentas (ver comentário em _publishInFlight).
    if (_publishInFlight) return;
    _publishInFlight = true;

    setState(() => _isPublishing = true);
    try {
      final notifier = ref.read(storiesViewModelProvider.notifier);

      // Duração real do vídeo (em segundos), lida do VideoPlayerController.
      // Backend (POST /stories/upload) aceita `duration_seconds` no range
      // [1, 60]. Antes deixávamos NULL e o viewer detectava em runtime do
      // <video> — funciona, mas perde a info útil pra UI (badge no thumb,
      // analytics, throttle de bandwidth). Agora enviamos sempre que temos.
      //
      // Clampa em [1, 60] pra nunca rejeitar 422 do FastAPI: se o vídeo
      // tem 60.4s por arredondamento do encoder, vai como 60.
      int? videoDurSec() {
        if (!_isVideo) return null;
        final d = _videoCtrl?.value.duration;
        if (d == null || d == Duration.zero) return null;
        return d.inSeconds.clamp(1, 60);
      }

      // Publica multi-segmento (cada parte vira 1 story sequencial).
      // IMPORTANTE: cada segmento usa uma idempotency key DERIVADA da
      // master key (key + ":" + index). Assim, se a request do segmento
      // 2 falhar e o usuário tentar novamente, o backend vê que segmento
      // 0 e 1 já foram processados (mesma key:0 / key:1) e devolve esses
      // registros sem duplicar — só cria o segmento 2 novo.
      //
      // No fluxo "Opção B" (vídeo único até 60s), `_videoSegments.length`
      // é tipicamente 1 e cai no `else` abaixo. O `if` só executa em
      // cenários legados (gravação multi-segmento, raro).
      if (_isVideo && _videoSegments.length > 1) {
        // Em multi-segmento NÃO temos a duração de cada segmento isolado
        // (só do composto exibido no preview). Deixa NULL — viewer detecta.
        for (int i = 0; i < _videoSegments.length; i++) {
          await notifier.createStory(
            localFilePath: _videoSegments[i].path,
            // Caption apenas no primeiro segmento (padrão Instagram)
            caption: i == 0 ? caption : null,
            originPostId: widget.initialOriginPostId,
            idempotencyKey: '$_idempotencyKey:$i',
          );
        }
      } else {
        // Foto: usa o PNG renderizado (com transform + textos) se disponível.
        // Vídeo: arquivo único (do trim, gravação 60s, ou galeria).
        final pathToUpload = flattenedImage?.path ?? _file!.path;
        await notifier.createStory(
          localFilePath: pathToUpload,
          caption: caption,
          durationSeconds: videoDurSec(),
          originPostId: widget.initialOriginPostId,
          idempotencyKey: _idempotencyKey,
        );
      }
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        _videoSegments.length > 1
            ? S
                  .of(context)
                  .composerMultipleStoriesPublished(_videoSegments.length)
            : S.of(context).composerStoryPublished,
      );
      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      // 🔍 Heurística importante:
      // Mesmo recebendo DioException, o BACKEND pode ter persistido o
      // story (timeout do TCP no upload de 50MB em 4G fraco é comum).
      // Se for `connectionTimeout`/`receiveTimeout`/`sendTimeout` E for
      // a primeira tentativa, mostramos um aviso AMBÍGUO (não "falha"
      // explícita) e deixamos o usuário voltar pra tela de stories — o
      // feed que recarrega vai mostrar se foi publicado ou não.
      //
      // Em todos os outros casos (4xx, sem rede, etc) é uma falha real
      // e podemos liberar o lock pra ele tentar de novo (com a mesma
      // idempotency key — backend deduplicará se já gravou).
      if (!mounted) return;
      final isTimeout =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      if (isTimeout) {
        AppSnackBar.showWarning(
          context,
          S.of(context).composerPublishTimeoutMaybe,
        );
        // Volta pro feed pra ele ver se chegou (o feed recarrega).
        Navigator.of(context).pop(true);
        return;
      }
      AppSnackBar.showError(context, S.of(context).composerPublishError);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(context, S.of(context).composerPublishError);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
      // Libera o lock APENAS se a tela ainda está aberta — caso de erro.
      // No caminho feliz a tela já foi pop'ada e o lock vai com ela.
      if (mounted) _publishInFlight = false;
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
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white70,
                      size: 48,
                    ),
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
                      label: Text(
                        S.of(context).composerRetry,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.electricPurple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).composerPreparing,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
                segmentProgress:
                    (_currentSegmentElapsed.inMilliseconds /
                            _kSegmentMax.inMilliseconds)
                        .clamp(0.0, 1.0),
                totalProgress:
                    ((_previousSegmentsTotal + _currentSegmentElapsed)
                                .inMilliseconds /
                            _kTotalMax.inMilliseconds)
                        .clamp(0.0, 1.0),
                segmentBreaks: _videoSegments.isEmpty
                    ? const []
                    : List<double>.generate(_videoSegments.length, (i) {
                        // posição cumulativa de cada break sobre 60s
                        double acc = 0;
                        for (int k = 0; k <= i; k++) {
                          // Aproxima usando _kSegmentMax (60s) por segmento.
                          // No fluxo "Opção B" (vídeo único) só existe 1
                          // segmento, então o break fica em 100% e visualmente
                          // some — comportamento esperado.
                          acc += _kSegmentMax.inMilliseconds.toDouble();
                        }
                        return (acc / _kTotalMax.inMilliseconds).clamp(
                          0.0,
                          1.0,
                        );
                      }),
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
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
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
      onTrim: _handleTrim,
    );
  }

  /// Abre o `StoryVideoTrimScreen` com o vídeo atual e, se o usuário
  /// salvar, substitui o arquivo + re-cria o `VideoPlayerController`
  /// via `_setSelected`. Pausa o player atual antes de abrir a tela
  /// pra evitar reprodução em background durante a edição.
  Future<void> _handleTrim() async {
    if (!_isVideo || _file == null) return;
    // Pausa o preview atual — fica estranho ouvir áudio enquanto a tela
    // de trim já tá tocando o mesmo vídeo.
    await _videoCtrl?.pause();
    if (!mounted) return;
    final trimmed = await StoryVideoTrimScreen.push(
      context,
      file: _file!,
      maxDuration: _kSegmentMax,
    );
    if (!mounted) return;
    if (trimmed == null) {
      // Cancelado — retoma o preview.
      await _videoCtrl?.play();
      return;
    }
    // Sucesso: substitui o arquivo. _setSelected dispose do velho
    // controller, cria novo com volume cheio e dá play em loop.
    // Importante: também esvazia _videoSegments porque o multi-segmento
    // perde sentido após o usuário escolher um corte específico.
    _videoSegments
      ..clear()
      ..add(trimmed);
    _previousSegmentsTotal = Duration.zero;
    await _setSelected(trimmed, isVideo: true);
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
                borderRadius: isRecording ? BorderRadius.circular(10) : null,
                gradient: LinearGradient(
                  colors: isRecording
                      ? const [Colors.redAccent, Color(0xFFFF3D6E)]
                      : const [AppColors.electricPurple, AppColors.coolCyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isRecording
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
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
  // Aceita `null` para representar estado desabilitado (ex.: enquanto a ação
  // está em progresso). `GestureDetector.onTap` já aceita callback nulo.
  final VoidCallback? onTap;

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
    required this.onTrim,
    this.isRepost = false,
  });

  final File file;
  final bool isVideo;
  final VideoPlayerController? videoCtrl;
  final bool isPublishing;
  final bool isRepost;
  final VoidCallback onBack;
  final Future<void> Function({required String? caption, File? flattenedImage})
  onPublish;

  /// Abre a tela de trim — implementada pelo parent
  /// (`_StoryComposerScreenState`), porque é ele quem detém o
  /// `VideoPlayerController` e precisa recriá-lo após o corte.
  final Future<void> Function() onTrim;

  @override
  State<_StoryEditor> createState() => _StoryEditorState();
}

class _StoryEditorState extends State<_StoryEditor> {
  // ⚠️ Removida a `caption` inferior — padrão moderno (Instagram/TikTok):
  // texto mora APENAS como overlay arrastável na própria mídia. A bottom
  // bar agora é só "Seu story" + botão Compartilhar.
  final List<_TextLayer> _layers = [];
  Color _currentColor = Colors.white;
  bool _composingText = false;
  final TextEditingController _composeCtrl = TextEditingController();

  // Estilo de fundo do texto sendo composto (cicla com botão "A").
  // 0 = sem fundo, 1 = preto translúcido, 2 = branco sólido (cor invertida).
  int _composeBgStyle = 0;

  // Alinhamento do parágrafo enquanto compõe (cicla com botão).
  // Aplica-se à camada quando ela é commitada e quando o texto quebra
  // em múltiplas linhas (single-line não muda visualmente).
  TextAlign _composeAlign = TextAlign.center;

  // Tamanho da fonte (multiplica 28). Slider vertical na lateral
  // esquerda do overlay de composição.
  double _composeFontScale = 1.0;
  static const double _kMinFontScale = 0.5;
  static const double _kMaxFontScale = 2.4;

  // ── Drag para lixeira ───────────────────────────────────────────────
  int? _draggingLayerIdx;
  bool _hoverTrash = false;

  // ── Flatten/Capture (fidelidade ao publicar) ────────────────────────
  // Envolvemos a tela em RepaintBoundary e renderizamos um PNG com o
  // que o usuário vê (mídia + transformação + textos). Os controles são
  // escondidos durante a captura via [_capturing].
  final GlobalKey _captureKey = GlobalKey();
  bool _capturing = false;

  // ── Salvar no dispositivo ───────────────────────────────────────────
  // Spinner do botão de download enquanto a mídia é renderizada e
  // gravada no álbum "Brawe" da galeria. Funciona pra foto (com
  // overlays via flatten PNG) e vídeo (arquivo já cortado, sem overlays
  // — limitação sem ffmpeg).
  bool _isSavingToDevice = false;

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
    _composeCtrl.dispose();
    _transformCtrl.dispose();
    _guidesTimer?.cancel();
    super.dispose();
  }

  void _startTextCompose() {
    _composeCtrl.clear();
    _composeBgStyle = 0;
    _composeAlign = TextAlign.center;
    _composeFontScale = 1.0;
    setState(() => _composingText = true);
  }

  void _cycleComposeAlign() {
    setState(() {
      _composeAlign = switch (_composeAlign) {
        TextAlign.center => TextAlign.left,
        TextAlign.left => TextAlign.right,
        _ => TextAlign.center,
      };
    });
    HapticFeedback.selectionClick();
  }

  IconData _alignIcon(TextAlign a) => switch (a) {
    TextAlign.left => Icons.format_align_left,
    TextAlign.right => Icons.format_align_right,
    _ => Icons.format_align_center,
  };

  void _commitTextLayer() {
    final txt = _composeCtrl.text.trim();
    if (txt.isNotEmpty) {
      _layers.add(
        _TextLayer(
          text: txt,
          color: _currentColor,
          offset: const Offset(80, 200),
          scale: _composeFontScale,
          bgStyle: _composeBgStyle,
          align: _composeAlign,
        ),
      );
    }
    setState(() => _composingText = false);
  }

  /// Renderiza a tela inteira (mídia transformada + textos) em um PNG.
  /// Retorna o [File] do PNG ou `null` se falhou. Compartilhado entre
  /// "Publicar" (flatten + upload) e "Salvar no dispositivo".
  ///
  /// Importante: marca `_capturing = true` antes do snapshot para
  /// esconder controles (top bar, lixeira, guias, chip de moldura). O
  /// caller é responsável por restaurar `_capturing = false` no finally.
  Future<File?> _captureFlatten() async {
    setState(() => _capturing = true);
    // Garante que a UI ocultou antes do snapshot.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 16));

    try {
      final boundary =
          _captureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // pixelRatio 3.0 ~= 1080p em devices comuns. Limita o teto para
      // evitar uploads gigantes em iPads/devices grandes.
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final ratio = math.min(3.0, dpr * 1.5);
      final uiImage = await boundary.toImage(pixelRatio: ratio);
      final bytes = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      uiImage.dispose();
      if (bytes == null) return null;

      final dir = await getTemporaryDirectory();
      final out = File(
        '${dir.path}/story_flat_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await out.writeAsBytes(bytes.buffer.asUint8List());
      return out;
    } catch (e, st) {
      debugPrint('[StoryComposer] Flatten falhou: $e\n$st');
      return null;
    }
  }

  /// Renderiza a tela inteira (mídia transformada + textos) em um PNG
  /// e dispara o [onPublish] com esse arquivo. Vídeos pulam o flatten
  /// (não dá pra rasterizar — usam o arquivo original sem caption,
  /// já que o texto agora vive como overlay na mídia).
  Future<void> _flattenAndPublish() async {
    // Defesa em camada extra: se o publish já está rolando (parent
    // ainda processando o último onPublish), ignora silenciosamente
    // este toque. O lock real fica em _StoryComposerScreenState mas
    // aqui evitamos até começar o flatten.
    if (widget.isPublishing) return;

    // Vídeo: publica direto, sem flatten e sem caption (texto vive como
    // overlay; pra renderizar overlay em vídeo precisaria ffmpeg).
    if (widget.isVideo) {
      await widget.onPublish(caption: null);
      return;
    }

    File? flat;
    try {
      flat = await _captureFlatten();
    } finally {
      if (mounted) setState(() => _capturing = false);
    }

    await widget.onPublish(caption: null, flattenedImage: flat);
  }

  /// Salva a mídia editada na galeria do dispositivo.
  ///
  /// Estratégia:
  ///   • FOTO: renderiza o flatten PNG (com transform + textos) e salva
  ///     via `Gal.putImage`.
  ///   • VÍDEO: salva o arquivo original cortado (sem overlays — não
  ///     temos ffmpeg pra rasterizar overlays na timeline). É o melhor
  ///     que dá sem +25MB de package nativo.
  ///
  /// Pede permissão automaticamente. Em iOS 14+ usa "Add Only" (não
  /// precisa de "Full Library Access"). Mostra snackbar de
  /// sucesso/falha — feedback é importante para o usuário entender que
  /// foi salvo (sem indicador visual ele vai pra galeria conferir).
  Future<void> _handleSaveToDevice() async {
    if (_isSavingToDevice) return;
    setState(() => _isSavingToDevice = true);

    try {
      // 1) Permissão: gal pede internamente, mas vale checar antes
      // pra dar mensagem clara em caso de "Negar para sempre".
      final hasAccess = await Gal.hasAccess(toAlbum: false);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: false);
        if (!granted) {
          if (!mounted) return;
          AppSnackBar.showError(
            context,
            S.of(context).composerSavePermissionDenied,
          );
          return;
        }
      }

      // 2) Foto: flatten primeiro
      if (!widget.isVideo) {
        File? flat;
        try {
          flat = await _captureFlatten();
        } finally {
          if (mounted) setState(() => _capturing = false);
        }
        // Fail-safe: se o flatten falhou, salva o arquivo original mesmo
        // sem overlays — é melhor do que nada.
        final source = flat ?? widget.file;
        await Gal.putImage(source.path, album: 'Brawe');
      } else {
        // 3) Vídeo: salva o arquivo (já cortado se passou pelo trim)
        await Gal.putVideo(widget.file.path, album: 'Brawe');
      }

      HapticFeedback.mediumImpact();
      if (!mounted) return;
      AppSnackBar.showSuccess(context, S.of(context).composerSavedToDevice);
    } on GalException catch (e, st) {
      debugPrint('[StoryComposer] Gal failed: ${e.type} $st');
      if (!mounted) return;
      // Type específico de "sem permissão" tem mensagem dedicada;
      // resto cai no genérico.
      if (e.type == GalExceptionType.accessDenied) {
        AppSnackBar.showError(
          context,
          S.of(context).composerSavePermissionDenied,
        );
      } else {
        AppSnackBar.showError(context, S.of(context).composerSaveError);
      }
    } catch (e, st) {
      debugPrint('[StoryComposer] Save failed: $e\n$st');
      if (!mounted) return;
      AppSnackBar.showError(context, S.of(context).composerSaveError);
    } finally {
      if (mounted) setState(() => _isSavingToDevice = false);
    }
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
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        _frameStyle == 0
                            ? S.of(context).composerFrameHint
                            : S
                                  .of(context)
                                  .composerFrameLabel(_frameLabel(context)),
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
                  // Hit-test da lixeira usando a posição GLOBAL do dedo
                  // (d.globalPosition), não a posição do widget. O widget
                  // arrastado pode ser largo (texto longo) e o offset é o
                  // canto superior-esquerdo — usar isso quebra a detecção
                  // em ~70% dos casos. O dedo é a referência correta.
                  //
                  // A lixeira mora em: bottom = bottomPad + 32, tamanho 84
                  // (estado expandido) → centro Y ≈ height - bottomPad - 74.
                  // Usamos um raio de 64 (maior que o widget pra dar tolerância).
                  final bottomPad = MediaQuery.of(context).padding.bottom;
                  final trashCenter = Offset(
                    size.width / 2,
                    size.height - bottomPad - 74,
                  );
                  final dist = (d.globalPosition - trashCenter).distance;
                  final onTrash = dist < 64;
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
                      _layers[idx].offset.dx.clamp(0.0, size.width - 40),
                      _layers[idx].offset.dy.clamp(0.0, size.height - 60),
                    );
                    setState(() {
                      _layers[idx] = _layers[idx].copyWith(offset: clamped);
                      _draggingLayerIdx = null;
                      _hoverTrash = false;
                    });
                  }
                },
                // maxWidth = largura útil a partir da posição da camada,
                // limitada a 88% da tela (mesmo limite do Instagram).
                child: _TextLayerView(
                  layer: layer,
                  maxWidth: math.max(
                    120.0,
                    math.min(
                      size.width * 0.88,
                      size.width - layer.offset.dx - 8,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Top bar — ferramentas estilo Instagram/TikTok.
          // Ordem: voltar | (reset zoom) | spacer | Aa (texto) | moldura | cor.
          // Padrão moderno: ações rápidas alinhadas à direita, voltar à esquerda.
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
                    builder: (_, _) {
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
                  // Botão "Aa" estilizado: o ícone padrão (text_fields)
                  // não comunica que dá pra adicionar texto. Trocamos por
                  // um botão maior com label "Aa" (linguagem universal).
                  _AaTextButton(onTap: _startTextCompose),
                  const SizedBox(width: 8),
                  // Botão "scissors" — só aparece quando a mídia é vídeo.
                  // Abre o StoryVideoTrimScreen pra cortar o trecho desejado.
                  if (widget.isVideo) ...[
                    _CircleIconBtn(
                      icon: Icons.content_cut_rounded,
                      onTap: () => widget.onTrim(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Botão "salvar no dispositivo" (download).
                  // Ícone de seta-pra-baixo: padrão Instagram/TikTok.
                  // Funciona pra foto (com overlays via flatten) e vídeo
                  // (arquivo cortado, sem overlays). Mostra spinner
                  // enquanto renderiza o flatten + grava no álbum "Brawe".
                  _CircleIconBtn(
                    icon: _isSavingToDevice
                        ? Icons.hourglass_top_rounded
                        : Icons.file_download_outlined,
                    onTap: _isSavingToDevice
                        ? null
                        : () => _handleSaveToDevice(),
                  ),
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

          // Bottom bar — modernizada (Instagram/TikTok 2026):
          // Não tem mais campo de "caption" inferior (texto vive como overlay
          // na própria mídia). Em vez disso, uma pill "Seu story" indica
          // o destino + botão "Compartilhar" pill grande à direita.
          if (!_capturing)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: Row(
                children: [
                  _StoryDestinationPill(label: S.of(context).composerYourStory),
                  const Spacer(),
                  _ShareButton(
                    loading: widget.isPublishing,
                    onPressed: _flattenAndPublish,
                  ),
                ],
              ),
            ),

          // ── Overlay de composição de texto (estilo Instagram 2026) ──
          // Layout:
          //  • Top-right: botões verticais (alinhamento, fundo, "OK")
          //  • Left side: slider vertical de tamanho da fonte
          //  • Center: TextField (autofocus, multi-linha, com maxWidth)
          //  • Bottom: paleta horizontal de cores
          if (_composingText && !_capturing)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _commitTextLayer,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.55),
                  child: Stack(
                    children: [
                      // Centro: campo de texto.
                      // Largura limitada a 84% da tela — alinhada com a
                      // largura do _TextLayerView depois de commitado para
                      // evitar "salto visual" entre composição e camada final.
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: _ComposeTextField(
                            controller: _composeCtrl,
                            color: _currentColor,
                            bgStyle: _composeBgStyle,
                            align: _composeAlign,
                            fontScale: _composeFontScale,
                            maxWidth: size.width * 0.84,
                            onSubmitted: (_) => _commitTextLayer(),
                          ),
                        ),
                      ),

                      // Topo direito: botões verticais (align / bg / OK).
                      // GestureDetector pra impedir que o tap no botão
                      // suba até o overlay externo (que commita a camada).
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: 12,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {},
                          child: Column(
                            children: [
                              _CircleIconBtn(
                                icon: _alignIcon(_composeAlign),
                                onTap: _cycleComposeAlign,
                              ),
                              const SizedBox(height: 8),
                              _CircleIconBtn(
                                icon: _composeBgStyle == 0
                                    ? Icons.format_color_text
                                    : (_composeBgStyle == 1
                                          ? Icons.title
                                          : Icons.text_format),
                                onTap: () {
                                  setState(
                                    () => _composeBgStyle =
                                        (_composeBgStyle + 1) % 3,
                                  );
                                  HapticFeedback.selectionClick();
                                },
                              ),
                              const SizedBox(height: 16),
                              // "OK" pill — atalho explícito pra commitar.
                              // Toque fora também funciona, mas o pill
                              // ajuda usuários que não conhecem o gesto.
                              GestureDetector(
                                onTap: _commitTextLayer,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Lateral esquerda: slider vertical de tamanho.
                      // Wrap em GestureDetector pra não commitar ao
                      // arrastar o slider.
                      Positioned(
                        left: 8,
                        top: MediaQuery.of(context).padding.top + 80,
                        bottom: 140,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {},
                          child: _FontSizeSlider(
                            value: _composeFontScale,
                            min: _kMinFontScale,
                            max: _kMaxFontScale,
                            onChanged: (v) =>
                                setState(() => _composeFontScale = v),
                          ),
                        ),
                      ),

                      // Rodapé: paleta de cores horizontal (substitui o
                      // bottom sheet bruto que tínhamos antes).
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: MediaQuery.of(context).padding.bottom + 24,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {},
                          child: _InlineColorPalette(
                            palette: _palette,
                            selected: _currentColor,
                            onSelect: (c) => setState(() => _currentColor = c),
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

class _TextLayer {
  _TextLayer({
    required this.text,
    required this.color,
    required this.offset,
    required this.scale,
    this.bgStyle = 0,
    this.align = TextAlign.center,
  });

  final String text;
  final Color color;
  final Offset offset;
  final double scale;

  /// 0 = sem fundo (com sombra)
  /// 1 = fundo preto translúcido (plaquinha)
  /// 2 = fundo branco sólido (texto inverte pra cor)
  final int bgStyle;

  /// Alinhamento do parágrafo (relevante quando o texto quebra em
  /// múltiplas linhas — single-line não muda nada visualmente).
  final TextAlign align;

  _TextLayer copyWith({
    Offset? offset,
    double? scale,
    Color? color,
    int? bgStyle,
    TextAlign? align,
  }) => _TextLayer(
    text: text,
    color: color ?? this.color,
    offset: offset ?? this.offset,
    scale: scale ?? this.scale,
    bgStyle: bgStyle ?? this.bgStyle,
    align: align ?? this.align,
  );
}

/// Renderiza uma camada de texto com 3 estilos de fundo + alinhamento.
/// Limita a largura a `maxWidth` (passada pelo pai) — assim, mesmo um
/// texto colado-sem-espaço quebra em múltiplas linhas em vez de sair da
/// tela. O `align` controla o paragraph wrap quando há quebras.
///
/// 0 = sem fundo, sombra para legibilidade
/// 1 = "plaquinha" preta translúcida
/// 2 = fundo branco sólido com cor do texto invertida
class _TextLayerView extends StatelessWidget {
  const _TextLayerView({required this.layer, required this.maxWidth});

  final _TextLayer layer;
  final double maxWidth;

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

    final text = Text(
      layer.text,
      textAlign: layer.align,
      softWrap: true,
      style: txtStyle,
    );

    final Widget content;
    switch (layer.bgStyle) {
      case 1:
        content = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(6),
          ),
          child: text,
        );
        break;
      case 2:
        content = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: text,
        );
        break;
      case 0:
      default:
        content = text;
    }

    // ConstrainedBox garante que mesmo um caractere de 200px não
    // estoure os limites do story (9:16). Sem isso, qualquer texto
    // longo "vaza" pra direita até sumir da tela.
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: content,
    );
  }

  /// Se a cor escolhida é muito clara, no fundo branco usamos preto;
  /// se é escura, mantém a própria cor.
  static Color _invertOnWhite(Color c) {
    final luminance = c.computeLuminance();
    return luminance > 0.7 ? Colors.black : c;
  }
}

/// TextField do overlay de composição com fundo (plaquinha) opcional,
/// alinhamento configurável e font-size dinâmico (slider lateral).
/// Limita a largura ao `maxWidth` para evitar overflow durante a digitação.
class _ComposeTextField extends StatelessWidget {
  const _ComposeTextField({
    required this.controller,
    required this.color,
    required this.bgStyle,
    required this.align,
    required this.fontScale,
    required this.maxWidth,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final Color color;
  final int bgStyle;
  final TextAlign align;
  final double fontScale;
  final double maxWidth;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final textColor = bgStyle == 2
        ? _TextLayerView._invertOnWhite(color)
        : color;
    final field = TextField(
      controller: controller,
      autofocus: true,
      textAlign: align,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      cursorColor: textColor,
      style: TextStyle(
        color: textColor,
        fontSize: 28 * fontScale,
        fontWeight: FontWeight.w700,
        height: 1.15,
        shadows: bgStyle == 0
            ? const [Shadow(blurRadius: 6, color: Colors.black54)]
            : null,
      ),
      decoration: InputDecoration(
        hintText: S.of(context).composerTextHint,
        hintStyle: TextStyle(
          color: bgStyle == 2 ? Colors.black38 : Colors.white54,
          fontSize: 28 * fontScale,
        ),
        border: InputBorder.none,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
      ),
      onSubmitted: onSubmitted,
    );

    final Widget wrapped;
    switch (bgStyle) {
      case 1:
        wrapped = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
          ),
          child: field,
        );
        break;
      case 2:
        wrapped = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: field,
        );
        break;
      case 0:
      default:
        wrapped = field;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: wrapped,
    );
  }
}

// PNG 1x1 transparente (mínimo para criar um arquivo válido).
final List<int> _kTransparentPngBytes = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
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
          child: _GuideLine(
            label: S.of(context).composerGuideBottom,
            alignEnd: true,
          ),
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
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
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

// ── Modernização (UI 2026) ──────────────────────────────────────────────────
//
// Widgets adicionados nessa rodada:
//  • _AaTextButton        — botão "Aa" da top bar (gateway pro modo texto)
//  • _StoryDestinationPill — pill esquerda da bottom bar ("Seu story")
//  • _ShareButton         — pill direita da bottom bar ("Compartilhar →")
//  • _FontSizeSlider      — slider vertical lateral (tamanho da fonte no compose)
//  • _InlineColorPalette  — paleta horizontal flutuante no rodapé do compose
//
// Substitui a antiga "caption inferior" (tipo Insta de 2014) pelo padrão
// moderno: texto vive como overlay arrastável, bottom bar é só destino +
// CTA de publicar.

/// Botão "Aa" da top bar — versão mais legível e moderna do antigo
/// `_CircleIconBtn(icon: Icons.text_fields)`. Usa label de texto "Aa" no
/// lugar do ícone genérico, padrão Instagram/TikTok.
class _AaTextButton extends StatelessWidget {
  const _AaTextButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Aa',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

/// Pill "Seu story" na bottom bar. Versão moderna do que antes era um
/// TextField vazio de caption — agora indica claramente o destino da
/// publicação (futuramente pode virar um seletor: Story / Close Friends).
class _StoryDestinationPill extends StatelessWidget {
  const _StoryDestinationPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.electricPurple, AppColors.coolCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão "Compartilhar" da bottom bar — pill grande com gradiente Brawe.
/// Versão moderna do antigo `_PublishFab` (FAB circular com ícone send),
/// segue padrão Instagram (pill horizontal com label "Compartilhar →").
class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.loading, required this.onPressed});
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: loading ? 18 : 22,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.electricPurple, AppColors.coolCyan],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricPurple.withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Builder(
                builder: (context) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.of(context).composerShare,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Slider vertical de tamanho da fonte (lateral esquerda do compose).
/// Padrão Instagram Stories / WhatsApp Status: fonte fica menor pra cima
/// e maior pra baixo? Não — invertemos pra "intuitivo": maior em cima
/// (puxa pra cima = aumenta), menor embaixo. RotationY -1 para inverter
/// a direção do slider sem inverter os ticks visuais.
class _FontSizeSlider extends StatelessWidget {
  const _FontSizeSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Column(
        children: [
          // Tick maior (topo)
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3, // vertical (slider rotaciona 90° anti-horário)
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withValues(alpha: 0.14),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 18,
                  ),
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  onChanged: (v) {
                    onChanged(v);
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
            ),
          ),
          // Tick menor (base)
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paleta de cores horizontal flutuante no rodapé do overlay de
/// composição. Substitui o bottom sheet bruto que abria fora da
/// tela. Padrão moderno: troca de cor instantânea, sem modal.
class _InlineColorPalette extends StatelessWidget {
  const _InlineColorPalette({
    required this.palette,
    required this.selected,
    required this.onSelect,
  });

  final List<Color> palette;
  final Color selected;
  final ValueChanged<Color> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: palette.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = palette[i];
          final isSelected = c.toARGB32() == selected.toARGB32();
          return GestureDetector(
            onTap: () {
              onSelect(c);
              HapticFeedback.selectionClick();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: isSelected ? 38 : 32,
              height: isSelected ? 38 : 32,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: c.withValues(alpha: 0.6),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
