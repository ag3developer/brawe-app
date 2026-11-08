// Brawe Ads — anúncio em tela cheia no "Para você" / "Seguindo" (padrão Reels/TikTok).
//
// - O anúncio é um item normal do feed vertical: pula a qualquer momento deslizando (sem contador forçado).
// - Embaixo: anunciante + "Patrocinado · 0:12" (tempo que falta no vídeo), texto e botão de ação.
//   O botão começa translúcido e fica azul cheio depois de 2 s (destaque sem pular na cara).
// - Impressão: 1 s com a página ativa (vídeo tocando). Vídeo: 25/50/100% e tempo assistido.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../../core/network/media_headers.dart';
import '../../../data/repositories/ads_repository.dart';
import '../../../domain/models/ad_models.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/verified_badge.dart';
import '../../home/view_models/feed_video_mute_provider.dart';
import 'ad_actions.dart';

class SponsoredVideoView extends ConsumerStatefulWidget {
  const SponsoredVideoView({
    super.key,
    required this.ad,
    required this.isActive,
    this.onHidden,
  });

  final FeedAd ad;
  final bool isActive;
  final VoidCallback? onHidden;

  @override
  ConsumerState<SponsoredVideoView> createState() => _SponsoredVideoViewState();
}

class _SponsoredVideoViewState extends ConsumerState<SponsoredVideoView> {
  VideoPlayerController? _ctrl;
  bool _ready = false;
  bool _userPaused = false;
  bool _ctaStrong = false;
  bool _impressionSent = false;
  bool _expanded = false;
  final Set<String> _quartiles = {};
  Timer? _impressionTimer;
  Timer? _ctaTimer;

  FeedAd get ad => widget.ad;

  @override
  void initState() {
    super.initState();
    if (ad.isVideo && (ad.playbackUrl ?? '').isNotEmpty) _initVideo();
    _applyActive();
  }

  @override
  void didUpdateWidget(covariant SponsoredVideoView old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive) _applyActive();
  }

  Future<void> _initVideo() async {
    final url = ad.playbackUrl!;
    final c = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: mediaHeadersFor(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _ctrl = c;
    try {
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(ref.read(feedVideoMuteProvider) ? 0 : 1);
      c.addListener(_onTick);
      if (!mounted) return;
      setState(() => _ready = true);
      _applyActive();
    } catch (_) {
      /* mostra a capa */
    }
  }

  void _onTick() {
    final c = _ctrl;
    if (c == null || !c.value.isInitialized) return;
    final d = c.value.duration.inMilliseconds;
    if (d <= 0) return;
    final p = c.value.position.inMilliseconds / d;
    for (final (mark, ev) in [
      (0.25, 'view_25'),
      (0.5, 'view_50'),
      (0.97, 'view_100'),
    ]) {
      if (p >= mark && !_quartiles.contains(ev)) {
        _quartiles.add(ev);
        ref
            .read(adsRepositoryProvider)
            .track(ad.token, ev, valueMs: c.value.position.inMilliseconds);
      }
    }
    if (mounted) setState(() {});
  }

  void _applyActive() {
    _impressionTimer?.cancel();
    _ctaTimer?.cancel();
    if (widget.isActive) {
      if (!_userPaused) _ctrl?.play();
      if (!_impressionSent) {
        _impressionTimer = Timer(const Duration(seconds: 1), () {
          _impressionSent = true;
          ref.read(adsRepositoryProvider).track(ad.token, 'impression');
        });
      }
      _ctaTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _ctaStrong = true);
      });
    } else {
      _ctrl?.pause();
      _ctrl?.seekTo(Duration.zero);
      _userPaused = false;
      if (mounted) setState(() => _ctaStrong = false);
    }
  }

  @override
  void dispose() {
    _impressionTimer?.cancel();
    _ctaTimer?.cancel();
    _ctrl?.removeListener(_onTick);
    _ctrl?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _ctrl;
    if (c == null || !_ready) return;
    setState(() {
      _userPaused = c.value.isPlaying;
      _userPaused ? c.pause() : c.play();
    });
  }

  Duration? get _remaining {
    final c = _ctrl;
    if (c == null || !_ready) return null;
    final r = c.value.duration - c.value.position;
    return r.isNegative ? Duration.zero : r;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(
      feedVideoMuteProvider,
      (_, m) => _ctrl?.setVolume(m ? 0 : 1),
    );
    final muted = ref.watch(feedVideoMuteProvider);
    final adv = ad.advertiser;
    final bottomPad = MediaQuery.paddingOf(context).bottom > 0 ? 8.0 : 16.0;
    final text = [
      ad.headline,
      ad.text,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join('\n');

    return GestureDetector(
      onTap: _togglePlay,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Media(ad: ad, ctrl: _ready ? _ctrl : null),
          // leitura do texto
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xB3000000)],
                  stops: [0.5, 1],
                ),
              ),
            ),
          ),
          if (_ready && _userPaused)
            const IgnorePointer(
              child: Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white70,
                  size: 72,
                ),
              ),
            ),

          // trilho da direita: anunciante, som e menu
          Positioned(
            right: 10,
            bottom: 140 + bottomPad,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (adv != null)
                  GestureDetector(
                    onTap: () => openAdvertiserProfile(context, ref, ad),
                    child: _Avatar(url: adv.avatarUrl, size: 46),
                  ),
                const SizedBox(height: 20),
                if (ad.isVideo)
                  _RailButton(
                    icon: muted ? LucideIcons.volumeX : LucideIcons.volume2,
                    onTap: () =>
                        ref.read(feedVideoMuteProvider.notifier).toggle(),
                  ),
                const SizedBox(height: 14),
                _RailButton(
                  icon: LucideIcons.ellipsis,
                  onTap: () =>
                      showAdMenu(context, ref, ad, onHidden: widget.onHidden),
                ),
              ],
            ),
          ),

          // anunciante, rótulo, texto e botão de ação
          Positioned(
            left: 16,
            right: 76,
            bottom: 18 + bottomPad,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (adv != null)
                  GestureDetector(
                    onTap: () => openAdvertiserProfile(context, ref, ad),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            adv.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (adv.isVerified) const VerifiedBadge(size: 14),
                      ],
                    ),
                  ),
                const SizedBox(height: 2),
                SponsoredLabel(remaining: ad.isVideo ? _remaining : null),
                if (text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      text,
                      maxLines: _expanded ? 8 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPad + 6,
            child: _CtaButton(
              label: adCtaLabel(context, ad),
              strong: _ctaStrong,
              onTap: () => openAdCta(context, ref, ad),
            ),
          ),

          // progresso fino na base (tempo do vídeo)
          if (_ready && _ctrl != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
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
        ],
      ),
    );
  }
}

/// Mídia: vídeo vertical preenche; horizontal/imagem fica inteira com fundo desfocado (sem corte).
class _Media extends StatelessWidget {
  const _Media({required this.ad, required this.ctrl});
  final FeedAd ad;
  final VideoPlayerController? ctrl;

  @override
  Widget build(BuildContext context) {
    final c = ctrl;
    if (c != null) {
      final vertical = c.value.aspectRatio <= 9 / 16 + 0.02;
      final player = SizedBox(
        width: c.value.size.width,
        height: c.value.size.height,
        child: VideoPlayer(c),
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          if (!vertical)
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: FittedBox(fit: BoxFit.cover, child: player),
            ),
          FittedBox(
            fit: vertical ? BoxFit.cover : BoxFit.contain,
            child: player,
          ),
        ],
      );
    }
    final url = ad.isVideo || ad.isLive
        ? (ad.posterUrl ?? ad.mediaUrl)
        : (ad.mediaUrl ?? ad.posterUrl);
    if (url == null || url.isEmpty) {
      return const ColoredBox(color: Colors.black);
    }
    final img = CachedNetworkImage(
      imageUrl: url,
      httpHeaders: mediaHeadersFor(url),
      fit: BoxFit.contain,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: CachedNetworkImage(
            imageUrl: url,
            httpHeaders: mediaHeadersFor(url),
            fit: BoxFit.cover,
          ),
        ),
        ColoredBox(color: Colors.black.withValues(alpha: 0.15)),
        Center(child: img),
        if (ad.isLive) const Positioned(top: 110, left: 16, child: _LiveChip()),
      ],
    );
  }
}

class _LiveChip extends StatelessWidget {
  const _LiveChip();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFE11D48),
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Text(
      'LIVE',
      style: TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    ),
  );
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.label,
    required this.strong,
    required this.onTap,
  });
  final String label;
  final bool strong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOut,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: strong
              ? AppColors.braweBlueBright
              : Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: strong ? 0 : 0.22),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 21),
    ),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size});
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 1.5),
    ),
    child: ClipOval(
      child: (url == null || url!.isEmpty)
          ? const ColoredBox(color: Colors.white24)
          : CachedNetworkImage(
              imageUrl: url!,
              httpHeaders: mediaHeadersFor(url),
              fit: BoxFit.cover,
            ),
    ),
  );
}
