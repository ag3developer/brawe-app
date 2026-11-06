import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../../domain/models/sound.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../shared/widgets/volume_mixer_sheet.dart';
import '../../sounds/view_models/sound_player_view_model.dart';
import '../../sounds/widgets/sound_trim_screen.dart';
import '../../sounds/widgets/sounds_catalog_screen.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import 'story_video_trim_screen.dart';
import '../view_models/video_upload_manager.dart';
import 'video_composer_view.dart';
import 'video_cover_picker_sheet.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// Bottom sheet de criação de post de **vídeo** (Reels / Shorts).
class CreateVideoSheet extends ConsumerStatefulWidget {
  const CreateVideoSheet({super.key});

  @override
  ConsumerState<CreateVideoSheet> createState() => _CreateVideoSheetState();
}

class _CreateVideoSheetState extends ConsumerState<CreateVideoSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _captionCtrl = TextEditingController();
  File? _video;
  VideoPlayerController? _videoCtrl;
  bool _isPublishing = false;
  File? _cover; // capa escolhida (null = frame automático do servidor)
  bool _pickerOpened = false;

  // ── Brawe Sound: música anexada ao Reel/vídeo (opcional) ──────────
  Sound? _selectedSound;
  static const Duration _kMaxSoundTrim = Duration(seconds: 60);
  int _soundTrimStartMs = 0;
  int? _soundTrimEndMs;
  // Fase D: mix de volumes entre a música anexada e o áudio original do
  // vídeo — já suportado pelo backend/payload (`sound_volume`/
  // `original_audio_volume`), mas sem UI até aqui.
  double _soundVolume = 1.0;
  double _originalAudioVolume = 1.0;
  late final AnimationController _pulseCtrl;

  static const Color _accent1 = AppColors.braweBlue;

  static const int _maxBytes = 100 * 1024 * 1024;
  static const Duration _maxDuration = Duration(minutes: 3);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pickerOpened) {
        _pickerOpened = true;
        _pickVideo();
      }
    });
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _videoCtrl?.dispose();
    _pulseCtrl.dispose();
    // `stop()` é assíncrono — dispose() precisa continuar síncrono, por
    // isso fire-and-forget com timeout de segurança (mesmo padrão usado
    // em StoryViewer/VideoFullscreenScreen).
    unawaited(
      ref
          .read(soundPlayerViewModelProvider.notifier)
          .stop()
          .timeout(const Duration(seconds: 2))
          .catchError((_) {}),
    );
    super.dispose();
  }

  /// Abre o catálogo do Brawe Sounds para escolher uma música pro Reel.
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
  /// deste vídeo/Reel.
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

  /// Fase D: abre o mixer de volumes (música × áudio original) com
  /// preview em tempo real — ajusta o `SoundPlayerViewModel` (música) e o
  /// `VideoPlayerController` local (áudio original) enquanto o usuário
  /// arrasta os sliders.
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

  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: _maxDuration,
      );
      if (picked == null) {
        if (mounted && _video == null) {
          Navigator.of(context).pop();
        }
        return;
      }
      final file = File(picked.path);
      final size = await file.length();
      if (size > _maxBytes) {
        if (!mounted) return;
        _snack(S.of(context).videoTooLarge, isError: true);
        return;
      }
      final ok = await _loadFile(file);
      if (!ok || !mounted) return;
      // Acima do limite de 3 min: obriga o corte.
      if (_videoCtrl!.value.duration > _maxDuration) {
        _snack(S.of(context).videoPubTooLong, isError: true);
        await _trim();
      }
    } catch (_) {
      if (!mounted) return;
      _snack(S.of(context).videoOpenError, isError: true);
    }
  }

  /// Inicializa o player com [file] e o torna o vídeo atual (zera a capa).
  Future<bool> _loadFile(File file) async {
    final ctrl = VideoPlayerController.file(file);
    try {
      await ctrl.initialize();
      await ctrl.setLooping(true);
      await ctrl.play();
    } catch (_) {
      await ctrl.dispose();
      rethrow;
    }
    if (!mounted) {
      await ctrl.dispose();
      return false;
    }
    final old = _videoCtrl;
    setState(() {
      _video = file;
      _videoCtrl = ctrl;
      _cover = null;
    });
    old?.dispose();
    return true;
  }

  Future<void> _trim() async {
    final video = _video;
    if (video == null || _isPublishing) return;
    await _videoCtrl?.pause();
    if (!mounted) return;
    final trimmed = await StoryVideoTrimScreen.push(
      context,
      file: video,
      maxDuration: _maxDuration,
    );
    if (!mounted) return;
    if (trimmed == null) {
      await _videoCtrl?.play();
      return;
    }
    try {
      await _loadFile(trimmed);
    } catch (_) {
      if (!mounted) return;
      _snack(S.of(context).videoPubTrimPrepareError, isError: true);
    }
  }

  Future<void> _pickCover() async {
    final video = _video;
    final ctrl = _videoCtrl;
    if (video == null || ctrl == null || _isPublishing) return;
    await ctrl.pause();
    final resume = ctrl.value.position;
    if (!mounted) return;
    final ar = ctrl.value.aspectRatio;
    final result = await VideoCoverPickerSheet.show(
      context,
      videoPath: video.path,
      durationMs: ctrl.value.duration.inMilliseconds,
      aspectRatio: ar > 0 ? ar : 4 / 5,
      initialMs: resume.inMilliseconds,
      // Mesmo controller do preview: o seletor reposiciona o vídeo (pausado)
      // no quadro escolhido, então o preview grande rola junto com a barra.
      previewBuilder: (_) => VideoPlayer(ctrl),
      onSeek: (ms) => ctrl.seekTo(Duration(milliseconds: ms)),
    );
    if (result != null && mounted) setState(() => _cover = result.file);
    // Volta ao ponto em que o usuário estava antes de abrir o seletor.
    try {
      await ctrl.seekTo(resume);
      if (mounted) await ctrl.play();
    } catch (_) {}
  }

  void _togglePlay() {
    final c = _videoCtrl;
    if (c == null) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
    });
  }

  Future<void> _publish() async {
    final video = _video;
    if (video == null) return;
    final ctrl = _videoCtrl;
    if (ctrl != null &&
        ctrl.value.duration > _maxDuration + const Duration(seconds: 1)) {
      _snack(S.of(context).videoPubTooLong, isError: true);
      return;
    }
    FocusScope.of(context).unfocus();
    final sz = ctrl?.value.size;
    setState(() => _isPublishing = true);
    // Enfileira no gerenciador global e fecha o compositor na hora: o envio
    // (com % real) continua no indicador acima da barra de navegação.
    ref
        .read(videoUploadManagerProvider.notifier)
        .enqueue(
          VideoUploadRequest(
            videoPath: video.path,
            content: _captionCtrl.text.trim(),
            coverPath: _cover?.path,
            soundId: _selectedSound?.id,
            soundTrimStartMs: _soundTrimStartMs,
            soundTrimEndMs: _soundTrimEndMs,
            soundVolume: _soundVolume,
            originalAudioVolume: _originalAudioVolume,
            width: (sz != null && sz.width > 0) ? sz.width.round() : null,
            height: (sz != null && sz.height > 0) ? sz.height.round() : null,
            durationSec: ctrl != null && ctrl.value.isInitialized
                ? ctrl.value.duration.inMilliseconds / 1000
                : null,
          ),
        );
    Navigator.of(context).pop();
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : _accent1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasVideo = _video != null && _videoCtrl?.value.isInitialized == true;
    final canPublish = hasVideo && !_isPublishing;
    final mq = MediaQuery.of(context);
    final s = S.of(context);
    final ctrl = _videoCtrl;
    final avail = mq.size.height - mq.viewInsets.bottom - mq.padding.top;

    // Se o compositor ainda estiver na tela, o botão mostra o % real.
    final job = ref.watch(
      videoUploadManagerProvider.select(
        (jobs) => jobs.isEmpty ? null : jobs.last,
      ),
    );
    final pubLabel = job == null
        ? s.videoUpQueued
        : switch (job.status) {
            VideoUploadStatus.uploading => s.videoUpUploading(job.percent),
            VideoUploadStatus.processing => s.videoUpProcessing,
            _ => s.videoUpQueued,
          };

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        height: math.min(mq.size.height * 0.94, avail),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Material(
            color: Colors.transparent,
            child: VideoComposerView(
              hasVideo: hasVideo,
              aspectRatio: hasVideo ? ctrl!.value.aspectRatio : 1,
              preview: hasVideo
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: ctrl!.value.aspectRatio,
                        child: VideoPlayer(ctrl),
                      ),
                    )
                  : const SizedBox.shrink(),
              playing: hasVideo ? ctrl!.value.isPlaying : true,
              durationChip: hasVideo ? _DurationChip(controller: ctrl!) : null,
              emptyState: _EmptyPickerState(
                onTap: _pickVideo,
                pulse: _pulseCtrl,
              ),
              captionController: _captionCtrl,
              onClose: () => Navigator.of(context).pop(),
              onSwap: _isPublishing ? () {} : _pickVideo,
              onTrim: _isPublishing ? null : _trim,
              onCover: _isPublishing ? null : _pickCover,
              onSound: _isPublishing ? null : _pickSound,
              soundActive: _selectedSound != null,
              cover: _cover,
              onClearCover: (_cover != null && !_isPublishing)
                  ? () => setState(() => _cover = null)
                  : null,
              onTogglePlay: _togglePlay,
              soundRow: _selectedSound == null
                  ? null
                  : Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: _editTrim,
                            child: _VideoSoundChip(
                              sound: _selectedSound!,
                              onRemove: _removeSound,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: s.videoPubSound,
                          child: Material(
                            color: c.surfaceHighest,
                            shape: CircleBorder(side: BorderSide(color: c.border)),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _openVolumeMixer,
                              child: SizedBox(
                                width: 38,
                                height: 38,
                                child: Icon(
                                  LucideIcons.slidersHorizontal,
                                  color: c.textPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              publishing: _isPublishing,
              publishLabel: pubLabel,
              progress: _isPublishing ? job?.progress : null,
              onPublish: canPublish ? _publish : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPickerState extends StatelessWidget {
  const _EmptyPickerState({required this.onTap, required this.pulse});

  final VoidCallback onTap;
  final AnimationController pulse;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: pulse,
                builder: (_, _) {
                  final v = pulse.value;
                  return Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [c.accentPrimary, c.accentSecondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.accentPrimary.withValues(alpha: 0.3 + v * 0.25),
                          blurRadius: 24 + v * 14,
                          spreadRadius: 1 + v * 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.video,
                      color: Colors.white,
                      size: 42,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context).videoSelect,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                S.of(context).videoFormatsHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip do som selecionado para este Reel/vídeo, com bot\u00e3o de remover.
/// Tap fora do bot\u00e3o de remover reabre a tela de trim (ver `_editTrim`).
class _VideoSoundChip extends StatelessWidget {
  const _VideoSoundChip({required this.sound, required this.onRemove});
  final Sound sound;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: c.surfaceHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.accentPink.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sound.coverUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                cacheWidth: context.decodePx(28),
                sound.coverUrl!,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Icon(LucideIcons.music, color: c.textSecondary, size: 16),
              ),
            )
          else
            Icon(LucideIcons.music, color: c.textSecondary, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              sound.title,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(LucideIcons.x, color: c.textSecondary, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationChip extends StatefulWidget {
  const _DurationChip({required this.controller});
  final VideoPlayerController controller;

  @override
  State<_DurationChip> createState() => _DurationChipState();
}

class _DurationChipState extends State<_DurationChip> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTick);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  String _f(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.controller.value;
    final pos = v.position;
    final total = v.duration;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Text(
        '${_f(pos)} / ${_f(total)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
