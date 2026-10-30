import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'dart:async';

import '../../../../data/repositories/post_repository.dart';
import '../../../../domain/models/feed_item.dart';
import '../../../../domain/models/sound_preview.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/app_colors.dart';
import '../../../shared/widgets/content_sound_attribution.dart';
import '../../../sounds/view_models/sound_player_view_model.dart';
import '../../../sounds/widgets/sound_player_bottom_sheet.dart';
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

  /// Última posição observada do vídeo — detecta o wraparound do loop
  /// para reiniciar a música anexada em sincronia (ver mesmo padrão em
  /// `video_fullscreen_screen.dart`).
  Duration _lastVideoPosition = Duration.zero;

  bool get _hasSound => widget.item.sound != null;

  String get _owner => 'feed:${widget.item.id}';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant VideoView old) {
    super.didUpdateWidget(old);
    if (old.item.playbackUrl != widget.item.playbackUrl) {
      _disposeController();
      _initController();
    } else if (old.isActive != widget.isActive) {
      _applyActiveState();
    }
  }

  Future<void> _initController() async {
    // HLS leve (Bunny) quando já convertido; senão o arquivo original.
    final url = widget.item.playbackUrl;
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
      // Brawe Sound: sem mixagem server-side — quando há faixa anexada, o
      // áudio ORIGINAL do vídeo toca no volume definido pelo autor
      // (geralmente abaixado/mutado) para não competir com a música.
      final baseVolume = _hasSound
          ? widget.item.originalAudioVolume.clamp(0.0, 1.0)
          : 1.0;
      await ctrl.setVolume(muted ? 0.0 : baseVolume);
      ctrl.addListener(_onVideoTick);
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

  /// Detecta o wraparound do loop do vídeo para reiniciar a música
  /// anexada em sincronia (o `ClippingAudioSource` não tem loop nativo).
  void _onVideoTick() {
    if (!_hasSound) return;
    final c = _ctrl;
    if (c == null) return;
    final pos = c.value.position;
    if (pos < _lastVideoPosition) {
      ref.read(soundPlayerViewModelProvider.notifier).seek(0.0);
    }
    _lastVideoPosition = pos;
  }

  void _applyActiveState() {
    final c = _ctrl;
    if (c == null || !_initialized) return;
    if (widget.isActive && !_userPaused) {
      c.play();
      _playAttachedSound();
      _scheduleViewTracking();
    } else {
      c.pause();
      _viewTimer?.cancel();
      if (!widget.isActive) {
        c.seekTo(Duration.zero);
        _userPaused = false;
        if (_hasSound) {
          ref.read(soundPlayerViewModelProvider.notifier).stop();
        }
      } else if (_hasSound) {
        ref.read(soundPlayerViewModelProvider.notifier).pause();
      }
    }
  }

  /// Toca a música do Brawe Sounds anexada a este vídeo (se houver) —
  /// respeitando o mute global do feed e o volume específico do post.
  void _playAttachedSound() {
    final sound = widget.item.sound;
    if (sound == null) return;
    final muted = ref.read(feedVideoMuteProvider);
    ref
        .read(soundPlayerViewModelProvider.notifier)
        .play(
          sound.toPlayableSound(volume: widget.item.soundVolume),
          owner: _owner,
        );
    if (muted) {
      ref.read(soundPlayerViewModelProvider.notifier).setVolume(0);
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
    _ctrl?.removeListener(_onVideoTick);
    _ctrl?.dispose();
    _ctrl = null;
    _initialized = false;
    _failed = false;
    _userPaused = false;
    if (_hasSound) {
      // `stop()` é assíncrono — dispara fire-and-forget com timeout de
      // segurança para nunca deixar áudio órfão tocando após o card sair
      // da tela (o PageView descarta este State ao trocar de página).
      unawaited(
        ref
            .read(soundPlayerViewModelProvider.notifier)
            .stop()
            .timeout(const Duration(seconds: 2))
            .catchError((_) {}),
      );
    }
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
        if (_hasSound) {
          ref.read(soundPlayerViewModelProvider.notifier).pause();
        }
      } else {
        c.play();
        _userPaused = false;
        _showPlayHint = false;
        _scheduleViewTracking();
        if (_hasSound) {
          _playAttachedSound();
        }
      }
    });
  }

  void _toggleMute() {
    ref.read(feedVideoMuteProvider.notifier).toggle();
    final muted = ref.read(feedVideoMuteProvider);
    final baseVolume = _hasSound
        ? widget.item.originalAudioVolume.clamp(0.0, 1.0)
        : 1.0;
    _ctrl?.setVolume(muted ? 0.0 : baseVolume);
    if (_hasSound) {
      ref
          .read(soundPlayerViewModelProvider.notifier)
          .setVolume(muted ? 0.0 : widget.item.soundVolume.clamp(0.0, 1.0));
    }
  }

  /// Abre o preview da faixa no bottom sheet, pausando o vídeo (áudio
  /// original) enquanto o player único continua tocando a faixa — evita
  /// duas fontes de áudio simultâneas (mesmo padrão do fullscreen).
  Future<void> _openSoundDetails(SoundPreview sound) async {
    final wasPlaying = _ctrl?.value.isPlaying ?? false;
    _ctrl?.pause();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SoundPlayerBottomSheet(
        sound: sound.toPlayableSound(volume: widget.item.soundVolume),
      ),
    );
    if (mounted && wasPlaying) _ctrl?.play();
  }

  @override
  Widget build(BuildContext context) {
    // Reage a mudanças globais de mute (ex: outro vídeo desmutou)
    ref.listen<bool>(feedVideoMuteProvider, (_, muted) {
      final baseVolume = _hasSound
          ? widget.item.originalAudioVolume.clamp(0.0, 1.0)
          : 1.0;
      _ctrl?.setVolume(muted ? 0.0 : baseVolume);
      if (_hasSound) {
        ref
            .read(soundPlayerViewModelProvider.notifier)
            .setVolume(muted ? 0.0 : widget.item.soundVolume.clamp(0.0, 1.0));
      }
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
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
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
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white54,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).videoLoadError,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

          // ── Rail de ações (curtir/comentar/share) ──────────────
          Positioned(
            right: 8,
            bottom: 62,
            child: FeedActionsRail(item: widget.item),
          ),

          // ── Legenda + autor (+ atribuição musical, se houver) ──
          Positioned(
            left: 16,
            right: 90,
            // A base do vídeo já é o topo da bottom nav (extendBody:false);
            // antes os offsets somavam a altura da nav de novo e sobrava
            // uma faixa morta de ~78pt sob a legenda.
            bottom: 22,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botão de som: na MESMA coluna da legenda,
                // logo acima dela. Antes ficavam em posições fixas
                // (bottom 170/220) e a legenda — que cresce para cima
                // conforme o texto — ficava por cima do botão de som.
                // (Repostar no Stories agora fica no botão Compartilhar.)
                _MuteButton(muted: muted, onTap: _toggleMute),
                const SizedBox(height: 12),
                if (widget.item.sound != null) ...[
                  ContentSoundAttribution(
                    trackId: widget.item.sound!.id,
                    title: widget.item.sound!.title,
                    artistName: widget.item.sound!.artistName,
                    coverUrl: widget.item.sound!.coverUrl,
                    isPlaying: isPlaying && !muted,
                    contentType: ContentSoundSurface.video,
                    onTap: () => _openSoundDetails(widget.item.sound!),
                  ),
                  const SizedBox(height: 6),
                ],
                CaptionBlock(
                  author: widget.item.author,
                  caption: widget.item.caption,
                ),
              ],
            ),
          ),

          // ── Barra de progresso fina na base ────────────────────
          if (_initialized && _ctrl != null)
            Positioned(
              left: 0,
              right: 0,
              // Colada na base do vídeo (logo acima da bottom nav), como
              // no TikTok/Reels. Arrastável para avançar/voltar; o padding
              // superior aumenta a área de toque sem engrossar a barra.
              bottom: 0,
              child: SizedBox(
                child: VideoProgressIndicator(
                  _ctrl!,
                  allowScrubbing: true,
                  padding: const EdgeInsets.only(top: 14),
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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

