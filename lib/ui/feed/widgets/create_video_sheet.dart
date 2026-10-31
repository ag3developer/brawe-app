import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../../data/repositories/post_repository.dart';
import '../../../domain/models/sound.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../home/view_models/for_you_feed_view_model.dart';
import '../../shared/widgets/volume_mixer_sheet.dart';
import '../../sounds/view_models/sound_player_view_model.dart';
import '../../sounds/widgets/sound_trim_screen.dart';
import '../../sounds/widgets/sounds_catalog_screen.dart';
import '../../core/themes/app_colors.dart';
import '../view_models/feed_view_model.dart';
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
  static const Color _accent2 = AppColors.braweSky;

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
      final ctrl = VideoPlayerController.file(file);
      await ctrl.initialize();
      await ctrl.setLooping(true);
      await ctrl.play();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _video = file;
        _videoCtrl?.dispose();
        _videoCtrl = ctrl;
      });
    } catch (_) {
      if (!mounted) return;
      _snack(S.of(context).videoOpenError, isError: true);
    }
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
    FocusScope.of(context).unfocus();
    setState(() => _isPublishing = true);
    try {
      await ref
          .read(postRepositoryProvider)
          .createVideoPost(
            videoLocalPath: video.path,
            content: _captionCtrl.text.trim(),
            soundId: _selectedSound?.id,
            soundTrimStartMs: _soundTrimStartMs,
            soundTrimEndMs: _soundTrimEndMs,
            // Fase D: mix de volumes definido pelo usuário no
            // `VolumeMixerSheet` (default 1.0/1.0 quando não ajustado).
            soundVolume: _soundVolume,
            originalAudioVolume: _originalAudioVolume,
          );
      ref.invalidate(forYouFeedViewModelProvider);
      ref.invalidate(feedViewModelProvider);
      if (!mounted) return;
      final s = S.of(context);
      Navigator.of(context).pop();
      _snack(s.videoPublishedSuccess);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPublishing = false);
      _snack(S.of(context).videoPublishError, isError: true);
    }
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
    final hasVideo = _video != null && _videoCtrl?.value.isInitialized == true;
    final canPublish = hasVideo && !_isPublishing;
    final mq = MediaQuery.of(context);

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        height: mq.size.height * 0.94,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Stack(
            children: [
              Positioned.fill(
                child: hasVideo
                    ? GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          color: Colors.black,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: _videoCtrl!.value.aspectRatio,
                              child: VideoPlayer(_videoCtrl!),
                            ),
                          ),
                        ),
                      )
                    : _EmptyPickerState(
                        accent1: _accent1,
                        accent2: _accent2,
                        onTap: _pickVideo,
                        pulse: _pulseCtrl,
                      ),
              ),
              if (hasVideo)
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.0, 0.18, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              if (hasVideo && !_videoCtrl!.value.isPlaying)
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.4),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Row(
                      children: [
                        _GlassIconButton(
                          icon: LucideIcons.x,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          S.of(context).videoSheetTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black54,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (hasVideo) ...[
                          _GlassIconButton(
                            icon: LucideIcons.music,
                            iconColor: _selectedSound != null
                                ? const Color(0xFFE11D48)
                                : null,
                            tooltip: S.of(context).createSoundsTitle,
                            onTap: _pickSound,
                          ),
                          const SizedBox(width: 8),
                          _GlassIconButton(
                            icon: LucideIcons.refreshCw,
                            tooltip: S.of(context).videoSwapTooltip,
                            onTap: _pickVideo,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (hasVideo)
                Positioned(
                  top: mq.padding.top + 68,
                  right: 16,
                  child: _DurationChip(controller: _videoCtrl!),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Chip do som selecionado (tap = ajustar o trecho)
                        // + botão de mixer de volumes (música × áudio
                        // original — Fase D do relatório de áudio).
                        if (_selectedSound != null) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: _editTrim,
                                child: _VideoSoundChip(
                                  sound: _selectedSound!,
                                  onRemove: _removeSound,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _openVolumeMixer,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              child: TextField(
                                controller: _captionCtrl,
                                maxLines: 3,
                                minLines: 1,
                                maxLength: 300,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.3,
                                ),
                                cursorColor: _accent1,
                                decoration: InputDecoration(
                                  hintText: S.of(context).videoCaptionHint,
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.55),
                                  ),
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  counterStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 54,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: canPublish ? 1.0 : 0.55,
                            child: Material(
                              color: Colors.transparent,
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_accent1, _accent2],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: canPublish
                                      ? [
                                          BoxShadow(
                                            color: _accent1.withValues(
                                              alpha: 0.45,
                                            ),
                                            blurRadius: 24,
                                            spreadRadius: -4,
                                            offset: const Offset(0, 8),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: InkWell(
                                  onTap: canPublish ? _publish : null,
                                  borderRadius: BorderRadius.circular(18),
                                  child: Center(
                                    child: _isPublishing
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                LucideIcons.sparkles,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                S
                                                    .of(context)
                                                    .videoPublishButton,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            ],
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
                ),
              ),
              if (hasVideo)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: VideoProgressIndicator(
                      _videoCtrl!,
                      allowScrubbing: false,
                      padding: EdgeInsets.zero,
                      colors: VideoProgressColors(
                        playedColor: _accent1,
                        bufferedColor: Colors.white.withValues(alpha: 0.2),
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPickerState extends StatelessWidget {
  const _EmptyPickerState({
    required this.accent1,
    required this.accent2,
    required this.onTap,
    required this.pulse,
  });

  final Color accent1;
  final Color accent2;
  final VoidCallback onTap;
  final AnimationController pulse;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: pulse,
                builder: (_, _) {
                  final v = pulse.value;
                  return Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accent1, accent2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent1.withValues(alpha: 0.4 + v * 0.3),
                          blurRadius: 32 + v * 16,
                          spreadRadius: 2 + v * 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.video,
                      color: Colors.white,
                      size: 48,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context).videoSelect,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                S.of(context).videoFormatsHint,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE11D48).withValues(alpha: 0.4),
            ),
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
                    errorBuilder: (_, __, ___) => const Icon(
                      LucideIcons.music,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ),
                )
              else
                const Icon(LucideIcons.music, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  sound.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close, color: Colors.white70, size: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final btn = ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withValues(alpha: 0.12),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Text(
            '${_f(pos)} / ${_f(total)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
