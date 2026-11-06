import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/stories_repository.dart';
import '../../../data/repositories/auth_state_provider.dart';
import 'stories_view_model.dart';
import '../../home/view_models/for_you_feed_view_model.dart';
import 'feed_view_model.dart';

enum VideoUploadStatus { queued, uploading, processing, done, failed }

/// Dados imutáveis do post a publicar (tudo que o repositório precisa).
class VideoUploadRequest {
  const VideoUploadRequest({
    required this.videoPath,
    this.content = '',
    this.coverPath,
    this.soundId,
    this.soundTrimStartMs = 0,
    this.soundTrimEndMs,
    this.soundVolume = 1.0,
    this.originalAudioVolume = 1.0,
    this.width,
    this.height,
    this.durationSec,
    this.storyKey,
    this.storyOverlayPath,
    this.storyOriginPostId,
    this.storyIsVideo = false,
    this.storySince,
  });

  /// Job de STORY (foto ou vídeo): [videoPath] é a mídia; [storyKey] é a
  /// Idempotency-Key do rascunho, reaproveitada em toda tentativa.
  final String? storyKey;
  final String? storyOverlayPath;
  final String? storyOriginPostId;
  final bool storyIsVideo;
  final DateTime? storySince;
  bool get isStory => storyKey != null;

  final String videoPath;
  final String content;
  final String? coverPath;
  final String? soundId;
  final int soundTrimStartMs;
  final int? soundTrimEndMs;
  final double soundVolume;
  final double originalAudioVolume;
  final int? width;
  final int? height;
  final double? durationSec;
}

enum VideoUploadError { none, cover, network, other }

class VideoUploadJob {
  const VideoUploadJob({
    required this.id,
    required this.request,
    this.status = VideoUploadStatus.queued,
    this.progress = 0,
    this.error = VideoUploadError.none,
    this.postId,
    this.attempts = 0,
  });

  final int id;
  final VideoUploadRequest request;
  final VideoUploadStatus status;

  /// 0..1 (bytes enviados). Só faz sentido em `uploading`.
  final double progress;
  final VideoUploadError error;
  final String? postId;
  final int attempts;

  bool get active =>
      status == VideoUploadStatus.queued ||
      status == VideoUploadStatus.uploading ||
      status == VideoUploadStatus.processing;

  int get percent => (progress * 100).floor().clamp(0, 100);

  VideoUploadJob copyWith({
    VideoUploadStatus? status,
    double? progress,
    VideoUploadError? error,
    String? postId,
    int? attempts,
  }) => VideoUploadJob(
    id: id,
    request: request,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    error: error ?? this.error,
    postId: postId ?? this.postId,
    attempts: attempts ?? this.attempts,
  );
}

/// Executa uma publicação. Injetável para testes.
typedef VideoUploadRunner =
    Future<String?> Function(
      VideoUploadRequest request, {
      required VideoPublishCheckpoint checkpoint,
      required CancelToken cancelToken,
      required void Function(double progress, bool processing) onProgress,
    });

/// Executa a publicação de um story. Injetável para testes.
typedef StoryUploadRunner =
    Future<String?> Function(
      VideoUploadRequest request, {
      required CancelToken cancelToken,
      required void Function(double progress, bool processing) onProgress,
    });

final storyUploadRunnerProvider = Provider<StoryUploadRunner>((ref) {
  final repo = ref.watch(storiesRepositoryProvider);
  return (r, {required cancelToken, required onProgress}) =>
      repo.createStoryResilient(
        localFilePath: r.videoPath,
        idempotencyKey: r.storyKey!,
        since: r.storySince ?? DateTime.now(),
        myUserId: ref.read(authStateProvider).value?.id,
        mediaType: r.storyIsVideo ? 'video' : 'photo',
        caption: r.content,
        durationSeconds: r.durationSec?.round(),
        originPostId: r.storyOriginPostId,
        soundId: r.soundId,
        soundTrimStartMs: r.soundTrimStartMs,
        soundTrimEndMs: r.soundTrimEndMs,
        soundVolume: r.soundVolume,
        originalAudioVolume: r.originalAudioVolume,
        overlayPath: r.storyOverlayPath,
        cancelToken: cancelToken,
        onSendProgress: (sent, total) {
          if (total > 0) onProgress(sent / total, sent >= total);
        },
      );
});

final videoUploadRunnerProvider = Provider<VideoUploadRunner>((ref) {
  final repo = ref.watch(postRepositoryProvider);
  return (r, {required checkpoint, required cancelToken, required onProgress}) =>
      repo.createVideoPost(
        videoLocalPath: r.videoPath,
        content: r.content,
        soundId: r.soundId,
        soundTrimStartMs: r.soundTrimStartMs,
        soundTrimEndMs: r.soundTrimEndMs,
        soundVolume: r.soundVolume,
        originalAudioVolume: r.originalAudioVolume,
        coverLocalPath: r.coverPath,
        fallbackWidth: r.width,
        fallbackHeight: r.height,
        fallbackDurationSec: r.durationSec,
        onProgress: onProgress,
        cancelToken: cancelToken,
        checkpoint: checkpoint,
      );
});

/// Gerenciador global de publicação de vídeo: o compositor só ENFILEIRA e
/// fecha; o envio segue aqui (sobrevive à navegação entre abas), com
/// progresso real, cancelar, tentar de novo e retomada ao voltar do
/// background. Fila sequencial (um upload por vez).
class VideoUploadManager extends Notifier<List<VideoUploadJob>>
    with WidgetsBindingObserver {
  static const int maxAutoRetries = 2;

  final Map<int, VideoPublishCheckpoint> _checkpoints = {};
  final Map<int, CancelToken> _tokens = {};
  int _seq = 0;
  bool _running = false;
  bool _wentBackground = false;

  @override
  List<VideoUploadJob> build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    return const [];
  }

  /// Job em foco para o indicador: o ativo mais antigo, senão o último.
  VideoUploadJob? get current {
    for (final j in state) {
      if (j.active) return j;
    }
    return state.isEmpty ? null : state.last;
  }

  int enqueue(VideoUploadRequest request) {
    final id = ++_seq;
    _checkpoints[id] = VideoPublishCheckpoint();
    state = [...state, VideoUploadJob(id: id, request: request)];
    _pump();
    return id;
  }

  void _update(int id, VideoUploadJob Function(VideoUploadJob) f) {
    state = [for (final j in state) j.id == id ? f(j) : j];
  }

  VideoUploadJob? _job(int id) {
    for (final j in state) {
      if (j.id == id) return j;
    }
    return null;
  }

  void _pump() {
    if (_running) return;
    VideoUploadJob? next;
    for (final j in state) {
      if (j.status == VideoUploadStatus.queued) {
        next = j;
        break;
      }
    }
    if (next == null) return;
    _running = true;
    unawaited(_run(next.id));
  }

  Future<void> _run(int id) async {
    final token = CancelToken();
    _tokens[id] = token;
    final job = _job(id)!;
    _update(
      id,
      (j) => j.copyWith(
        status: VideoUploadStatus.uploading,
        progress: 0,
        error: VideoUploadError.none,
        attempts: j.attempts + 1,
      ),
    );
    _wentBackground = false;
    try {
      void onProgress(double p, bool processing) {
          if (_job(id) == null || token.isCancelled) return;
          _update(
            id,
            (j) => j.copyWith(
              status: processing
                  ? VideoUploadStatus.processing
                  : VideoUploadStatus.uploading,
              // nunca regride: o % mostrado só sobe
              progress: p > j.progress ? p : j.progress,
            ),
          );
      }

      final String? postId;
      if (job.request.isStory) {
        postId = await ref.read(storyUploadRunnerProvider)(
          job.request,
          cancelToken: token,
          onProgress: onProgress,
        );
      } else {
        postId = await ref.read(videoUploadRunnerProvider)(
          job.request,
          checkpoint: _checkpoints[id]!,
          cancelToken: token,
          onProgress: onProgress,
        );
      }
      _update(
        id,
        (j) => j.copyWith(
          status: VideoUploadStatus.done,
          progress: 1,
          postId: job.request.isStory ? null : postId,
        ),
      );
      _checkpoints.remove(id);
      if (job.request.isStory) {
        // Pós-sucesso é best-effort: o story JÁ está publicado.
        try {
          ref.invalidate(storiesViewModelProvider);
        } catch (_) {}
      } else {
        ref.invalidate(forYouFeedViewModelProvider);
        ref.invalidate(feedViewModelProvider);
      }
    } catch (e) {
      if (token.isCancelled || _job(id) == null) {
        // cancelado pelo usuário: já removido da lista
      } else {
        final err = e is VideoCoverUploadFailure
            ? VideoUploadError.cover
            : VideoUploadError.network;
        _update(
          id,
          (j) => j.copyWith(status: VideoUploadStatus.failed, error: err),
        );
        // Interrompido com o app em segundo plano: tenta de novo sozinho
        // quando voltar (ver didChangeAppLifecycleState).
      }
    } finally {
      _tokens.remove(id);
      _running = false;
      _pump();
    }
  }

  /// Tentar de novo: reaproveita vídeo/capa já enviados (sem duplicar post).
  void retry(int id) {
    final j = _job(id);
    if (j == null || j.status != VideoUploadStatus.failed) return;
    _update(
      id,
      (x) => x.copyWith(
        status: VideoUploadStatus.queued,
        error: VideoUploadError.none,
      ),
    );
    _pump();
  }

  /// Cancela (em andamento ou na fila) e remove o job.
  void cancel(int id) {
    _tokens[id]?.cancel('user');
    _checkpoints.remove(id);
    state = [for (final j in state) if (j.id != id) j];
  }

  /// Fecha o aviso de um job concluído/falho.
  void dismiss(int id) => cancel(id);

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.hidden) {
      _wentBackground = true;
    } else if (lifecycle == AppLifecycleState.resumed) {
      // iOS/Android suspendem a rede em segundo plano: se o envio caiu
      // enquanto o app estava fora, recomeça sozinho (sem refazer etapas
      // concluídas) até [maxAutoRetries] vezes.
      if (_wentBackground) {
        for (final j in state) {
          if (j.status == VideoUploadStatus.failed &&
              j.error != VideoUploadError.none &&
              j.attempts <= maxAutoRetries) {
            retry(j.id);
          }
        }
      }
      _wentBackground = false;
    }
  }

  /// Marca que o app foi pro fundo (usado em testes).
  @visibleForTesting
  void debugMarkBackground() => _wentBackground = true;
}

final videoUploadManagerProvider =
    NotifierProvider<VideoUploadManager, List<VideoUploadJob>>(
      VideoUploadManager.new,
    );
