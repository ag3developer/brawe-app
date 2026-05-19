import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import 'dart:async';

import '../../../../data/repositories/post_repository.dart';
import '../../../../domain/models/feed_item.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/force_dark_theme.dart';
import '../../../feed/widgets/story_composer_screen.dart';
import '../../view_models/feed_video_mute_provider.dart';
import 'shared/_caption_block.dart';
import 'shared/_feed_actions_rail.dart';

/// 🎥 View para VideoFeedItem — player real estilo Reels/TikTok/Shorts.
///
/// Comportamento:
/// - Auto-play quando a página fica ativa (PageView atual)
/// - Pausa automática quando sai da tela
/// - Loop infinito
/// - Tap no vídeo: play/pause (sem mexer no volume)
/// - Botão de volume flutuante: alterna mute/unmute globalmente
///   (igual TikTok — o "mudo" persiste entre vídeos)
/// - Barra de progresso fina na base
class VideoView extends ConsumerStatefulWidget {
  const VideoView({super.key, required this.item, this.isActive = true});

  final VideoFeedItem item;
  final bool isActive;

  @override
  ConsumerState<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends ConsumerState<VideoView> {
  VideoPlayerController? _ctrl;
  bool _initialized = false;
  bool _failed = false;
  bool _userPaused = false;
  bool _showPlayHint = false;

  // View tracking — conta 1 view após 3s de reprodução ativa, no máximo 1x.
  Timer? _viewTimer;
  bool _viewSent = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant VideoView old) {
    super.didUpdateWidget(old);
    if (old.item.videoUrl != widget.item.videoUrl) {
      _disposeController();
      _initController();
    } else if (old.isActive != widget.isActive) {
      _applyActiveState();
    }
  }

  Future<void> _initController() async {
    final url = widget.item.videoUrl;
    if (url.isEmpty) {
      setState(() => _failed = true);
      return;
    }
    final ctrl = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _ctrl = ctrl;
    try {
      await ctrl.initialize();
      await ctrl.setLooping(true);
      final muted = ref.read(feedVideoMuteProvider);
      await ctrl.setVolume(muted ? 0.0 : 1.0);
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() => _initialized = true);
      _applyActiveState();
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  void _applyActiveState() {
    final c = _ctrl;
    if (c == null || !_initialized) return;
    if (widget.isActive && !_userPaused) {
      c.play();
      _scheduleViewTracking();
    } else {
      c.pause();
      _viewTimer?.cancel();
      if (!widget.isActive) {
        c.seekTo(Duration.zero);
        _userPaused = false;
      }
    }
  }

  void _scheduleViewTracking() {
    if (_viewSent) return;
    _viewTimer?.cancel();
    _viewTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _viewSent) return;
      final c = _ctrl;
      if (c == null || !c.value.isPlaying) return;
      _viewSent = true;
      ref.read(postRepositoryProvider).incrementView(widget.item.id);
    });
  }

  void _disposeController() {
    _viewTimer?.cancel();
    _ctrl?.dispose();
    _ctrl = null;
    _initialized = false;
    _failed = false;
    _userPaused = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _togglePlayPause() {
    final c = _ctrl;
    if (c == null || !_initialized) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
        _viewTimer?.cancel();
        _userPaused = true;
        _showPlayHint = true;
      } else {
        c.play();
        _userPaused = false;
        _showPlayHint = false;
        _scheduleViewTracking();
      }
    });
  }

  void _toggleMute() {
    ref.read(feedVideoMuteProvider.notifier).toggle();
    final muted = ref.read(feedVideoMuteProvider);
    _ctrl?.setVolume(muted ? 0.0 : 1.0);
  }

  void _repostAsStory() {
    final url = widget.item.videoUrl;
    if (url.isEmpty) return;
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ForceDarkTheme(
          child: StoryComposerScreen(
            initialRemoteUrl: url,
            initialOriginPostId: widget.item.id,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reage a mudanças globais de mute (ex: outro vídeo desmutou)
    ref.listen<bool>(feedVideoMuteProvider, (_, muted) {
      _ctrl?.setVolume(muted ? 0.0 : 1.0);
    });
    final muted = ref.watch(feedVideoMuteProvider);
    final isPlaying = _ctrl?.value.isPlaying ?? false;

    return GestureDetector(
      onTap: _togglePlayPause,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camada 1: thumbnail (fallback até inicializar) ─────
          Image.network(
            widget.item.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.slate),
          ),

          // ── Camada 2: player com fit inteligente ───────────────
          // • Vídeo vertical (≥ 9:16) → cover (TikTok-like)
          // • Vídeo quadrado/horizontal → contain + blur lateral
          //   (estilo Instagram Reels — sem super-zoom, sem corte)
          if (_initialized && _ctrl != null) ...[
            // Blur de fundo só pra vídeos não-verticais
            if (_ctrl!.value.aspectRatio > 9 / 16)
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _ctrl!.value.size.width,
                      height: _ctrl!.value.size.height,
                      child: VideoPlayer(_ctrl!),
                    ),
                  ),
                ),
              ),
            SizedBox.expand(
              child: FittedBox(
                fit: _ctrl!.value.aspectRatio <= 9 / 16
                    ? BoxFit.cover
                    : BoxFit.contain,
                child: SizedBox(
                  width: _ctrl!.value.size.width,
                  height: _ctrl!.value.size.height,
                  child: VideoPlayer(_ctrl!),
                ),
              ),
            ),
          ],

          // ── Camada 3: gradiente p/ legibilidade da UI ──────────
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),

          // ── Camada 4: ícone central de play (só quando pausado pelo usuário) ─
          if (_initialized && !isPlaying && _showPlayHint)
            IgnorePointer(
              child: Center(
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 48),
                ),
              ),
            ),

          // ── Camada 5: spinner enquanto carrega ─────────────────
          if (!_initialized && !_failed)
            const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),

          // ── Camada 6: erro ─────────────────────────────────────
          if (_failed)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.white54, size: 40),
                    SizedBox(height: 8),
                    Text('Não foi possível carregar o vídeo.',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),

          // ── Botão de mute (canto inferior-esquerdo, acima da legenda) ─
          // Fora da coluna de ações (curtir/comentar/share) e longe da
          // top bar (Seguindo/Para Você + lupa), pra não dar conflito de tap.
          Positioned(
            left: 16,
            bottom: 170,
            child: _MuteButton(muted: muted, onTap: _toggleMute),
          ),

          // ── Repostar no Stories (mesmo ícone do atalho de criar Story
          // no bottom nav — LucideIcons.aperture — p/ reforçar memória).
          Positioned(
            left: 16,
            bottom: 220,
            child: _RepostStoryButton(onTap: _repostAsStory),
          ),

          // ── Rail de ações (curtir/comentar/share) ──────────────
          Positioned(
            right: 8,
            bottom: 140,
            child: FeedActionsRail(item: widget.item),
          ),

          // ── Legenda + autor ────────────────────────────────────
          Positioned(
            left: 16,
            right: 90,
            bottom: 100,
            child: CaptionBlock(
                author: widget.item.author, caption: widget.item.caption),
          ),

          // ── Barra de progresso fina na base ────────────────────
          if (_initialized && _ctrl != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 78, // acima da bottom nav
              child: IgnorePointer(
                child: VideoProgressIndicator(
                  _ctrl!,
                  allowScrubbing: false,
                  padding: EdgeInsets.zero,
                  colors: VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white.withValues(alpha: 0.25),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Botão circular de mute/unmute (glassmorphism).
class _MuteButton extends StatelessWidget {
  const _MuteButton({required this.muted, required this.onTap});
  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.5),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Botão circular para repostar o vídeo como Story (mesmo estilo do mute).
/// Usa o ícone `LucideIcons.aperture` — idêntico ao atalho de criar Story
/// no bottom nav — para o usuário associar visualmente.
class _RepostStoryButton extends StatelessWidget {
  const _RepostStoryButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: 'Repostar no Stories',
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.5),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              LucideIcons.aperture,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
