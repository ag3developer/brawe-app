import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../data/repositories/post_repository.dart';
import '../../../data/services/feedback_service.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/post.dart';
import '../../../domain/models/sound_preview.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../shared/widgets/content_sound_attribution.dart';
import '../../sounds/view_models/sound_player_view_model.dart';
import '../../sounds/widgets/sound_player_bottom_sheet.dart';
import '../view_models/feed_view_model.dart';
import 'comments_sheet.dart';
import 'reactions_bar.dart';
import 'share_to_chat_sheet.dart';

/// Player de vídeo em **tela cheia** com action rail vertical (TikTok style).
///
/// Carrega o post via [postRepositoryProvider] caso ainda não esteja em cache.
/// Reproduz com som ON, autoplay, loop e progress bar interativa.
class VideoFullscreenScreen extends ConsumerStatefulWidget {
  const VideoFullscreenScreen({
    super.key,
    required this.postId,
    this.initialUrl,
  });

  final String postId;

  /// URL do vídeo já conhecida (evita roundtrip). Se `null`, busca via API.
  final String? initialUrl;

  @override
  ConsumerState<VideoFullscreenScreen> createState() =>
      _VideoFullscreenScreenState();
}

class _VideoFullscreenScreenState extends ConsumerState<VideoFullscreenScreen>
    with WidgetsBindingObserver {
  VideoPlayerController? _ctrl;
  Post? _post;
  bool _loading = true;
  bool _error = false;
  bool _muted = false;
  bool _controlsVisible = true;

  /// `true` quando o vídeo/música foram pausados automaticamente pelo
  /// lifecycle do app (background) — distingue de uma pausa manual do
  /// usuário via toque, que nunca deve ser retomada sozinha ao voltar.
  bool _pausedByLifecycle = false;

  /// Última posição observada do vídeo — usada para detectar quando o
  /// loop (`setLooping(true)`) reinicia o vídeo do zero, para então
  /// reiniciar a música do Brawe Sounds em sincronia (senão a música
  /// toca uma vez só enquanto o vídeo continua repetindo).
  Duration _lastVideoPosition = Duration.zero;

  /// Timer throttled de correção de drift entre vídeo (master clock) e
  /// música anexada — nunca faz seek por frame.
  Timer? _syncTimer;
  static const _driftCheckInterval = Duration(milliseconds: 600);
  static const _driftThreshold = Duration(milliseconds: 300);

  /// Sessão do bootstrap atual — permite abortar callbacks assíncronos
  /// (ex.: aguardando o player de música ficar pronto) se a tela for
  /// fechada antes deles terminarem.
  int _session = 0;

  String get _owner => 'fullscreen:${widget.postId}';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  /// Fase A: pausa vídeo + música quando o app sai de foreground e
  /// retoma ao voltar (nunca sobre uma pausa manual do usuário).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        final c = _ctrl;
        if (c != null && c.value.isPlaying) {
          _pausedByLifecycle = true;
          c.pause();
          if (_post?.sound != null) {
            ref.read(soundPlayerViewModelProvider.notifier).pause();
          }
        }
        break;
      case AppLifecycleState.resumed:
        if (_pausedByLifecycle) {
          _pausedByLifecycle = false;
          _ctrl?.play();
          final sound = _post?.sound;
          if (sound != null) {
            ref
                .read(soundPlayerViewModelProvider.notifier)
                .play(
                  sound.toPlayableSound(volume: _post!.soundVolume),
                  owner: _owner,
                );
          }
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _bootstrap() async {
    final session = ++_session;
    try {
      final repo = ref.read(postRepositoryProvider);
      final post = await repo.getById(widget.postId);
      if (!mounted || session != _session) return;
      _post = post;
      final url = widget.initialUrl ?? post.imageUrl;
      if (url == null || url.isEmpty) {
        setState(() {
          _loading = false;
          _error = true;
        });
        return;
      }
      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      await c.initialize();
      if (!mounted || session != _session) {
        await c.dispose();
        return;
      }
      final attachedSound = post.sound;
      // Brawe Sound: NÃO há mixagem server-side (sem ffmpeg) — a música
      // NUNCA está "dentro" do arquivo de vídeo. Quando há faixa anexada,
      // o áudio ORIGINAL do vídeo toca no volume definido pelo autor
      // (`originalAudioVolume`, geralmente abaixado/mutado) e a música
      // toca separadamente pelo player único (`SoundPlayerViewModel`).
      final baseVolume = attachedSound != null
          ? post.originalAudioVolume.clamp(0.0, 1.0)
          : 1.0;
      c.setLooping(true);
      await c.setVolume(_muted ? 0 : baseVolume);

      // Fase C: vídeo é o master clock. Inicia vídeo + progress bar
      // primeiro, depois anexa a música (owner dedicado desta tela) e só
      // então libera o loading — evita a janela de "vídeo tocando sem
      // música" enquanto a faixa ainda carrega da rede.
      await c.play();
      if (!mounted || session != _session) {
        await c.dispose();
        return;
      }
      if (attachedSound != null) {
        await ref
            .read(soundPlayerViewModelProvider.notifier)
            .play(
              attachedSound.toPlayableSound(volume: post.soundVolume),
              owner: _owner,
            );
        if (!mounted || session != _session) {
          await c.dispose();
          return;
        }
        _startDriftCorrection(session: session);
      }
      // Marca view.
      repo.incrementView(widget.postId);
      // Listener para rebuild da progress bar + detectar loop.
      c.addListener(_onTick);
      setState(() {
        _ctrl = c;
        _loading = false;
      });
    } on Failure catch (_) {
      if (mounted && session == _session) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    } catch (_) {
      if (mounted && session == _session) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  void _onTick() {
    final c = _ctrl;
    if (c == null) return;
    // Detecta o wraparound do loop (`setLooping(true)`): a posição atual
    // fica MENOR que a anterior quando o vídeo reinicia do zero. Nesse
    // momento, reinicia a música anexada em sincronia — senão a faixa
    // (que não tem loop nativo no ClippingAudioSource) tocaria só na
    // primeira passada e ficaria em silêncio nas repetições seguintes.
    final pos = c.value.position;
    if (_post?.sound != null && pos < _lastVideoPosition) {
      ref.read(soundPlayerViewModelProvider.notifier).seek(0.0);
    }
    _lastVideoPosition = pos;
    if (mounted) setState(() {});
  }

  /// Correção de drift throttled entre vídeo (master) e música anexada.
  /// Nunca faz seek por frame — só a cada [_driftCheckInterval] e só se
  /// o desvio exceder [_driftThreshold].
  void _startDriftCorrection({required int session}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_driftCheckInterval, (_) {
      if (!mounted || session != _session) {
        _syncTimer?.cancel();
        return;
      }
      final c = _ctrl;
      if (c == null || !c.value.isPlaying) return;
      final notifier = ref.read(soundPlayerViewModelProvider.notifier);
      if (!notifier.isOwner(_owner)) return;
      final playerState = ref.read(soundPlayerViewModelProvider);
      if (playerState.sound == null || !playerState.isPlaying) return;
      final musicDurationMs = playerState.duration.inMilliseconds;
      if (musicDurationMs <= 0) return;

      final drift = c.value.position - playerState.position;
      if (drift.abs() > _driftThreshold) {
        final progress = (c.value.position.inMilliseconds / musicDurationMs)
            .clamp(0.0, 1.0);
        notifier.seek(progress);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _session++; // aborta bootstrap/drift-correction pendentes
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _syncTimer?.cancel();
    _ctrl?.removeListener(_onTick);
    _ctrl?.dispose();
    // Brawe Sound: para a música ao sair da tela — não deve continuar
    // tocando em background depois que o usuário fecha o fullscreen.
    // `stop()` é assíncrono; aguardamos com timeout de segurança via
    // fire-and-forget (dispose precisa continuar síncrono).
    if (_post?.sound != null) {
      unawaited(
        ref
            .read(soundPlayerViewModelProvider.notifier)
            .stop()
            .timeout(const Duration(seconds: 2))
            .catchError((_) {}),
      );
    }
    super.dispose();
  }

  void _togglePlay() {
    final c = _ctrl;
    if (c == null) return;
    HapticFeedback.selectionClick();
    final sound = _post?.sound;
    if (c.value.isPlaying) {
      c.pause();
      _syncTimer?.cancel();
      if (sound != null) {
        ref.read(soundPlayerViewModelProvider.notifier).pause();
      }
    } else {
      c.play();
      if (sound != null) {
        // `play()` do notifier faz toggle play/pause quando já é a mesma
        // faixa carregada — reaproveita a mesma chamada usada no bootstrap.
        ref
            .read(soundPlayerViewModelProvider.notifier)
            .play(
              sound.toPlayableSound(volume: _post!.soundVolume),
              owner: _owner,
            );
        _startDriftCorrection(session: _session);
      }
    }
    setState(() {});
  }

  void _toggleMute() {
    final c = _ctrl;
    if (c == null) return;
    HapticFeedback.selectionClick();
    setState(() => _muted = !_muted);
    final post = _post;
    final sound = post?.sound;
    final baseVolume = sound != null
        ? post!.originalAudioVolume.clamp(0.0, 1.0)
        : 1.0;
    c.setVolume(_muted ? 0 : baseVolume);
    // Brawe Sound: o mute do vídeo também silencia a música anexada —
    // mesma semântica de um único controle de áudio usada em Stories.
    if (sound != null) {
      ref
          .read(soundPlayerViewModelProvider.notifier)
          .setVolume(_muted ? 0 : post!.soundVolume.clamp(0.0, 1.0));
    }
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
  }

  /// Abre a página/bottom sheet da faixa (reutiliza `SoundPlayerBottomSheet`
  /// já existente — não cria uma segunda tela duplicada). O player de
  /// música (`SoundPlayerViewModel`) é o MESMO usado para tocar a faixa
  /// durante o vídeo — pausamos apenas o vídeo (áudio original) enquanto
  /// o bottom sheet está aberto, para evitar competir visualmente/
  /// sonoramente, sem nunca abrir uma segunda fonte de áudio.
  Future<void> _openSoundDetails(SoundPreview sound) async {
    final wasPlaying = _ctrl?.value.isPlaying ?? false;
    _ctrl?.pause();
    // Suspende a correção de drift enquanto o bottom sheet está aberto —
    // ele reutiliza o MESMO player global (mesma faixa), então não há
    // segunda fonte de áudio, mas o vídeo (master clock) está pausado e
    // não deve haver correção de drift comparando contra um vídeo parado.
    _syncTimer?.cancel();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SoundPlayerBottomSheet(
        sound: sound.toPlayableSound(volume: _post?.soundVolume ?? 1.0),
      ),
    );
    if (!mounted) return;
    if (wasPlaying) {
      _ctrl?.play();
      if (_post?.sound != null) {
        _startDriftCorrection(session: _session);
      }
    }
  }

  Future<void> _onLike() async {
    final post = _post;
    if (post == null) return;
    ref.read(feedbackServiceProvider).like();
    await ref.read(feedViewModelProvider.notifier).toggleLike(post.id);
    setState(() {
      _post = post.copyWith(
        userLiked: !post.userLiked,
        likesCount: post.userLiked ? post.likesCount - 1 : post.likesCount + 1,
      );
    });
  }

  Future<void> _onReact(BraweReaction reaction) async {
    final post = _post;
    if (post == null) return;
    ref.read(feedbackServiceProvider).reaction();
    try {
      await ref
          .read(feedViewModelProvider.notifier)
          .reactToPost(post.id, reaction.key);
      if (!post.userLiked) {
        setState(
          () => _post = post.copyWith(
            userLiked: true,
            likesCount: post.likesCount + 1,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).feedCannotLike)));
    }
  }

  void _onComment() {
    final post = _post;
    if (post == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(postId: post.id),
    );
  }

  Future<void> _onShare() async {
    final post = _post;
    if (post == null) return;
    ref.read(feedbackServiceProvider).share();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ShareToChatSheet(postId: post.id, postCaption: post.content),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          onVerticalDragEnd: (d) {
            // Swipe-down para fechar
            if ((d.primaryVelocity ?? 0) > 600) {
              Navigator.of(context).maybePop();
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Vídeo
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFFA855F7)),
                )
              else if (_error || _ctrl == null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.feedCannotShare, // genérico — pode-se trocar por chave dedicada
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              else
                Center(
                  child: AspectRatio(
                    aspectRatio: _ctrl!.value.aspectRatio,
                    child: VideoPlayer(_ctrl!),
                  ),
                ),

              // Overlay de play/pause
              if (_ctrl != null && !_ctrl!.value.isPlaying)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                  ),
                ),

              // Top bar (back + mute)
              if (_controlsVisible)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 4,
                  right: 4,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _muted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: Colors.white,
                        ),
                        onPressed: _toggleMute,
                      ),
                    ],
                  ),
                ),

              // Action rail
              if (_post != null && _controlsVisible)
                Positioned(
                  right: 8,
                  bottom: 110,
                  child: _VideoActionRail(
                    post: _post!,
                    onLike: _onLike,
                    onLikeLongPress: () async {
                      final size = MediaQuery.of(context).size;
                      final picked = await showReactionsBar(
                        context,
                        globalPosition: Offset(
                          size.width - 48,
                          size.height * 0.5,
                        ),
                      );
                      if (picked != null) _onReact(picked);
                    },
                    onLikeCountTap: () =>
                        context.push('/post/${_post!.id}/likes'),
                    onComment: _onComment,
                    onShare: _onShare,
                  ),
                ),

              // Bottom: caption + progress bar
              if (_post != null && _controlsVisible)
                Positioned(
                  left: 0,
                  right: 70,
                  bottom: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brawe Sound: atribuição musical compacta. O
                          // áudio JÁ ESTÁ mixado no arquivo de vídeo (não
                          // existe player de música separado aqui) — o
                          // componente só exibe metadados e sincroniza o
                          // estado visual "tocando" com o player de vídeo,
                          // sem nunca iniciar uma segunda reprodução.
                          if (_post!.sound != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: ContentSoundAttribution(
                                trackId: _post!.sound!.id,
                                title: _post!.sound!.title,
                                artistName: _post!.sound!.artistName,
                                coverUrl: _post!.sound!.coverUrl,
                                isPlaying:
                                    (_ctrl?.value.isPlaying ?? false) &&
                                    !_muted,
                                contentType: ContentSoundSurface.reel,
                                onTap: () => _openSoundDetails(_post!.sound!),
                              ),
                            ),
                          if (_post!.content.isNotEmpty)
                            Text(
                              _post!.content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.4,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 6),
                                ],
                              ),
                            ),
                          if (_ctrl != null) ...[
                            const SizedBox(height: 10),
                            _ProgressBar(controller: _ctrl!),
                          ],
                        ],
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

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final position = value.position.inMilliseconds.toDouble();
    final duration = value.duration.inMilliseconds.toDouble().clamp(1, 1e12);
    final progress = (position / duration).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: const Color(0xFFA855F7),
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: progress,
            onChanged: (v) {
              final ms = (v * duration).toInt();
              controller.seekTo(Duration(milliseconds: ms));
            },
          ),
        ),
        Text(
          '${_fmt(value.position)} / ${_fmt(value.duration)}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _VideoActionRail extends StatelessWidget {
  const _VideoActionRail({
    required this.post,
    required this.onLike,
    required this.onLikeLongPress,
    required this.onLikeCountTap,
    required this.onComment,
    required this.onShare,
  });

  final Post post;
  final VoidCallback onLike;
  final VoidCallback onLikeLongPress;
  final VoidCallback onLikeCountTap;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RailItem(
          icon: post.userLiked
              ? Icons.favorite_rounded
              : Icons.favorite_outline_rounded,
          label: _fmt(post.likesCount),
          color: post.userLiked ? const Color(0xFFFF3B5C) : Colors.white,
          onTap: onLike,
          onLongPress: onLikeLongPress,
          onLabelTap: onLikeCountTap,
        ),
        const SizedBox(height: 18),
        _RailItem(
          icon: Icons.mode_comment_outlined,
          label: _fmt(post.commentsCount),
          color: Colors.white,
          onTap: onComment,
        ),
        const SizedBox(height: 18),
        _RailItem(
          icon: Icons.send_rounded,
          label: _fmt(post.repostsCount),
          color: Colors.white,
          onTap: onShare,
        ),
      ],
    );
  }

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.onLongPress,
    this.onLabelTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onLabelTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          behavior: HitTestBehavior.opaque,
          child: Icon(
            icon,
            color: color,
            size: 34,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onLabelTap ?? onTap,
          behavior: HitTestBehavior.opaque,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ),
      ],
    );
  }
}
