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
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../core/themes/app_colors.dart';
import '../../core/ui/app_snackbar.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../domain/models/sound.dart';
import '../../shared/widgets/volume_mixer_sheet.dart';
import '../../sounds/view_models/sound_player_view_model.dart';
import '../../sounds/widgets/sound_trim_screen.dart';
import '../../sounds/widgets/sounds_catalog_screen.dart';
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
/// Textos em VÍDEO: o editor exporta só as camadas como um PNG
/// transparente 1080×1920 ("overlay", enviado via `overlayPath` no
/// `createStory`) que o viewer desenha por cima do vídeo — sem ffmpeg.
/// Em FOTO o editor faz flatten (mídia + transform + textos) num PNG 9:16.
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

class _StoryComposerScreenState extends ConsumerState<StoryComposerScreen>
    with WidgetsBindingObserver {
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

  // ── Brawe Sound: música anexada ao story (opcional) ───────────────
  Sound? _selectedSound;
  // Trecho ESPECÍFICO escolhido para ESTE story (teto = 60s, igual ao
  // limite de duração de vídeo/story validado no backend).
  static const Duration _kMaxSoundTrim = Duration(seconds: 60);
  int _soundTrimStartMs = 0;
  int? _soundTrimEndMs;

  // Fase D: volumes específicos do MIX entre a música anexada e o áudio
  // original do vídeo — persistidos com o story (`sound_volume`/
  // `original_audio_volume`, já suportados pelo backend/payload). Default
  // 1.0/1.0 preserva o comportamento anterior quando o usuário não abre
  // o mixer de volumes.
  double _soundVolume = 1.0;
  double _originalAudioVolume = 1.0;

  // ── Live camera preview (background of picker) ──────────────────────
  CameraController? _camCtrl;
  Future<void>? _camInitFuture;
  bool _camAvailable = false;
  bool _camInitializing = false;
  bool _camPermissionDenied = false;
  List<CameraDescription> _cameras = const [];

  /// Direção atual — frontal (selfie) por padrão.
  CameraLensDirection _lens = CameraLensDirection.front;

  /// Invalida inits em voo quando a câmera é trocada/parada.
  int _camGeneration = 0;
  double _minZoom = 1;
  double _maxZoom = 1;
  double _zoom = 1;
  double _zoomBase = 1;
  final ValueNotifier<double?> _zoomLabel = ValueNotifier(null);
  Timer? _zoomLabelTimer;
  Offset? _focusPoint;
  Timer? _focusTimer;

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
  _StoryFlash _flash = _StoryFlash.off;

  // ── Repost de post remoto (initialRemoteUrl) ────────────────────────
  /// True enquanto a tela está em modo "repost" (mídia remota baixando).
  /// Nesse modo NÃO mostramos o picker da câmera — só um loader dedicado.
  bool _isRepostMode = false;
  String? _remoteError;

  /// Story "só texto" (placeholder PNG + fundo gradiente no editor).
  bool _isTextOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _recordTicker?.cancel();
    _zoomLabelTimer?.cancel();
    _focusTimer?.cancel();
    _zoomLabel.dispose();
    _videoCtrl?.dispose();
    _camCtrl?.dispose();
    ref.read(soundPlayerViewModelProvider.notifier).stop();
    super.dispose();
  }

  /// Abre o catálogo do Brawe Sounds para escolher uma música pro story.
  /// Reaproveita a mesma tela usada em `create_post_sheet.dart`.
  Future<void> _pickSound() async {
    ref.read(soundPlayerViewModelProvider.notifier).stop();
    final sound = await Navigator.of(context).push<Sound>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const SoundsCatalogScreen(),
      ),
    );
    if (sound != null && mounted) {
      ref.read(soundPlayerViewModelProvider.notifier).stop();
      await _openTrimScreen(sound);
    }
  }

  /// Abre a tela de trim para o usuário escolher o trecho ESPECÍFICO
  /// deste story.
  Future<void> _openTrimScreen(Sound sound) async {
    final result = await SoundTrimScreen.push(
      context,
      sound: sound,
      maxDuration: _kMaxSoundTrim,
    );
    if (result != null && mounted) {
      setState(() {
        _selectedSound = sound;
        _soundTrimStartMs = result.trimStartMs;
        _soundTrimEndMs = result.trimEndMs;
        // Nova faixa — reseta o mix de volumes para o default (1.0/1.0)
        // em vez de herdar valores de uma faixa anterior removida.
        _soundVolume = 1.0;
        _originalAudioVolume = 1.0;
      });
    }
  }

  /// Reabre a tela de trim para AJUSTAR o trecho de uma música já
  /// selecionada (tap no chip).
  Future<void> _editTrim() async {
    final sound = _selectedSound;
    if (sound == null) return;
    await _openTrimScreen(sound);
  }

  void _removeSound() {
    ref.read(soundPlayerViewModelProvider.notifier).stop();
    setState(() {
      _selectedSound = null;
      _soundTrimStartMs = 0;
      _soundTrimEndMs = null;
      _soundVolume = 1.0;
      _originalAudioVolume = 1.0;
    });
  }

  /// Fase D: abre o mixer de volumes (música anexada × áudio original do
  /// vídeo) com preview em tempo real — ajusta o volume do
  /// `SoundPlayerViewModel` (música) e do `VideoPlayerController` local
  /// (áudio original) enquanto o usuário arrasta os sliders, e persiste
  /// os valores finais em [_soundVolume]/[_originalAudioVolume] para
  /// envio no payload existente de `createStory` (restauração ao reabrir
  /// a edição não se aplica aqui — story é criado uma única vez — mas os
  /// valores ficam disponíveis para o `_StoryEditor` durante toda a
  /// sessão de composição).
  Future<void> _openVolumeMixer() async {
    if (_selectedSound == null) return;
    HapticFeedback.selectionClick();
    await VolumeMixerSheet.show(
      context,
      initialMusicVolume: _soundVolume,
      initialOriginalVolume: _originalAudioVolume,
      musicTitle: _selectedSound!.title,
      onMusicVolumeChanged: (v) {
        setState(() => _soundVolume = v);
        ref.read(soundPlayerViewModelProvider.notifier).setVolume(v);
      },
      onOriginalVolumeChanged: (v) {
        setState(() => _originalAudioVolume = v);
        _videoCtrl?.setVolume(v);
      },
    );
  }

  /// Inicializa a câmera na direção pedida (default: a atual, frontal no
  /// 1º acesso). Escolhe a PRIMEIRA lente daquela direção — devices com
  /// várias lentes traseiras não caem na ultra-wide/tele por índice.
  Future<void> _initCameraPreview({CameraLensDirection? lens}) async {
    final gen = ++_camGeneration;
    final target = lens ?? _lens;
    if (mounted) {
      setState(() {
        _camInitializing = true;
        _camPermissionDenied = false;
      });
    }
    try {
      if (_cameras.isEmpty) _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted && gen == _camGeneration) {
          setState(() {
            _camAvailable = false;
            _camInitializing = false;
          });
        }
        return;
      }
      final cam = _cameras.firstWhere(
        (c) => c.lensDirection == target,
        orElse: () => _cameras.first,
      );
      final ctrl = CameraController(
        cam,
        _kCameraResolution,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _camInitFuture = ctrl.initialize();
      await _camInitFuture;
      // Corrida: a tela mudou (editor aberto, flip, app pausado) enquanto
      // inicializava → descarta este controller.
      if (!mounted || gen != _camGeneration || _file != null) {
        await ctrl.dispose();
        return;
      }
      var minZ = 1.0;
      var maxZ = 1.0;
      try {
        minZ = await ctrl.getMinZoomLevel();
        maxZ = await ctrl.getMaxZoomLevel();
      } catch (_) {}
      try {
        await ctrl.setFlashMode(FlashMode.off);
      } catch (_) {}
      if (!mounted || gen != _camGeneration) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _camCtrl = ctrl;
        _camAvailable = true;
        _camInitializing = false;
        _lens = cam.lensDirection;
        _minZoom = minZ;
        _maxZoom = math.max(minZ, math.min(maxZ, 10.0));
        _zoom = minZ;
        _flash = _StoryFlash.off;
      });
    } on CameraException catch (e) {
      debugPrint('[StoryComposer] Camera init: ${e.code} ${e.description}');
      if (!mounted || gen != _camGeneration) return;
      setState(() {
        _camAvailable = false;
        _camInitializing = false;
        _camPermissionDenied = _kPermissionErrorCodes.contains(e.code);
      });
    } catch (_) {
      // Sem câmera (simulador) → fallback gradiente + galeria/texto.
      if (!mounted || gen != _camGeneration) return;
      setState(() {
        _camAvailable = false;
        _camInitializing = false;
      });
    }
  }

  static const Set<String> _kPermissionErrorCodes = {
    'CameraAccessDenied',
    'CameraAccessDeniedWithoutPrompt',
    'CameraAccessRestricted',
    'AudioAccessDenied',
    'AudioAccessDeniedWithoutPrompt',
    'AudioAccessRestricted',
    'cameraPermission',
  };

  Future<void> _stopCameraPreview() async {
    _camGeneration++;
    final c = _camCtrl;
    _camCtrl = null;
    _camAvailable = false;
    await c?.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Só no picker (editor/repost não usam a câmera).
    if (_file != null || _isRepostMode) return;
    if (state == AppLifecycleState.paused) {
      if (!_isRecording && _camCtrl != null) {
        _stopCameraPreview().then((_) {
          if (mounted) setState(() {});
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      // Também cobre a volta dos Ajustes após liberar a permissão.
      if (_camCtrl == null) _initCameraPreview();
    }
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
      // Flash "on" em vídeo = lanterna durante a gravação.
      if (_flash == _StoryFlash.on && _isBackCamera) {
        try {
          await ctrl.setFlashMode(FlashMode.torch);
        } catch (_) {}
      }
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
      if (_flash == _StoryFlash.on) {
        try {
          await ctrl.setFlashMode(_flashModeFor(_flash));
        } catch (_) {}
      }
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

  bool get _isBackCamera =>
      _camCtrl?.description.lensDirection == CameraLensDirection.back;

  bool get _canFlip =>
      _cameras.any((c) => c.lensDirection == CameraLensDirection.front) &&
      _cameras.any((c) => c.lensDirection == CameraLensDirection.back);

  FlashMode _flashModeFor(_StoryFlash f) => switch (f) {
    _StoryFlash.off => FlashMode.off,
    _StoryFlash.auto => FlashMode.auto,
    _StoryFlash.on => FlashMode.always,
  };

  /// off → auto → on (só câmera traseira; o botão some na frontal).
  Future<void> _cycleFlash() async {
    final ctrl = _camCtrl;
    if (ctrl == null || !ctrl.value.isInitialized || _isRecording) return;
    final next = _StoryFlash.values[(_flash.index + 1) % 3];
    try {
      await ctrl.setFlashMode(_flashModeFor(next));
    } catch (_) {
      return;
    }
    HapticFeedback.selectionClick();
    if (mounted) setState(() => _flash = next);
  }

  /// Alterna entre a primeira câmera frontal e a primeira traseira.
  /// Zoom volta ao mínimo e o flash desliga (controller novo).
  Future<void> _flipCamera() async {
    if (_isRecording || _camInitializing || !_canFlip) return;
    HapticFeedback.selectionClick();
    final next = _lens == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    await _stopCameraPreview();
    if (!mounted) return;
    setState(() {
      _lens = next;
      _focusPoint = null;
    });
    await _initCameraPreview(lens: next);
  }

  // ── Pinch-zoom / tap-to-focus no preview ─────────────────────────────
  void _onPreviewScaleStart(ScaleStartDetails d) => _zoomBase = _zoom;

  void _onPreviewScaleUpdate(ScaleUpdateDetails d) {
    final ctrl = _camCtrl;
    if (ctrl == null || !ctrl.value.isInitialized || d.pointerCount < 2) {
      return;
    }
    final z = (_zoomBase * d.scale).clamp(_minZoom, _maxZoom);
    if ((z - _zoom).abs() < 0.01) return;
    _zoom = z;
    _zoomLabel.value = z;
    _applyZoom(ctrl, z);
  }

  void _onPreviewScaleEnd(ScaleEndDetails _) {
    _zoomLabelTimer?.cancel();
    _zoomLabelTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) _zoomLabel.value = null;
    });
  }

  Future<void> _applyZoom(CameraController ctrl, double z) async {
    try {
      await ctrl.setZoomLevel(z);
    } catch (_) {}
  }

  Future<void> _onPreviewTapUp(TapUpDetails d, Size size) async {
    final ctrl = _camCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    setState(() => _focusPoint = d.localPosition);
    _focusTimer?.cancel();
    _focusTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _focusPoint = null);
    });
    // Converte o ponto do canvas (cover) para o frame inteiro do preview.
    final pv = ctrl.value.previewSize;
    var p = Offset(
      d.localPosition.dx / size.width,
      d.localPosition.dy / size.height,
    );
    if (pv != null && pv.width > 0 && pv.height > 0) {
      final pw = pv.height; // preview em retrato
      final ph = pv.width;
      final scale = math.max(size.width / pw, size.height / ph);
      final dw = pw * scale;
      final dh = ph * scale;
      p = Offset(
        (d.localPosition.dx - (size.width - dw) / 2) / dw,
        (d.localPosition.dy - (size.height - dh) / 2) / dh,
      );
    }
    p = Offset(p.dx.clamp(0.0, 1.0), p.dy.clamp(0.0, 1.0));
    try {
      if (ctrl.value.focusPointSupported) await ctrl.setFocusPoint(p);
      if (ctrl.value.exposurePointSupported) await ctrl.setExposurePoint(p);
    } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    // Foto ou vídeo: ImagePicker não tem combinado; usamos pickMedia.
    final x = await ImagePicker().pickMedia();
    if (x == null) return;
    final isVid = _looksLikeVideo(x.path);
    await _setSelected(File(x.path), isVideo: isVid);
  }

  Future<void> _publish({
    String? caption,
    File? flattenedImage,
    File? overlayImage,
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
            // Caption e música apenas no primeiro segmento (padrão Instagram)
            caption: i == 0 ? caption : null,
            originPostId: widget.initialOriginPostId,
            idempotencyKey: '$_idempotencyKey:$i',
            soundId: i == 0 ? _selectedSound?.id : null,
            soundTrimStartMs: i == 0 ? _soundTrimStartMs : 0,
            soundTrimEndMs: i == 0 ? _soundTrimEndMs : null,
            soundVolume: i == 0 ? _soundVolume : 1.0,
            originalAudioVolume: i == 0 ? _originalAudioVolume : 1.0,
            // Textos do editor (PNG transparente) — só no 1º segmento.
            overlayPath: i == 0 ? overlayImage?.path : null,
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
          soundId: _selectedSound?.id,
          soundTrimStartMs: _soundTrimStartMs,
          soundTrimEndMs: _soundTrimEndMs,
          // Fase D: mix de volumes definido pelo usuário no
          // `VolumeMixerSheet` (default 1.0/1.0 quando não ajustado).
          soundVolume: _soundVolume,
          originalAudioVolume: _originalAudioVolume,
          // Vídeo: camadas de texto como PNG transparente 9:16 que o
          // viewer desenha por cima (null em foto/sem textos).
          overlayPath: overlayImage?.path,
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
      // Também tratamos 500 (`badResponse`) como AMBÍGUO: o endpoint
      // POST /stories/upload faz o commit principal do story e SÓ DEPOIS
      // roda passos "extra" (incrementar contagem de uso da música,
      // buscar preview da faixa para a resposta). Se qualquer um desses
      // passos pós-commit falhar no servidor, o cliente recebe 500 —
      // mas o story JÁ ESTÁ publicado e visível no feed. Sem essa
      // heurística, o usuário via "falha ao publicar" para um story que
      // na verdade foi criado com sucesso (bug relatado: "story aparece
      // como erro, mas já está publicado quando eu vou ver").
      //
      // Em todos os outros casos (4xx, sem rede, etc) é uma falha real
      // e podemos liberar o lock pra ele tentar de novo (com a mesma
      // idempotency key — backend deduplicará se já gravou).
      if (!mounted) return;
      final isTimeout =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      final isServerError =
          e.type == DioExceptionType.badResponse &&
          (e.response?.statusCode ?? 0) >= 500;
      if (isTimeout || isServerError) {
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        // O editor posiciona o modo texto acima do teclado via viewInsets;
        // sem isso o canvas 9:16 encolheria quando o teclado abre.
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          top: false,
          child: _file != null
              ? _buildEditor()
              : (_isRepostMode ? _buildRepostLoader() : _buildPicker()),
        ),
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
              colors: [Color(0xFF0B0F1A), Color(0xFF0B1A3D), Color(0xFF0B0F1A)],
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
                      color: AppColors.braweBlue,
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

  /// Captura (UI 2026): preview full-bleed no MESMO canvas 9:16 do editor,
  /// X + flash no topo, anel de captura com galeria (esq.) e virar câmera
  /// (dir.), e o seletor de modo "STORY · TEXTO" abaixo.
  Widget _buildPicker() {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        SizedBox(height: topPad + 4),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LayoutBuilder(
                  builder: (_, c) => _buildCameraCanvas(c.biggest),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 68,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _isRecording ? 0 : 1,
            child: IgnorePointer(
              ignoring: _isRecording,
              child: _ModeSwitcher(
                storyLabel: S.of(context).composerModeStory,
                textLabel: S.of(context).composerModeText,
                onText: _createTextOnly,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraCanvas(Size size) {
    final s = S.of(context);
    final ctrl = _camCtrl;
    final ready = _camAvailable && ctrl != null && ctrl.value.isInitialized;
    final focus = _focusPoint;

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B0F1A), Color(0xFF0B1A3D), Color(0xFF0B0F1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        if (ready)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) => _onPreviewTapUp(d, size),
            onDoubleTap: _flipCamera,
            onScaleStart: _onPreviewScaleStart,
            onScaleUpdate: _onPreviewScaleUpdate,
            onScaleEnd: _onPreviewScaleEnd,
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: ctrl.value.previewSize?.height ?? 1,
                  height: ctrl.value.previewSize?.width ?? 1,
                  child: CameraPreview(ctrl),
                ),
              ),
            ),
          )
        else if (_camPermissionDenied)
          _CameraPermissionView(
            title: s.composerCameraPermissionTitle,
            body: s.composerCameraPermissionBody,
            action: s.composerOpenSettings,
            onOpenSettings: openAppSettings,
          )
        else if (!_camInitializing)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.videocam_off_outlined,
                  color: Colors.white54,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  s.composerNoCamera,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

        // Vinheta sutil para legibilidade dos controles.
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x59000000),
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0x66000000),
                ],
                stops: [0.0, 0.18, 0.7, 1.0],
              ),
            ),
          ),
        ),

        if (focus != null)
          Positioned(
            left: focus.dx - 32,
            top: focus.dy - 32,
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.4, end: 1.0),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ),
          ),

        // Topo: X (esq.) e flash (dir., só câmera traseira).
        if (!_isRecording) ...[
          Positioned(
            top: 6,
            left: 4,
            child: _RailButton(
              tooltip: s.composerClose,
              onTap: () => Navigator.of(context).maybePop(),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 28,
                shadows: _kIconShadows,
              ),
            ),
          ),
          if (ready && _isBackCamera)
            Positioned(
              top: 6,
              right: 4,
              child: _RailButton(
                tooltip: s.composerFlash,
                onTap: _cycleFlash,
                child: Icon(
                  switch (_flash) {
                    _StoryFlash.off => Icons.flash_off_rounded,
                    _StoryFlash.auto => Icons.flash_auto_rounded,
                    _StoryFlash.on => Icons.flash_on_rounded,
                  },
                  color: _flash == _StoryFlash.on
                      ? AppColors.gold
                      : Colors.white,
                  size: 26,
                  shadows: _kIconShadows,
                ),
              ),
            ),
        ],

        // Timer de gravação.
        if (_isRecording)
          Positioned(
            top: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mutedRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatRecordTime(
                    _previousSegmentsTotal + _currentSegmentElapsed,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),

        // Indicador de zoom.
        Positioned(
          left: 0,
          right: 0,
          bottom: 132,
          child: IgnorePointer(
            child: ValueListenableBuilder<double?>(
              valueListenable: _zoomLabel,
              builder: (_, z, _) => AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: z == null ? 0 : 1,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(z ?? 1).toStringAsFixed(1)}x',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Base: galeria · anel · virar câmera.
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opacidade (não remoção) → o anel não "pula" ao gravar.
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: ready && !_isRecording ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    s.composerCaptureHint,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      shadows: _kIconShadows,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: _isRecording
                          ? const SizedBox.shrink()
                          : _GalleryButton(
                              tooltip: s.composerGallery,
                              onTap: _pickFromGallery,
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : ready
                        ? _CaptureRing(
                            isRecording: _isRecording,
                            segmentProgress:
                                (_currentSegmentElapsed.inMilliseconds /
                                        _kSegmentMax.inMilliseconds)
                                    .clamp(0.0, 1.0),
                            totalProgress:
                                ((_previousSegmentsTotal +
                                                _currentSegmentElapsed)
                                            .inMilliseconds /
                                        _kTotalMax.inMilliseconds)
                                    .clamp(0.0, 1.0),
                            segmentBreaks: const [],
                            onTap: _capturePhoto,
                            onLongPressStart: _startRecording,
                            onLongPressEnd: () => _stopRecording(),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: Center(
                      child: _isRecording || !_canFlip
                          ? const SizedBox.shrink()
                          : _RoundGlassButton(
                              tooltip: s.composerFlipCamera,
                              icon: Icons.cameraswitch_rounded,
                              onTap: _flipCamera,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    // Antes do _setSelected: o editor precisa nascer já em modo "só texto".
    _isTextOnly = true;
    await _setSelected(tmp, isVideo: false);
  }

  Widget _buildEditor() {
    return _StoryEditor(
      file: _file!,
      isVideo: _isVideo,
      isTextOnly: _isTextOnly,
      videoCtrl: _videoCtrl,
      isPublishing: _isPublishing,
      isRepost: _isRepostMode,
      avatarUrl: ref.watch(authStateProvider).value?.avatarUrl,
      selectedSound: _selectedSound,
      onPickSound: _pickSound,
      onEditSoundTrim: _editTrim,
      onRemoveSound: _removeSound,
      onOpenVolumeMixer: _openVolumeMixer,
      onBack: () async {
        // Repost: não há câmera/picker para voltar — fecha a tela.
        if (_isRepostMode) {
          Navigator.of(context).pop();
          return;
        }
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
          _isTextOnly = false;
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
                      : const [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isRecording
                        ? Colors.redAccent.withValues(alpha: 0.55)
                        : Colors.black.withValues(alpha: 0.25),
                    blurRadius: isRecording ? 22 : 12,
                    spreadRadius: isRecording ? 2 : 0,
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
            AppColors.braweBlue,
            AppColors.braweSky,
            AppColors.braweBlue,
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

// ─── Captura: widgets ────────────────────────────────────────────────────────

enum _StoryFlash { off, auto, on }

/// Seletor de modo estilo Instagram: "STORY · TEXTO".
class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({
    required this.storyLabel,
    required this.textLabel,
    required this.onText,
  });

  final String storyLabel;
  final String textLabel;
  final VoidCallback onText;

  @override
  Widget build(BuildContext context) {
    TextStyle style(bool selected) => TextStyle(
      color: selected ? Colors.white : Colors.white54,
      fontSize: 13,
      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      letterSpacing: 1.2,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          selected: true,
          button: true,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(storyLabel.toUpperCase(), style: style(true)),
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.white38,
            shape: BoxShape.circle,
          ),
        ),
        Semantics(
          button: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              onText();
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(textLabel.toUpperCase(), style: style(false)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CameraPermissionView extends StatelessWidget {
  const _CameraPermissionView({
    required this.title,
    required this.body,
    required this.action,
    required this.onOpenSettings,
  });

  final String title;
  final String body;
  final String action;
  final Future<bool> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: Colors.white70,
              size: 44,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => onOpenSettings(),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(
                action,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryButton extends StatelessWidget {
  const _GalleryButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.photo_library_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundGlassButton extends StatelessWidget {
  const _RoundGlassButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.35),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
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

// ─── Editor pós-captura (UI 2026: canvas 9:16 + tool rail vertical) ─────────
//
// Estrutura:
//  • Canvas 9:16 com cantos arredondados, centralizado entre o topo e a
//    bottom bar — é EXATAMENTE o enquadramento que o viewer mostra.
//  • Dentro do canvas:
//      [_flatKey] RepaintBoundary → fundo + mídia (+ transform da foto)
//                                   + [_overlayKey] RepaintBoundary → camadas
//      Superfície de gestos (uma só: decide se o gesto é de uma camada de
//      texto ou da mídia), guias de snap, lixeira, chrome (X, rail, música).
//  • Publicação:
//      FOTO  → flatten de [_flatKey] em 1080×1920 → `flattenedImage`.
//      VÍDEO → só as camadas ([_overlayKey], fundo transparente) em
//              1080×1920 → `overlayImage` (o viewer desenha por cima).
//  • Performance: gestos atualizam um ChangeNotifier ([_CanvasStore]) e
//    um ValueNotifier ([_MediaXform]) — o State do editor NÃO faz setState
//    por frame, então vídeo/imagem não são reconstruídos durante o arrasto.

/// Largura do export (flatten/overlay) — 1080×1920 para o canvas 9:16.
const double _kExportWidth = 1080;

/// Tamanho base do texto relativo à LARGURA do canvas (≈28pt num canvas de
/// 390pt). Tudo relativo → mesmo layout em qualquer tela e no export.
const double _kBaseFontFactor = 0.072;
const double _kTextMaxWidthFactor = 0.86;
const double _kMinFontScale = 0.5;
const double _kMaxFontScale = 2.4;
const double _kSnapDistancePx = 8;
const double _kTrashSize = 56;
const double _kTrashBottom = 20;
const double _kCanvasRadius = 16;

const LinearGradient _kBrandGradient = LinearGradient(
  colors: [AppColors.braweBlue, AppColors.braweSky],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const List<Shadow> _kIconShadows = [
  Shadow(color: Color(0x73000000), blurRadius: 8, offset: Offset(0, 1)),
];

/// Fundos do story "só texto" (cicla no botão de swatch do rail).
const List<Gradient> _kTextBackgrounds = [
  LinearGradient(
    colors: [AppColors.braweDeep, AppColors.braweBlue, AppColors.braweSky],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [AppColors.brandPink, AppColors.amber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [AppColors.midnightBlue, AppColors.braweSky],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
  LinearGradient(
    colors: [AppColors.success, AppColors.braweSky],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [AppColors.braweBlueSoft, AppColors.braweBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
  LinearGradient(
    colors: [AppColors.gold, AppColors.mutedRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [AppColors.darkSurfaceHighest, AppColors.darkBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
  LinearGradient(colors: [Colors.black, Colors.black]),
];

enum _StoryFont { classic, modern, serif, typewriter, neon }

enum _TextBg { none, translucent, solid }

enum _GestureTarget { none, layer, media }

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
    this.isTextOnly = false,
    this.avatarUrl,
    this.selectedSound,
    required this.onPickSound,
    required this.onEditSoundTrim,
    required this.onRemoveSound,
    required this.onOpenVolumeMixer,
  });

  final File file;
  final bool isVideo;
  final VideoPlayerController? videoCtrl;
  final bool isPublishing;
  final bool isRepost;

  /// Story "só texto": fundo gradiente Brawe (a mídia é um PNG 1×1
  /// transparente placeholder) e o modo texto abre automaticamente.
  final bool isTextOnly;

  /// Avatar do usuário logado (pill "Seu story").
  final String? avatarUrl;
  final VoidCallback onBack;

  /// FOTO: [flattenedImage] = PNG 1080×1920 (mídia + transform + textos).
  /// VÍDEO: [overlayImage] = PNG transparente 1080×1920 só com os textos
  /// (null se não houver camadas).
  final Future<void> Function({
    String? caption,
    File? flattenedImage,
    File? overlayImage,
  })
  onPublish;

  /// Abre a tela de trim — implementada pelo parent
  /// (`_StoryComposerScreenState`), porque é ele quem detém o
  /// `VideoPlayerController` e precisa recriá-lo após o corte.
  final Future<void> Function() onTrim;

  /// Brawe Sound: música anexada ao story (opcional), e callbacks para
  /// selecionar/remover — implementados pelo parent (que detém o player).
  final Sound? selectedSound;
  final Future<void> Function() onPickSound;

  /// Reabre a tela de trim para ajustar o trecho da música já selecionada
  /// (tap no chip).
  final Future<void> Function() onEditSoundTrim;
  final VoidCallback onRemoveSound;

  /// Fase D: abre o `VolumeMixerSheet` (só em vídeo com música).
  final Future<void> Function() onOpenVolumeMixer;

  @override
  State<_StoryEditor> createState() => _StoryEditorState();
}

class _StoryEditorState extends State<_StoryEditor> {
  // ── Estado do canvas (notificado sem setState) ───────────────────────
  final _CanvasStore _store = _CanvasStore();
  final ValueNotifier<_MediaXform> _xform = ValueNotifier(
    const _MediaXform.identity(),
  );
  final Map<String, GlobalKey> _layerKeys = {};
  int _layerSeq = 0;

  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _flatKey = GlobalKey();
  final GlobalKey _overlayKey = GlobalKey();
  Size _canvasSize = Size.zero;

  // ── Gestos ───────────────────────────────────────────────────────────
  _GestureTarget _target = _GestureTarget.none;
  Offset _lastFocal = Offset.zero;
  Offset _rawCenter = const Offset(0.5, 0.5);
  double _baseScale = 1;
  double _baseRotation = 0;
  double _mediaBaseScale = 1;
  Offset _mediaAnchor = Offset.zero;

  // ── Modo texto (compose) ─────────────────────────────────────────────
  bool _composing = false;
  final TextEditingController _composeCtrl = TextEditingController();
  Color _cColor = Colors.white;
  _TextBg _cBg = _TextBg.none;
  TextAlign _cAlign = TextAlign.center;
  _StoryFont _cFont = _StoryFont.classic;
  double _cFontScale = 1.0;

  // ── Outros ───────────────────────────────────────────────────────────
  /// 0 = nenhuma, 1 = polaroid, 2 = gradiente Brawe (só foto).
  int _frameStyle = 0;

  /// Índice em [_kTextBackgrounds] (só no story "só texto").
  int _bgIndex = 0;
  bool _isSavingToDevice = false;
  bool _exporting = false;
  final ValueNotifier<String?> _toast = ValueNotifier(null);
  Timer? _toastTimer;

  static const List<Color> _palette = [
    Colors.white,
    Colors.black,
    AppColors.braweBlue,
    AppColors.braweSky,
    AppColors.brandPink,
    AppColors.mutedRed,
    AppColors.amber,
    AppColors.gold,
    AppColors.success,
    AppColors.braweBlueSoft,
    AppColors.midnightBlue,
  ];

  bool get _canTransformMedia => !widget.isVideo && !widget.isTextOnly;
  bool get _canFrame => !widget.isVideo && !widget.isTextOnly;

  bool get _hasEdits =>
      _store.layers.isNotEmpty ||
      _frameStyle != 0 ||
      _bgIndex != 0 ||
      !_xform.value.isIdentity ||
      widget.selectedSound != null;

  @override
  void initState() {
    super.initState();
    if (widget.isTextOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openCompose();
      });
    }
  }

  @override
  void dispose() {
    _composeCtrl.dispose();
    _store.dispose();
    _xform.dispose();
    _toast.dispose();
    _toastTimer?.cancel();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // Camadas de texto
  // ═══════════════════════════════════════════════════════════════════

  GlobalKey _keyFor(String id) => _layerKeys.putIfAbsent(id, GlobalKey.new);

  _TextLayer? _layerById(String? id) {
    if (id == null) return null;
    final i = _store.indexOf(id);
    return i < 0 ? null : _store.layers[i];
  }

  void _openCompose([_TextLayer? layer]) {
    if (widget.isPublishing || _exporting) return;
    _composeCtrl.text = layer?.text ?? '';
    _composeCtrl.selection = TextSelection.collapsed(
      offset: _composeCtrl.text.length,
    );
    if (layer != null) {
      _cColor = layer.color;
      _cBg = layer.bg;
      _cAlign = layer.align;
      _cFont = layer.font;
      _cFontScale = layer.fontScale;
    }
    // Camadas novas herdam o último estilo usado (padrão Instagram).
    _store
      ..editingId = layer?.id
      ..changed();
    setState(() => _composing = true);
  }

  void _commitCompose() {
    if (!_composing) return;
    final txt = _composeCtrl.text.trim();
    final editing = _layerById(_store.editingId);
    if (editing != null) {
      final i = _store.indexOf(editing.id);
      if (txt.isEmpty) {
        _store.layers.removeAt(i);
        _layerKeys.remove(editing.id);
      } else {
        _store.layers[i] = editing.copyWith(
          text: txt,
          color: _cColor,
          bg: _cBg,
          align: _cAlign,
          font: _cFont,
          fontScale: _cFontScale,
        );
      }
    } else if (txt.isNotEmpty) {
      _store.layers.add(
        _TextLayer(
          id: 'l${_layerSeq++}',
          text: txt,
          color: _cColor,
          bg: _cBg,
          align: _cAlign,
          font: _cFont,
          fontScale: _cFontScale,
        ),
      );
    }
    _store
      ..editingId = null
      ..changed();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _composing = false);
  }

  String? _hitLayer(Offset global) {
    for (final l in _store.layers.reversed) {
      if (l.id == _store.editingId) continue;
      final box = _layerKeys[l.id]?.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final local = box.globalToLocal(global);
      // Tolerância extra (em px de tela) para textos pequenos.
      final slop = 14 / l.scale.clamp(0.5, 4.0);
      if ((Offset.zero & box.size).inflate(slop).contains(local)) return l.id;
    }
    return null;
  }

  RenderBox? get _canvasBox {
    final r = _canvasKey.currentContext?.findRenderObject();
    return r is RenderBox && r.hasSize ? r : null;
  }

  Offset _trashCenter(Size size) =>
      Offset(size.width / 2, size.height - _kTrashBottom - _kTrashSize / 2);

  void _onTapUp(TapUpDetails d) {
    if (_target != _GestureTarget.none) return;
    final hit = _hitLayer(d.globalPosition);
    _openCompose(_layerById(hit));
  }

  void _onScaleStart(ScaleStartDetails d) {
    if (_target == _GestureTarget.layer &&
        _layerById(_store.activeId) == null) {
      _target = _GestureTarget.none;
    }
    if (_target == _GestureTarget.none) {
      final hit = _hitLayer(d.focalPoint);
      if (hit != null) {
        _target = _GestureTarget.layer;
        // Traz a camada para frente.
        final i = _store.indexOf(hit);
        _store.layers.add(_store.layers.removeAt(i));
        _store.activeId = hit;
        HapticFeedback.selectionClick();
      } else if (_canTransformMedia) {
        _target = _GestureTarget.media;
      } else {
        return;
      }
    }

    // (Re)base — também chamado quando o nº de dedos muda no meio do gesto.
    if (_target == _GestureTarget.layer) {
      final l = _layerById(_store.activeId)!;
      _lastFocal = d.focalPoint;
      _rawCenter = l.center;
      _baseScale = l.scale;
      _baseRotation = l.rotation;
    } else if (_target == _GestureTarget.media) {
      final box = _canvasBox;
      if (box == null) return;
      final local =
          box.globalToLocal(d.focalPoint) - box.size.center(Offset.zero);
      final x = _xform.value;
      _mediaBaseScale = x.scale;
      _mediaAnchor = (local - x.offset) / x.scale;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final box = _canvasBox;
    if (box == null) return;
    final size = box.size;

    if (_target == _GestureTarget.layer) {
      final l = _layerById(_store.activeId);
      if (l == null) return;
      final delta = d.focalPoint - _lastFocal;
      _lastFocal = d.focalPoint;
      _rawCenter += Offset(delta.dx / size.width, delta.dy / size.height);

      var c = _rawCenter;
      final snapX = ((c.dx - 0.5) * size.width).abs() < _kSnapDistancePx;
      final snapY = ((c.dy - 0.5) * size.height).abs() < _kSnapDistancePx;
      if (snapX) c = Offset(0.5, c.dy);
      if (snapY) c = Offset(c.dx, 0.5);
      if ((snapX && !_store.snapX) || (snapY && !_store.snapY)) {
        HapticFeedback.selectionClick();
      }
      c = Offset(c.dx.clamp(-0.1, 1.1), c.dy.clamp(-0.1, 1.1));

      var rot = _baseRotation + d.rotation;
      if (rot.abs() < 0.05) rot = 0;

      final local = box.globalToLocal(d.focalPoint);
      final hover =
          (local - _trashCenter(size)).distance < _kTrashSize / 2 + 28;
      if (hover != _store.hoverTrash) HapticFeedback.mediumImpact();

      _store.layers[_store.indexOf(l.id)] = l.copyWith(
        center: c,
        scale: (_baseScale * d.scale).clamp(0.25, 6.0),
        rotation: rot,
      );
      _store
        ..dragging = true
        ..hoverTrash = hover
        ..snapX = snapX
        ..snapY = snapY
        ..changed();
    } else if (_target == _GestureTarget.media) {
      final local = box.globalToLocal(d.focalPoint) - size.center(Offset.zero);
      final s = (_mediaBaseScale * d.scale).clamp(0.3, 6.0);
      var t = local - _mediaAnchor * s;
      final snapX = t.dx.abs() < _kSnapDistancePx;
      final snapY = t.dy.abs() < _kSnapDistancePx;
      if (snapX) t = Offset(0, t.dy);
      if (snapY) t = Offset(t.dx, 0);
      if ((snapX && !_store.snapX) || (snapY && !_store.snapY)) {
        HapticFeedback.selectionClick();
      }
      _xform.value = _MediaXform(scale: s, offset: t);
      if (snapX != _store.snapX || snapY != _store.snapY || !_store.guides) {
        _store
          ..snapX = snapX
          ..snapY = snapY
          ..guides = true
          ..changed();
      }
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    // Dedos mudaram no meio do gesto: o recognizer chama onStart de novo
    // (rebase) — não finaliza aqui.
    if (d.pointerCount > 0) return;
    if (_target == _GestureTarget.layer && _store.hoverTrash) {
      final id = _store.activeId;
      if (id != null) {
        _store.layers.removeWhere((l) => l.id == id);
        _layerKeys.remove(id);
        HapticFeedback.heavyImpact();
      }
    }
    _target = _GestureTarget.none;
    _store
      ..activeId = null
      ..dragging = false
      ..hoverTrash = false
      ..snapX = false
      ..snapY = false
      ..guides = false
      ..changed();
  }

  // ═══════════════════════════════════════════════════════════════════
  // Ações
  // ═══════════════════════════════════════════════════════════════════

  void _showToast(String text) {
    _toastTimer?.cancel();
    _toast.value = text;
    _toastTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) _toast.value = null;
    });
  }

  void _cycleFrame() {
    setState(() => _frameStyle = (_frameStyle + 1) % 3);
    HapticFeedback.selectionClick();
    final s = S.of(context);
    final label = switch (_frameStyle) {
      1 => s.composerFramePolaroid,
      2 => s.composerFrameBrawe,
      _ => s.composerFrameNone,
    };
    _showToast(_frameStyle == 0 ? label : s.composerFrameLabel(label));
  }

  void _resetTransform() {
    _xform.value = const _MediaXform.identity();
    HapticFeedback.selectionClick();
  }

  Future<void> _handleClose() async {
    if (widget.isPublishing || _exporting) return;
    if (_composing) {
      _commitCompose();
      return;
    }
    if (_hasEdits) {
      final discard = await _confirmDiscard();
      if (discard != true || !mounted) return;
    }
    widget.onBack();
  }

  Future<bool?> _confirmDiscard() {
    final s = S.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: AlertDialog(
          backgroundColor: AppColors.darkSurfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(s.composerDiscardTitle),
          content: Text(s.composerDiscardMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                s.composerKeepEditing,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                s.composerDiscard,
                style: const TextStyle(
                  color: AppColors.mutedRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renderiza um RepaintBoundary do canvas em PNG 1080×1920.
  Future<File?> _renderBoundary(GlobalKey key, String prefix) async {
    try {
      await WidgetsBinding.instance.endOfFrame;
      final ro = key.currentContext?.findRenderObject();
      if (ro is! RenderRepaintBoundary || !ro.hasSize || ro.size.width <= 0) {
        return null;
      }
      final image = await ro.toImage(pixelRatio: _kExportWidth / ro.size.width);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) return null;
      final dir = await getTemporaryDirectory();
      final out = File(
        '${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await out.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      return out;
    } catch (e, st) {
      debugPrint('[StoryComposer] Render $prefix falhou: $e\n$st');
      return null;
    }
  }

  /// FOTO → flatten (mídia + transform + moldura + textos) → flattenedImage.
  /// VÍDEO → só as camadas (transparente) → overlayImage (null sem camadas).
  Future<void> _publish() async {
    if (widget.isPublishing || _exporting) return;
    if (_composing) _commitCompose();
    setState(() => _exporting = true);
    try {
      if (widget.isVideo) {
        File? overlay;
        if (_store.layers.isNotEmpty) {
          overlay = await _renderBoundary(_overlayKey, 'story_overlay');
          if (overlay == null) {
            if (mounted) {
              AppSnackBar.showError(
                context,
                S.of(context).composerOverlayError,
              );
            }
            return;
          }
        }
        if (!mounted) return;
        await widget.onPublish(overlayImage: overlay);
      } else {
        final flat = await _renderBoundary(_flatKey, 'story_flat');
        if (!mounted) return;
        await widget.onPublish(flattenedImage: flat);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// Salva na galeria: FOTO → flatten (com textos); VÍDEO → arquivo (já
  /// cortado), sem os textos (não há encoder de vídeo no app).
  Future<void> _handleSaveToDevice() async {
    if (_isSavingToDevice) return;
    setState(() => _isSavingToDevice = true);
    try {
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
      if (!widget.isVideo) {
        final flat = await _renderBoundary(_flatKey, 'story_save');
        await Gal.putImage((flat ?? widget.file).path, album: 'Brawe');
      } else {
        await Gal.putVideo(widget.file.path, album: 'Brawe');
      }
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      AppSnackBar.showSuccess(context, S.of(context).composerSavedToDevice);
    } on GalException catch (e, st) {
      debugPrint('[StoryComposer] Gal failed: ${e.type} $st');
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        e.type == GalExceptionType.accessDenied
            ? S.of(context).composerSavePermissionDenied
            : S.of(context).composerSaveError,
      );
    } catch (e, st) {
      debugPrint('[StoryComposer] Save failed: $e\n$st');
      if (!mounted) return;
      AppSnackBar.showError(context, S.of(context).composerSaveError);
    } finally {
      if (mounted) setState(() => _isSavingToDevice = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Build
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final s = S.of(context);
    final busy = widget.isPublishing || _exporting;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleClose();
      },
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                SizedBox(height: topPad + 4),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: LayoutBuilder(
                        builder: (_, c) => _buildCanvas(c.biggest),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 68,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        _StoryDestinationPill(
                          label: s.composerYourStory,
                          avatarUrl: widget.avatarUrl,
                        ),
                        const Spacer(),
                        _SendButton(
                          loading: busy,
                          tooltip: s.composerShare,
                          onPressed: busy ? null : _publish,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_composing) Positioned.fill(child: _buildComposeOverlay()),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas(Size size) {
    _canvasSize = size;
    final media = RepaintBoundary(
      child: _CanvasMedia(
        file: widget.file,
        isVideo: widget.isVideo,
        isTextOnly: widget.isTextOnly,
        videoCtrl: widget.videoCtrl,
        frameStyle: _frameStyle,
      ),
    );

    return ClipRRect(
      key: _canvasKey,
      borderRadius: BorderRadius.circular(_kCanvasRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Conteúdo exportável ──────────────────────────────────
          RepaintBoundary(
            key: _flatKey,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: _CanvasBackground(
                    file: widget.file,
                    isVideo: widget.isVideo,
                    isTextOnly: widget.isTextOnly,
                    gradient: _kTextBackgrounds[_bgIndex],
                  ),
                ),
                if (_canTransformMedia)
                  ValueListenableBuilder<_MediaXform>(
                    valueListenable: _xform,
                    child: media,
                    builder: (_, x, child) => Transform.translate(
                      offset: x.offset,
                      child: Transform.scale(scale: x.scale, child: child),
                    ),
                  )
                else
                  media,
                RepaintBoundary(
                  key: _overlayKey,
                  child: _LayersView(
                    store: _store,
                    canvasWidth: size.width,
                    keyFor: _keyFor,
                  ),
                ),
              ],
            ),
          ),

          // ── Superfície de gestos ─────────────────────────────────
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: _onTapUp,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
            ),
          ),

          // ── Guias de centro + lixeira ────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: ListenableBuilder(
                listenable: _store,
                builder: (_, _) => Stack(
                  fit: StackFit.expand,
                  children: [
                    _CenterGuides(
                      vertical: _store.snapX && _store.isGesturing,
                      horizontal: _store.snapY && _store.isGesturing,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: _kTrashBottom,
                      child: Center(
                        child: _TrashTarget(
                          visible: _store.dragging,
                          hover: _store.hoverTrash,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Toast (moldura) ───────────────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<String?>(
                valueListenable: _toast,
                builder: (_, text, _) => AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: text == null ? 0 : 1,
                  child: Center(child: _Pill(text: text ?? '')),
                ),
              ),
            ),
          ),

          // ── Chrome (some durante drag e no modo texto) ───────────
          if (!_composing)
            Positioned.fill(
              child: ListenableBuilder(
                listenable: _store,
                builder: (_, child) => IgnorePointer(
                  ignoring: _store.dragging,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _store.dragging ? 0 : 1,
                    child: child,
                  ),
                ),
                child: _buildChrome(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChrome() {
    final s = S.of(context);
    final sound = widget.selectedSound;
    return Stack(
      children: [
        Positioned(
          top: 6,
          left: 4,
          child: _RailButton(
            tooltip: s.composerClose,
            onTap: _handleClose,
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 28,
              shadows: _kIconShadows,
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RailButton(
                tooltip: s.composerToolText,
                onTap: () => _openCompose(),
                child: const Text(
                  'Aa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    shadows: _kIconShadows,
                  ),
                ),
              ),
              _RailButton(
                tooltip: s.composerToolMusic,
                onTap: () => widget.onPickSound(),
                badge: sound != null,
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 24,
                  shadows: _kIconShadows,
                ),
              ),
              if (widget.isTextOnly)
                _RailButton(
                  tooltip: s.composerToolBackground,
                  onTap: () => setState(
                    () => _bgIndex = (_bgIndex + 1) % _kTextBackgrounds.length,
                  ),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _kTextBackgrounds[_bgIndex],
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x40000000), blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              if (widget.isVideo)
                _RailButton(
                  tooltip: s.composerToolTrim,
                  onTap: () => widget.onTrim(),
                  child: const Icon(
                    Icons.content_cut_rounded,
                    color: Colors.white,
                    size: 24,
                    shadows: _kIconShadows,
                  ),
                ),
              _RailButton(
                tooltip: s.composerToolSave,
                onTap: _isSavingToDevice ? null : _handleSaveToDevice,
                child: _isSavingToDevice
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 24,
                        shadows: _kIconShadows,
                      ),
              ),
              if (_canFrame)
                _RailButton(
                  tooltip: s.composerToolFrame,
                  onTap: _cycleFrame,
                  badge: _frameStyle != 0,
                  child: Icon(
                    switch (_frameStyle) {
                      1 => Icons.filter_frames_outlined,
                      2 => Icons.auto_awesome_outlined,
                      _ => Icons.crop_square_rounded,
                    },
                    color: Colors.white,
                    size: 24,
                    shadows: _kIconShadows,
                  ),
                ),
              if (_canTransformMedia)
                ValueListenableBuilder<_MediaXform>(
                  valueListenable: _xform,
                  builder: (_, x, _) => x.isIdentity
                      ? const SizedBox.shrink()
                      : _RailButton(
                          tooltip: s.composerToolResetZoom,
                          onTap: _resetTransform,
                          child: const Icon(
                            Icons.fit_screen_rounded,
                            color: Colors.white,
                            size: 24,
                            shadows: _kIconShadows,
                          ),
                        ),
                ),
            ],
          ),
        ),
        if (sound != null)
          Positioned(
            top: 12,
            left: 56,
            right: 56,
            child: Center(
              child: _SelectedStorySoundChip(
                sound: sound,
                onTap: () => widget.onEditSoundTrim(),
                onRemove: widget.onRemoveSound,
                onMixer: widget.isVideo
                    ? () => widget.onOpenVolumeMixer()
                    : null,
                mixerTooltip: s.composerVolumeMix,
              ),
            ),
          ),
      ],
    );
  }

  // ── Overlay do modo texto (Instagram-like) ──────────────────────────
  Widget _buildComposeOverlay() {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    final kb = mq.viewInsets.bottom;
    final topPad = mq.padding.top;
    final canvasW = _canvasSize.width > 0 ? _canvasSize.width : mq.size.width;

    void absorb() {}

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _commitCompose,
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.62),
        child: Stack(
          children: [
            // Campo de texto, centrado na área acima do teclado.
            Positioned(
              left: 44,
              right: 44,
              top: topPad + 64,
              bottom: kb + 72,
              child: Center(
                child: SingleChildScrollView(
                  child: _ComposeTextField(
                    controller: _composeCtrl,
                    color: _cColor,
                    bg: _cBg,
                    align: _cAlign,
                    font: _cFont,
                    fontSize: canvasW * _kBaseFontFactor * _cFontScale,
                    maxWidth: canvasW * _kTextMaxWidthFactor,
                    hint: s.composerTextHint,
                  ),
                ),
              ),
            ),

            // Topo: estilos + Concluir.
            Positioned(
              top: topPad + 8,
              left: 8,
              right: 12,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: absorb,
                child: Row(
                  children: [
                    _RailButton(
                      tooltip: s.composerTextAlignTooltip,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(
                          () => _cAlign = switch (_cAlign) {
                            TextAlign.center => TextAlign.left,
                            TextAlign.left => TextAlign.right,
                            _ => TextAlign.center,
                          },
                        );
                      },
                      child: Icon(
                        switch (_cAlign) {
                          TextAlign.left => Icons.format_align_left_rounded,
                          TextAlign.right => Icons.format_align_right_rounded,
                          _ => Icons.format_align_center_rounded,
                        },
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    _RailButton(
                      tooltip: s.composerTextBackgroundTooltip,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(
                          () => _cBg = _TextBg
                              .values[(_cBg.index + 1) % _TextBg.values.length],
                        );
                      },
                      child: Icon(
                        switch (_cBg) {
                          _TextBg.none => Icons.font_download_off_outlined,
                          _TextBg.translucent => Icons.font_download_outlined,
                          _TextBg.solid => Icons.font_download_rounded,
                        },
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _FontChip(
                      label: _fontLabel(s, _cFont),
                      style: _TextLook.baseFor(_cFont, 15),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(
                          () => _cFont =
                              _StoryFont.values[(_cFont.index + 1) %
                                  _StoryFont.values.length],
                        );
                      },
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _commitCompose,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(
                        s.composerDone,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lateral esquerda: tamanho.
            Positioned(
              left: 4,
              top: topPad + 80,
              height: math.max(140.0, mq.size.height - topPad - 80 - kb - 96),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: absorb,
                child: _FontSizeSlider(
                  value: _cFontScale,
                  min: _kMinFontScale,
                  max: _kMaxFontScale,
                  onChanged: (v) => setState(() => _cFontScale = v),
                ),
              ),
            ),

            // Paleta logo acima do teclado.
            Positioned(
              left: 0,
              right: 0,
              bottom: kb + 12,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: absorb,
                child: _InlineColorPalette(
                  palette: _palette,
                  selected: _cColor,
                  onSelect: (c) => setState(() => _cColor = c),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Estado do canvas ────────────────────────────────────────────────────────

class _CanvasStore extends ChangeNotifier {
  final List<_TextLayer> layers = [];

  /// Camada aberta no modo texto (escondida no canvas enquanto edita).
  String? editingId;

  /// Camada sob o gesto atual.
  String? activeId;

  /// Camada sendo movida (mostra lixeira, esconde o chrome).
  bool dragging = false;
  bool hoverTrash = false;
  bool snapX = false;
  bool snapY = false;

  /// Gesto da mídia (foto) em andamento.
  bool guides = false;

  bool get isGesturing => dragging || guides;

  int indexOf(String id) => layers.indexWhere((l) => l.id == id);

  void changed() => notifyListeners();
}

@immutable
class _MediaXform {
  const _MediaXform({required this.scale, required this.offset});
  const _MediaXform.identity() : scale = 1, offset = Offset.zero;

  final double scale;
  final Offset offset;

  bool get isIdentity => scale == 1 && offset == Offset.zero;
}

@immutable
class _TextLayer {
  const _TextLayer({
    required this.id,
    required this.text,
    required this.color,
    this.center = const Offset(0.5, 0.5),
    this.scale = 1,
    this.rotation = 0,
    this.fontScale = 1,
    this.bg = _TextBg.none,
    this.align = TextAlign.center,
    this.font = _StoryFont.classic,
  });

  final String id;
  final String text;
  final Color color;

  /// Centro NORMALIZADO (0..1) no canvas 9:16 — independe da tela.
  final Offset center;

  /// Escala do gesto de pinça (multiplica o tamanho base).
  final double scale;

  /// Rotação em radianos.
  final double rotation;

  /// Tamanho escolhido no slider do modo texto.
  final double fontScale;
  final _TextBg bg;
  final TextAlign align;
  final _StoryFont font;

  _TextLayer copyWith({
    String? text,
    Color? color,
    Offset? center,
    double? scale,
    double? rotation,
    double? fontScale,
    _TextBg? bg,
    TextAlign? align,
    _StoryFont? font,
  }) => _TextLayer(
    id: id,
    text: text ?? this.text,
    color: color ?? this.color,
    center: center ?? this.center,
    scale: scale ?? this.scale,
    rotation: rotation ?? this.rotation,
    fontScale: fontScale ?? this.fontScale,
    bg: bg ?? this.bg,
    align: align ?? this.align,
    font: font ?? this.font,
  );
}

String _fontLabel(S s, _StoryFont f) => switch (f) {
  _StoryFont.classic => s.composerFontClassic,
  _StoryFont.modern => s.composerFontModern,
  _StoryFont.serif => s.composerFontSerif,
  _StoryFont.typewriter => s.composerFontTypewriter,
  _StoryFont.neon => s.composerFontNeon,
};

/// Estilo visual compartilhado entre a camada no canvas e o campo do modo
/// texto — garante que o que se digita é exatamente o que fica no story.
abstract final class _TextLook {
  static String get _serif => Platform.isIOS ? 'Georgia' : 'serif';
  static String get _mono => Platform.isIOS ? 'Courier' : 'monospace';

  static TextStyle baseFor(_StoryFont font, double fontSize) => switch (font) {
    _StoryFont.classic => TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.18,
    ),
    _StoryFont.modern => TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 1.04,
      letterSpacing: -fontSize * 0.03,
    ),
    _StoryFont.serif => TextStyle(
      fontSize: fontSize,
      fontFamily: _serif,
      fontFamilyFallback: const ['Georgia', 'Times New Roman', 'serif'],
      fontWeight: FontWeight.w600,
      height: 1.15,
    ),
    _StoryFont.typewriter => TextStyle(
      fontSize: fontSize,
      fontFamily: _mono,
      fontFamilyFallback: const ['Courier', 'Courier New', 'monospace'],
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    _StoryFont.neon => TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.15,
    ),
  };

  static Color _contrastOn(Color c) =>
      c.computeLuminance() > 0.55 ? Colors.black : Colors.white;

  static TextStyle style({
    required Color color,
    required _TextBg bg,
    required _StoryFont font,
    required double fontSize,
  }) {
    var fg = bg == _TextBg.solid ? _contrastOn(color) : color;
    List<Shadow>? shadows;
    if (font == _StoryFont.neon) {
      final glow = bg == _TextBg.solid ? fg : color;
      if (bg != _TextBg.solid) fg = Color.lerp(Colors.white, color, 0.12)!;
      shadows = [
        Shadow(color: glow, blurRadius: fontSize * 0.2),
        Shadow(color: glow, blurRadius: fontSize * 0.5),
        Shadow(color: glow.withValues(alpha: 0.8), blurRadius: fontSize),
      ];
    } else if (bg == _TextBg.none) {
      shadows = [
        Shadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: fontSize * 0.18,
          offset: Offset(0, fontSize * 0.03),
        ),
      ];
    }
    return baseFor(font, fontSize).copyWith(color: fg, shadows: shadows);
  }

  static BoxDecoration? decoration(Color color, _TextBg bg, double fontSize) {
    switch (bg) {
      case _TextBg.none:
        return null;
      case _TextBg.translucent:
        return BoxDecoration(
          color: color.computeLuminance() > 0.35
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(fontSize * 0.32),
        );
      case _TextBg.solid:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(fontSize * 0.32),
        );
    }
  }

  static EdgeInsets padding(_TextBg bg, double fontSize) => bg == _TextBg.none
      ? EdgeInsets.zero
      : EdgeInsets.symmetric(
          horizontal: fontSize * 0.38,
          vertical: fontSize * 0.16,
        );
}

// ─── Widgets do canvas ───────────────────────────────────────────────────────

/// Fundo do canvas: gradiente (só texto), preto (vídeo) ou a própria foto
/// desfocada (aparece ao reduzir a foto ou com moldura).
class _CanvasBackground extends StatelessWidget {
  const _CanvasBackground({
    required this.file,
    required this.isVideo,
    required this.isTextOnly,
    required this.gradient,
  });

  final File file;
  final bool isVideo;
  final bool isTextOnly;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    if (isTextOnly) {
      return DecoratedBox(decoration: BoxDecoration(gradient: gradient));
    }
    if (isVideo) return const ColoredBox(color: Colors.black);
    return ColoredBox(
      color: Colors.black,
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          opacity: const AlwaysStoppedAnimation(0.55),
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

/// Mídia no canvas. FOTO: BoxFit.cover no 9:16 (o flatten publica
/// exatamente isso). VÍDEO: mesmo enquadramento do viewer
/// (`BraweStoryMedia`: AspectRatio centralizado) — sem transform, já que o
/// arquivo é publicado como está.
class _CanvasMedia extends StatelessWidget {
  const _CanvasMedia({
    required this.file,
    required this.isVideo,
    required this.isTextOnly,
    required this.videoCtrl,
    required this.frameStyle,
  });

  final File file;
  final bool isVideo;
  final bool isTextOnly;
  final VideoPlayerController? videoCtrl;
  final int frameStyle;

  @override
  Widget build(BuildContext context) {
    if (isTextOnly) return const SizedBox.expand();
    if (isVideo) {
      final ctrl = videoCtrl;
      if (ctrl == null || !ctrl.value.isInitialized) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white54),
        );
      }
      return Center(
        child: AspectRatio(
          aspectRatio: ctrl.value.aspectRatio,
          child: VideoPlayer(ctrl),
        ),
      );
    }
    final image = Image.file(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
    );
    switch (frameStyle) {
      case 1: // Polaroid
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 52),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: AspectRatio(aspectRatio: 4 / 5, child: image),
            ),
          ),
        );
      case 2: // Gradiente Brawe
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 56),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: _kBrandGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.braweBlue.withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: image,
            ),
          ),
        );
      default:
        return image;
    }
  }
}

/// Camadas de texto posicionadas pelo centro normalizado, com escala e
/// rotação. Rebuilda só com o [_CanvasStore] (não reconstrói a mídia).
class _LayersView extends StatelessWidget {
  const _LayersView({
    required this.store,
    required this.canvasWidth,
    required this.keyFor,
  });

  final _CanvasStore store;
  final double canvasWidth;
  final GlobalKey Function(String id) keyFor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => ListenableBuilder(
        listenable: store,
        builder: (_, _) => Stack(
          clipBehavior: Clip.none,
          children: [
            for (final l in store.layers)
              if (l.id != store.editingId)
                Positioned(
                  left: l.center.dx * c.maxWidth,
                  top: l.center.dy * c.maxHeight,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: Transform.rotate(
                      angle: l.rotation,
                      child: Transform.scale(
                        scale: l.scale,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 120),
                          opacity: store.hoverTrash && store.activeId == l.id
                              ? 0.45
                              : 1,
                          child: KeyedSubtree(
                            key: keyFor(l.id),
                            child: _TextLayerView(
                              layer: l,
                              canvasWidth: canvasWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _TextLayerView extends StatelessWidget {
  const _TextLayerView({required this.layer, required this.canvasWidth});

  final _TextLayer layer;
  final double canvasWidth;

  @override
  Widget build(BuildContext context) {
    final fs = canvasWidth * _kBaseFontFactor * layer.fontScale;
    Widget child = Text(
      layer.text,
      textAlign: layer.align,
      textWidthBasis: TextWidthBasis.longestLine,
      style: _TextLook.style(
        color: layer.color,
        bg: layer.bg,
        font: layer.font,
        fontSize: fs,
      ),
    );
    final deco = _TextLook.decoration(layer.color, layer.bg, fs);
    if (deco != null) {
      child = DecoratedBox(
        decoration: deco,
        child: Padding(padding: _TextLook.padding(layer.bg, fs), child: child),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: canvasWidth * _kTextMaxWidthFactor),
      child: child,
    );
  }
}

/// Campo do modo texto — mesmo visual da camada final.
class _ComposeTextField extends StatelessWidget {
  const _ComposeTextField({
    required this.controller,
    required this.color,
    required this.bg,
    required this.align,
    required this.font,
    required this.fontSize,
    required this.maxWidth,
    required this.hint,
  });

  final TextEditingController controller;
  final Color color;
  final _TextBg bg;
  final TextAlign align;
  final _StoryFont font;
  final double fontSize;
  final double maxWidth;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final style = _TextLook.style(
      color: color,
      bg: bg,
      font: font,
      fontSize: fontSize,
    );
    Widget field = IntrinsicWidth(
      child: TextField(
        controller: controller,
        autofocus: true,
        textAlign: align,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: style.color,
        style: style,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: style.copyWith(
            color: (style.color ?? Colors.white).withValues(alpha: 0.45),
            shadows: const [],
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
    final deco = _TextLook.decoration(color, bg, fontSize);
    if (deco != null) {
      field = DecoratedBox(
        decoration: deco,
        child: Padding(padding: _TextLook.padding(bg, fontSize), child: field),
      );
    }
    return Align(
      alignment: switch (align) {
        TextAlign.left => Alignment.centerLeft,
        TextAlign.right => Alignment.centerRight,
        _ => Alignment.center,
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: field,
      ),
    );
  }
}

class _CenterGuides extends StatelessWidget {
  const _CenterGuides({required this.vertical, required this.horizontal});

  final bool vertical;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    const color = AppColors.braweSky;
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: vertical ? 1 : 0,
            child: const SizedBox(
              width: 1,
              height: double.infinity,
              child: ColoredBox(color: color),
            ),
          ),
        ),
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: horizontal ? 1 : 0,
            child: const SizedBox(
              height: 1,
              width: double.infinity,
              child: ColoredBox(color: color),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrashTarget extends StatelessWidget {
  const _TrashTarget({required this.visible, required this.hover});

  final bool visible;
  final bool hover;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: visible ? 1 : 0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        scale: hover ? 1.25 : 1,
        child: Container(
          width: _kTrashSize,
          height: _kTrashSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hover
                ? AppColors.mutedRed
                : Colors.black.withValues(alpha: 0.35),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}

// ─── Chrome ──────────────────────────────────────────────────────────────────

/// Botão do rail: ícone sem círculo de fundo, sombra sutil, área de toque
/// de 44pt. O rótulo fica no tooltip/semantics (UI limpa).
class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.child,
    required this.tooltip,
    required this.onTap,
    this.badge = false,
  });

  final Widget child;
  final String tooltip;
  final VoidCallback? onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                child,
                if (badge)
                  Positioned(
                    right: 8,
                    top: 9,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _kBrandGradient,
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
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FontChip extends StatelessWidget {
  const _FontChip({
    required this.label,
    required this.style,
    required this.onTap,
  });

  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Text(label, style: style.copyWith(color: Colors.white)),
      ),
    );
  }
}

/// Chip compacto da música (topo do canvas): tap = ajustar trecho,
/// ícone de mixer (só vídeo) e X = remover.
class _SelectedStorySoundChip extends StatelessWidget {
  const _SelectedStorySoundChip({
    required this.sound,
    required this.onTap,
    required this.onRemove,
    required this.onMixer,
    required this.mixerTooltip,
  });

  final Sound sound;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback? onMixer;
  final String mixerTooltip;

  @override
  Widget build(BuildContext context) {
    final artist = sound.artist?.artistName;
    return Container(
      height: 34,
      padding: const EdgeInsets.only(left: 4, right: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: sound.coverUrl != null
                        ? Image.network(
                            sound.coverUrl!,
                            width: 26,
                            height: 26,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _fallback(),
                          )
                        : _fallback(),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      artist != null && artist.isNotEmpty
                          ? '${sound.title} · $artist'
                          : sound.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onMixer != null)
            _ChipIcon(
              icon: Icons.tune_rounded,
              tooltip: mixerTooltip,
              onTap: onMixer!,
            ),
          _ChipIcon(
            icon: Icons.close_rounded,
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
            onTap: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(
    width: 26,
    height: 26,
    decoration: const BoxDecoration(gradient: _kBrandGradient),
    child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 15),
  );
}

class _ChipIcon extends StatelessWidget {
  const _ChipIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 34,
          child: Icon(icon, color: Colors.white, size: 17),
        ),
      ),
    );
  }
}

/// Pill "Seu story" (destino) com o avatar do usuário.
class _StoryDestinationPill extends StatelessWidget {
  const _StoryDestinationPill({required this.label, this.avatarUrl});
  final String label;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 16, 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: _kBrandGradient,
            ),
            child: ClipOval(
              child: ColoredBox(
                color: AppColors.darkSurfaceElevated,
                child: url != null && url.isNotEmpty
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
              ),
            ),
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

/// Botão enviar circular com gradiente Brawe (spinner durante publish).
class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.loading,
    required this.tooltip,
    required this.onPressed,
  });

  final bool loading;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      child: GestureDetector(
        onTap: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: loading ? 0.8 : 1,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _kBrandGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.braweBlue.withValues(alpha: 0.45),
                  blurRadius: 16,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Slider vertical de tamanho da fonte (lateral esquerda do modo texto):
/// puxar pra cima = maior.
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
      child: RotatedBox(
        quarterTurns: 3,
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withValues(alpha: 0.14),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

/// Paleta horizontal (logo acima do teclado no modo texto).
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
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: palette.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final c = palette[i];
          final isSelected = c.toARGB32() == selected.toARGB32();
          return GestureDetector(
            onTap: () {
              onSelect(c);
              HapticFeedback.selectionClick();
            },
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: isSelected ? 34 : 28,
                height: isSelected ? 34 : 28,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: isSelected ? 3 : 2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// PNG 1x1 transparente (placeholder do story "só texto").
const List<int> _kTransparentPngBytes = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, //
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, //
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, //
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82, //
];
