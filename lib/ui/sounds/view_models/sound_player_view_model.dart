import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/sound_repository.dart';
import '../../../domain/models/sound.dart';

part 'sound_player_view_model.g.dart';

enum SoundPlayerStatus { idle, loading, playing, paused, error }

class SoundPlayerState {
  final Sound? sound;
  final SoundPlayerStatus status;
  final Duration position;
  final Duration duration;
  final double progress; // 0.0 – 1.0

  const SoundPlayerState({
    this.sound,
    this.status = SoundPlayerStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.progress = 0,
  });

  bool get isPlaying => status == SoundPlayerStatus.playing;
  bool get isLoading => status == SoundPlayerStatus.loading;

  SoundPlayerState copyWith({
    Sound? sound,
    SoundPlayerStatus? status,
    Duration? position,
    Duration? duration,
    double? progress,
  }) =>
      SoundPlayerState(
        sound: sound ?? this.sound,
        status: status ?? this.status,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        progress: progress ?? this.progress,
      );
}

@riverpod
class SoundPlayerViewModel extends _$SoundPlayerViewModel {
  AudioPlayer? _player;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _statusSub;

  @override
  SoundPlayerState build() {
    ref.onDispose(_dispose);
    return const SoundPlayerState();
  }

  // ── Carrega e toca ────────────────────────────────────────────────────────

  Future<void> play(Sound sound) async {
    // Se já está tocando a mesma música — toggle pause/play
    if (state.sound?.id == sound.id) {
      if (state.isPlaying) {
        await _player?.pause();
        state = state.copyWith(status: SoundPlayerStatus.paused);
      } else {
        await _player?.play();
        state = state.copyWith(status: SoundPlayerStatus.playing);
      }
      return;
    }

    // Nova música
    await _dispose();
    state = state.copyWith(
      sound: sound,
      status: SoundPlayerStatus.loading,
      position: Duration.zero,
      progress: 0,
    );

    try {
      _player = AudioPlayer();

      _durationSub = _player!.durationStream.listen((d) {
        if (d != null) {
          state = state.copyWith(duration: d);
        }
      });

      _positionSub = _player!.positionStream.listen((p) {
        final dur = state.duration.inMilliseconds;
        final progress =
            dur > 0 ? (p.inMilliseconds / dur).clamp(0.0, 1.0) : 0.0;
        state = state.copyWith(position: p, progress: progress);
      });

      _statusSub = _player!.playerStateStream.listen((ps) {
        if (ps.processingState == ProcessingState.completed) {
          state = state.copyWith(
              status: SoundPlayerStatus.paused,
              progress: 1.0,
              position: state.duration);
        }
      });

      // Calcula trim: se allow_trim = false ou trim não definido, toca tudo
      final start = sound.allowTrim
          ? Duration(milliseconds: sound.trimStartMs)
          : Duration.zero;
      final end = (sound.allowTrim && sound.trimEndMs != null)
          ? Duration(milliseconds: sound.trimEndMs!)
          : null;

      await _player!.setAudioSource(
        ClippingAudioSource(
          start: start,
          end: end,
          child: AudioSource.uri(Uri.parse(sound.audioUrl)),
        ),
      );

      state = state.copyWith(status: SoundPlayerStatus.playing);
      await _player!.play();

      // Registra play (fire-and-forget)
      ref.read(soundRepositoryProvider).registerPlay(sound.id);
    } catch (_) {
      state = state.copyWith(status: SoundPlayerStatus.error);
    }
  }

  Future<void> pause() async {
    await _player?.pause();
    state = state.copyWith(status: SoundPlayerStatus.paused);
  }

  Future<void> seek(double progress) async {
    final ms = (state.duration.inMilliseconds * progress).round();
    await _player?.seek(Duration(milliseconds: ms));
  }

  void stop() {
    _dispose();
    state = const SoundPlayerState();
  }

  Future<void> _dispose() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _statusSub?.cancel();
    await _player?.stop();
    await _player?.dispose();
    _player = null;
    _positionSub = null;
    _durationSub = null;
    _statusSub = null;
  }
}
