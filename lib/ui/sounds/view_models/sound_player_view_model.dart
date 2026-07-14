import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/sound_repository.dart';
import '../../../domain/models/sound.dart';

part 'sound_player_view_model.g.dart';

enum SoundPlayerStatus { idle, loading, playing, paused, error }

/// Identificador opcional de quem está usando o player global no momento
/// (ex.: `story:{storyId}`, `fullscreen:{postId}`, `feed:{postId}`). Não é
/// um mecanismo de exclusão mútua rígido — apenas permite detectar/registrar
/// quando um novo "owner" assume o player, útil para logs/instrumentação e
/// para telas decidirem se ainda são o dono legítimo antes de agir sobre o
/// player (ex.: não retomar play() se outro owner já assumiu).
typedef SoundPlayerOwner = String;

class SoundPlayerState {
  final Sound? sound;
  final SoundPlayerStatus status;
  final Duration position;
  final Duration duration;
  final double progress; // 0.0 – 1.0

  /// Owner atual do player (ver [SoundPlayerOwner]). `null` quando idle/sem
  /// dono explícito (ex.: preview tocado a partir do catálogo).
  final SoundPlayerOwner? owner;

  const SoundPlayerState({
    this.sound,
    this.status = SoundPlayerStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.progress = 0,
    this.owner,
  });

  bool get isPlaying => status == SoundPlayerStatus.playing;
  bool get isLoading => status == SoundPlayerStatus.loading;

  SoundPlayerState copyWith({
    Sound? sound,
    SoundPlayerStatus? status,
    Duration? position,
    Duration? duration,
    double? progress,
    SoundPlayerOwner? owner,
    bool clearOwner = false,
  }) => SoundPlayerState(
    sound: sound ?? this.sound,
    status: status ?? this.status,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    progress: progress ?? this.progress,
    owner: clearOwner ? null : (owner ?? this.owner),
  );
}

@riverpod
class SoundPlayerViewModel extends _$SoundPlayerViewModel {
  AudioPlayer? _player;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _statusSub;

  /// Token monotônico incrementado a cada novo `play()`/`stop()`. Usado
  /// para invalidar callbacks assíncronos de uma chamada anterior — evita
  /// que um `play()` cujo widget já foi descartado "reviva" o player depois
  /// de um `stop()` mais recente (a causa raiz do Bug #2 do relatório de
  /// áudio: Future pendente do `play()` antigo terminando DEPOIS do
  /// `stop()` do dispose, e deixando o player tocando "órfão").
  int _generation = 0;

  @override
  SoundPlayerState build() {
    ref.onDispose(() {
      // Best-effort: dispose do provider não pode await, mas ainda
      // queremos liberar o player nativo o quanto antes.
      unawaited(_dispose());
    });
    return const SoundPlayerState();
  }

  // ── Carrega e toca ────────────────────────────────────────────────────────

  /// Toca [sound]. [owner] identifica quem está solicitando a reprodução
  /// (ver [SoundPlayerOwner]) — usado para que o chamador possa depois
  /// confirmar, via [isOwner], se ainda é o dono legítimo do player antes
  /// de agir sobre ele (ex.: não chamar `play()` de novo num `_resume()`
  /// se outra tela já assumiu o player nesse meio tempo).
  ///
  /// Sempre para/descarta o player anterior ANTES de criar o novo — nunca
  /// há dois `AudioPlayer` vivos simultaneamente (impede player órfão e
  /// áudio duplicado quando duas telas tentam tocar músicas diferentes).
  Future<void> play(Sound sound, {SoundPlayerOwner? owner}) async {
    final myGeneration = ++_generation;

    // Se já está tocando a mesma música (mesmo owner OU sem owner
    // explícito) — toggle pause/play em vez de recriar o player.
    if (state.sound?.id == sound.id && _player != null) {
      if (state.isPlaying) {
        await _player?.pause();
        if (!_isCurrent(myGeneration)) return;
        state = state.copyWith(
          status: SoundPlayerStatus.paused,
          owner: owner,
          clearOwner: owner == null,
        );
      } else {
        // ⚠️ NUNCA `await` o `Future` de `AudioPlayer.play()` — ele só
        // completa quando a reprodução TERMINA (ou é pausada/parada),
        // não quando ela COMEÇA (documentado no próprio just_audio:
        // "The Future returned by this method completes when the
        // playback completes or is paused or stopped"). Um `await`
        // aqui travava toda a função até a faixa acabar de tocar —
        // causa raiz do bug "a música toca inteira e só depois o
        // tempo do Story começa a contar".
        unawaited(_player?.play() ?? Future.value());
        state = state.copyWith(
          status: SoundPlayerStatus.playing,
          owner: owner,
          clearOwner: owner == null,
        );
      }
      return;
    }

    // Nova música — descarta o player anterior por completo (garante um
    // único owner ativo por vez; nunca dois AudioPlayer simultâneos).
    await _dispose();
    if (!_isCurrent(myGeneration)) return; // stop() concorrente venceu

    state = state.copyWith(
      sound: sound,
      status: SoundPlayerStatus.loading,
      position: Duration.zero,
      progress: 0,
      owner: owner,
      clearOwner: owner == null,
    );

    try {
      final player = AudioPlayer();
      _player = player;

      _durationSub = player.durationStream.listen((d) {
        if (!_isCurrent(myGeneration)) return;
        if (d != null) {
          state = state.copyWith(duration: d);
        }
      });

      _positionSub = player.positionStream.listen((p) {
        if (!_isCurrent(myGeneration)) return;
        final dur = state.duration.inMilliseconds;
        final progress = dur > 0
            ? (p.inMilliseconds / dur).clamp(0.0, 1.0)
            : 0.0;
        state = state.copyWith(position: p, progress: progress);
      });

      _statusSub = player.playerStateStream.listen((ps) {
        if (!_isCurrent(myGeneration)) return;
        if (ps.processingState == ProcessingState.completed) {
          state = state.copyWith(
            status: SoundPlayerStatus.paused,
            progress: 1.0,
            position: state.duration,
          );
        }
      });

      // Calcula trim: se allow_trim = false ou trim não definido, toca tudo
      final start = sound.allowTrim
          ? Duration(milliseconds: sound.trimStartMs)
          : Duration.zero;
      final end = (sound.allowTrim && sound.trimEndMs != null)
          ? Duration(milliseconds: sound.trimEndMs!)
          : null;

      await player.setAudioSource(
        ClippingAudioSource(
          start: start,
          end: end,
          child: AudioSource.uri(Uri.parse(sound.audioUrl)),
        ),
      );

      // Se um `stop()`/`play()` mais recente já rodou enquanto
      // aguardávamos o setAudioSource, aborta silenciosamente e libera
      // este player — nunca deixa dois players vivos nem reativa áudio
      // depois que o "dono" já mandou parar (Bug #2).
      if (!_isCurrent(myGeneration)) {
        await player.stop().catchError((_) {});
        await player.dispose().catchError((_) {});
        return;
      }

      // Aplica o volume específico deste conteúdo (post/story) — default
      // 1.0 quando não informado (compat com conteúdo antigo/catálogo).
      await player.setVolume(sound.volume.clamp(0.0, 1.0));

      if (!_isCurrent(myGeneration)) {
        await player.stop().catchError((_) {});
        await player.dispose().catchError((_) {});
        return;
      }

      state = state.copyWith(status: SoundPlayerStatus.playing);
      // ⚠️ NUNCA `await` aqui — ver comentário detalhado no ramo de
      // toggle acima. `player.play()` só completa quando a MÚSICA
      // INTEIRA termina (ou é pausada/parada), não quando ela começa.
      // Com `await`, todo chamador que faz `await notifier.play(...)`
      // (ex.: `StoryViewer._startStory()`) ficava bloqueado até a
      // faixa acabar — daí o Story só "iniciar o cronômetro" depois da
      // música toda já ter tocado. Erros de ativação de audio session
      // são absorvidos internamente pelo just_audio (não lançam), então
      // não perdemos tratamento de erro relevante ao não aguardar.
      unawaited(player.play());

      // Registra play (fire-and-forget)
      ref.read(soundRepositoryProvider).registerPlay(sound.id);
    } catch (_) {
      if (!_isCurrent(myGeneration)) return;
      state = state.copyWith(status: SoundPlayerStatus.error);
    }
  }

  /// True se [generation] ainda corresponde à chamada mais recente de
  /// `play()`/`stop()` — usado para descartar efeitos de Futures "velhas"
  /// que terminam depois de uma chamada mais nova (dispose/stop/novo play).
  bool _isCurrent(int generation) => generation == _generation;

  /// True se [owner] é (ou não há) o dono atual do player — telas podem
  /// checar isso antes de agir sobre o player (ex.: `_resume()` de um
  /// Story não deve religar a música se outra tela já assumiu o player).
  bool isOwner(SoundPlayerOwner owner) =>
      state.owner == null || state.owner == owner;

  Future<void> pause() async {
    final myGeneration = _generation;
    await _player?.pause();
    if (!_isCurrent(myGeneration)) return;
    state = state.copyWith(status: SoundPlayerStatus.paused);
  }

  Future<void> seek(double progress) async {
    final ms = (state.duration.inMilliseconds * progress).round();
    await _player?.seek(Duration(milliseconds: ms));
  }

  /// Ajusta o volume (0.0–1.0) do player atual, se houver.
  /// Usado pelo `StoryViewer` para sincronizar a música com o botão de mute.
  Future<void> setVolume(double volume) async {
    await _player?.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Para e libera completamente o player atual. **Assíncrono** — os
  /// chamadores que precisam garantir que nenhum áudio "sobrevive" após
  /// este ponto (ex.: `dispose()` de telas) devem `await` esta chamada
  /// (com timeout) em vez de dispará-la fire-and-forget.
  Future<void> stop() async {
    _generation++; // invalida qualquer play() em andamento
    await _dispose();
    state = const SoundPlayerState();
  }

  Future<void> _dispose() async {
    final player = _player;
    _player = null;
    try {
      await _positionSub?.cancel();
      await _durationSub?.cancel();
      await _statusSub?.cancel();
    } catch (_) {
      // Ignora falhas ao cancelar streams — não pode travar o dispose.
    }
    _positionSub = null;
    _durationSub = null;
    _statusSub = null;
    if (player == null) return;
    try {
      await player.stop().timeout(const Duration(seconds: 1));
    } catch (_) {
      // Ignora — ainda tentamos dispose() abaixo mesmo se stop() falhar/travar.
    }
    try {
      await player.dispose().timeout(const Duration(seconds: 1));
    } catch (_) {
      // Ignora — na pior hipótese o GC coleta depois; não pode travar a UI.
    }
  }
}
